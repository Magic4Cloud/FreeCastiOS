//
//  TTPlatformSelectViewController.m
//  presentationLiveDemo
//
//  Created by tc on 6/28/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTPlatformSelectViewController.h"
#import "TTPlatFormCell.h"
#import "CollectionHeaderView.h"
#import "CollectionReusableFooterView.h"
#import "LiveViewViewController.h"
#import "SubtitleViewController.h"
#import "BannerViewController.h"
#import "AudioViewController.h"

#import "Scanner.h"

#import "TTCoreDataClass.h"

#import "TTYoutubuViewController.h"
#import "TTFacebookViewController.h"

#import "TTPlatformCustomViewController.h"
#import "TTTwicthViewController.h"


#import "CommanParameters.h"

#import "TTSearchDeviceClass.h"
#import "CommonAppHeaders.h"

@interface TTPlatformSelectViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong)Scanner * device_Scan;

@property (nonatomic, copy) NSString * userip;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray<PlatformModel *> * platformsArray;

@property (nonatomic, strong) NSThread * searchThread;
@property (nonatomic, strong) UIAlertView *waitAlertView;

@end

@implementation TTPlatformSelectViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_configIP != nil) {
        _userip = _configIP;
    }
    [self initData];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_configIP) {
        [self scanDevice];
    }
    [self initUI];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_main_queue(),^ {
        [_waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)initData {
    NSArray * array = [[TTCoreDataClass shareInstance] localAllPlatforms];
    _platformsArray = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
    
}

- (void)initUI
{
    self.title = @"Stream";
    
    self.view.backgroundColor = [UIColor TTBackLightGrayColor];
    
    [self configNavigationWithTitle:@"stream" rightButtonTitle:nil];
    
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TTPlatFormCell" bundle:nil] forCellWithReuseIdentifier:@"TTPlatFormCell"];

    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionReusableFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionReusableFooterView"];
    
}

#pragma mark - 扫描设备--------------------------
- (void)scanDevice {
    
    _waitAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"main_scan_indicator_title", nil)
                                               message:NSLocalizedString(@"main_scan_indicator", nil)
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil, nil];
    [_waitAlertView show];
    [[TTSearchDeviceClass shareInstance] searDeviceWithSecond:5 CompletionHandler:^(Scanner *resultinfo) {
        [self scanDeviceOver:resultinfo];
    }];
    
//    if (!_searchThread) {
//        _searchThread = [[NSThread alloc] initWithTarget:self selector:@selector(scanDeviceTask) object:nil];
//    }
//    [_searchThread start];
//    [NSThread detachNewThreadSelector:@selector(scanDeviceTask) toTarget:self withObject:nil];
}

//- (void)scanDeviceTask
//{
//    Lx52x_Device_Info *result = [_device_Scan ScanDeviceWithTime:3.0f];
//    [self performSelectorOnMainThread:@selector(scanDeviceOver:) withObject:result waitUntilDone:NO];
//}

- (void)scanDeviceOver:(Scanner *)result;
{
    
    if (result.Device_ID_Arr.count > 0) {
        
//        NSString *video_type=@"h264";
//        //使用扫描到的第一个设备
//        NSString *urlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", [result.Device_IP_Arr objectAtIndex:0],video_type];
        _userip = [result.Device_IP_Arr objectAtIndex:0];
        
    }else{
        
        
        
    }
    
    dispatch_async(dispatch_get_main_queue(),^ {
        [_waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
        [_collectionView reloadData];
    });
}

#pragma mark - actions
- (void)_backBtnClick
{
    [_searchThread cancel];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goliVeNowButtonClick
{
    NSArray * viewcontrollers = self.navigationController.viewControllers;
    
    __block LiveViewViewController * popVc;
    [viewcontrollers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LiveViewViewController class]]) {
            popVc = (LiveViewViewController *)obj;
        }
    }];
    
    if (popVc) {
        [self.navigationController popToViewController:popVc animated:YES];
    }
    else
    {
        LiveViewViewController *v = [[LiveViewViewController alloc] init];
        v.isLiveView=YES;
        [self.navigationController pushViewController: v animated:true];
    }

}

