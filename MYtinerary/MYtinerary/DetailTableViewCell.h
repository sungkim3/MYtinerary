//
//  DetailTableViewCell.h
//  MYtinerary
//
//  Created by Sung Kim on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface DetailTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *comments;
@property (strong, nonatomic) Record *record;

@end
