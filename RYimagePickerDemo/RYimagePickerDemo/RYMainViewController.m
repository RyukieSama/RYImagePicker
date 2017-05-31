//
//  RYMainViewController.m
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYMainViewController.h"
#import <Masonry.h>
#import "RYImagePicker.h"

static NSString *cellId = @"cellId";

@interface RYMainViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tvDemoList;
@property (nonatomic, strong) NSArray *demoList;

@end

@implementation RYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self setUpUI];
}

- (void)setUpUI {
    [self.view addSubview:self.tvDemoList];
    
    [self.tvDemoList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - lazyInit
- (UITableView *)tvDemoList {
    if (!_tvDemoList) {
        _tvDemoList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvDemoList.delegate = self;
        _tvDemoList.dataSource = self;
        [_tvDemoList registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    }
    return _tvDemoList;
}

- (NSArray *)demoList {
    return @[
             @"选择视频(1个)",
             @"选择图片(9张)",
             @"选择图片(1张)",
             @"显示原图按钮",
             @"自定义最大张数提示语"
             ];
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = self.demoList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {//选择一个视频
            RYImagePicker *picker = [RYImagePicker sharedInstance];
            picker.videoOnly = YES;
            picker.maxSelectedNumber = 1;
            picker.isShowOriginalImageButton = YES;
            [picker presentImagePickerControllerWithFinishedHandler:^(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info) {
                NSLog(@"selectedImages = %@",selectedImages);
                NSLog(@"selectedAssets =  %@",selectedAssets);
            } cancelHandler:^{
                
            }];
        }
            break;
        case 1: {//选择9张图片
            RYImagePicker *picker = [RYImagePicker sharedInstance];
            picker.maxSelectedNumber = 0;
            [picker presentImagePickerControllerWithFinishedHandler:^(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info) {
                NSLog(@"selectedImages = %@",selectedImages);
                NSLog(@"selectedAssets =  %@",selectedAssets);
            } cancelHandler:^{
                
            }];
        }
            break;
        case 2: {//单张图片选择
            RYImagePicker *picker = [RYImagePicker sharedInstance];
            picker.maxSelectedNumber = 1;
            [picker presentImagePickerControllerWithFinishedHandler:^(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info) {
                NSLog(@"selectedImages = %@",selectedImages);
                NSLog(@"selectedAssets =  %@",selectedAssets);
            } cancelHandler:^{
                
            }];
        }
            break;
        case 3: {//显示原图按钮
            RYImagePicker *picker = [RYImagePicker sharedInstance];
            picker.maxSelectedNumber = 1;
            picker.isShowOriginalImageButton = YES;
            [picker presentImagePickerControllerWithFinishedHandler:^(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info) {
                NSLog(@"selectedImages = %@",selectedImages);
                NSLog(@"selectedAssets =  %@",selectedAssets);
            } cancelHandler:^{
                
            }];
        }
            break;
        case 4: {//自定义最大张数提示语
            RYImagePicker *picker = [RYImagePicker sharedInstance];
            picker.maxSelectedNumber = 0;
            picker.overMaxInfo = @"哈哈哈哈哈哈哈哈最多9张哦";
            [picker presentImagePickerControllerWithFinishedHandler:^(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info) {
                NSLog(@"selectedImages = %@",selectedImages);
                NSLog(@"selectedAssets =  %@",selectedAssets);
            } cancelHandler:^{
                
            }];
        }
            break;
        default:
            break;
    }
}

@end
