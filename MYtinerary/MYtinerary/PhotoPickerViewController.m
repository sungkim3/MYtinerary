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
@import Photos;
@import UIKit;

NSString  * const _Nonnull cellReuseID = @"CollectionViewCell";

@interface PhotoPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) PHImageRequestOptions *requestOptions;
@property (strong, nonatomic) PHImageManager *manager;
@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) NSMutableArray *thumbnails;
@property (strong, nonatomic) NSMutableArray *selectedAssets;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;

@property (strong, nonatomic) Itinerary *itinerary;

@property (nonatomic) CGFloat cellWidth;

@end

@implementation PhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.allowsMultipleSelection = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    [self fetchPhotosFromPhotoLibrary];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat side = (MIN(self.view.frame.size.height , self.view.frame.size.width) / 3);
    self.cellWidth = side;
}

-(void)fetchPhotosFromPhotoLibrary {
    self.thumbnails = [[NSMutableArray alloc]init];
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
    }];
    
}

-(void)doneButtonPressed {
    [self createItineraryWith:self.titleTextField.text];
    MapViewController *mapVC = (MapViewController *)self.navigationController.viewControllers.firstObject;
    if (!mapVC.assets) {
        mapVC.assets = [[NSMutableArray alloc]initWithArray:self.selectedAssets];
    }
//    for (PHAsset *asset in self.assets) {
//        if ([asset isKindOfClass:[PHAsset class]]) {
//            [mapVC.assets addObject:asset];
//        }
//    }
    mapVC.itinerary = self.itinerary;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)createItineraryWith:(NSString *)title {
    Itinerary *itinerary = [NSEntityDescription insertNewObjectForEntityForName:@"Itinerary" inManagedObjectContext:[NSManagedObject managedContext]];
    itinerary.records = [[NSOrderedSet alloc]init];
    itinerary.title = title;
    itinerary.author = @"Author";
    self.itinerary = itinerary;
    
    NSError *saveError;
    BOOL isSaved = [[NSManagedObject managedContext] save:&saveError];
    if(isSaved) {
        NSLog(@"Itinerary with records successfully saved");
    } else {
        NSLog(@"Unsuccessful saving Itinerary with records: %@", saveError.localizedDescription);
    }
}

#pragma - CollectionView DataSource Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseID forIndexPath:indexPath];
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        cell.backgroundColor = [UIColor blueColor];
    } else {
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
                                            [self.thumbnails addObject:result];
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




@end
