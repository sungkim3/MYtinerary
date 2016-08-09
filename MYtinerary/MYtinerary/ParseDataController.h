//
//  ParseDataController.h
//  MYtinerary
//
//  Created by Jess Malesh on 8/8/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseDataController : NSObject

@property (nonnull, nonatomic) NSString *itineraryTitle;
@property (nullable, nonatomic) NSString *localImageURL;
@property (nullable, nonatomic) NSString *parseImageURL;
@property (nullable, nonatomic) NSString *parseThumbnailURL;
//parse image
@property (nonnull, nonatomic) NSNumber *latitude;
@property (nonnull, nonatomic) NSNumber *longitude;
@property (nonnull, nonatomic) NSDate *date;
@property (nullable, nonatomic) NSString *title;
@property (nullable, nonatomic) NSString *comments;

+(ParseDataController *)shared;
-(void)saveItinerary:(NSString *)itineraryTitle;
//-(void)saveRecords:(NSString *)itineraryTitle localImageURL:(NSString *)localImageURL parseImageURL:(NSString *)parseImageURL parseThumbnailURL:(NSString *)parseThumbnailURL latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude date:(NSDate *)date title:(NSString *)title comments:(NSString *)comments;

@end