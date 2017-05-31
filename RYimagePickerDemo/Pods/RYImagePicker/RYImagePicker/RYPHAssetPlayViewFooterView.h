//
//  RYPHAssetPlayViewFooterView.h
//  BigFan
//
//  Created by RongqingWang on 16/10/13.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYImagePicker.h"

typedef void(^RYPlayFooterHandler)(id obj);

@interface RYPHAssetPlayViewFooterView : UIView

/**
 原图
 */
@property (nonatomic, strong) UIButton *btSee;
/**
 选择
 */
@property (nonatomic, strong) UIButton *btCommit;
/**
 当前序号
 */
@property (nonatomic, assign) NSInteger currentOrder;
/**
 当前序号 Label
 */
@property (nonatomic, strong) UILabel *lbCurrentOrder;

@property (nonatomic, copy) RYPlayFooterHandler handlerSee;
@property (nonatomic, copy) RYPlayFooterHandler handlerCommit;

@end
