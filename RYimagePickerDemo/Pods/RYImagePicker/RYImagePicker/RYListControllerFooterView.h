//
//  RYListControllerFooterView.h
//  BigFan
//
//  Created by RongqingWang on 16/10/14.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYImagePicker.h"

typedef void(^RYListFooterHandler)(id obj);

@interface RYListControllerFooterView : UIView

@property (nonatomic, strong) UIButton *btSee;
@property (nonatomic, copy) RYListFooterHandler handlerSee;

@end
