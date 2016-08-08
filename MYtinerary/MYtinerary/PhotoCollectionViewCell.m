//
//  PhotoCollectionViewCell.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/7/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end

@implementation PhotoCollectionViewCell

-(void)setPhoto:(UIImage *)photo {
    self.photoView.image = photo;
}

@end
