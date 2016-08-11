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

@interface MapViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonOutlet;

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)logoutButtonSelected:(UIBarButtonItem *)sender;
- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)bookmarkButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIButton *playButtonOutlet;
- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)detailButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *detailButtonOutlet;

@property (strong, nonatomic) NSMutableArray *toolbarButtons;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    self.mapView.delegate = self;
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    //[self login];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.itinerary) {
        for (PHAsset *asset in self.assets) {
            [self createAnnotationForRecord:asset];
        }
        [self setRegion];
        self.playButtonOutlet.hidden = NO;
        self.detailButtonOutlet.enabled = YES;
        [self.detailButtonOutlet setTintColor:nil];
    } else {
        self.playButtonOutlet.hidden = YES;
        self.detailButtonOutlet.enabled = NO;
        [self.detailButtonOutlet setTintColor:[UIColor clearColor]];
    }
    [self sortRecordsByDate];
    [self addPolylineToMap];
}

-(void)setupView {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setTintColor: nil];
    [self.playButtonOutlet.layer setCornerRadius:5.0];
    self.navigationController.toolbar.layer.opacity = 0.5;
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!self.itinerary) {
        self.playButtonOutlet.hidden = YES;
        self.playButtonOutlet.enabled = NO;
        self.editButtonOutlet.enabled = NO;
        [self.editButtonOutlet setTintColor:[UIColor clearColor]];

    } else {
        self.playButtonOutlet.hidden = NO;
        self.playButtonOutlet.enabled = YES;
        self.editButtonOutlet.enabled = YES;
        [self.editButtonOutlet setTintColor:nil];

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
    
    
    NSLog(@"Sorted latitudes: %@", latitudes);
    NSLog(@"Sorted longitudes: %@", longitudes);
    
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

- (IBAction)searchButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"recordsViewController" sender:self];
}

- (IBAction)detailButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"detailViewSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:editSegueIdentifier] || [segue.identifier isEqualToString:createSegueIdentifier]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoPickerViewController class]]) {
            PhotoPickerViewController *photoPickerVC = (PhotoPickerViewController *) segue.destinationViewController;
            photoPickerVC.records = self.records;
            photoPickerVC.selectedAssets = self.assets;
            photoPickerVC.itinerary = self.itinerary;
        }
    } else if ([segue.identifier isEqualToString:presentstionSegueIdentifier]) {
            if ([segue.destinationViewController isKindOfClass:[PresentationViewController class]]) {
                PresentationViewController *presentationVC = (PresentationViewController *)segue.destinationViewController;
                presentationVC.records = self.records;
            }
        }
    else {
        if ([segue.identifier isEqualToString:@"detailViewSegue"]) {
            if ([segue.destinationViewController isKindOfClass:[RecordsViewController class]]) {
                
                RecordsViewController *recordsViewController = (RecordsViewController *)segue.destinationViewController;
                recordsViewController.records = self.records;
            }
        }
        
    }
}

- (IBAction)playButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:presentstionSegueIdentifier sender:self];
}
@end
