//
//  RYPHAssetCacheHelper.m
//  BigFan
//
//  Created by RongqingWang on 16/10/24.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import "RYPHAssetCacheHelper.h"

@interface RYPHAssetCacheHelper ()

//用来存放缩略图的缓存池
@property (nonatomic, strong) NSMutableDictionary *cachePool;

@end

@implementation RYPHAssetCacheHelper

- (NSMutableDictionary *)cachePool {
    if (!_cachePool) {
        _cachePool = [[NSMutableDictionary alloc] init];
    }
    return _cachePool;
}

- (void)cacheImage:(UIImage *)image forPHAsset:(PHAsset *)asset {
    //localIdentifier  作为Key
    if (image) {
        [self.cachePool setObject:image forKey:asset.localIdentifier];
    }
}

- (void)removeCacheForPHAsset:(PHAsset *)asset {
    if ([self.cachePool objectForKey:asset.localIdentifier]) {
        [self.cachePool removeObjectForKey:asset.localIdentifier];
    }
}

- (BOOL)checkPHAsset:(PHAsset *)asset {
    return [self.cachePool objectForKey:asset.localIdentifier] ? YES : NO ;
}

- (UIImage *)getImageForPHAsset:(PHAsset *)asset {
    UIImage *image = [self.cachePool objectForKey:asset.localIdentifier];
    NSLog(@"图片来自缓存 localIdentifier = %@ \n %@",asset.localIdentifier,image);
    return image;
}

- (void)removeAllCaches {
    NSLog(@"清空了相册图片缓存 %s",__FUNCTION__);
    self.cachePool = nil;
}

@end
