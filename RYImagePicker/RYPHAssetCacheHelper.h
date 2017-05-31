//
//  RYPHAssetCacheHelper.h
//  BigFan
//
//  Created by RongqingWang on 16/10/24.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface RYPHAssetCacheHelper : NSObject

/**
 添加对应PHAsset的缩略图缓存

 @param asset 需要缓存缩略图的PHAsset
 */
- (void)cacheImage:(UIImage *)image forPHAsset:(PHAsset *)asset;
/**
 删除对应PHAsset的缩略图缓存
 
 @param asset 需要删除缓存缩略图的PHAsset
 */
- (void)removeCacheForPHAsset:(PHAsset *)asset;
/**
 检查是否存在指定PHAsset 缩略图缓存

 @param asset PHAsset

 @return YES 已经存在了    NO 还未存在
 */
- (BOOL)checkPHAsset:(PHAsset *)asset;
/**
 获取缓存的图片

 @param asset 对应的PHAsset
 */
- (UIImage *)getImageForPHAsset:(PHAsset *)asset;
/**
 移除所有缓存
 */
- (void)removeAllCaches;

@end
