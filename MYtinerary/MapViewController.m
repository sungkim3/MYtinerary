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
#import "PresentationViewController.h"
#import "RecordsViewController.h"
#import "ItinerariesViewController.h"
#include <math.h>

@import Photos;
@import MapKit;
@import CoreLocation;
@import Parse;
@import ParseUI;

typedef void(^imageCompletion)(UIImage *image);
NSString  * const _Nonnull editSegueIdentifier = @"EditItinerary";
NSString  * const _Nonnull createSegueIdentifier = @"CreateItinerary";
NSString  * const _Nonnull presentstionSegueIdentifier = @"ShowPresentation";

@interface MapViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, ItinerariesViewControllerDelegate,RecordsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonOutlet;

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)logoutButtonSelected:(UIBarButtonItem *)sender;
- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)bookmarkButtonPressed:(UIBarButtonItem *)sender;
//- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)detailButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)playButtonPressed:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButtonOutlet;
//@property (weak, nonatomic) IBOutlet UIButton *playButtonOutlet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *detailButtonOutlet;
@property (strong, nonatomic) NSMutableArray *toolbarButtons;
@property (strong, nonatomic)UITapGestureRecognizer *tapGesture;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    self.mapView.delegate = self;
    [self.navigationController setToolbarHidden:NO animated:NO];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupAppearance];
    
    [self sortRecordsByDate];
    [self addPolylineToMap];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self sortRecordsByDate];
}

-(void)setupView {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setTintColor: nil];
//    [self.playButtonOutlet.layer setCornerRadius:5.0];
    self.navigationController.toolbar.layer.opacity = 0.5;
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)setupAppearance {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    if (self.itinerary) {
        [self sortRecordsByDate];
        for (PHAsset *asset in self.assets) {
            [self createAnnotationForRecord:asset];
        }
        [self setRegion];
        self.title = self.itinerary.title;
        self.playButtonOutlet.enabled = YES;
        [self.playButtonOutlet setTintColor:nil];
        self.detailButtonOutlet.enabled = YES;
        [self.detailButtonOutlet setTintColor:nil];
        self.editButtonOutlet.enabled = YES;
        [self.editButtonOutlet setTintColor:nil];
        
    } else {
        self.playButtonOutlet.enabled = NO;
        [self.playButtonOutlet setTintColor:[UIColor clearColor]];
        self.detailButtonOutlet.enabled = NO;
        [self.detailButtonOutlet setTintColor:[UIColor clearColor]];
        self.editButtonOutlet.enabled = NO;
        [self.editButtonOutlet setTintColor:[UIColor clearColor]];
    }
}

-(void)setRegion {
    NSMutableArray *latitudes = [[NSMutableArray alloc]initWithCapacity:self.records.count];
    NSMutableArray *longitudes = [[NSMutableArray alloc]initWithCapacity:self.records.count];
    
    for (Record *record in self.records) {
        [latitudes addObject:record.latitude];
        [longitudes addObject:record.longitude];
    }
    
    [latitudes sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([(NSNumber *)obj1 doubleValue]  < [(NSNumber *)obj2 doubleValue])
            return NSOrderedAscending;
        else if ([(NSNumber *)obj1 doubleValue] > [(NSNumber *)obj2 doubleValue])
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    [longitudes sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([(NSNumber *)obj1 doubleValue] < [(NSNumber *)obj2 doubleValue])
            return NSOrderedAscending;
        else if ([(NSNumber *)obj1 doubleValue] > [(NSNumber *)obj2 doubleValue])
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
//    
//    NSLog(@"Sorted latitudes: %@", latitudes);
//    NSLog(@"Sorted longitudes: %@", longitudes);
    
    double longitudeDifference = [longitudes.lastObject doubleValue] - [longitudes.firstObject doubleValue];
    double latitudeDifference = [latitudes.lastObject doubleValue] - [latitudes.firstObject doubleValue];
    MKCoordinateSpan span = MKCoordinateSpanMake(fabs(latitudeDifference * kSpanMultiplier), fabs(longitudeDifference * kSpanMultiplier));
    
    double centerLatitude = [latitudes.firstObject doubleValue] + latitudeDifference/2;
    double centerLongitude = [longitudes.firstObject doubleValue] + longitudeDifference/2;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(centerLatitude, centerLongitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region];
}

-(void)sortRecordsByDate {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    self.records = [[self.records sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    NSSortDescriptor *assetDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
    NSArray *assetSortDescriptors = [NSArray arrayWithObject:assetDateDescriptor];
    self.assets = [[self.assets sortedArrayUsingDescriptors:assetSortDescriptors] mutableCopy];
    
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
    annotationView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//    [tapGesture setDelegate:annotationView.image];
    [annotationView addGestureRecognizer:tapGesture];
    NSLog(@"Photo tapped");
    
    return annotationView;
}

-(void)tapGesture:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:presentstionSegueIdentifier sender:self];

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

- (void)signUpViewController:(CustomLoginViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self performSegueWithIdentifier:editSegueIdentifier sender:self];
}

- (IBAction)logoutButtonSelected:(UIBarButtonItem *)sender {
    [self logout];
}

- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender {
    self.assets = nil;
    self.itinerary = nil;
    self.records = nil;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self performSegueWithIdentifier:createSegueIdentifier sender:self];
}

- (IBAction)bookmarkButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"ShowItineraries" sender:self];
    
}