- (void)cellEditButtonClick:(UIButton *)button
{
    NSInteger index = button.tag;
    switch (index) {
        case 0://facebook
        {
            
        }
            break;
        case 1://youtubu
        {
            TTYoutubuViewController * vc = [[TTYoutubuViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2://uStream
        {
            
        }
            break;
        case 3://Twitch
        {
            TTTwicthViewController * vc = [[TTTwicthViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case 4://LiveStream
        {
            
        }
            break;
        case 5://Custom
        {
            TTPlatformCustomViewController * vc = [[TTPlatformCustomViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }


}

#pragma mark - praivate methods
- (PlatformModel *)getPlatformByName:(NSString *)name
{
    __block PlatformModel * model = nil;
    [_platformsArray enumerateObjectsUsingBlock:^(PlatformModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:name]) {
            model = obj;
            *stop = YES;
        }
    }];
    
    return model;
}

#pragma mark - collectionView  delegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    return 3;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if (_userip == nil) {
        return 1;
    }else{
        return 2;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        CollectionHeaderView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView" forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            view.headerLabel.text = @"Live Platform";
        }else{
            view.headerLabel.text = @"Personalize your Live Stream";
        }
        reusableview = view;
    }else if (kind == UICollectionElementKindSectionFooter) {
        
        CollectionReusableFooterView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionReusableFooterView" forIndexPath:indexPath];
        
        [footerView.button addTarget:self action:@selector(goliVeNowButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
//        if (indexPath.section == 1) {
            reusableview = footerView;
//        }
    }

    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    
    if (_userip == nil) {
        return CGSizeMake(ScreenWidth, 100);
    }else{
        if (section == 0) {
            return CGSizeZero;
        }else {
            return CGSizeMake(ScreenWidth, 100);
        }
    }
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTPlatFormCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTPlatFormCell" forIndexPath:indexPath];
    if (indexPath.section == 0)
    {
        
        [cell.cellEditButton addTarget:self action:@selector(cellEditButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.cellEditButton.tag = indexPath.row;
        
        switch (indexPath.row) {
            case 0://facebook
            {
                [cell setModel:[self getPlatformByName:faceBook] andPlatformName:faceBook];
            }
                break;
            case 1://youtubu
            {
                [cell setModel:[self getPlatformByName:youtubu] andPlatformName:youtubu];
            }
                break;
            case 2://uStream
            {
                [cell setModel:[self getPlatformByName:uStream] andPlatformName:uStream];
            }
                break;
            case 3://Twitch
            {
                [cell setModel:[self getPlatformByName:twitch] andPlatformName:twitch];
            }
                break;
            case 4://LiveStream
            {
                [cell setModel:[self getPlatformByName:liveStream] andPlatformName:liveStream];
            }
                break;
            case 5://Custom
            {
                [cell setModel:[self getPlatformByName:custom] andPlatformName:custom];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
            {
                [cell setImageviewImageWithImageName:@"button_subtitle"];
                
            }
                break;
            case 1:
            {
                [cell setImageviewImageWithImageName:@"button_logo_nor"];
                
            }
                break;
            case 2:
            {
                [cell setImageviewImageWithImageName:@"button_audio_nor"];
            }
                break;
                
            default:
                break;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        TTPlatFormCell * cell = (TTPlatFormCell *)[collectionView cellForItemAtIndexPath:indexPath];
        PlatformModel * model = cell.model;
        NSLog(@"name:%@",model.name);
        NSLog(@"isEnable:%d",model.isEnable);
        
        if (model && model.isEnable)
        {
            if (!model.isSelected) {
                [[TTCoreDataClass shareInstance] setlocalSelectedPlatformName:model.name];
                [_platformsArray enumerateObjectsUsingBlock:^(PlatformModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.isSelected = NO;
                }];
                model.isSelected = YES;
                [collectionView reloadData];
            }
            return;
        }
        switch (indexPath.row) {
            case 0://facebook
            {
                [self showHudMessage:NSLocalizedString(@"Notyetopened", nil)];
//                TTFacebookViewController *vc = [[TTFacebookViewController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1://youtubu
            {
                TTYoutubuViewController * vc = [[TTYoutubuViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2://uStream
            {
                [self showHudMessage:NSLocalizedString(@"Notyetopened", nil)];
            }
                break;
            case 3://Twitch
            {
                TTTwicthViewController * vc = [[TTTwicthViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 4://LiveStream
            {
                [self showHudMessage:NSLocalizedString(@"Notyetopened", nil)];
            }
                break;
            case 5://Custom
            {
                TTPlatformCustomViewController * vc = [[TTPlatformCustomViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }

    }
    else
    {
        if (!_userip) {
            [self showHudMessage:@"Device not found!"];
            return;
        }
        switch (indexPath.row) {
            case 0:
            {
                SubtitleViewController * subtitleViewController = [[SubtitleViewController alloc] init];
                subtitleViewController.ip = _userip;
                [self.navigationController pushViewController:subtitleViewController animated:YES];
                
            }
                break;
            case 1:
            {
                BannerViewController * bannerViewController = [[BannerViewController alloc] init];
                bannerViewController.ip = _userip;
                [self.navigationController pushViewController:bannerViewController animated:YES];

            }
                break;
            case 2:
            {
                AudioViewController * audioViewController = [[AudioViewController alloc] init];
                audioViewController.ip = _userip;
                [self.navigationController pushViewController:audioViewController animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    
    
}


#pragma mark - setter
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat sizeWidth = ScreenWidth/3;
        layout.itemSize = CGSizeMake(sizeWidth, sizeWidth);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.headerReferenceSize = CGSizeMake(ScreenWidth, 45);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64,ScreenWidth , ScreenHeight-64) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor TTBackLightGrayColor];
        }
    return _collectionView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
