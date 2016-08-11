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
#import "DetailTableViewCell.h"

@import Photos;

typedef void(^imageConversionCompletion)(NSArray *images);


@interface RecordsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(strong, nonatomic)NSMutableArray *recordImages;
//@property(strong, nonatomic)NSArray *coreRecords;
//@property(strong, nonatomic)Record *record;

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
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    Record *record = [self.records objectAtIndex:indexPath.row];
    
    cell.image = [self.recordImages objectAtIndex:indexPath.row];
    cell.date = record.date;
    cell.title = record.title;
    cell.comments = record.comments;
    
    return cell;
}

@end

     
