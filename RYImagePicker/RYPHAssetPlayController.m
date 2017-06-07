//
//  RYPHAssetPlayController.m
//  RYImagePicker
//
//  Created by RongqingWang on 16/10/13.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYPHAssetPlayController.h"

@interface RYPHAssetPlayController ()

@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) PHImageRequestID playerItemRequestID;
@property (nonatomic, strong) RYImagePickerScrollView *scrollView;

@end

@implementation RYPHAssetPlayController

#pragma mark - init
+ (RYPHAssetPlayController *)assetItemViewControllerForCellModel:(RYGridCellModel *)cellModel {
    return [[self alloc] initWithCellModel:cellModel];
}

- (instancetype)initWithCellModel:(RYGridCellModel *)cellModel {
    if (self = [super init]) {
        _imageManager = [PHImageManager defaultManager];
        self.cellModel = cellModel;
        self.asset = cellModel.asset;
        self.allowsSelection = NO;
    }
    return self;
}

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestAssetImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelRequestAsset];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.scrollView setNeedsUpdateConstraints];
    [self.scrollView updateConstraintsIfNeeded];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        [self.scrollView updateZoomScalesAndZoom:YES];
    } completion:nil];
}

- (void)dealloc {
    NSLog(@"- [%@ dealloc]",[self class]);
}

#pragma mark - set
- (void)setUpUI {
    RYImagePickerScrollView *scrollView = [[RYImagePickerScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.allowsSelection = self.allowsSelection;
    scrollView.cellModel = self.cellModel;
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
    [self.view layoutIfNeeded];
}

#pragma mark - Request image
- (void)requestAssetImage {
    CGSize targetSize = [self targetImageSize];
    PHImageRequestOptions *options = [self imageRequestOptions];
    
    self.imageRequestID =
    [self.imageManager requestImageForAsset:self.asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFit
                                    options:options
                              resultHandler:^(UIImage *image, NSDictionary *info) {
                                  // this image is set for transition animation
                                  self.image = image;
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      
                                      NSError *error = [info objectForKey:PHImageErrorKey];
                                      
                                      if (error)
                                          [self showRequestImageError:error title:nil];
                                      else
                                          [self.scrollView bind:self.asset image:image requestInfo:info];
                                  });
                              }];
}

- (CGSize)targetImageSize {
    UIScreen *screen = UIScreen.mainScreen;
    CGFloat scale = screen.scale;
    return CGSizeMake(CGRectGetWidth(screen.bounds) * scale, CGRectGetHeight(screen.bounds) * scale);
}

- (PHImageRequestOptions *)imageRequestOptions {
    PHImageRequestOptions *options  = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    };
    return options;
}

#pragma mark - Request error
- (void)showRequestImageError:(NSError *)error title:(NSString *)title {
    [self showRequestError:error title:title];
}

- (void)showRequestVideoError:(NSError *)error title:(NSString *)title {
    [self showRequestError:error title:title];
}

- (void)showRequestError:(NSError *)error title:(NSString *)title {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action =
    [UIAlertAction actionWithTitle:@"Error"
                             style:UIAlertActionStyleDefault
                           handler:nil];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Cancel request
- (void)cancelRequestAsset {
    [self cancelRequestImage];
    [self cancelRequestPlayerItem];
}

- (void)cancelRequestImage {
    if (self.imageRequestID) {
        [self.imageManager cancelImageRequest:self.imageRequestID];
    }
}

- (void)cancelRequestPlayerItem {
    if (self.playerItemRequestID) {
        [self.imageManager cancelImageRequest:self.playerItemRequestID];
    }
}

#pragma mark - others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
