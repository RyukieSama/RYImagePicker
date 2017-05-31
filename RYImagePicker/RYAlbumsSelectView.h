//
//  RYAlbumsSelectView.h
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/10/12.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef  void(^RYAlbumsSelectViewHandler)(id obj);

@interface RYAlbumsSelectView : UIView

/**需要展示的相册的第一张图片*/
@property (nonatomic, strong) NSArray *showImageArr;
/**需要展示的相册数组*/
@property (nonatomic, strong) PHFetchResult *fetchResults;
/**选择相册的回调*/
@property (nonatomic, copy) RYAlbumsSelectViewHandler handlerSelect;
/** 筛选条件 */
@property (nonatomic, strong) PHFetchOptions *fetchOptions;

@end