- (IBAction)detailButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"detailViewSegue" sender:self];
}

- (IBAction)playButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:presentstionSegueIdentifier sender:self];

}

//- (IBAction)playButtonPressed:(UIButton *)sender {
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:editSegueIdentifier] || [segue.identifier isEqualToString:createSegueIdentifier]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoPickerViewController class]]) {
            PhotoPickerViewController *photoPickerVC = (PhotoPickerViewController *) segue.destinationViewController;
            photoPickerVC.records = self.records;
            photoPickerVC.selectedAssets = self.assets;
            photoPickerVC.itinerary = self.itinerary;
            photoPickerVC.title = self.itinerary.title;
            
        }
    } else if ([segue.identifier isEqualToString:presentstionSegueIdentifier]) {
        if ([segue.destinationViewController isKindOfClass:[PresentationViewController class]]) {
            PresentationViewController *presentationVC = (PresentationViewController *)segue.destinationViewController;
            presentationVC.records = self.records;
            presentationVC.title = self.itinerary.title;
        }
    } else if ([segue.identifier isEqualToString:@"ShowItineraries"]) {
        if ([segue.destinationViewController isKindOfClass:[ItinerariesViewController class]]) {
            ItinerariesViewController *itinerariesVC = (ItinerariesViewController *)segue.destinationViewController;
            itinerariesVC.delegate = self;
        }
    }
    else {
        if ([segue.identifier isEqualToString:@"detailViewSegue"]) {
            if ([segue.destinationViewController isKindOfClass:[RecordsViewController class]]) {
                RecordsViewController *recordsViewController = (RecordsViewController *)segue.destinationViewController;
                recordsViewController.records = self.records;
                recordsViewController.title = self.itinerary.title;
                recordsViewController.delegate = self;
                recordsViewController.itinerary = self.itinerary;
            }
        }
    }
}

#pragma mark - ItinerariesViewControllerDelegate

-(void)itineraryDeleted:(Itinerary *)itinerary {
    if (self.itinerary == itinerary) {
        self.itinerary = nil;
    }
}

#pragma mark - RecordsViewControllerDelegate

-(void)recordDeleted:(Record *)record date:(NSDate *)creationDate itinerary:(Itinerary *)itinerary {
        if ([self.records containsObject:record]) {
            NSMutableOrderedSet *mutableRecords = [self.records mutableCopy];
            [mutableRecords removeObject:record];
            self.records = mutableRecords;
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (PHAsset *asset in self.assets) {
                if ([asset.creationDate compare:creationDate] == NSOrderedSame) {
                    NSLog(@"Found it!");
                } else {
                    [array addObject:asset];
                }
            }
            self.assets = array;
        } else {
            NSLog(@"Record is not in self.records");
        }
    
    if (self.records.count == 0) {
        NSManagedObjectContext *context = [NSManagedObject managedContext];
        NSFetchRequest *fetch = [[NSFetchRequest alloc]init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Itinerary" inManagedObjectContext:context];
        [fetch setEntity:entityDescription];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"(title==%@)", self.itinerary.title]];
        NSError *error;
        NSArray *objects = [context executeFetchRequest:fetch error:&error];
        
        if (error) {
            NSLog(@"Error fetching context");
        } else {
            [context deleteObject:objects[0]];


            NSError *saveError;
            [context save:&saveError];
            
            if (saveError) {
                NSLog(@"Error saving to context");
            } else {
                NSError *saveError;
                [context save:&saveError];
                if (saveError) {
                    NSLog(@"Error saving to context");
                } else {
                    NSLog(@"Success saving to context");
                }
            }
            
        }
        self.itinerary = nil;
        self.title = nil;
    }
}

@end
