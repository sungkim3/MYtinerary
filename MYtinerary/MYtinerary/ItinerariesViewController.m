//
//  ItinerariesViewController.m
//  MYtinerary
//
//  Created by Sung Kim on 8/8/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "ItinerariesViewController.h"
#import "AppDelegate.h"
#import "Itinerary.h"
#import "Record.h"
#import "MapViewController.h"
@import Photos;

@interface ItinerariesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *itineraries;
@property (strong, nonatomic) NSOrderedSet *records;
@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) Itinerary *itinerary;

@end

@implementation ItinerariesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self fetchItinerariesFromCoreData];
}

-(void)setupView {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setTintColor: [UIColor clearColor]];
}

- (void)fetchItinerariesFromCoreData {
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Itinerary"];
    NSError *error;
    self.itineraries = [context executeFetchRequest:request error:&error];
    NSLog(@"Number of itineraries in Core Data: %lu", (unsigned long)self.itineraries.count);
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itineraries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itineraryCell"];
    Itinerary *itinerary = [self.itineraries objectAtIndex:indexPath.row];
    
    cell.textLabel.text = itinerary.title;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Itinerary *itinerary = [self.itineraries objectAtIndex:indexPath.row];
    self.itinerary = itinerary;

    NSMutableArray *assetIds = [[NSMutableArray alloc]init];
    NSMutableOrderedSet *mutableRecords = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.records]; //[self.records mutableCopy];
    for (Record *record in itinerary.records) {
        [mutableRecords addObject:record];
        [assetIds addObject:record.localImageURL];
    }
    self.records = (NSOrderedSet *)mutableRecords;
    self.assets = [[NSMutableArray alloc]init];
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:assetIds options:allPhotosOptions];
    
    [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAsset class]]) {
            [self.assets addObject:(PHAsset *)obj];
        }
        if (idx == assets.count - 1) {
            [self performSegueWithIdentifier:@"displayItineraryOnMapVC" sender:self];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"displayItineraryOnMapVC"]) {
        if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
            MapViewController *mapVC = (MapViewController *)segue.destinationViewController;
            mapVC.itinerary = self.itinerary;
            mapVC.assets = self.assets;
            mapVC.records = self.records;
        }
    }
}

//TODO

//determine if itineraries will be populated from Core Data or Parse
//ensure textfield in photopickerviewcontroller is mandatory for itinerary.title
//create didselectatindexpath delegate to move into mapviewcontroller and pass off necessary data to populate the local store there

@end
