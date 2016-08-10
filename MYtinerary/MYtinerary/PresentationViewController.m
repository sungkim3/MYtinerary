//
//  PresentationViewController.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "PresentationViewController.h"
#import "Record.h"
@import Photos;

typedef void(^imageConversionCompletion)(NSArray *images);

@interface PresentationViewController ()

- (IBAction)cancelButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray *recordImages;

@end

@implementation PresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getImagesWith:^(NSArray *images) {
        [self setupPresentation:images];
    }];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
}

-(void)getImagesWith:(imageConversionCompletion)completion {
    
    NSMutableArray *assetIds = [[NSMutableArray alloc]init];
    self.recordImages = [[NSMutableArray alloc]init];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    for (Record *record in self.records) {
        [assetIds addObject:record.localImageURL];
    }
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:assetIds options:allPhotosOptions];
    
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc]init];
    imageRequestOptions.synchronous = YES;
    
    for (PHAsset *asset in assets) {
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:imageRequestOptions
                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            [self.recordImages addObject:result];
                            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                completion(self.recordImages);
                            }];
                        }];
    }
}

-(void)setupPresentation:(NSArray *)images {
    self.imageView.animationImages = images;
    self.imageView.animationDuration = (5.0*images.count);
    self.imageView.animationRepeatCount =0 ;
    [self.imageView startAnimating];

    NSTimer *timer = [NSTimer timerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(onTimer)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
}

-(void)onTimer {
    [UIView animateWithDuration:4.0 animations:^{
        self.imageView.alpha = 0.0;
    }];
    [UIView animateWithDuration:1.0 animations:^{
        self.imageView.alpha = 1.0;
    }];
}


@end
