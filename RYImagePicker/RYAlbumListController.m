//
//  RYAlbumListController.m
//  RYImagePicker
//
//  Created by RongqingWang on 16/5/6.
//  Copyright © 2016年 RongqingWang. All rights reserved.
//

#import "RYAlbumListController.h"
#import <Photos/Photos.h>
#import "RYAlbumsSelectView.h"
#import "RYAlbumSelectNaviTopView.h"
#import "RYGridCell.h"
#import "RYGridCellModel.h"
#import "RYImagePicker.h"
#import "RYPHAssetBorwserController.h"
#import "RYListControllerFooterView.h"

static NSString *reuseID = @"HeheCell";
#define IMAGE_CELL_WIDTH_HEIGHT ([UIScreen mainScreen].bounds.size.width)/4

@interface RYAlbumListController ()<RYGridCellDelegate,UICollectionViewDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHFetchResult *fetchResults;
/**
 顶部选择相册的按钮
 */
@property (nonatomic, strong) RYAlbumSelectNaviTopView *vTopCenterView;
/**
 相册列表
 */
@property (nonatomic, strong) RYAlbumsSelectView *vAlbumSelectView;
/**
 下拉弹窗高度
 */
@property (nonatomic, assign) CGFloat topSelectViewHeight;
/**
 需要展示的模型
 */
@property (nonatomic, strong) NSArray *cellModels;
/**
 管理器
 */
@property (nonatomic, strong) PHCachingImageManager *imageCachingManger;
@property (nonatomic, strong) UICollectionView *cvImages;
/**
 当前展示的 fetchResult 内为PHAsset
 */
@property (nonatomic, strong) PHFetchResult *currentFetchResult;
/**
 筛选条件
 */
@property (nonatomic, strong) PHFetchOptions *fetchOptions;
/**
 当前已选择的相册 index
 */
@property (nonatomic, assign) NSInteger currentAlbumIndex;
/**
 底部悬浮预览条
 */
@property (nonatomic, strong) RYListControllerFooterView *vFooter;
/**
 导航栏上的确定按钮
 */
@property (nonatomic, strong) UIButton *btNaviCommit;
/**
 RYImagePicker
 */
@property (nonatomic, weak) RYImagePicker *imagePickerManger;
/**
 下拉列表的背后蒙版
 */
@property (nonatomic, strong) UIButton *btBack;
/**
 导航栏确定按钮
 */
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIButton *doneInnerBt;
/**
 相册数据是否发生变化
 */
@property (nonatomic, assign) BOOL isLibChanged;

@end

@implementation RYAlbumListController

- (instancetype)init {
    self = [super init];
    
    //配置默认初始值
    [self setDefaultValue];
    
    //访问系统相册
    __weak typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [weakSelf loadLibraryData];
        }
    }];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    [self setupUI];
    [self addNotificationOb];
    //监控相册的变化
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //保证每次进入预览后再回来  选中的图片的显示没问题
    [self.cvImages reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Noti
- (void)addNotificationOb {
    //监听点击完成按钮的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneClick) name:kRYImagePickerDoneClick object:nil];
}

- (void)doneClick {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRYImagePickerVCDidDimissed object:nil];
    }];
}

#pragma mark - UI
- (void)setupUI {
    //设置导航栏
    [self.view addSubview:self.vTopCenterView];
    self.navigationItem.titleView = self.vTopCenterView;
    
    //取消按钮
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    cancel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    //确定按钮
    self.doneInnerBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.doneInnerBt.titleLabel.font = [UIFont systemFontOfSize:15];
    self.doneInnerBt.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.doneInnerBt setTitle:@"确定" forState:UIControlStateNormal];
    [self.doneInnerBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.doneInnerBt setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateDisabled];
    [self.doneInnerBt addTarget:self action:@selector(commitClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithCustomView:self.doneInnerBt];
    self.doneInnerBt.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    [self.view addSubview:self.cvImages];
    self.cvImages.frame = [RYImagePicker sharedInstance].videoOnly ?
    CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) :
    CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-50);
    
    //设置footer
    if (![RYImagePicker sharedInstance].videoOnly) {
        [self.view addSubview:self.vFooter];
    }
    
    //一定放在最后
    [self.view addSubview:self.btBack];
    [self.view addSubview:self.vAlbumSelectView];
}

