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
@import Photos;

@interface RecordsViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)NSArray *itineraries;
@property (strong, nonatomic)NSArray *records;
@property (strong, nonatomic)Itinerary *itinerary;
@property (strong, nonatomic)Record *record;
@property (strong, nonatomic)NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic)NSMutableArray *assets;
typedef void(^imageCompletion)(UIImage *image);
@property (strong, nonatomic)UIImageView *imageView;

@end


@implementation RecordsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Details"];
    
    [self setUpView];

}

- (void)setUpView
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
}



- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
        AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;

        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext: context sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"Fetch request successfull");
        }
    }
    
    return _fetchedResultsController;
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



#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *record = [self.fetchedResultsController fetchedObjects];
    
    return record.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    Record *record = [self.records objectAtIndex:indexPath.row];
    cell.textLabel.text = record.itinerary.title;
    NSManagedObject *managedObject = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Managed Object: %@", managedObject);
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"detailCell"];
    }
//    Record *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
   
    
    UIImage *cellImage = [[UIImage alloc]init];

    cell.imageView.image = cellImage;
    
    UIImageView *cellImageView = [[UIImageView alloc]initWithImage:cellImage];
////    cell.textLabel.text = record.itinerary.title;
////    NSLog(@"Record title: %@", record.itinerary.title);
//    
    [cell addSubview:cellImageView];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Record *record = [self.records objectAtIndex:indexPath.row];
    self.record = record;
    
    NSMutableArray *assetIds = [[NSMutableArray alloc]init];
    NSMutableOrderedSet *mutableRecords = [[NSMutableOrderedSet alloc]initWithArray:self.records];
    
    for (Record *recordd in _itinerary.records) {
        [mutableRecords addObject:recordd];
        [assetIds addObject:record.localImageURL];
    }
    
    self.assets = [[NSMutableArray alloc]init];
    PHFetchOptions *allPhotos = [[PHFetchOptions alloc]init];
    allPhotos.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *assetResults = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.assets] options:nil];
    assert(assetResults.count == 1);
    [assetResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAsset class]]) {
            self.assets = obj;
        }
        if (idx == assetResults.count - 1) {
            PHImageManager *manager = [PHImageManager defaultManager];
            
            [manager requestImageForAsset:self.assets targetSize:self.imageView.intrinsicContentSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                self.imageView.image = result;
            }];
        }
    }];
}

    
@end

     
