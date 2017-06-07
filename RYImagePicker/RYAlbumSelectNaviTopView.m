//
//  RYAlbumSelectNaviTopView.m
//  RYImagePicker
//
//  Created by RongqingWang on 16/10/12.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYAlbumSelectNaviTopView.h"
#import "Masonry.h"

@interface  RYAlbumSelectNaviTopView ()

/**title按钮*/
@property (nonatomic, strong) UIButton *btTitlte;
/**箭头*/
@property (nonatomic, strong) UIImageView *ivArrow;

@end

@implementation RYAlbumSelectNaviTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setUpUI];
    return self;
}

- (void)setUpUI {
    [self addSubview:self.btTitlte];
    [self.btTitlte addSubview:self.ivArrow];
    
    [self.btTitlte mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    [self.ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.btTitlte.mas_right);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(4);
    }];
}

#pragma mark - set
- (void)setTitle:(NSString *)title {
    _title = title;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.btTitlte setTitle:[NSString stringWithFormat:@"    %@    ",title] forState:UIControlStateNormal];
    });
}

- (void)setIsShowed:(BOOL)isShowed {
    _isShowed = isShowed;
    if (isShowed) {
        self.ivArrow.image = [UIImage imageNamed:@"RYPhotosPickerManager.bundle/icon_arrow_up_gray"];
    } else {
        self.ivArrow.image = [UIImage imageNamed:@"RYPhotosPickerManager.bundle/icon_arrow_down_gray"];
    }
}

#pragma mark - acrion
- (void)titleClick {
    if (self.handlerTitleClick) {
        self.handlerTitleClick(nil);
    }
}

#pragma mark - lazyInit
-(UIButton *)btTitlte {
    if (!_btTitlte) {
        _btTitlte = [[UIButton alloc] init];
        _btTitlte.titleLabel.font = [UIFont systemFontOfSize:16];
        [_btTitlte setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btTitlte setTitle:@" " forState:UIControlStateNormal];
        [_btTitlte addTarget:self action:@selector(titleClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btTitlte;
}

- (UIImageView *)ivArrow {
    if (!_ivArrow) {
        _ivArrow = [[UIImageView alloc] init];
        _ivArrow.image = [UIImage imageNamed:@"RYPhotosPickerManager.bundle/icon_arrow_down_gray"];
    }
    return _ivArrow;
}

@end
