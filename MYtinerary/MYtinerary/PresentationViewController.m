//
//  PresentationViewController.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "PresentationViewController.h"
#import "PresentationCollectionViewCell.h"
#import "Record.h"

NSString  * const _Nonnull collectionCellReuseID = @"PresentationCell";

@interface PresentationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
- (IBAction)cancelButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.records.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PresentationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellReuseID forIndexPath:indexPath];
    cell.assetID = [((Record *)self.records[indexPath.row]) localImageURL];
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.collectionView.frame.size.height, self.collectionView.frame.size.height);
}

@end
