//
//  CustomPointAnnotation.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/5/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "CustomPointAnnotation.h"

@implementation CustomPointAnnotation
-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                            image:(UIImage *)image {
    self = [super init];
    self.image = image;
    
    return self;
}

@end
