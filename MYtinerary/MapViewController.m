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
#import "PhotoPickerViewController.h"
@import Photos;
@import MapKit;
@import CoreLocation;
@import Parse;
@import ParseUI;

typedef void(^imageCompletion)(UIImage *image);
NSString  * const _Nonnull editSegueIdentifier = @"EditItinerary";

@interface MapViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)libraryButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)logoutButtonSelected:(UIBarButtonItem *)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self.navigationController setToolbarHidden:NO animated:NO];

    [self login];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.itinerary) {
        for (PHAsset *asset in self.assets) {
            [self createAnnotationForRecord:asset];
        }
        [self sortRecordsByDate];
        [self addPolylineToMap];
    }
}


-(void)sortRecordsByDate {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    self.records = [[self.records sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

-(void)convertToImageFrom:(PHAsset *)asset withCompletion:(imageCompletion)completion {
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(800, 800)
                                              contentMode:PHImageContentModeDefault
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         completion(result);
     }];
}

- (UIImage *)createThumbnailFrom:(PHAsset *)asset toRect:(CGRect)rect
{
    __block UIImage * roundedImg;
    
    [self convertToImageFrom:asset withCompletion:^(UIImage *image) {
        //resize image
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

-(void)createAnnotationForRecord:(PHAsset *)asset {
    CustomPointAnnotation *newPoint = [[CustomPointAnnotation alloc]init];
    newPoint.coordinate = CLLocationCoordinate2DMake(asset.location.coordinate.latitude, asset.location.coordinate.longitude);
    //newPoint.title = record.title;
    if (asset) {
        newPoint.image = [self createThumbnailFrom:asset toRect:CGRectMake(0.0, 0.0, kThumbnailSize, kThumbnailSize)];
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


- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:editSegueIdentifier sender:self];
}

- (IBAction)libraryButtonPressed:(UIBarButtonItem *)sender {
    
}

- (IBAction)logoutButtonSelected:(UIBarButtonItem *)sender {
    [self logout];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:editSegueIdentifier]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoPickerViewController class]]) {
            PhotoPickerViewController *photoPickerVC = (PhotoPickerViewController *) segue.destinationViewController;
            photoPickerVC.records = self.records;
            photoPickerVC.selectedAssets = self.assets;
            photoPickerVC.itinerary = self.itinerary;
        }
    }
}


@end
