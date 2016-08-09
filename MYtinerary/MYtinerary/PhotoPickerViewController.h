//
//  PhotoPickerViewController.h
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/7/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"
#import "Record.h"

@interface PhotoPickerViewController : UIViewController

-(void)fetchPhotosFromPhotoLibrary;
@property (strong, nonatomic) Itinerary *itinerary;
@property (strong, nonatomic) NSOrderedSet *records;
@property (strong, nonatomic) NSMutableArray *selectedAssets;


@end
