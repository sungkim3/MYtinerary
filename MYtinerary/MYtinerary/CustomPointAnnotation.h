//
//  CustomPointAnnotation.h
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/5/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) UIImage *image;
-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                            image:(UIImage *)image;
@end
