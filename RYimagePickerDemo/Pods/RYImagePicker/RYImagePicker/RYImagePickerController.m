//
//  RYImagePickerController.m
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYImagePickerController.h"
#import "RYImagePicker.h"

@interface RYImagePickerController ()

@end

@implementation RYImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)setUpUI {
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.translucent = NO;
}

- (void)dealloc {
    NSLog(@"- [%@ dealloc]",[self class]);
}

@end
