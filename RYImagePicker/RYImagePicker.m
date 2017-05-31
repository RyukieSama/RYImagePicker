//
//  RYImagePicker.m
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYImagePicker.h"

@interface RYImagePicker ()

@end

@implementation RYImagePicker

+ (instancetype)sharedInstance {
    static RYImagePicker *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RYImagePicker alloc] init];
        instance.maxSelectedNumber = 9;
    });
    return instance;
}

- (void)setMaxSelectedNumber:(NSInteger)maxSelectedNumber {
    _maxSelectedNumber = (maxSelectedNumber > 0) ? maxSelectedNumber : 9;
    self.isSingleSelect = (maxSelectedNumber == 1) ? YES : NO;
}

#pragma mark - present
- (void)presentImagePickerControllerWithFinishedHandler:(finishedPickImageRY)finished cancelHandler:(canceledPickImageRY)canceled from:(UIViewController *)vc {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined: {//未确定 申请
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                switch (status) {
                    case PHAuthorizationStatusAuthorized: {
                        break;
                    }
                    default: {
                        return;
                        break;
                    }
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            //弹窗提示
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在iPhone的“设置—隐私—照片”选项中，允许访问你的照片" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *actionCommit = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alertC addAction:actionCancle];
            [alertC addAction:actionCommit];
            [[self getAppTopVieController] presentViewController:alertC animated:YES completion:^{
            }];
            return;
            break;
        }
        case PHAuthorizationStatusAuthorized://允许了
        default: {
            break;
        }
    }
    
    _finishedCallBack = finished;
    _canceledCallBack = canceled;
    
    if (vc) {
        [vc presentViewController:self.pickerController animated:YES completion:^{
            
        }];
    } else {
        UIViewController *vcT = [self getAppTopVieController];
        [vcT presentViewController:self.pickerController animated:YES completion:nil];
    }
    
    [self addNotificationOb];
}

- (void)presentImagePickerControllerWithFinishedHandler:(finishedPickImageRY)finished cancelHandler:(canceledPickImageRY)canceled {
    [self presentImagePickerControllerWithFinishedHandler:finished cancelHandler:canceled from:nil];
}

#pragma mark - functions
- (void)reorderCellModelArr {
    NSInteger order = 0;
    for (RYGridCellModel *obj in self.selectedCellModelArr) {
        obj.orderIndex = order;
        order++;
    }
}

- (void)addNotificationOb {
    //监听点击完成按钮的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneClick) name:kRYImagePickerVCDidDimissed object:nil];
}

- (void)removeNotificationOb {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIViewController *)getAppTopVieController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return tabBarController.selectedViewController;
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return navigationController.visibleViewController;
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return presentedViewController.presentedViewController;
    } else {
        return rootViewController;
    }
}

#pragma mark - action
- (void)doneClick {
    NSLog(@"点击完成");
    if (self.finishedCallBack && self.selectedCellModelArr.count > 0) {
        NSMutableArray *imagesSmall = [NSMutableArray array];
        NSMutableArray *phassetArr = [NSMutableArray array];
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES; //必要时从icould下载
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        
        for (RYGridCell *obj in self.selectedCellModelArr) {
            [phassetArr addObject:(obj.asset ?: [PHAsset new])];
            [[PHImageManager defaultManager] requestImageForAsset:obj.asset
                                                       targetSize:CGSizeMake(100,100)
                                                      contentMode:PHImageContentModeAspectFill
                                                          options:options
                                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                        if (result) {
                                                            [imagesSmall addObject:result];
                                                        }
                                                    }];
        }
        
        NSDictionary *info = @{
                               RY_ORIGINAL_IMAGE_NEEDED : @(self.isShowOrImageSize)
                               };
        self.finishedCallBack(imagesSmall.copy,phassetArr.copy,info);
    }
    [self resetManager];
}

#pragma mark - lazyInit
- (RYImagePickerController *)pickerController {
    if (_pickerController == nil) {
        RYAlbumListController *vc = [[RYAlbumListController alloc] init];
        
        //设置相关配置参数
        vc.maxSelectedNumber = self.maxSelectedNumber;//最大数量
        vc.overMaxInfo = self.overMaxInfo;//超过最大选择时的提示语
        vc.iCloudEnable = self.showiCloud;//是否支持iCloud
        
        if (self.videoOnly) {
            vc.videoOnly = YES;
            vc.imageOnly = NO;
        } else {
            vc.videoOnly = NO;
            vc.imageOnly = YES;
        }
        _pickerController = [[RYImagePickerController alloc] initWithRootViewController:vc];
    }
    return  _pickerController;
}

- (NSMutableArray *)selectedCellModelArr {
    if (!_selectedCellModelArr) {
        _selectedCellModelArr = [NSMutableArray array];
    }
    return _selectedCellModelArr;
}

- (RYPHAssetCacheHelper *)imageCacheHelper {
    if (!_imageCacheHelper) {
        _imageCacheHelper = [[RYPHAssetCacheHelper alloc] init];
    }
    return _imageCacheHelper;
}

- (void)resetManager {
    //店家完成回调
    _finishedCallBack = nil;
    //点击取消的回调
    _canceledCallBack = nil;
    //VC
    _pickerController = nil;
    //超出显示的自定义提示文字
    _overMaxInfo = nil;
    //选中的cellModel数组
    _selectedCellModelArr = nil;
    //缩略图缓存器
    _imageCacheHelper = nil;
    //恢复不显示视频资源
    _videoOnly = NO;
    //恢复不显示原图大小
    _isShowOrImageSize = NO;
    //当前展示的相册的资源个数
    _currentAlbumImageCount = 0;
    //重置最大张数
    _maxSelectedNumber = 9;
    NSLog(@"==RYImagePicker reseted!==");
    //移除通知监听
    [self removeNotificationOb];
}

@end
