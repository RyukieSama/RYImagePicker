//
//  RYAlbumSelectNaviTopView.h
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/10/12.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^AlbumSelectNaviTopViewHandler)(id obj);

@interface RYAlbumSelectNaviTopView : UIView

/**当前展示的相册名称*/
@property (nonatomic, copy) NSString *title;
/**是否已展开*/
@property (nonatomic, assign) BOOL isShowed;
/**点击title的回调*/
@property (nonatomic, copy) AlbumSelectNaviTopViewHandler handlerTitleClick;

@end
