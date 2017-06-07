//
//  RYImagePickerUIConfig.h
//  RYImagePicker
//
//  Created by RongqingWang on 16/12/5.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RYImagePickerUIConfig : NSObject

/**
 "#e8e8e8" 这种格式字符串的颜色
 
 @param hexString
 
 @return
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
