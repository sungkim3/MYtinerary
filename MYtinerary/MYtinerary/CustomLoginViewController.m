//
//  CustomLoginViewController.m
//  MYtinerary
//
//  Created by David Livingstone on 8/7/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "CustomLoginViewController.h"

@implementation CustomLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *customLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"meet-the-pug-pug-6.jpg"]];
    self.logInView.logo = customLogo;
}

@end
