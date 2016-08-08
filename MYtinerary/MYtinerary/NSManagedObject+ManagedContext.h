//
//  NSManagedObject+ManagedContext.h
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/5/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ManagedContext)

+(NSManagedObjectContext *) managedContext;

@end
