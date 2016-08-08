//
//  NSManagedObject+ManagedContext.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/5/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "NSManagedObject+ManagedContext.h"
#import "AppDelegate.h"

@implementation NSManagedObject (ManagedContext)

+(NSManagedObjectContext *) managedContext {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}


@end
