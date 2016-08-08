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
@import Photos;
@import MapKit;
@import CoreLocation;

typedef void(^imageCompletion)(UIImage *image);
typedef void(^urlCompletion)(NSURL *url);
typedef void(^recordCompletion)(Record *record);

@interface MapViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSMutableArray *records;

- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)libraryButtonPressed:(UIBarButtonItem *)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Itinerary"];
    NSError *error;
    NSArray *results = [[NSManagedObject managedContext] executeFetchRequest: request error:&error];
    if (error) {
        NSLog(@"Error with fetching itineraryies");
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
    if (self.itinerary) {
        for (PHAsset *asset in self.assets) {
            NSLog(@"Asset for record: %@", asset);
            [self recordFrom:asset withCompletion:^(Record *record) {
                [self.records addObject:record];
                [self sortRecordsByDate];
                [self addPolylineToMap];
                 [self createAnnotationForRecord:asset];
            }];
        }
    }
}

-(void)recordFrom:(PHAsset *)asset withCompletion:(recordCompletion)completion {
    Record *record = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:[NSManagedObject managedContext]];
    
    record.latitude = [NSNumber numberWithDouble:asset.location.coordinate.latitude];
    record.longitude = [NSNumber numberWithDouble:asset.location.coordinate.longitude];
    record.date = asset.creationDate;
    record.itinerary = self.itinerary;
    [self getURLFor:asset withCompletion:^(NSURL *url) {
        record.localImageURL = [NSString stringWithFormat:@"%@", url];
        NSLog(@"Longitude: %f, latitude: %f\n ImageURL: %@", record.longitude.doubleValue, record.latitude.doubleValue, record.localImageURL);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(record);
           

        });
    }];
    
}

-(void)getURLFor:(PHAsset *)asset withCompletion: (urlCompletion) completion {
    
    [asset requestContentEditingInputWithOptions:[PHContentEditingInputRequestOptions new] completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        //dispatch_async(dispatch_get_main_queue(), ^{
            completion(contentEditingInput.fullSizeImageURL);
        //});
        
    }];
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


- (IBAction)libraryButtonPressed:(UIBarButtonItem *)sender {
}

@end