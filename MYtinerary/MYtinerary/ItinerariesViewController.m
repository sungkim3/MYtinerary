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

@interface ItinerariesViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *itineraries;

@end

@implementation ItinerariesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchItinerariesFromCoreData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

//TODO
//set up segue (bookmark button selected into ItinerariesViewController
//determine if itineraries will be populated from Core Data or Parse
//ensure textfield in photopickerviewcontroller is mandatory for itinerary.title
//create didselectatindexpath delegate to move into mapviewcontroller and pass off necessary data to populate the local store there

@end
