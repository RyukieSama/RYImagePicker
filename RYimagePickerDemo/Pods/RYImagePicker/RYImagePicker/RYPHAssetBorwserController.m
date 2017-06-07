//
//  RYPHAssetBorwserController.m
//  RYImagePicker
//
//  Created by RongqingWang on 16/10/13.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYPHAssetBorwserController.h"
#import "RYPHAssetPlayViewHeaderView.h"
#import "RYPHAssetPlayViewFooterView.h"
#import "RYGridCellModel.h"

@interface RYPHAssetBorwserController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, assign) BOOL allowsSelection;

@property (nonatomic, assign, getter = isStatusBarHidden) BOOL statusBarHidden;

@property (nonatomic, strong, readonly) PHAsset *asset;
@property (nonatomic, strong) RYPHAssetPlayViewFooterView *footer;
@property (nonatomic, strong) RYPHAssetPlayViewHeaderView *header;
@property (nonatomic, strong) NSArray *cellModels;
@property (nonatomic, strong) RYGridCellModel *currentCellModel;
@property (nonatomic, weak) RYImagePicker *imagePickerManger;

@end

@implementation RYPHAssetBorwserController

#pragma mark - init
- (instancetype)initWithCellModels:(NSArray *)cellModels fromPreviewButton:(BOOL)isFromPreviewButton {
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:@{UIPageViewControllerOptionInterPageSpacingKey:@30.f}];
    
    if (self) {
        self.cellModels = cellModels.copy;
        self.dataSource      = self;
        self.delegate        = self;
        self.allowsSelection = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.isFromPreviewClick = isFromPreviewButton;
        
        self.imagePickerManger = [RYImagePicker sharedInstance];
        
        [self addNotificationOB];
    }

    return self;
}

#pragma mark - NOTIFICATION
- (void)addNotificationOB {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(borwersOneClick:) name:kRYImagePickerOneClick object:nil];
}

- (void)borwersOneClick:(NSNotification *)noti {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.header.alpha = (weakSelf.header.alpha==1) ? 0 : 1;
        weakSelf.footer.alpha = (weakSelf.footer.alpha==1) ? 0 : 1;
    }];
}

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //隐藏导航栏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //取消  隐藏导航栏状态栏
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - set
- (void)setUpUI {
    self.title = @"图片预览";
    self.view.backgroundColor = [UIColor blackColor];

    //添加header
    [self.view addSubview:self.header];
    //添加footer
    [self.view addSubview:self.footer];
}

