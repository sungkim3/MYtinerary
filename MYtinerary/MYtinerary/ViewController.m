//
//  ViewController.m
//  MYtinerary
//
//  Created by Sung Kim on 8/4/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "ViewController.h"
#import "CustomLoginViewController.h"
@import Parse;
@import ParseUI;

@interface ViewController ()<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self login];
}

- (void)login {
    if (![PFUser currentUser]) {
        CustomLoginViewController *loginViewController = [[CustomLoginViewController alloc]init];
        
        loginViewController.delegate = self;
        loginViewController.signUpController.delegate = self;
        [self presentViewController:loginViewController animated:YES completion:nil];
    } else {
        NSLog(@"already logged in");
    }
}

- (void)logout {
    [PFUser logOut];
    [self login];
}

#pragma mark - PFLogInViewControllerDelegate

- (void)logInViewController:(CustomLoginViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark - PFSignUpViewControllerDelegate
//
//- (void)signUpViewController:(CustomSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
