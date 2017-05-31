//
//  RYGridCell.h
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "RYImagePicker.h"

@class RYGridCellModel,RYGridCell;

@protocol RYGridCellDelegate <NSObject>
/**
 *  点击选择按钮的代理事件
 */
- (void)gridCellClickBtSelect:(RYGridCellModel *)cellModel cell:(RYGridCell *)cell;
/**
 *  点击图片的代理事件
 */
- (void)gridCellClickBtImage:(RYGridCellModel *)cellModel;

@end

@interface RYGridCell : UICollectionViewCell

/**
 *  对应的PHAsset
 */
@property (nonatomic, strong) PHAsset *asset;
/**
 *  缩略图片按钮
 */
@property (nonatomic, strong) UIButton *bt_image;
/**
 *  选择按钮
 */
@property (nonatomic, strong) UIButton *bt_select;
/**
 *  cellModel
 */
@property (nonatomic, strong) RYGridCellModel *cellModel;
/**
 PHAsset 对应标识
 */
@property (nonatomic, copy) NSString *representedAssetIdentifier;
/**
 *  该cell的indexPath
 */
@property (nonatomic, strong) NSIndexPath *cellIndexPath;
/**
 *  cell的代理
 */
@property (nonatomic, weak) id<RYGridCellDelegate> delegate;

@end