#pragma mark - set
#pragma mark 设置一些属性默认初始值
- (void)setDefaultValue {
    //设置默认筛选条件
    self.imageOnly = YES;//默认只显示图片
    self.videoOnly = NO;//默认不显示视频
    self.iCloudEnable = NO;//默认不显示iCloud相册
    
    //manager
    self.imagePickerManger = [RYImagePicker sharedInstance];
    
    //选中的albumIndex
    self.currentAlbumIndex = -1;
    
    //TODO: 需要保留之前选择的时候注意修改
    self.imagePickerManger.selectedCellModelArr = [NSMutableArray array];
    
}

- (void)setCellModels:(NSArray *)cellModels {
    _cellModels = cellModels;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.isLibChanged) { //图库内容变更引起的更新不设置偏移
            //总高度
            CGFloat totalHeight = cellModels.count * IMAGE_CELL_WIDTH_HEIGHT / 4;
            //当前CV高度
            CGFloat cvHeight = weakSelf.cvImages.frame.size.height;
            //需要设置的偏移量
            if (totalHeight <= cvHeight) {
                //不做偏移
                weakSelf.cvImages.contentOffset = CGPointMake(0, 0);
            } else {
                //需要偏移
                weakSelf.cvImages.contentOffset = CGPointMake(0, totalHeight);
            }
        }
        [self.cvImages reloadData];
        self.isLibChanged = NO;
    });
}

#pragma mark - cacheSmallImage
- (NSString *)getCacheKeyForIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%ld",(long)indexPath.row];
}

/**
 清空缓存池
 */
- (void)resetCachePool {
    [self.imagePickerManger.imageCacheHelper removeAllCaches];
    [self.cvImages reloadData];
}

#pragma mark - action
/**
 点击导航栏取消按钮
 */
- (void)cancelClick {
    if (self.imagePickerManger.canceledCallBack) {
        self.imagePickerManger.canceledCallBack(nil);
    }
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.imagePickerManger resetManager];
    }];
}

/**
 点击导航栏上的确定按钮
 */
- (void)commitClick {
    NSLog(@"确定");
    [[NSNotificationCenter defaultCenter] postNotificationName:kRYImagePickerDoneClick object:self userInfo:nil];
}

/**
 点击背景
 */
- (void)backgroundClick {
    self.vTopCenterView.isShowed = NO;
    self.btBack.alpha = 0;
    self.vAlbumSelectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
}

/**
 获取系统相册列表
 */
- (void)loadLibraryData {
    NSArray *typsArr = @[
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumUserLibrary],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumFavorites],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumPanoramas],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumTimelapses],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumBursts],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumAllHidden],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumGeneric],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumRegular],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedAlbum],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedEvent],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedFaces],
                         [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumImported]
                         ];
    
    // Add iOS 9's new albums
    if ([[PHAsset new] respondsToSelector:@selector(sourceType)]) {
        NSMutableArray *subtypes = [NSMutableArray arrayWithArray:typsArr];
        [subtypes insertObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumSelfPortraits] atIndex:4];
        [subtypes insertObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumScreenshots] atIndex:10];
        typsArr = [NSArray arrayWithArray:subtypes];
    }
    
    NSMutableArray *fetchResults = [NSMutableArray new];
    
    for (NSNumber *subtypeNumber in typsArr) {
        PHAssetCollectionType type       = (subtypeNumber.integerValue >= PHAssetCollectionSubtypeSmartAlbumGeneric) ? PHAssetCollectionTypeSmartAlbum : PHAssetCollectionTypeAlbum;
        PHAssetCollectionSubtype subtype = subtypeNumber.integerValue;
        PHFetchResult *fetchResult =
        [PHAssetCollection fetchAssetCollectionsWithType:type
                                                 subtype:subtype
                                                 options:nil];
        
        [fetchResults addObject:fetchResult];
    }
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    //ImageOnly
    if (self.imageOnly) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    }
    //VideoOnly
    else if (self.videoOnly) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
    }
    
    //TODO:现在还没做 livePhoto的兼容
    self.fetchOptions = fetchOptions;
    
    //过滤空相册
    NSMutableArray *arr = [NSMutableArray array];
    for (PHFetchResult *fetchResult in fetchResults) {
        for (PHAssetCollection *assetCollection in fetchResult) {
            if (![self checkRepeatWithTitle:assetCollection.localizedTitle inFetchResult:arr]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
                if (fetchResult.count != 0) {
                    [arr addObject:assetCollection];
                }
            }
        }
    }
    self.fetchResults = arr.copy;
    
    self.vAlbumSelectView.fetchResults = self.fetchResults;
    self.topSelectViewHeight = (self.fetchResults.count * 85 < 340) ? (self.fetchResults.count * 85) : 360;
    
    [self showImagesAlbumWithSelectedAlbum:(self.currentAlbumIndex >= 0) ? self.currentAlbumIndex : 0];
}

