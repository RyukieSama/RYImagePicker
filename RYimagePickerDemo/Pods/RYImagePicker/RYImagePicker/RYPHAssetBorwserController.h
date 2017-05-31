//
//  RYPHAssetBorwserController.h
//  BigFan
//
//  Created by RongqingWang on 16/10/13.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "RYPHAssetPlayController.h"
#import "RYGridCellModel.h"

@interface RYPHAssetBorwserController : UIPageViewController

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) RYGridCellModel *cellModel;
/**
 是否是点击预览按钮进行的预览操作
 */
@property (nonatomic, assign) BOOL isFromPreviewClick;

- (instancetype)initWithCellModels:(NSArray *)cellModels fromPreviewButton:(BOOL)isFromPreviewButton;

@end
