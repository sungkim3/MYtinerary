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

- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)sender;
- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)playButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray *recordImages;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int index;
@property (strong, nonatomic) UIImage *image;

@end

@implementation PresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = self.navigationItem.backBarButtonItem;
    [backButton setAction:@selector(backBarButtonItem)];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    [self getImagesWith:^(NSArray *images) {
        [self setRecordImagesArray:images index:0];
    }];
}

- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"Image clicked index: %d", self.index);
}

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender {
    [self setRecordImagesArray:self.recordImages index:0];
}

- (IBAction)playButtonPressed:(UIBarButtonItem *)sender {
    [self setRecordImagesArray:self.recordImages index:self.index];
    
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
    imageRequestOptions.networkAccessAllowed = YES;
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    for (PHAsset *asset in assets) {
        [manager requestImageForAsset: asset
                           targetSize: PHImageManagerMaximumSize
                          contentMode: PHImageContentModeDefault
                              options: imageRequestOptions
                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            if (result) {
                                [self.recordImages addObject:result];
                            }
                            if (self.recordImages.count >= assets.count/5) {
                                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                    completion(self.recordImages);
                                }];
                            }
                        }];
    }
    
    NSLog(@"Images: %@", self.recordImages);
}

//-(void)setupPresentation:(NSArray *)images {
//    self.imageView.animationImages = images;
//    self.imageView.animationDuration = (5.0*images.count);
//    self.imageView.animationRepeatCount = 0 ;
//    [self.imageView startAnimating];
//
//    self.timer = [NSTimer timerWithTimeInterval:5.0
//                                             target:self
//                                           selector:@selector(onTimer)
//                                           userInfo:nil
//                                            repeats:YES];
//
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//    [self.timer fire];
//
//}

//-(void)onTimer {
//    [UIView animateWithDuration:4.0 animations:^{
//        self.imageView.alpha = 0.0;
//    }];
//    [UIView animateWithDuration:1.0 animations:^{
//        self.imageView.alpha = 1.0;
//    }];
//}

-(void)setRecordImagesArray:(NSArray *)recordImagesArray index:(int)index {
    [self.timer invalidate];
    self.index = index;
    self.image = [recordImagesArray objectAtIndex:self.index];
    [UIView animateWithDuration:7.0 animations:^{
            [self onTimer];
    }];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:7.0
                                                target:self
                                                selector:@selector(onTimer)
                                                userInfo:nil
                                                repeats:YES];
    
}

-(void)displayNextImage {
    self.imageView.image = self.image;
    self.index = (self.index + 1) % self.recordImages.count;
    NSLog(@"Current Image Index %d", self.index);
    self.image = [self.recordImages objectAtIndex:self.index];
}

-(void)backButtonPressed:(UIBarButtonItem *)sender {
    [self.timer invalidate];
    self.timer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onTimer {
    [self displayNextImage];
    
    [UIView animateWithDuration:5.0 animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.imageView.alpha = 0.5;
    }];
    
    [UIView animateWithDuration:2.0 animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.imageView.alpha = 1.0;
    }];
}



@end
