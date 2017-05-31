//
//  RYListControllerFooterView.h
//  BigFan
//
//  Created by RongqingWang on 16/10/14.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import "RYListControllerFooterView.h"
#import "RYImagePickerUIConfig.h"

@interface RYListControllerFooterView ()

@property (nonatomic, strong) UIView *vBackView;

@end

@implementation RYListControllerFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50 - 64, [UIScreen mainScreen].bounds.size.width, 50)];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.vBackView = [[UIView alloc] init];
    self.vBackView.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [RYImagePickerUIConfig colorWithHexString:@"e8e8e8"];
    
    self.btSee = [[UIButton alloc] init];
    self.btSee.titleLabel.font = [UIFont systemFontOfSize:16];
    self.btSee.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.btSee setTitleColor:[UIColor colorWithRed:0.178 green:0.179 blue:0.217 alpha:1] forState:UIControlStateNormal];
    [self.btSee setTitle:@"预览" forState:UIControlStateNormal];
    [self.btSee addTarget:self action:@selector(seeClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.vBackView];
    [self addSubview:self.btSee];
    [self addSubview:line];
    
    self.vBackView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70);
    [self.btSee mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-12);
        make.width.mas_equalTo(200);
    }];
    [self.btSee.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.btSee.mas_right);
    }];
    
    return self;
}

//点击预览
- (void)seeClick {
    if (self.handlerSee) {
        self.handlerSee(nil);
    }
}

@end
