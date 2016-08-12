//
//  CustomLoginViewController.m
//  MYtinerary
//
//  Created by David Livingstone on 8/7/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "CustomLoginViewController.h"
#import <Parse/Parse.h>


@implementation CustomLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor lightGrayColor];
//    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
//    self.logInView.logo = image;
    [self setupLoginUI];
    [self setupSignUpUI];
}

- (void)setupLoginUI {
    
    UIImage *logoImage = [UIImage imageNamed:@"icon"];
    UIImageView *logoView = [[UIImageView alloc]initWithImage:logoImage];
    
    logoView.frame = CGRectMake(0.0, 0.0, 500.0, 100.0);
    logoView.contentMode = UIViewContentModeScaleToFill;

    
    self.logInView.logo = logoView;
    
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
