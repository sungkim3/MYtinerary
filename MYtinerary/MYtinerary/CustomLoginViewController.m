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
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"meet-the-pug-pug-6.jpg"]];
    
    self.logInView.logo = logo;
    NSLayoutConstraint *logoHeight = [NSLayoutConstraint constraintWithItem:self.logInView.logo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.logInView.logo attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    
    logo.activeHeight = YES;

    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)setupSignUpUI {
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"meet-the-pug-pug-6.jpg"]];
    
    self.signUpController.signUpView.logo = logo;
    self.signUpController.signUpView.backgroundColor =  [UIColor whiteColor];
}

@end
