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

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)playButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextField *commentsTextField;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) NSMutableArray *recordImages;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int index;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic)UIImageView *currentImageView;
@property (strong, nonatomic)UIImageView *nextImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@property (strong, nonatomic)Record *currentRecord;



@end

@implementation PresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.currentImageView = self.imageView;
    self.nextImageView = self.imageView2;
    
    [self getImagesWith:^(NSArray *images) {
        [self setRecordImagesArray:images index:0];
    }];
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:self.tapGesture];
    
    [self prefersStatusBarHidden];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self backButtonPressed];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)handleTap:(UITapGestureRecognizer *)sender {
    [self.timer invalidate];
    self.timer = nil;
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    self.navigationController.toolbarHidden = !self.navigationController.toolbarHidden;
    NSLog(@"Image clicked index: %d", self.index);
    
}

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender {
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    self.navigationController.toolbarHidden = !self.navigationController.toolbarHidden;
    [self setRecordImagesArray:self.recordImages index:0];
}

- (IBAction)playButtonPressed:(UIBarButtonItem *)sender {
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    self.navigationController.toolbarHidden = !self.navigationController.toolbarHidden;
    
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

-(void)setRecordImagesArray:(NSArray *)recordImagesArray index:(int)index {
    [self.timer invalidate];
    self.index = index;
    
    [self displayNextImage];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:7.0
                                                  target:self
                                                selector:@selector(displayNextImage)
                                                userInfo:nil
                                                 repeats:YES];
    
}

-(void)displayNextImage {
    self.currentRecord = [self.records objectAtIndex:self.index];
    self.commentsTextField.text = self.currentRecord.comments;

    self.currentImageView.image = [self.recordImages objectAtIndex:self.index];
    self.index = (self.index + 1) % self.recordImages.count;
    self.nextImageView.image = [self.recordImages objectAtIndex:self.index];
    
    [UIView animateWithDuration:7.0 animations:^{
        self.currentImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.currentImageView.alpha = 0.0;
        self.nextImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.nextImageView.alpha = 1.0;
        
    }];
    
    UIImageView *tempView = self.currentImageView;
    self.currentImageView = self.nextImageView;
    self.nextImageView = tempView;
}

-(void)backButtonPressed {
    [self.timer invalidate];
    self.timer = nil;
}


@end
