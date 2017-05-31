//
//  RYAlbumListController.h
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RYAlbumListController : UIViewController

/**
 是否仅显示图片资源 默认YES
 */
@property (nonatomic, assign) BOOL imageOnly;
/**
 是否仅显示视频资源 默认NO
 */
@property (nonatomic, assign) BOOL videoOnly;
/**
 是否显示iCloud相册 默认NO
 */
@property (nonatomic, assign) BOOL iCloudEnable;
/**
 最大选择张数
 */
@property (nonatomic, assign) NSInteger maxSelectedNumber;
/**
 超过最大限制后的提示文案
 */
@property (nonatomic, copy) NSString *overMaxInfo;

@end