/**
 解决iOS8可能存在的重复显示的问题
 
 @param title       需要检查的标题
 @param fetchResult
 
 @return 是否存在重复
 */
- (BOOL)checkRepeatWithTitle:(NSString *)title inFetchResult:(NSArray *)fetchResult{
    for (PHAssetCollection *assetCollection in fetchResult) {
        if ([title isEqualToString:assetCollection.localizedTitle]) {//如果有标题相同的就不加进去
            return YES;
        }
    }
    return NO;
}

/**
 展示柜选中的相册   同时初始化缓存池
 
 @param index index
 */
- (void)showImagesAlbumWithSelectedAlbum:(NSInteger) index{
    //如果选择的还是当前相册的话就什么都不做
    if (index == self.currentAlbumIndex && !self.isLibChanged) {
        return;
    }
    if (index >= self.fetchResults.count) {
        return;
    }
    
    //切换相册 清空已选择的照片
    [self.imagePickerManger.selectedCellModelArr removeAllObjects];
    
    PHCollection *collection = [self.fetchResults objectAtIndex:index];
    self.currentAlbumIndex = index;
    if (![collection isKindOfClass:[PHAssetCollection class]]) {
        return;
    }
    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.vTopCenterView setTitle:[assetCollection localizedTitle]];//一定放在这里
    });
    
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
    self.currentFetchResult = assetsFetchResult;
    self.vAlbumSelectView.fetchOptions = self.fetchOptions;
    
    [RYImagePicker sharedInstance].currentAlbumImageCount = assetsFetchResult.count;
    
    NSMutableArray *arrTemp = [NSMutableArray array];
    NSInteger indexInAlbum = 1;
    for (PHAsset *asset in assetsFetchResult) {
        RYGridCellModel *cellModel = [[RYGridCellModel alloc] init];
        cellModel.asset = asset;
        cellModel.indexPath = [NSIndexPath indexPathForItem:indexInAlbum inSection:0];
        indexInAlbum ++;
        [arrTemp addObject:cellModel];
    };
    
    //    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.cellModels = arrTemp.copy;
        //选择完成后收起
        weakSelf.vTopCenterView.isShowed = NO;
        weakSelf.btBack.alpha = 0;
        weakSelf.vAlbumSelectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
    });
}

/**
 弹出最大选择数量提示框
 */
- (void)showAlertAboutMAxCount {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:self.overMaxInfo ?: [NSString stringWithFormat:@"选择图片不能超过%ld张", (long)_maxSelectedNumber]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 根据cellmodel设置cell的状态
 
 @param cell      设置的cell
 @param cellModel cellModel
 */
- (void)setUpCell:(RYGridCell *)cell withCellModel:(RYGridCellModel *)cellModel {
    if (self.imagePickerManger.isSingleSelect) {
        //已选的CellModel
        RYGridCellModel *model = [self.imagePickerManger.selectedCellModelArr firstObject];
        
        //点选同一个Cell
        if (model == cellModel) {
            cellModel.isSelected = !cellModel.isSelected;
            [self.imagePickerManger.selectedCellModelArr removeAllObjects];
            return;
        }
        
        model.isSelected = NO;
        [self.imagePickerManger.selectedCellModelArr removeAllObjects];
        //设置新的
        cellModel.isSelected = YES;
        cellModel.orderIndex = self.imagePickerManger.selectedCellModelArr.count;
        [self.imagePickerManger.selectedCellModelArr addObject:cellModel];
        //设置序号
        [self.imagePickerManger reorderCellModelArr];
    } else {
        if (cellModel.isSelected) {
            cellModel.isSelected = NO;
            [self.imagePickerManger.selectedCellModelArr removeObject:cellModel];
            [self.imagePickerManger reorderCellModelArr];
        } else {
            cellModel.isSelected = YES;
            cellModel.orderIndex = self.imagePickerManger.selectedCellModelArr.count;
            [self.imagePickerManger.selectedCellModelArr addObject:cellModel];
        }
    }
}

#pragma mark - collection
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RYGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    if (indexPath.row < self.cellModels.count) {
        RYGridCellModel *currentCellModel = _cellModels[indexPath.row];
        currentCellModel.indexPath = indexPath;
        cell.delegate = self;
        cell.representedAssetIdentifier = currentCellModel.asset.localIdentifier;
        cell.cellModel = currentCellModel;
    }
    if (self.imagePickerManger.selectedCellModelArr.count > 0) {
        [self.vFooter.btSee setTitle:[NSString stringWithFormat:@"预览(%ld)",(unsigned long)self.imagePickerManger.selectedCellModelArr.count] forState:UIControlStateNormal];
        self.vFooter.btSee.alpha = 1;
    } else {
        [self.vFooter.btSee setTitle:@"预览" forState:UIControlStateNormal];
        self.vFooter.btSee.alpha = 0.6f;
    }
    return cell;
}

