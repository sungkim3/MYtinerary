//
//  ItinerariesViewController.h
//  MYtinerary
//
//  Created by Sung Kim on 8/8/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"

@protocol ItinerariesViewControllerDelegate <NSObject>

@required
-(void)itineraryDeleted:(Itinerary *)itinerary;

@end

@interface ItinerariesViewController : UIViewController

@property (weak, nonatomic) id <ItinerariesViewControllerDelegate> delegate;

@end
