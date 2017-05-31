//
//  RYAlbumsSelectCell.h
//  RYimagePickerDemo
//
//  Created by RongqingWang on 16/10/12.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RYAlbumsSelectCell : UITableViewCell

@property (nonatomic, assign) BOOL isCurrent;

- (void)setTitle:(NSString *)title andCount:(NSInteger )count;
- (void)setLastImage:(UIImage *)lasImage;

@end
