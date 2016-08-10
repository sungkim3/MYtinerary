//
//  PresentationCollectionViewCell.m
//  MYtinerary
//
//  Created by Olesia Kalashnik on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "PresentationCollectionViewCell.h"
@import Photos;

@interface PresentationCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) PHAsset *asset;
@property (strong, nonatomic) UIImage *image;



@end


@implementation PresentationCollectionViewCell


-(void)setAssetID:(NSString *)assetID {
    _assetID = assetID;
    [self getAssetForAssetID];
}

-(void)getAssetForAssetID {
    PHFetchResult *assetResults = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.assetID] options:nil];
    assert(assetResults.count == 1);
    [assetResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAsset class]]) {
            self.asset = obj;
        }
        if (idx == assetResults.count - 1) {
            PHImageManager *manager = [PHImageManager defaultManager];

            [manager requestImageForAsset:self.asset targetSize:self.imageView.intrinsicContentSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                self.imageView.image = result;
            }];
        }
    }];

    
}


@end
