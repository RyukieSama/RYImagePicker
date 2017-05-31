//
//  RYAlbumsSelectCell.m
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/10/12.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYAlbumsSelectCell.h"
#import "Masonry.h"

@interface RYAlbumsSelectCell  ()

/**该相册的第一张图片缩略图*/
@property (nonatomic, strong) UIImageView *ivFirstImage;
/**相册名称*/
@property (nonatomic, strong) UILabel *lbAlbumTitle;
/** 图片数量 */
@property (nonatomic, strong) UILabel *lbCount;
/**选中状态的红点*/
@property (nonatomic, strong) UIButton *btRedPoint;

@end

@implementation RYAlbumsSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setUpUI];
    return self;
}

- (void)setUpUI {
    [self.contentView addSubview:self.ivFirstImage];
    [self.contentView addSubview:self.lbAlbumTitle];
    [self.contentView addSubview:self.lbCount];
    [self.contentView addSubview:self.btRedPoint];
    
    [self.ivFirstImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(66);
    }];
    [self.lbAlbumTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24);
        make.left.mas_equalTo(self.ivFirstImage.mas_right).offset(20);
        make.right.mas_lessThanOrEqualTo(self.btRedPoint.mas_left).offset(-12);
    }];
    [self.lbCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lbAlbumTitle.mas_left);
        make.top.mas_equalTo(self.lbAlbumTitle.mas_bottom).offset(4);
        make.width.mas_equalTo(self.lbAlbumTitle.mas_width);
    }];
    [self.btRedPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-24);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(16);
        make.centerY.mas_equalTo(0);
    }];
}

#pragma mark -  set
- (void)setIsCurrent:(BOOL)isCurrent {
    _isCurrent = isCurrent;
    self.btRedPoint.hidden = !isCurrent;
}

- (void)setTitle:(NSString *)title andCount:(NSInteger)count {
    self.lbAlbumTitle.text = title;
    if (count > 999) {
        self.lbCount.text = [NSString stringWithFormat:@"%ld,%ld",(long)count/1000,(long)count%1000];
    } else {
        self.lbCount.text = [NSString stringWithFormat:@"%ld",(long)count];
    }
}

- (void)setLastImage:(UIImage *)lasImage {
    self.ivFirstImage.image = lasImage;
}

#pragma mark - lazyInit 
- (UIImageView *)ivFirstImage {
    if (!_ivFirstImage) {
        _ivFirstImage = [[UIImageView alloc] init];
        _ivFirstImage.backgroundColor = [UIColor grayColor];
        _ivFirstImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _ivFirstImage;
}

- (UILabel *)lbAlbumTitle {
    if (!_lbAlbumTitle) {
        _lbAlbumTitle = [[UILabel alloc] init];
        _lbAlbumTitle.text = @"";
        _lbAlbumTitle.font = [UIFont systemFontOfSize:17];
        _lbAlbumTitle.textColor = [UIColor blackColor];
    }
    return _lbAlbumTitle;
}

- (UILabel *)lbCount {
    if (!_lbCount) {
        _lbCount = [[UILabel alloc] init];
        _lbCount.font = [UIFont systemFontOfSize:12];
        _lbCount.textColor = [UIColor blackColor];
    }
    return _lbCount;
}

- (UIButton *)btRedPoint {
    if (!_btRedPoint) {
        _btRedPoint = [[UIButton alloc] init];
        [_btRedPoint setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_file_select"] forState:UIControlStateNormal];
    }
    return _btRedPoint;
}

@end
