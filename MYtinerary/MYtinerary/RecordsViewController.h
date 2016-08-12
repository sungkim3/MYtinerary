//
//  RecordsViewController.h
//  MYtinerary
//
//  Created by Jessica Malesh on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"
#import "Record.h"

@protocol RecordsViewControllerDelegate <NSObject>

@required
-(void)recordDeleted:(Record *)record date:(NSDate *)creationDate itinerary:(Itinerary *)itinerary;

@end

@interface RecordsViewController : UIViewController

@property (strong, nonatomic) NSOrderedSet *records;
@property (strong, nonatomic) Itinerary *itinerary;
@property (weak, nonatomic) id <RecordsViewControllerDelegate> delegate;
@property (strong, nonatomic) UIImage *thisImage;

@end
