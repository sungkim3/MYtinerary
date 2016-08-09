//
//  RecordsViewController.m
//  MYtinerary
//
//  Created by Jess Malesh on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "RecordsViewController.h"
#import "NSManagedObject+ManagedContext.h"

@interface RecordsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic)UITableView *tableView;


@end


@implementation RecordsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Details"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
   if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"detailCell"];
    }
    
    return cell;

}

@end
