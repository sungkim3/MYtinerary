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
    
    [self setupLoginUI];
    [self setupSignUpUI];
}

- (void)setupLoginUI {
    UIImage *logoImage = [UIImage imageNamed:@"icon"];
    UIImageView *logoView = [[UIImageView alloc]initWithImage:logoImage];
    
    logoView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 500.0);
    logoView.contentMode = UIViewContentModeScaleToFill;
    logoView.clipsToBounds = YES;
    
    self.logInView.logo = logoView;
//    NSLayoutConstraint *logoHeight = [NSLayoutConstraint constraintWithItem:self.logInView.logo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.logInView.logo attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];

    
}

- (void)setupSignUpUI {
//    UIImage *logoImage = [UIImage imageNamed:@"icon"];
//    UIImageView *logoView = [[UIImageView alloc]initWithImage:logoImage];
//    
//    logoView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 500.0);
//    logoView.contentMode = UIViewContentModeScaleToFill;
//    logoView.clipsToBounds = YES;
//    
//    self.logInView.logo = logoView;
//    
    
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
    
    self.signUpController.signUpView.logo = logo;
    self.signUpController.signUpView.backgroundColor =  [UIColor whiteColor];
}



@end
