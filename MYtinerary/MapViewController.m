//
//  MapViewController.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/5/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "MapViewController.h"
#import "Record.h"
#import "NSManagedObject+ManagedContext.h"
#import "Constants.h"
#import "CustomPointAnnotation.h"
#import "CustomLoginViewController.h"
@import Photos;
@import MapKit;
@import CoreLocation;
@import Parse;
@import ParseUI;


typedef void(^imageCompletion)(UIImage *image);//, BOOL success);

@interface MapViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSMutableArray *records;
@property (strong, nonatomic) Itinerary *itinerary;
@property (copy, nonatomic) imageCompletion completion;


- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)libraryButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)logoutButtonSelected:(UIBarButtonItem *)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self login];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.mapView.delegate = self;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Itinerary"];
    NSError *error;
    NSArray *results = [[NSManagedObject managedContext] executeFetchRequest: request error:&error];
    if (error) {
        NSLog(@"Error with fetching reserved rooms");
    } else {
        if (results.count > 0) {
            self.itinerary = results.firstObject;
        }
    }
    self.records = [[NSMutableArray alloc]init];
    for (Record* record in self.itinerary.records) {
        [self.records addObject:record];
    }
    NSLog(@"Itinerary records: %@", self.records);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sortRecordsByDate];
    [self addPolylineToMap];
}

-(void)sortRecordsByDate {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    self.records = [[self.records sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender {
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    Record *record = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:[NSManagedObject managedContext]];
    
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    PHAsset *asset = fetchResult.firstObject;
    
    record.latitude = [NSNumber numberWithDouble:asset.location.coordinate.latitude];
    record.longitude = [NSNumber numberWithDouble:asset.location.coordinate.longitude];
    record.localImageURL = [NSString stringWithFormat:@"%@",url];
    record.date = asset.creationDate;
    record.itinerary = self.itinerary;
    
    //    NSLog(@"Longitude: %f, latitude: %f\n ImageURL: %@", record.longitude.doubleValue, record.latitude.doubleValue, record.localImageURL);
    
    [self.records addObject:record];
    [self createAnnotationForRecord:record];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    Itinerary *itinerary = [NSEntityDescription insertNewObjectForEntityForName:@"Itinerary" inManagedObjectContext:[NSManagedObject managedContext]];
    itinerary.records = [[NSOrderedSet alloc]init];
    itinerary.title = @"New Title";
    itinerary.author = @"Author";
    itinerary.records = [[NSOrderedSet alloc]initWithArray:self.records];
    self.itinerary = itinerary;
    
    NSError *saveError;
    BOOL isSaved = [[NSManagedObject managedContext] save:&saveError];
    if(isSaved) {
        NSLog(@"Itinerary with records successfully saved");
    } else {
        NSLog(@"Unsuccessful saving Itinerary with records: %@", saveError.localizedDescription);
    }
    
    [self dismissViewControllerAnimated:self.imagePicker completion:nil];
}

-(void)convertToImageFrom:(NSString *)urlString withCompletion:(imageCompletion)completion {
    self.completion = completion;
    
    NSURL *url = [NSURL URLWithString:urlString];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithALAssetURLs:@[url]
                                                                   options:nil];
    assert(assets.count == 1);
    PHAsset *asset = assets.firstObject;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(800, 800)
                                              contentMode:PHImageContentModeDefault
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         self.completion(result);
     }];
}



- (UIImage *)createThumbnailFrom:(NSString *)urlString toRect:(CGRect)rect
{
    __block UIImage * roundedImg;
    
    [self convertToImageFrom:urlString withCompletion:^(UIImage *image) {
        //resize image
        NSLog(@"ThumbnailUmage: %@", image);
        UIGraphicsBeginImageContext( rect.size );
        [image drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(picture1);
        UIImage *img = [UIImage imageWithData:imageData];
        
        //make rounded corners
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = rect;
        imageLayer.contents = (id) img.CGImage;
        
        imageLayer.masksToBounds = YES;
        imageLayer.cornerRadius = kCornerRadius;
        
        UIGraphicsBeginImageContext(img.size);
        [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
        roundedImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }];
    return roundedImg;
    
}

-(void)createAnnotationForRecord:(Record *)record {
    CustomPointAnnotation *newPoint = [[CustomPointAnnotation alloc]init];
    newPoint.coordinate = CLLocationCoordinate2DMake(record.latitude.doubleValue, record.longitude.doubleValue);
    //newPoint.title = record.title;
    if (record.localImageURL) {
        newPoint.image = [self createThumbnailFrom:record.localImageURL toRect:CGRectMake(0.0, 0.0, kThumbnailSize, kThumbnailSize)];
    }
    else {
        //newPoint.image = [self createThumbnailFrom:record.parseImageURL toRect:CGRectMake(0.0, 0.0, kThumbnailSize, kThumbnailSize)];
    }
    [self.mapView addAnnotation:newPoint];
}


-(void)addPolylineToMap {
    CLLocationCoordinate2D coordinates[self.records.count];
    int i = 0;
    for (Record *currentRec in self.records) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(currentRec.latitude.doubleValue, currentRec.longitude.doubleValue);
        coordinates[i] = coordinate;
        i++;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:self.records.count];
    [self.mapView addOverlay:polyLine];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
    if (annotationView)
    {
        annotationView.annotation = annotation;
    }
    else
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"annotationView"];
    }
    
    annotationView.canShowCallout = NO;
    annotationView.image = [(CustomPointAnnotation *)annotation image];
    return annotationView;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    polylineRenderer.strokeColor = [UIColor blueColor];
    polylineRenderer.lineWidth = kPolylineWidth;
    polylineRenderer.alpha = kPolylineAlpha;
    return polylineRenderer;
}
- (void)login {
    if (![PFUser currentUser]) {
        CustomLoginViewController *loginViewController = [[CustomLoginViewController alloc]init];
        
        loginViewController.delegate = self;
        loginViewController.signUpController.delegate = self;
        [self presentViewController:loginViewController animated:YES completion:nil];
    } else {
        NSLog(@"already logged in");
    }
}

- (void)logout {
    [PFUser logOut];
    [self login];
}

#pragma mark - PFLogInViewControllerDelegate

- (void)logInViewController:(CustomLoginViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PFSignUpViewControllerDelegate

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)libraryButtonPressed:(UIBarButtonItem *)sender {
}

- (IBAction)logoutButtonSelected:(UIBarButtonItem *)sender {
    [self logout];
}

@end
