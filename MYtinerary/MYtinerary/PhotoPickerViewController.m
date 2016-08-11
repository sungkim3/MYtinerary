//
//  PhotoPickerViewController.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/7/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "PhotoCollectionViewCell.h"
#import "MapViewController.h"
#import "Itinerary.h"
#import "NSManagedObject+ManagedContext.h"
#import "ParseDataController.h"
@import Photos;
@import UIKit;

typedef void(^urlCompletion)(NSURL *url);
typedef void(^recordCompletion)(NSOrderedSet *records);

NSString  * const _Nonnull cellReuseID = @"CollectionViewCell";

@interface PhotoPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) PHImageRequestOptions *requestOptions;
@property (strong, nonatomic) PHImageManager *manager;

@property (strong, nonatomic) NSMutableArray *assets; //all photos on device
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@property (strong, nonatomic) NSMutableArray *selectedAssetsForEditing;


@property (nonatomic) CGFloat cellWidth;

@end

@implementation PhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.allowsMultipleSelection = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat side = (MIN(self.view.frame.size.height , self.view.frame.size.width) / 3);
    self.cellWidth = side;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        [self fetchPhotosFromPhotoLibrary];
    }];
}

-(void)fetchPhotosFromPhotoLibrary {
    
    self.assets = [[NSMutableArray alloc]init];
    self.manager = [PHImageManager defaultManager];
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.synchronous = true;
    self.requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset) {
            [self.assets addObject:asset];
        }
        if (idx == allPhotosResult.count - 1) {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [self.collectionView reloadData];
            }];
        }
    }];
}

-(void)doneButtonPressed {
    if (!self.itinerary) {
        if ([self.titleTextField.text isEqual: @""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Please enter a Name for this Itinerary" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"OK pressed");
            }];
            
            [alert addAction:ok];
            
            
            [self presentViewController:alert animated:YES completion:Nil];
            return;
            
        }
        [self createItinerary];
        
        
        
    } else {
        //update existing itinerary
        [self recordsFrom:self.selectedAssets withCompletion:^(NSOrderedSet *records) {
            NSMutableArray *updatedRecords = [NSMutableArray new];//[self.records mutableCopy];
            
            
            
            for (Record *record in records) {
                [updatedRecords addObject:record];
            }
            self.records = (NSOrderedSet *)updatedRecords;
            
            //update Core Data Objects
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Itinerary"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(title==%@)",self.itinerary.title]];
            
            NSError *error;
            NSArray *results = [[NSManagedObject managedContext] executeFetchRequest: request error:&error];
            assert(results.count == 1);
            ((Itinerary *)results.firstObject).records = [NSOrderedSet orderedSetWithArray:(NSArray *)self.records];
            
            //save context
            NSError *saveError;
            BOOL isSaved = [[NSManagedObject managedContext] save:&saveError];
            if(isSaved) {
                NSLog(@"Itinerary with records successfully updated and saved");
            } else {
                NSLog(@"Unsuccessful saving Itinerary when updating records: %@", saveError.localizedDescription);
            }
            
            //pass data to MapVC
            MapViewController *mapVC = (MapViewController *)self.navigationController.viewControllers.firstObject;
            mapVC.records = self.records;
            NSMutableArray *updatedAssets = [mapVC.assets mutableCopy];
            [updatedAssets addObjectsFromArray:self.selectedAssets];
            mapVC.assets = updatedAssets;
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}

-(void)createItinerary {
    Itinerary *itinerary = [NSEntityDescription insertNewObjectForEntityForName:@"Itinerary" inManagedObjectContext:[NSManagedObject managedContext]];
    
    
    
    
    [self recordsFrom:self.selectedAssets withCompletion:^(NSOrderedSet *records) {
        itinerary.records = records;
        itinerary.title = self.titleTextField.text;
        itinerary.author = @"Author";
        self.itinerary = itinerary;
        self.records = records;
        
        //save context
        NSError *saveError;
        BOOL isSaved = [[NSManagedObject managedContext] save:&saveError];
        if(isSaved) {
            NSLog(@"Itinerary with records saved to Core Data");
        } else {
            NSLog(@"Unsuccessful saving Itinerary with records: %@", saveError.localizedDescription);
        }
        
        //pass data to MapVC
        MapViewController *mapVC = (MapViewController *)self.navigationController.viewControllers.firstObject;
        
        //        [mapVC.mapView removeAnnotations:mapVC.mapView.annotations];
        //        [mapVC.mapView removeOverlays:mapVC.mapView.overlays];
        
        mapVC.itinerary = self.itinerary;
        mapVC.records = self.records;
        mapVC.assets = self.selectedAssets;
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    //[[ParseDataController shared]saveItinerary: self.titleTextField.text];
    
}

-(void)recordsFrom:(NSArray *)assets withCompletion:(recordCompletion)completion {
    NSMutableOrderedSet *mutableRecords = [[NSMutableOrderedSet alloc]init];
    
    for (PHAsset * asset in assets) {
        Record *record = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:[NSManagedObject managedContext]];
        
        record.latitude = [NSNumber numberWithDouble:asset.location.coordinate.latitude];
        record.longitude = [NSNumber numberWithDouble:asset.location.coordinate.longitude];
        record.date = asset.creationDate;
        record.itinerary = self.itinerary;
        record.localImageURL = asset.localIdentifier;
        [mutableRecords addObject:record];
        
//        [[ParseDataController shared]saveRecords:@"foo"
//                                        latitude:record.latitude
//                                       longitude:record.longitude
//                                            date:record.date
//                                           title:@"title placeholder"
//                                        comments:@"comment placeholder"
//                                   localImageURL:asset.localIdentifier
//                                      localImage:asset];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(mutableRecords);
        });
        
        //        [self getURLFor:asset withCompletion:^(NSURL *url) {
        //            record.localImageURL = [NSString stringWithFormat:@"%@", url];
        //            [mutableRecords addObject:record];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                completion(mutableRecords);
        //            });
        //        }];
    }
}

-(void)getURLFor:(PHAsset *)asset withCompletion: (urlCompletion) completion {
    
    [asset requestContentEditingInputWithOptions:[PHContentEditingInputRequestOptions new] completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        completion(contentEditingInput.fullSizeImageURL);
    }];
}


#pragma - CollectionView DataSource Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseID forIndexPath:indexPath];

    if ([self.selectedAssets containsObject:self.assets[indexPath.row]]) {
        cell.backgroundColor = [UIColor blueColor];
    }
    else {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if (cell.tag) {
        [self.manager cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    PHAsset *asset = self.assets[indexPath.row];
    
    cell.tag = [self.manager requestImageForAsset:asset
                                       targetSize:CGSizeMake(self.cellWidth - 10.0, self.cellWidth - 10.0)
                                      contentMode:PHImageContentModeAspectFill
                                          options:self.requestOptions
                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                        if (result) {
                                            cell.photo = result;
                                        }
                                    }];
    
    return cell;
}

#pragma - CollectionViewDelegate Methods
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.cellWidth, self.cellWidth);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor blueColor];
    
    if (!self.selectedAssets) {
        self.selectedAssets = [[NSMutableArray alloc]init];
    }
    if (!self.selectedIndexPaths) {
        self.selectedIndexPaths = [[NSMutableArray alloc]init];
    }
    [self.selectedIndexPaths addObject:indexPath];
    [self.selectedAssets addObject:self.assets[indexPath.row]];
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [self.selectedIndexPaths removeObject:indexPath];
    [self.selectedAssets removeObject:self.assets[indexPath.row]];
}

#pragma - UITextFieldDelegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



@end
