//
//  Itinerary+CoreDataProperties.h
//  MYtinerary
//
//  Created by Sung Kim on 8/4/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Itinerary.h"

NS_ASSUME_NONNULL_BEGIN

@interface Itinerary (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSOrderedSet<Record *> *records;

@end

@interface Itinerary (CoreDataGeneratedAccessors)

- (void)insertObject:(Record *)value inRecordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRecordsAtIndex:(NSUInteger)idx;
- (void)insertRecords:(NSArray<Record *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRecordsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRecordsAtIndex:(NSUInteger)idx withObject:(Record *)value;
- (void)replaceRecordsAtIndexes:(NSIndexSet *)indexes withRecords:(NSArray<Record *> *)values;
- (void)addRecordsObject:(Record *)value;
- (void)removeRecordsObject:(Record *)value;
- (void)addRecords:(NSOrderedSet<Record *> *)values;
- (void)removeRecords:(NSOrderedSet<Record *> *)values;

@end

NS_ASSUME_NONNULL_END
