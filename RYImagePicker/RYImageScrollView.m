//
//  RYImageScrollView.m
//  BigFan
//
//  Created by RongqingWang on 16/10/13.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import "RYImageScrollView.h"
#import "RYImagePicker.h"

NSString * const RYAssetScrollViewDidTapNotification = @"RYAssetScrollViewDidTapNotification";
NSString * const RYAssetScrollViewPlayerWillPlayNotification = @"RYAssetScrollViewPlayerWillPlayNotification";
NSString * const RYAssetScrollViewPlayerWillPauseNotification = @"RYAssetScrollViewPlayerWillPauseNotification";

@interface RYImageScrollView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL didLoadPlayerItem;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, assign) CGFloat maximumDoubleTapZoomScale;
@property (nonatomic, assign) CGFloat perspectiveZoomScale;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation RYImageScrollView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.allowsSelection = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.delegate = self;
        
        [self setUpUI];
        [self addGestureRecognizers];
    }
    return self;
}

#pragma mark - set
- (void)setUpUI {
    self.backgroundColor = [UIColor blackColor];
    
    UIImageView *imageView = [UIImageView new];
    imageView.isAccessibilityElement    = YES;
    imageView.accessibilityTraits       = UIAccessibilityTraitImage;
    self.imageView = imageView;
    [self addSubview:self.imageView];
    
    UIActivityIndicatorView *activityView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView = activityView;
    [self addSubview:self.activityView];
    
}

#pragma mark - Bind asset image
- (void)bind:(PHAsset *)asset image:(UIImage *)image requestInfo:(NSDictionary *)info {
    self.asset = asset;
    self.imageView.accessibilityLabel = asset.accessibilityLabel;
    
    BOOL isDegraded = [info[PHImageResultIsDegradedKey] boolValue];
    
    if (self.image == nil || !isDegraded) {
        // Reset
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        
        self.contentSize = CGSizeMake(0, 0);
        
        self.imageView.image = image;
        
        // 设置size
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = [self assetSize];
        
        self.imageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        // 缩放到最小
        [self setMaxMinZoomScalesForCurrentBounds];
        
        [self setNeedsLayout];
        
    }
}

#pragma mark - Gesture recognizers
- (void)addGestureRecognizers {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    
    [doubleTap setNumberOfTapsRequired:2.0];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [singleTap setDelegate:self];
    [doubleTap setDelegate:self];
    
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Handle tappings
- (void)handleTapping:(UITapGestureRecognizer *)recognizer {
    [[NSNotificationCenter defaultCenter] postNotificationName:RYAssetScrollViewDidTapNotification object:recognizer];
    
    if (recognizer.numberOfTapsRequired == 2) {
        if (self.cellModel.asset.mediaType == PHAssetMediaTypeVideo) {
            
        } else {
            [self zoomWithGestureRecognizer:recognizer];
        }
    } else if(recognizer.numberOfTapsRequired == 1) {
        if (self.cellModel.asset.mediaType == PHAssetMediaTypeVideo) {//如果是视频就播放
            if (self.playerLayer && self.player) {
                if (self.isPlaying == NO) {//self.player.timeControlStatus 这个属性只有iOS10有
                    [self.player play];
                } else {
                    self.isPlaying = NO;
                    [self.player pause];
                }
            } else {
                [[PHImageManager defaultManager] requestAVAssetForVideo:self.cellModel.asset
                                                                options:nil
                                                          resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  CALayer *viewLayer = self.layer;
                                                                  
                                                                  // Create an AVPlayerItem for the AVAsset.
                                                                  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                                                                  playerItem.audioMix = audioMix;
                                                                  
                                                                  // Create an AVPlayer with the AVPlayerItem.
                                                                  AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                                                                  player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
                                                                  
                                                                  // Create an AVPlayerLayer with the AVPlayer.
                                                                  AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                                                                  
                                                                  // Configure the AVPlayerLayer and add it to the view.
                                                                  playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                                                                  playerLayer.frame = CGRectMake(0, 0, viewLayer.bounds.size.width, viewLayer.bounds.size.height);
                                                                  
                                                                  [viewLayer addSublayer:playerLayer];
                                                                  [player play];
                                                                  self.isPlaying = YES;
                                                                  
                                                                  // Store a reference to the player layer we added to the view.
                                                                  self.playerLayer = playerLayer;
                                                                  self.player = player;
                                                              });
                                                          }];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kRYImagePickerOneClick object:self userInfo:@{
                                                                                                                     @"isVideo":@1
                                                                                                                     }];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRYImagePickerOneClick object:self userInfo:nil];
        }
    }
}

#pragma mark - Scroll view delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Zoom with gesture recognizer
- (void)zoomWithGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self];
    
    //保证 plus上的缩放效果一致
    touchPoint.x = touchPoint.x * [UIScreen mainScreen].scale;
    touchPoint.y = touchPoint.y * [UIScreen mainScreen].scale;
    
    // 取消当前所有target为self.imageview的操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self.imageView];
    
    // Zoom
    if (self.zoomScale == self.maximumZoomScale) {
        //缩小
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        //放大
//        CGSize targetSize = CGSizeMake(self.frame.size.width / self.maximumDoubleTapZoomScale, self.frame.size.height / self.maximumDoubleTapZoomScale);
//        CGPoint targetPoint = CGPointMake(touchPoint.x - targetSize.width / 2, touchPoint.y - targetSize.height / 2);
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

#pragma mark - zoom
- (void)setMaxMinZoomScalesForCurrentBounds {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    if (self.imageView.image == nil) return;
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    boundsSize.width -= 0.1;
    boundsSize.height -= 0.1;
    
    CGSize imageSize = self.imageView.frame.size;
    
    // 计算最小比例
    CGFloat xScale = boundsSize.width / imageSize.width;    // 最适应图片宽度的比例
    CGFloat yScale = boundsSize.height / imageSize.height;  // 最适应图片高度的比例
    CGFloat minScale = MIN(xScale, yScale);                 // 用其中最小的一个来作为全屏缩放的比例
    
    // 如果都比屏幕小  就设置为1
    if (xScale > 1 && yScale > 1) {
        minScale = 1.0;
    }
    
    // 计算最大比例
    CGFloat maxScale = 4.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
        
        if (maxScale < minScale) {
            maxScale = minScale * 2;
        }
    }
    
    // 计算双击后的最大比例
    CGFloat maxDoubleTapZoomScale = 4.0 * minScale; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxDoubleTapZoomScale = maxDoubleTapZoomScale / [[UIScreen mainScreen] scale];
        
        if (maxDoubleTapZoomScale < minScale) {
            maxDoubleTapZoomScale = minScale * 2;
        }
    }
    
    // Set
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    self.maximumDoubleTapZoomScale = maxDoubleTapZoomScale;
    
    // Reset
    self.imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    [self setNeedsLayout];
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 当图片比当前屏幕小的时候居中
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // H
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // V
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter))
        self.imageView.frame = frameToCenter;
}

#pragma mark - asset size
- (CGSize)assetSize {
    return CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
}

@end
