//
//  ParseDataController.h
//  MYtinerary
//
//  Created by Jess Malesh on 8/8/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

@import UIKit;
@import Photos;

@interface ParseDataController : NSObject

@property (nonnull, nonatomic) NSString *itineraryTitle;
@property (nonnull, nonatomic) NSNumber *latitude;
@property (nonnull, nonatomic) NSNumber *longitude;
@property (nonnull, nonatomic) NSDate *date;
@property (nullable, nonatomic) NSString *title;
@property (nullable, nonatomic) NSString *comments;
@property (nullable, nonatomic) NSString *localImageURL;
@property (nonnull, nonatomic) PHAsset *localImage;

// thumbnail

+ (nonnull ParseDataController *)shared;
- (void)saveItinerary:(nonnull NSString *)itineraryTitle;
- (void)saveRecords:(nonnull NSString *)itineraryTitle
          latitude:(nonnull NSNumber *)latitude
         longitude:(nonnull NSNumber *)longitude
              date:(nonnull NSDate *)date
             title:(nullable NSString *)title
          comments:(nullable NSString *)comments
     localImageURL:(nullable NSString *)localImageURL
         localImage:(nonnull PHAsset *)localImage;

@end