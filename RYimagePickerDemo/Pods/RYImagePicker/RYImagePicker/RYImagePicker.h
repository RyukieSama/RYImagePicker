//
//  RYImagePicker.h
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "RYImagePicker.h"
#import "RYImagePickerController.h"
#import "RYAlbumListController.h"
#import "RYGridCell.h"
#import "RYGridCellModel.h"
#import "RYPHAssetCacheHelper.h"
#import <Masonry/Masonry.h>

/**
 完成的回调中的 info 字段_用户是否指定需要原图 1: 用户选择需要原图
 */
#define RY_ORIGINAL_IMAGE_NEEDED @"RY_ORIGINAL_IMAGE_NEEDED"

/**
 选择图片完成的回调
 
 @param selectedImages 已经选择的图片_用来展示的 100x100 的缩略图
 @param selectedAssets 已经选择的图片_PHAsset对象
 @param info           一些配置项
 */
typedef void(^finishedPickImageRY)(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info);
/**
 点击取消的回调  默认 dismiss   这里添加的回调会在dismiss之前执行
 */
typedef void(^canceledPickImageRY)();

@interface RYImagePicker : NSObject

+ (instancetype)sharedInstance;
/**
 *  使用Manager 在当前控制器下 Present 出图片选择控制器
 *
 *  @param finished 点击完成的回调    先dismiss   再执行回调    强烈建议不要在这个回调中  将PHAsset转换成图片  否则可能会造成主线程卡顿  在上传的时候再转换图片  需要使用缩略图的可以使用回调中的缩略图
 *  @param canceled 点击取消的回调
 */
- (void)presentImagePickerControllerWithFinishedHandler:(finishedPickImageRY)finished cancelHandler:(canceledPickImageRY)canceled;

- (void)presentImagePickerControllerWithFinishedHandler:(finishedPickImageRY)finished cancelHandler:(canceledPickImageRY)canceled from:(UIViewController *)vc;
/**
 最大可选图片数量  默认9张   设置为0 的话也是9张
 */
@property (nonatomic, assign) NSInteger maxSelectedNumber;
/**
 超过最大限制后的提示文案   默认文案 : "选择图片不能超过XXOO张"
 */
@property (nonatomic, copy) NSString *overMaxInfo;
/**
 是否显示iCloud相册   默认NO 不显示
 */
@property (nonatomic, assign) BOOL showiCloud;
/**
 仅显示视频资源   默认 NO 只显示图片
 */
@property (nonatomic, assign) BOOL videoOnly;
/**
 是否显示  "原图" 按钮    默认YES   显示原图按钮
 */
@property (nonatomic, assign) BOOL isShowOriginalImageButton;
/**
 点击完成按钮的回调
 */
@property (nonatomic, copy) finishedPickImageRY finishedCallBack;
/**
 点击取消按钮的回调   默认执行dismiss操作
 */
@property (nonatomic, copy) canceledPickImageRY canceledCallBack;
/**
 弹出的图片选择导航控制器
 */
@property (nonatomic, strong) RYImagePickerController *pickerController;
/**
 缩略图缓存器
 */
@property (nonatomic, strong) RYPHAssetCacheHelper *imageCacheHelper;
/**
 视频最大分辨率
 */
@property (nonatomic, assign) NSInteger maxVideoHeight;
/**
 选择的视频大于最大分辨率时的操作如HUD等
 */
@property (nonatomic, copy) canceledPickImageRY maxVideoHeightHud;
/**
 最大视频大小  如 1024*1024*20   20M
 */
@property (nonatomic, assign) NSInteger maxVideoSize;
/**
 选择的视频大于最大尺寸时的操作如HUD等
 */
@property (nonatomic, copy) canceledPickImageRY maxVideoSizeHud;










#pragma mark -
/**
 是否指定原图
 */
@property (nonatomic, assign) BOOL isShowOrImageSize;
/**
 默认NO  当最大选择张数为1时 自动设为YES  是否在单选情况下直接切换选中的图片  而不弹窗提示  不能超过1张
 */
@property (nonatomic, assign) BOOL isSingleSelect;
/**
 已选择的CellModel对象数组
 */
@property (nonatomic, strong) NSMutableArray *selectedCellModelArr;
/**
 当前展示的相册的图片数量
 */
@property (nonatomic, assign) NSInteger currentAlbumImageCount;

/**
 将选中的cellModel重新排序
 */
- (void)reorderCellModelArr;

- (void)resetManager;

#pragma mark - Notification
/** 点击确认按钮的通知 */
#define kRYImagePickerDoneClick @"kRYImagePickerDoneClick"
/** 图片预览界面单击 */
#define kRYImagePickerOneClick @"kRYImagePickerOneClick"
/** DidDimiss的通知 */
#define kRYImagePickerVCDidDimissed @"kRYImagePickerVCDidDimissed"

#pragma mark - others
#define RY_CELLIMAGESIZE CGSizeMake(150, 150)

@end
