//
//  RecordsViewController.m
//  MYtinerary
//
//  Created by Jess Malesh on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "RecordsViewController.h"
#import "NSManagedObject+ManagedContext.h"
#import "ParseDataController.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "Record+CoreDataProperties.h"
#import "Record.h"
#import "Itinerary.h"
#import "PresentationViewController.h"

@import Photos;

typedef void(^imageConversionCompletion)(NSArray *images);


@interface RecordsViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(strong, nonatomic)NSMutableArray *recordImages;
//@property(strong, nonatomic)NSArray *coreRecords;
@property(strong, nonatomic)Record *record;

@end


@implementation RecordsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setUpView];
//    [self fetchRecordsFromCoreData];
    [self getImagesWith:^(NSArray *images) {
        [self setupTableImages:images];
    }];
    
}


-(void)getImagesWith:(imageConversionCompletion)completion {
    
    NSMutableArray *assetIds = [[NSMutableArray alloc]init];
    self.recordImages = [[NSMutableArray alloc]init];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    for (Record *record in self.records) {
        [assetIds addObject:record.localImageURL];
    }
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:assetIds options:allPhotosOptions];
    
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc]init];
    imageRequestOptions.synchronous = YES;
    
    for (PHAsset *asset in assets) {
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:imageRequestOptions
                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            [self.recordImages addObject:result];
                            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                completion(self.recordImages);
                            }];
                        }];
    }
}

- (void)setupTableImages:(NSArray *)images
{
    UIImageView *tableViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 150.0, 100.0)];
    tableViewImage.layer.cornerRadius = 30.0;

    

}


- (void)setUpView
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
}

//- (void)fetchRecordsFromCoreData {
//    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
//    NSManagedObjectContext *context = delegate.managedObjectContext;
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
//    NSError *error;
//    self.coreRecords = [context executeFetchRequest:request error:&error];
//    NSLog(@"Number of itineraries in Core Data: %lu", (unsigned long)self.records.count);
//}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    Record *record = [self.records objectAtIndex:indexPath.row];
    self.record = record;
    
//    UIImage *testImage = [UIImage imageWithContentsOfFile:self.recordImages[indexPath.row]];
//    UIImageView *testImageView = [[UIImageView alloc]initWithImage:testImage];
    
//    [cell addSubview:testImageView];
    cell.textLabel.text = @"Place Holder";
    
    //    cell.imageView.image = testImage;
    
    return cell;
}
    
//    NSMutableOrderedSet *recordImages = [[NSMutableOrderedSet alloc]init];
//    NSMutableArray *assetIds = [[NSMutableArray alloc]init];
//    NSMutableOrderedSet *mutableRecords = [[NSMutableOrderedSet alloc]initWithOrderedSet:recordImages];
//    
//    for (Record *record in self.records) {
//        [mutableRecords addObject:record];
//        [assetIds addObject:record.localImageURL];
//    }
//    self.records = (NSArray *)mutableRecords;
//    self.assets = [[NSMutableArray alloc]init];
//    
//    
////    PHImageManager *manager = [PHImageManager defaultManager];
//    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
//    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
//    
////    PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:assetIds options:allPhotosOptions];
////    self.assets = [[NSMutableArray alloc]init];
//    
////    assert(assets.count == 1);
//    
//    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc]init];
//    imageRequestOptions.synchronous = YES;
//    PHImageManager *manager = [PHImageManager defaultManager];
//    PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:assetIds options:allPhotosOptions];
//    
//
//    for (PHAsset *asset in assets) {
//        [manager requestImageForAsset:asset
//                           targetSize:PHImageManagerMaximumSize
//                          contentMode:PHImageContentModeDefault
//                              options:imageRequestOptions
//                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                            [recordImages addObject:result];
//                        }];
//    }
//    
//
//    
//    UIImageView *testImageView = [[self setupTableImage]initWithImage:recordImages[0]];
//    
//    [cell addSubview:testImageView];
// 
//    cell.textLabel.text = @"LABELLLLLL";
//    return cell;
//}
//

//
//#pragma mark - UITableViewDelegate
//
//
//    
@end

     