#pragma mark - cellClickDelegate
- (void)gridCellClickBtImage:(RYGridCellModel *)cellModel {
    RYPHAssetBorwserController *vc = [[RYPHAssetBorwserController alloc] initWithCellModels:self.cellModels fromPreviewButton:NO];
    vc.pageIndex = [self.currentFetchResult indexOfObject:cellModel.asset];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gridCellClickBtSelect:(RYGridCellModel *)cellModel cell:(RYGridCell *)cell {
    if ([RYImagePicker sharedInstance].videoOnly) {
        //检查Video大小
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestAVAssetForVideo:cellModel.asset
                                                        options:nil
                                                  resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                                                      NSLog(@"11");
                                                      AVAssetTrack *tarck = [avAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
                                                      if ([tarck naturalSize].height > [RYImagePicker sharedInstance].maxVideoHeight && [RYImagePicker sharedInstance].maxVideoHeight > 0) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              //如 @"暂不支持分辨率大于1080P的视频!"
                                                              if ([RYImagePicker sharedInstance].maxVideoHeightHud) {
                                                                  [RYImagePicker sharedInstance].maxVideoHeightHud();
                                                              }
                                                          });
                                                          return ;
                                                      }
                                                      AVURLAsset *URLAsset = (AVURLAsset *)avAsset;
                                                      NSData *videoData = [NSData dataWithContentsOfURL:URLAsset.URL];
                                                      if (videoData.length > [RYImagePicker sharedInstance].maxVideoSize && [RYImagePicker sharedInstance].maxVideoSize > 0) {
                                                          //提示
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              //如 @"暂不支持大于20M的视频!"
                                                              if ([RYImagePicker sharedInstance].maxVideoSizeHud) {
                                                                  [RYImagePicker sharedInstance].maxVideoSizeHud();
                                                              }
                                                          });
                                                      } else {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [weakSelf loadCell:cellModel cell:cell];
                                                          });
                                                      }
                                                  }];
    } else {
        [self loadCell:cellModel cell:cell];
    }
    
}

- (void)loadCell:(RYGridCellModel *)cellModel cell:(RYGridCell *)cell {
    //点击之前的index数组
    NSArray *old = [self getItemsNeedReloadWithCellModels:self.imagePickerManger.selectedCellModelArr];
    
    if ((self.imagePickerManger.selectedCellModelArr.count == self.maxSelectedNumber) && (cellModel.isSelected == NO) && (self.imagePickerManger.isSingleSelect == NO)) {
        [self showAlertAboutMAxCount];
    } else {
        [self setUpCell:cell withCellModel:cellModel];
    }
    
    //点击之后的index数组
    NSArray *new = [self getItemsNeedReloadWithCellModels:self.imagePickerManger.selectedCellModelArr];
    
    //取元素数量最多的一个数组进行reload
    if (!old || !new) {//防止出现异常
        [self.cvImages reloadData];
    }
    
    [UIView performWithoutAnimation:^{//取消隐式动画
        if (self.imagePickerManger.isSingleSelect) {
            [_cvImages reloadData];
        } else {
            [self.cvImages reloadItemsAtIndexPaths:(old.count > new.count) ? old : new];
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    if (self.imagePickerManger.selectedCellModelArr.count > 0) {
        weakSelf.doneInnerBt.enabled = YES;
    } else {
        weakSelf.doneInnerBt.enabled = NO;
    }
}

- (NSArray<NSIndexPath *> *)getItemsNeedReloadWithCellModels:(NSArray<RYGridCellModel *> *)cellModels {
    NSMutableArray *muarr = [NSMutableArray array];
    for (RYGridCellModel *cellModel in cellModels) {
        if (!cellModel.indexPath) {
            return nil;//防止异常
        }
        [muarr addObject:cellModel.indexPath];
    }
    return muarr.copy;
}

#pragma mark - PHPhotoLibraryChangeObserver 相册变化的代理方法 试试更新相册
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.currentFetchResult];
    if (collectionChanges == nil) {
        return;
    }
    
    self.isLibChanged = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.currentFetchResult = [collectionChanges fetchResultAfterChanges];
        
        [RYImagePicker sharedInstance].selectedCellModelArr = [NSMutableArray array];
        [RYImagePicker sharedInstance].currentAlbumImageCount = weakSelf.currentFetchResult.count;
        
        NSMutableArray *arrTemp = [NSMutableArray array];
        NSInteger indexInAlbum = 1;
        for (PHAsset *asset in weakSelf.currentFetchResult) {
            RYGridCellModel *cellModel = [[RYGridCellModel alloc] init];
            cellModel.asset = asset;
            cellModel.indexPath = [NSIndexPath indexPathForItem:indexInAlbum inSection:0];
            indexInAlbum ++;
            [arrTemp addObject:cellModel];
        };
        weakSelf.cellModels = arrTemp.copy;
    });
}