- (void)setCellModel:(RYGridCellModel *)cellModel {
    _cellModel = cellModel;
    //设置序号
    [self.header setIndex:cellModel.indexPath.row countAll:[RYImagePicker sharedInstance].currentAlbumImageCount countSelected:[RYImagePicker sharedInstance].selectedCellModelArr.count];
    //设置确定的状态
    
    //设置是否选择 及序号
    if (cellModel.isSelected) {
        [self.footer.btCommit setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_preview_select"] forState:UIControlStateNormal];
        [self.footer.btCommit setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.footer.lbCurrentOrder.text = [NSString stringWithFormat:@"%ld",(long)cellModel.orderIndex+1];
    } else {
        [self.footer.btCommit setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_original_default"] forState:UIControlStateNormal];
        [self.footer.btCommit setTitleColor:[UIColor colorWithWhite:0.4 alpha:1.f] forState:UIControlStateNormal];
        self.footer.lbCurrentOrder.text = @"";
    }
    self.footer.currentOrder = cellModel.orderIndex;
    [self.footer layoutIfNeeded];
    
    //设置原图大小
    if ([RYImagePicker sharedInstance].isShowOrImageSize && cellModel.asset.mediaType == PHAssetMediaTypeImage) {
        [self.footer.btSee setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_original_select"] forState:UIControlStateNormal];
        [self.footer.btSee setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        __weak typeof(self) weakSelf = self;
        [[[PHCachingImageManager alloc] init] requestImageDataForAsset:cellModel.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            CGFloat size = imageData.length/1024.f;
            NSString *dataSize;
            if (size >= 1024) { //M
                dataSize = [NSString stringWithFormat:@"%0.1fM",size/1024.f];
            } else {//KB
                dataSize = [NSString stringWithFormat:@"%0.1fKB",size];
            }
            [weakSelf.footer.btSee setTitle:[NSString stringWithFormat:@"  原图(%@)",dataSize] forState:UIControlStateNormal];
        }];
        
    } else {
        [self.footer.btSee setImage:[UIImage imageNamed:@"RYPhotosPickerManager.bundle/album_original_default"] forState:UIControlStateNormal];
        [self.footer.btSee setTitleColor:[UIColor colorWithWhite:0.4 alpha:1.f] forState:UIControlStateNormal];
        [self.footer.btSee setTitle:@"  原图" forState:UIControlStateNormal];
    }
}

#pragma mark - lazyInit
- (RYPHAssetPlayViewHeaderView *)header {
    if (!_header) {
        _header = [[RYPHAssetPlayViewHeaderView alloc] init];
        __weak typeof(self) weakSelf = self;
        _header.lbIndex.hidden = self.isFromPreviewClick;
        _header.handlerBack = ^(id obj) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        _header.handlerSelect = ^(id obj) {
            [RYImagePicker sharedInstance].isShowOrImageSize = [RYImagePicker sharedInstance].isShowOrImageSize ? NO : YES;
        };

    }
    return _header;
}

- (RYPHAssetPlayViewFooterView *)footer {
    if (!_footer) {
        _footer = [[RYPHAssetPlayViewFooterView alloc] init];
        __weak typeof(self) weakSelf = self;
        _footer.btSee.hidden = !self.imagePickerManger.isShowOriginalImageButton;
        _footer.handlerSee = ^(id obj) {
            weakSelf.imagePickerManger.isShowOrImageSize = weakSelf.imagePickerManger.isShowOrImageSize ? NO : YES;
            weakSelf.cellModel = weakSelf.cellModel;
        };
        _footer.handlerCommit = ^(id obj) {
            if (weakSelf.cellModel.isSelected) {
                //重置cellModel的状态
                [weakSelf.cellModel resetStatus];
                //存入Manager
                [weakSelf.imagePickerManger.selectedCellModelArr removeObject:weakSelf.cellModel];
                [weakSelf.imagePickerManger reorderCellModelArr];
            } else {
                if (weakSelf.imagePickerManger.selectedCellModelArr.count == weakSelf.imagePickerManger.maxSelectedNumber) {
                    UIAlertController *alert =
                    [UIAlertController alertControllerWithTitle:@"提示"
                                                        message:weakSelf.imagePickerManger.overMaxInfo ?: [NSString stringWithFormat:@"选择图片不能超过%ld张", (long)weakSelf.imagePickerManger.maxSelectedNumber]
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action =
                    [UIAlertAction actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                           handler:nil];
                    [alert addAction:action];
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                } else {
                    weakSelf.cellModel.isSelected = YES;
                    weakSelf.cellModel.orderIndex = weakSelf.imagePickerManger.selectedCellModelArr.count;
                    //存入Manager
                    [weakSelf.imagePickerManger.selectedCellModelArr addObject:weakSelf.cellModel];
                }
            }
            
            //最后手动调用一次set方法
            weakSelf.cellModel = weakSelf.cellModel;

        };
    }
    return _footer;
}

#pragma mark - Accessors
- (NSInteger)pageIndex {    
    return [self.cellModels indexOfObject:self.currentCellModel];
}

- (void)setPageIndex:(NSInteger)pageIndex {
    NSInteger count = self.cellModels.count;
    
    if (pageIndex >= 0 && pageIndex < count) {
        RYGridCellModel *cellModel = [self.cellModels objectAtIndex:pageIndex];
        RYPHAssetPlayController *page = [RYPHAssetPlayController assetItemViewControllerForCellModel:cellModel];
        page.allowsSelection = self.allowsSelection;
        
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:^(BOOL finished) {
                      }];
        self.cellModel = cellModel;
    }
}

- (PHAsset *)asset {
    return ((RYPHAssetPlayController *)self.viewControllers[0]).asset;
}

#pragma mark - Page view controller data source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    RYGridCellModel *cellModel = ((RYPHAssetPlayController *)viewController).cellModel;
    NSInteger index = [self.cellModels indexOfObject:cellModel];
    
    if (index > 0) {
        RYGridCellModel *beforeCellModel = [self.cellModels objectAtIndex:(index - 1)];
        RYPHAssetPlayController *page = [RYPHAssetPlayController assetItemViewControllerForCellModel:beforeCellModel];
        page.allowsSelection = self.allowsSelection;
        
        return page;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    RYGridCellModel *cellModel  = ((RYPHAssetPlayController *)viewController).cellModel;
    NSInteger index = [self.cellModels indexOfObject:cellModel];
    NSInteger count = self.cellModels.count;
    
    if (index < count - 1) {
        RYGridCellModel *afterCellModel = [self.cellModels objectAtIndex:(index + 1)];
        RYPHAssetPlayController *page = [RYPHAssetPlayController assetItemViewControllerForCellModel:afterCellModel];
        page.allowsSelection = self.allowsSelection;
        
        return page;
    }
    return nil;
}


#pragma mark - Page view controller delegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        RYPHAssetPlayController *vc = (RYPHAssetPlayController *)pageViewController.viewControllers[0];
        self.cellModel = vc.cellModel;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"- [%@ dealloc]",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRYImagePickerOneClick object:nil];
}

@end
