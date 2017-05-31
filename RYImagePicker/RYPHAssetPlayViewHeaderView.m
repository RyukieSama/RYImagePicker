//
//  RYPHAssetPlayViewHeaderView.m
//  BigFan
//
//  Created by RongqingWang on 16/10/13.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import "RYPHAssetPlayViewHeaderView.h"

@interface RYPHAssetPlayViewHeaderView ()

@property (nonatomic, strong) UIButton *btBack;
/**
 确定按钮
 */
@property (nonatomic, strong) UIButton *btSelect;
@property (nonatomic, strong) UIView *vBackView;

@end

@implementation RYPHAssetPlayViewHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    
    self.backgroundColor = [UIColor clearColor];
    
    //返回按钮
    self.btBack = [[UIButton alloc] init];
    [self.btBack setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/title_icon_return"] forState:UIControlStateNormal];
    
    //确认按钮
    self.btSelect = [[UIButton alloc] init];
    [self.btSelect setTitle:@"确定" forState:UIControlStateNormal];
    [self.btSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btSelect setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateDisabled];
    
    //背景
    self.vBackView = [[UIView alloc] init];
    self.vBackView.backgroundColor = [UIColor blackColor];
    self.vBackView.alpha = 0.9f;
    
    //序号
    self.lbIndex = [[UILabel alloc] init];
    self.lbIndex.textColor = [UIColor whiteColor];
    self.lbIndex.textAlignment = NSTextAlignmentCenter;
    self.lbIndex.font = [UIFont systemFontOfSize:15];
    self.lbIndex.text = @" ";
    
    [self addSubview:self.vBackView];
    [self addSubview:self.btSelect];
    [self addSubview:self.btBack];
    [self addSubview:self.lbIndex];
    
    [self.vBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.btBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    [self.btSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-12);
    }];
    [self.lbIndex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    [self.btBack addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.btSelect addTarget:self action:@selector(selectClick) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

- (void)setIndex:(NSInteger)index countAll:(NSInteger)countAll countSelected:(NSInteger)countSelected {
    self.lbIndex.text = [NSString stringWithFormat:@"%ld/%ld",(long)index+1,(long)countAll];
    if (countSelected == 0) {
        [self.btSelect setTitle:@"确定" forState:UIControlStateNormal];
        self.btSelect.enabled = NO;
    } else {
        [self.btSelect setTitle:[NSString stringWithFormat:@"确定(%ld)",(long)countSelected] forState:UIControlStateNormal];
        self.btSelect.enabled = YES;
    }
}

- (void)backClick {
    if (self.handlerBack) {
        self.handlerBack(nil);
    }
}

- (void)selectClick {
    //发送点击完成按钮的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kRYImagePickerDoneClick object:self userInfo:nil];
    if (self.handlerSelect) {
        self.handlerSelect(nil);
    }
}

@end
