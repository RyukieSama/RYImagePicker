//
//  RYGridCell.m
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYGridCell.h"
#import "Masonry.h"
#import "RYGridCellModel.h"

@interface RYGridCell ()

/**
 在图片选择页面已经选择但未点击完成确定的PHAsset 可以实现自定义图片排序
 */
@property (nonatomic, strong) NSArray *tempSelectedAssets;
/**
 大号的区域  原来的区域太小了
 */
@property (nonatomic, strong) UIButton *btBackBigSelect;
@property (nonatomic, strong) UIView *vVideoFooter;
@property (nonatomic, strong) UIImageView *ivVideo;
@property (nonatomic, strong) UILabel *lbTime;

@end

@implementation RYGridCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setupCell];
    return self;
}

- (void)setupCell {
    [self.contentView addSubview:self.bt_image];
    [self.contentView addSubview:self.btBackBigSelect];
    [self.btBackBigSelect addSubview:self.bt_select];
    
    if (![RYImagePicker sharedInstance].videoOnly) {
        [self.btBackBigSelect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.mas_equalTo(0);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(40);
        }];
    }
    else {
        [self.btBackBigSelect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    
    [self.bt_select mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(4);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-4);
        make.width.mas_equalTo(23);
        make.height.mas_equalTo(23);
    }];
    
    [self.btBackBigSelect addTarget:self action:@selector(bt_selectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bt_select addTarget:self action:@selector(bt_selectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bt_image addTarget:self action:@selector(bt_imageClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - data
- (void)setCellModel:(RYGridCellModel *)cellModel {
    _cellModel = cellModel;
    
    if (!cellModel.isSelected) {
        [_bt_select setBackgroundImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_default"] forState:UIControlStateNormal];
    } else {
        [_bt_select setBackgroundImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_select"] forState:UIControlStateNormal];
    }
    
    PHAsset *asset = _cellModel.asset;
    __weak typeof(self) weakSelf = self;
    
    [self checkVideo:cellModel];
    
    //设置顺序序号
    if (cellModel.isSelected) {
        [self.bt_select setTitle:[NSString stringWithFormat:@"%ld",(long)cellModel.orderIndex + 1] forState:UIControlStateNormal];
    } else {
        [self.bt_select setTitle:@"" forState:UIControlStateNormal];
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES; //必要时从icould下载
    
    if ([[RYImagePicker sharedInstance].imageCacheHelper checkPHAsset:asset]) {//已经存在
        UIImage *image = [[RYImagePicker sharedInstance].imageCacheHelper getImageForPHAsset:asset];
        [self.bt_image setImage:image forState:UIControlStateNormal];
    } else {
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:RY_CELLIMAGESIZE//太奇葩了...  之前设置的100 * 100的大小有时候会转换图片失败 解决办法最后一条  http://stackoverflow.com/questions/31037859/phimagemanager-requestimageforasset-returns-nil-sometimes-for-icloud-photos
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    NSLog(@"%@",info);
                                                    NSLog(@"localIdentifier = %@",asset.localIdentifier);
                                                    if (!result) {
                                                        NSLog(@"Do something with the regraded image    result空");
                                                        [self.bt_image setImage:nil forState:UIControlStateNormal];
                                                    } else {
                                                        __weak typeof(weakSelf) wweakSelf = weakSelf;
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [[RYImagePicker sharedInstance].imageCacheHelper cacheImage:result forPHAsset:asset];
                                                            // Set the cell's thumbnail image if it's still showing the same asset.  防止复用造成显示照片不对的问题
                                                            if ([wweakSelf.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                                [wweakSelf.bt_image setImage:result forState:UIControlStateNormal];
                                                            }
                                                            NSLog(@"Do something with the regraded image   转化出图片");
                                                        });
                                                    }
                                                }];
    }
    
}

- (void)checkVideo:(RYGridCellModel *)cellModel {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.vVideoFooter removeFromSuperview];
        if (cellModel.asset.mediaType == PHAssetMediaTypeVideo) {
            [weakSelf.contentView addSubview:weakSelf.vVideoFooter];
            [weakSelf.vVideoFooter mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.height.mas_equalTo(18);
            }];
        }
        
        NSInteger min = (cellModel.asset.duration/60);
        NSInteger sec = (NSInteger)(cellModel.asset.duration) % 60;
        self.lbTime.text = [NSString stringWithFormat:@"%ld:%02ld",(long)min,(long)sec];
        
    });
}

#pragma mark - Action
- (void)bt_selectClick {
    if ([self.delegate respondsToSelector:@selector(gridCellClickBtSelect:cell:)]) {
        [self.delegate gridCellClickBtSelect:self.cellModel cell:self];
    }
}

- (void)bt_imageClick {
    if ([self.delegate respondsToSelector:@selector(gridCellClickBtImage:)]) {
        [self.delegate gridCellClickBtImage:self.cellModel];
    }
}

#pragma mark - lazy
- (UIButton *)bt_image {
    if (!_bt_image) {
        _bt_image = [[UIButton alloc] initWithFrame:CGRectMake(1, 1, self.frame.size.width-2, self.frame.size.height-2)];
        _bt_image.backgroundColor = [UIColor whiteColor];
        _bt_image.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bt_image;
}

- (UIButton *)btBackBigSelect {
    if (!_btBackBigSelect) {
        _btBackBigSelect = [[UIButton alloc] init];
        [_btBackBigSelect setBackgroundColor:[UIColor clearColor]];
    }
    return _btBackBigSelect;
}

- (UIButton *)bt_select {
    if (!_bt_select) {
        _bt_select = [[UIButton alloc] init];
        _bt_select.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_bt_select setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bt_select setBackgroundImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_default"] forState:UIControlStateNormal];
    }
    return _bt_select;
}

- (UIView *)vVideoFooter {
    if (!_vVideoFooter) {
        _vVideoFooter = [[UIView alloc] init];
        _vVideoFooter.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
        
        [_vVideoFooter addSubview:self.ivVideo];
        [self.ivVideo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(6);
        }];
        
        [_vVideoFooter addSubview:self.lbTime];
        [self.lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-6);
            make.centerY.mas_equalTo(_vVideoFooter.mas_centerY);
        }];
    }
    return _vVideoFooter;
}

- (UIImageView *)ivVideo {
    if (!_ivVideo) {
        _ivVideo = [[UIImageView alloc] init];
        _ivVideo.image = [UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_icon_video"];
    }
    return _ivVideo;
}

- (UILabel *)lbTime {
    if (!_lbTime) {
        _lbTime = [[UILabel alloc] init];
        _lbTime.backgroundColor = [UIColor clearColor];
        _lbTime.font = [UIFont systemFontOfSize:10];
        _lbTime.textColor = [UIColor whiteColor];
    }
    return _lbTime;
}

@end
