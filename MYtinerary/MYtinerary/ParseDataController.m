//
//  ParseDataController.m
//  MYtinerary
//
//  Created by Jess Malesh on 8/8/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "ParseDataController.h"
@import Parse;

@implementation ParseDataController

+ (ParseDataController *)shared {
    static ParseDataController *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc]init];
    });
    
    return shared;
}

- (void)saveItinerary:(NSString *)itineraryTitle {
    NSString *author = [[PFUser currentUser] username];
    
    PFObject *itinerary = [PFObject objectWithClassName:@"Itinerary"];
    itinerary[@"author"] = author; //USER name from PFuser
    itinerary[@"title"] = itineraryTitle; //text fields.text in photo picker view controller
    
    [itinerary saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSLog(@"Itinerary saved to Parse");
        } else
        {
            NSLog(@"!!!Error saving Itinerary to Parse");
        }
    }];
}

- (void)saveRecords:(NSString *)itineraryTitle
                  latitude:(NSNumber *)latitude
                 longitude:(NSNumber *)longitude
                      date:(NSDate *)date
                     title:(NSString *)title
                  comments:(NSString *)comments
             localImageURL:(NSString *)localImageURL
                localImage:(PHAsset *)localImage
    {
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
        UIImage *bbbImage;
    
//        [imageManager requestImageForAsset:localImage
//                                targetSize:CGSizeMake(1000, 1000)
//                               contentMode:PHImageContentModeAspectFit
//                                   options:nil
//                             resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            bbbImage = result;
//        }];
        
    [imageManager requestImageForAsset:localImage targetSize:CGSizeMake(1000, 1000) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        bbbImage = result;
    }];
    
    PFObject *records = [PFObject objectWithClassName:@"Record"];
    
    records[@"latitude"] = latitude;
    records[@"longitude"] = longitude;
    records[@"date"] = date;
    records[@"title"] = title;
    records[@"comments"] = comments;
    records[@"localImageURL"] = localImageURL;
    records[@"localImage"] = localImage;
    // thumbnail
    
    [records saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSLog(@"Record saved to Parse");
        } else
        {
            NSLog(@"!!!Error saving Record to Parse");
        }
    }];
}

//- (void)PHAssetToJPG:(PHAsset *)localImage{
//    
//    
//}

@end
