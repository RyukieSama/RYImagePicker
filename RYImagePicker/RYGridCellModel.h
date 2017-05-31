//
//  RYGridCellModel.h
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/10.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface RYGridCellModel : NSObject
/**
 *  对应的PHAsset
 */
@property (nonatomic, strong) PHAsset *asset;
/**
 *  是否被选中
 */
@property (nonatomic, assign) BOOL isSelected;
/**
 *  图片排序的序号
 */
@property (nonatomic, assign) NSInteger orderIndex;
/**
 *  对应的indexPath
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)resetStatus;

@end
