//
//  RYPHAssetPlayViewFooterView.m
//  BigFan
//
//  Created by RongqingWang on 16/10/13.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import "RYPHAssetPlayViewFooterView.h"

@interface RYPHAssetPlayViewFooterView ()

@property (nonatomic, strong) UIView *vBackView;

@end

@implementation RYPHAssetPlayViewFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width, 64)];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.vBackView = [[UIView alloc] init];
    self.vBackView.backgroundColor = [UIColor blackColor];
    self.vBackView.alpha = 0.9f;
    
    self.btSee = [[UIButton alloc] init];
    self.btSee.titleLabel.font = [UIFont systemFontOfSize:13];
    self.btSee.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.btSee setTitleColor:[UIColor colorWithWhite:0.4 alpha:1.f] forState:UIControlStateNormal];
    [self.btSee setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_original_default"] forState:UIControlStateNormal];
    [self.btSee setTitle:@"  原图" forState:UIControlStateNormal];
    [self.btSee addTarget:self action:@selector(seeClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.btCommit = [[UIButton alloc] init];
    self.btCommit.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.btCommit setTitleColor:[UIColor colorWithWhite:0.4 alpha:1.f] forState:UIControlStateNormal];
    [self.btCommit setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_original_default"] forState:UIControlStateNormal];
    [self.btCommit setTitle:@"  选择" forState:UIControlStateNormal];
    [self.btCommit addTarget:self action:@selector(commitClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.lbCurrentOrder = [[UILabel alloc] init];
    self.lbCurrentOrder.textColor = [UIColor whiteColor];
    self.lbCurrentOrder.textAlignment = NSTextAlignmentCenter;
    self.lbCurrentOrder.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:self.vBackView];
    [self addSubview:self.btSee];
    [self addSubview:self.btCommit];
    [self.btCommit.imageView addSubview:self.lbCurrentOrder];
    
    [self.vBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.btSee mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(150);
    }];
    [self.btSee.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    [self.btSee.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.btSee.imageView.mas_right);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.btCommit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-12);
    }];
    [self.lbCurrentOrder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    return self;
}

//点击原图
- (void)seeClick {
    if (self.handlerSee) {
        self.handlerSee(nil);
    }
}

//点击选择
- (void)commitClick {
    if (self.handlerCommit) {
        self.handlerCommit(nil);
    }
}

@end