#pragma mark - lazyInit
- (UICollectionView *)cvImages {
    if (!_cvImages) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(IMAGE_CELL_WIDTH_HEIGHT, IMAGE_CELL_WIDTH_HEIGHT);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _cvImages = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _cvImages.backgroundColor = [UIColor whiteColor];
        _cvImages.delegate = self;
        _cvImages.dataSource = self;
        _cvImages.bounces = NO;
        [_cvImages registerClass:[RYGridCell class] forCellWithReuseIdentifier:reuseID];
    }
    return _cvImages;
}

- (RYAlbumsSelectView *)vAlbumSelectView {
    if (!_vAlbumSelectView) {
        _vAlbumSelectView = [[RYAlbumsSelectView alloc] init];
        _vAlbumSelectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
        __weak typeof(self) weakSelf = self;
        _vAlbumSelectView.handlerSelect = ^(id obj) {
            NSNumber *index = obj;
            [weakSelf showImagesAlbumWithSelectedAlbum:[index integerValue]];
        };
    }
    return _vAlbumSelectView;
}

- (RYAlbumSelectNaviTopView *)vTopCenterView {
    if (!_vTopCenterView) {
        _vTopCenterView = [[RYAlbumSelectNaviTopView alloc] init];
        _vTopCenterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 100, 40);
        
        __weak typeof(_vTopCenterView)weakTopCenterView = _vTopCenterView;
        __weak typeof(self)weakSelf = self;
        _vTopCenterView.handlerTitleClick = ^(id obj) {
            if (weakTopCenterView.isShowed) {//如果已经展开了 就收起
                weakTopCenterView.isShowed = NO;
                weakSelf.btBack.alpha = 0;
                weakSelf.vAlbumSelectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
            } else {//如果没展开
                weakTopCenterView.isShowed = YES;
                weakSelf.btBack.alpha = 1;
                weakSelf.vAlbumSelectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, weakSelf.topSelectViewHeight);
            }
        };
    }
    return _vTopCenterView ;
}

- (RYListControllerFooterView *)vFooter {
    if (!_vFooter) {
        _vFooter = [[RYListControllerFooterView alloc] init];
        __weak typeof(self) weakSelf = self;
        _vFooter.handlerSee = ^(id obj) {
            if (weakSelf.imagePickerManger.selectedCellModelArr.count > 0) {
                RYPHAssetBorwserController *vc = [[RYPHAssetBorwserController alloc] initWithCellModels:weakSelf.imagePickerManger.selectedCellModelArr fromPreviewButton:YES];
                vc.pageIndex = 0;
                vc.isFromPreviewClick = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    return _vFooter;
}

- (UIButton *)btBack {
    if (!_btBack) {
        _btBack = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _btBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _btBack.alpha = 0;
        [_btBack addTarget:self action:@selector(backgroundClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btBack;
}

#pragma mark - Other
- (UIViewController *)getAppTopVieController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return tabBarController.selectedViewController;
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return navigationController.visibleViewController;
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return presentedViewController.presentedViewController;
    } else {
        return rootViewController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self resetCachePool];
}

- (void)dealloc {
    NSLog(@"- [%@ dealloc]",[self class]);
    //注销监控
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    
    [self resetCachePool];
}

@end


