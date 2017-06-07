//
//  RYAlbumsSelectView.m
//  RYImagePicker
//
//  Created by RongqingWang on 16/10/12.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYAlbumsSelectView.h"
#import "RYAlbumsSelectCell.h"
#import "Masonry.h"
#import "RYImagePicker.h"

static NSString *cellID = @"cellID";

@interface RYAlbumsSelectView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tvAlbumsTableView;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation RYAlbumsSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setUpUI];
    return self;
}

- (void)setUpUI {
    [self addSubview:self.tvAlbumsTableView];
    
    [self.tvAlbumsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - set
- (void)setFetchResults:(PHFetchResult *)fetchResults {
    _fetchResults = fetchResults;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tvAlbumsTableView reloadData];
    });
}

#pragma mark - action
- (NSInteger)getAssetsFromFetchResults:(PHCollection *)collcetion {
    if (![collcetion isKindOfClass:[PHAssetCollection class]]) {
        return 0;
    }
    PHAssetCollection *assetCollection = (PHAssetCollection *)collcetion;
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
    return assetsFetchResult.count;
}

#pragma mark - lazyInit
-(UITableView *)tvAlbumsTableView {
    if (!_tvAlbumsTableView) {
        _tvAlbumsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvAlbumsTableView.delegate = self;
        _tvAlbumsTableView.dataSource = self;
        [_tvAlbumsTableView registerClass:[RYAlbumsSelectCell class] forCellReuseIdentifier:cellID];
    }
    return _tvAlbumsTableView;
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RYAlbumsSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    PHCollection *collection = self.fetchResults[indexPath.row];
    
    //设置最近一张图片
    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
    PHAsset *lastPHAsset = [assetsFetchResult lastObject];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES; //必要时从icould下载
    [[PHImageManager defaultManager] requestImageForAsset:lastPHAsset
                                               targetSize:RY_CELLIMAGESIZE
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                [cell setLastImage:result ?: [UIImage new]];
    }];
    
    //设置数量   名称
    NSInteger count = [self getAssetsFromFetchResults:collection];
    [cell setTitle:[collection localizedTitle] andCount:count];
    
    if (self.selectedIndex == indexPath.row) {
        cell.isCurrent = YES;
    } else {
        cell.isCurrent = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.handlerSelect) {
        self.handlerSelect(@(indexPath.row));
        self.selectedIndex = indexPath.row;
        [self.tvAlbumsTableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

#pragma mark - cell分割线全尺寸
- (void)viewDidLayoutSubviews {
    if ([self.tvAlbumsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tvAlbumsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tvAlbumsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tvAlbumsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

@end
