//
//  ParseDataController.h
//  MYtinerary
//
//  Created by Jess Malesh on 8/8/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseDataController : NSObject

@property void *itineraryTitle;

+(ParseDataController *)shared;
-(void)test:(NSString *)title;
-(void)saveItinerary;
-(void)saveRecords;

@end
