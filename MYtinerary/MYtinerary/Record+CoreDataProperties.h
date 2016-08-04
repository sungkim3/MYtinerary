//
//  Record+CoreDataProperties.h
//  MYtinerary
//
//  Created by Sung Kim on 8/4/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface Record (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *localImageURL;
@property (nullable, nonatomic, retain) NSString *parseImageURL;
@property (nullable, nonatomic, retain) NSString *parseThumbnailURL;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *comments;
@property (nullable, nonatomic, retain) Itinerary *itinerary;

@end

NS_ASSUME_NONNULL_END
