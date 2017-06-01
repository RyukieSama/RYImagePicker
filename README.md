# RYImagePicker

## 导入:
`pod 'RYImagePicker'`

## 照片选择器  
支持`图片` `视频`选择
![](http://ohfpqyfi7.bkt.clouddn.com/14963080079150.png)

![](http://ohfpqyfi7.bkt.clouddn.com/14963079957246.png)


## 配置:
``` swift
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
 是否显示  "原图" 按钮    默认NO   不显示原图按钮
 */
@property (nonatomic, assign) BOOL isShowOriginalImageButton;
```

## 方法:
``` swift
+ (instancetype)sharedInstance;
/**
 *  使用Manager 在当前控制器下 Present 出图片选择控制器
 *
 *  @param finished 点击完成的回调 传回选取的UIImage原图数组
 *  @param canceled 点击取消的回调
 */
- (void)presentImagePickerControllerWithFinishedHandler:(finishedPickImageRY)finished cancelHandler:(canceledPickImageRY)canceled;

/**
 选择图片完成的回调

 @param selectedImages 已经选择的图片_用来展示的 100x100 的缩略图
 @param selectedAssets 已经选择的图片_PHAsset对象
 @param info           一些配置项
 */
typedef void(^finishedPickImageRY)(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info);
```

## 回调说明:
``` swift
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

```

## 使用:
``` swift
RYImagePickerManager *imanager = [RYImagePickerManager sharedInstance];
imanager.maxSelectedNumber = self.maxImagesCount;
[imanager presentImagePickerControllerWithFinishedHandler:^(NSArray *selectedImages,NSArray *selectedAssets,NSDictionary *info) {
                //TODO: 点击完成的回调
            } cancelHandler:^{
                //TODO: 点击取消的回调
            }];
```


