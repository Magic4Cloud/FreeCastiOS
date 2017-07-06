//
//  BrowseViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/11.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "BrowseViewController.h"
#import "CommanParameter.h"
#import "AlbumObject.h"
#import "MediaData.h"
#import "MediaGroup.h"
#import "CollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayPhotoViewController.h"
#import "PlayVideoViewController.h"
#import <Foundation/Foundation.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <MOBFoundation/MOBFoundation.h>
#import "CommanParameters.h"

NSMutableArray *Medias;

@interface BrowseViewController ()
{
    AlbumObject *_albumObject;
    bool is_grouped;
    bool is_photo_choose;
    NSString *albumName;
    NSMutableArray *photoImages;
    NSMutableArray *selectedDic;
    NSMutableArray *shareImg;
}
@property (nonatomic,strong) NSMutableArray *groupArrays;
/**
 *  面板
 */
@property (nonatomic, strong) UIView *panelView;

/**
 *  加载视图
 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end

@implementation BrowseViewController

- (void)viewDidLoad {
    [self _switchPortrait];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    Medias=[[NSMutableArray alloc]init];
    photoImages = [[NSMutableArray alloc] init];
    shareImg = [[NSMutableArray alloc] init];
    selectedDic = [[NSMutableArray alloc] init];
    self.groupArrays = [NSMutableArray array];
    albumName=@"FREECAST";
    is_photo_choose=YES;
    
    //加载等待视图
    self.panelView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.panelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.panelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.frame = CGRectMake((self.view.frame.size.width - self.loadingView.frame.size.width) / 2, (self.view.frame.size.height - self.loadingView.frame.size.height) / 2, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.panelView addSubview:self.loadingView];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:244/255.0 green:245/255.0 blue:247/255.0 alpha:1.0];
    
    //顶部
    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*67/totalHeight);
    _topBg.backgroundColor = [UIColor whiteColor];
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
//    UIImageView *_Bg=[[UIImageView alloc]init];
//    _Bg.frame = CGRectMake(0, 0, viewW, viewH*20/totalHeight);
//    _Bg.contentMode=UIViewContentModeScaleToFill;
//    _Bg.backgroundColor=[UIColor blackColor];
//    _Bg.alpha=0.1;
//    [self.view addSubview:_Bg];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(viewW*10.5/totalHeight, viewH*32.5/totalHeight, viewH*24.5/totalHeight, viewH*24.5/totalHeight);
    [_backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    _backBtn.frame = CGRectMake(0, viewH*20/totalHeight, viewH*44/totalHeight, viewH*44/totalHeight);
//    [_backBtn setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    
    _editBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _editBtn.frame = CGRectMake(viewW-viewW*99/totalWeight, diff_top, viewW*84/totalWeight, viewH*44/totalHeight);
    [_editBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
    [_editBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [_editBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _editBtn.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _editBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [_editBtn addTarget:nil action:@selector(_editBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_editBtn];
    //设置分段控件点击相应事件
    NSArray *segmentedData = [[NSArray alloc]initWithObjects:NSLocalizedString(@"photo", nil),NSLocalizedString(@"videos", nil),nil];
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedData];
    segmentedControl.frame = CGRectMake(0,0,viewW*152/totalWeight,viewH*29/totalHeight);
    segmentedControl.center=CGPointMake(viewW*0.5, _backBtn.center.y);
    segmentedControl.tintColor = [UIColor whiteColor];
    segmentedControl.layer.borderWidth = 2.0;
    segmentedControl.layer.borderColor = MAIN_COLOR.CGColor;
    segmentedControl.layer.cornerRadius = viewW*5/totalWeight;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segmentedControl.selectedSegmentIndex = 0;//默认选中的按钮索引

    
    
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:MAIN_COLOR,UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,[UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1.0],UITextAttributeTextShadowColor ,nil];
    [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    
    NSDictionary *highlightedAttributes2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1.0],UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,[UIColor whiteColor],UITextAttributeTextShadowColor ,nil];
    
    [segmentedControl setTitleTextAttributes:highlightedAttributes2 forState:UIControlStateNormal];
    [segmentedControl addTarget:self action:@selector(doSomethingInSegment:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    UILabel *videoline =  [[UILabel alloc] initWithFrame:CGRectMake(0,0,2,segmentedControl.frame.size.height)];
    videoline.center = segmentedControl.center;
    videoline.backgroundColor = MAIN_COLOR;
    [self.view addSubview:videoline];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.headerReferenceSize = CGSizeMake(viewW, viewH*35/totalHeight);//头部
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(viewW*4/totalWeight, _topBg.frame.size.height+_topBg.frame.origin.y, viewW-2*viewW*4/375, viewH-(_topBg.frame.size.height+_topBg.frame.origin.y)) collectionViewLayout:flowLayout];
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //注册cell
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[CollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cell"];
    _albumObject = [[AlbumObject alloc]init];
    [_albumObject delegate:self];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_albumObject readFileFromAlbum:albumName];
    });
    
    //底部
    _bottomBg=[[UIView alloc]init];
    _bottomBg.userInteractionEnabled=YES;
    UIColor *bgColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"nav bar_bg@3x.png"]];
    [_bottomBg setBackgroundColor:bgColor];
    _bottomBg.frame = CGRectMake(0, viewH-viewH*44/totalHeight, viewW,viewH*44/totalHeight);
    _bottomBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_bottomBg];
    
    _deleteBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(viewW/2-viewH*60/totalHeight, 0, viewH*30/totalHeight, viewH*30/totalHeight);
    [_deleteBtn setImage:[UIImage imageNamed:@"edit_delete_nor@3x.png"] forState:UIControlStateNormal];
    [_deleteBtn setImage:[UIImage imageNamed:@"edit_delete_pre@3x.png"] forState:UIControlStateHighlighted];
    [_deleteBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _deleteBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_deleteBtn addTarget:nil action:@selector(_deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg  addSubview:_deleteBtn];
    
    _deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW/2-viewH*75/totalHeight, _deleteBtn.frame.origin.y+_deleteBtn.frame.size.height, viewH*60/totalHeight, viewH*14/totalHeight)];
    _deleteLabel.center=CGPointMake(_deleteBtn.center.x, _deleteLabel.center.y);
    _deleteLabel.text = NSLocalizedString(@"delete", nil);
    _deleteLabel.font = [UIFont systemFontOfSize: viewH*14/totalHeight*0.8];
    _deleteLabel.backgroundColor = [UIColor clearColor];
    _deleteLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _deleteLabel.lineBreakMode = UILineBreakModeWordWrap;
    _deleteLabel.textAlignment=UITextAlignmentCenter;
    _deleteLabel.numberOfLines = 0;
    [_bottomBg addSubview:_deleteLabel];
    
    _shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _shareBtn.frame = CGRectMake(viewW/2+viewH*30/totalHeight, 0,viewH*30/totalHeight, viewH*30/totalHeight);
    [_shareBtn setImage:[UIImage imageNamed:@"edit_share_nor@3x.png"] forState:UIControlStateNormal];
    [_shareBtn setImage:[UIImage imageNamed:@"edit_share_pre@3x.png"] forState:UIControlStateHighlighted];
    [_shareBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_shareBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _shareBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_shareBtn addTarget:nil action:@selector(_shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg  addSubview:_shareBtn];
    
    _shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW/2+viewH*15/totalHeight, _deleteBtn.frame.origin.y+_deleteBtn.frame.size.height, viewH*60/totalHeight, viewH*14/totalHeight)];
    _shareLabel.center=CGPointMake(_shareBtn.center.x, _shareLabel.center.y);
    _shareLabel.text = NSLocalizedString(@"share", nil);
    _shareLabel.font = [UIFont systemFontOfSize: viewH*14/totalHeight*0.8];
    _shareLabel.backgroundColor = [UIColor clearColor];
    _shareLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _shareLabel.lineBreakMode = UILineBreakModeWordWrap;
    _shareLabel.textAlignment=UITextAlignmentCenter;
    _shareLabel.numberOfLines = 0;
    [_bottomBg addSubview:_shareLabel];
    
    _bottomBg.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//屏幕常亮
}
//切换到竖屏
-(void)_switchPortrait{
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int valOrientation = UIInterfaceOrientationPortrait;
    [invocation setArgument:&valOrientation atIndex:2];
    [invocation invoke];
}

//编辑
- (void)_editBtnClick{
    if ([_editBtn.titleLabel.text compare:NSLocalizedString(@"edit", nil)]==NSOrderedSame) {
        _bottomBg.hidden=NO;
        [_editBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        [selectedDic removeAllObjects];
        [photoImages removeAllObjects];
        [shareImg removeAllObjects];
        [_collectionView reloadData];
    }
    else{
        _bottomBg.hidden=YES;
        [_editBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
        [shareImg removeAllObjects];
        [selectedDic removeAllObjects];
        [photoImages removeAllObjects];
        [_collectionView reloadData];
    }
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_deleteBtnClick{
    NSLog(@"_deleteBtnClick");
    
    int count = (int)[selectedDic count];
    NSMutableArray *videos=[self Get_Paths:@"video_flag"];
    NSMutableArray *mutaArray = [[NSMutableArray alloc] init];
    [mutaArray addObjectsFromArray:videos];
    for (int i = 0; i < count; i++) {
        [Medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //根据记录的删除的键值，删除组内元素
            MediaGroup *get_medias=Medias[idx];
            [get_medias.medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx2, BOOL *stop) {
                MediaData *media=get_medias.medias[idx2];
                if([([media getName]) compare:(selectedDic[i])]==NSOrderedSame ){
                    if(is_photo_choose){
                        [[Medias[idx] getMedias] removeObject:media];
                        [_albumObject removeFileFromAlbum:[media getUrl]];
                    }
                    else{
                        NSString *timeSp=[media getTimesamp];
                        
                        for(int i=0;i<[videos count];i++)
                        {
                            if (([timeSp compare:videos[i]]==NSOrderedSame )) {
                                [mutaArray removeObject:timeSp];
                                break;
                            }
                        }
                        [[Medias[idx] getMedias] removeObject:media];
                    }
                    NSLog(@"Medias=%@",[media getUrl]);
                }
            }];
            //当组内元素为0时，删除组
            if ([[Medias[idx] getMedias] count]==0) {
                [Medias removeObject :Medias[idx]];
            }
        }];
    }
    
    if(!is_photo_choose)
        [self Save_Paths:mutaArray :@"video_flag"];\
    
    [selectedDic removeAllObjects];
    [shareImg removeAllObjects];
    [photoImages removeAllObjects];
    [_collectionView reloadData];
}

- (void)_shareBtnClick{
    NSLog(@"_shareBtnClick");
    if ([selectedDic count]==0) {
        return;
    }
    [self showShareActionSheet:self.view];
}

#pragma mark 显示分享菜单

/**
 *  显示分享菜单
 *
 *  @param view 容器视图
 */
- (void)showShareActionSheet:(UIView *)view
{
    /**
     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
     **/
    __weak BrowseViewController *theController = self;
    
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    //NSLocalizedString(@"broswer_share_message", nil)
    //[NSURL URLWithString:@"http://www.mob.com"]
    //NSLocalizedString(@"broswer_share_title", nil)
    [shareParams SSDKSetupShareParamsByText:nil
                                     images:shareImg
                                        url:nil
                                      title:nil
                                       type:SSDKContentTypeImage];
    
    //1.2、自定义分享平台（非必要）
//    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:[ShareSDK activePlatforms]];
//    //添加一个自定义的平台（非必要）
//    SSUIShareActionSheetCustomItem *item = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"Icon.png"]
//                                                                                  label:@"自定义"
//                                                                                onClick:^{
//                                                                                    
//                                                                                    //自定义item被点击的处理逻辑
//                                                                                    NSLog(@"=== 自定义item被点击 ===");
//                                                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"自定义item被点击"
//                                                                                                                                        message:nil
//                                                                                                                                       delegate:nil
//                                                                                                                              cancelButtonTitle:@"确定"
//                                                                                                                              otherButtonTitles:nil];
//                                                                                    [alertView show];
//                                                                                }];
//    [activePlatforms addObject:item];
    
    //设置分享菜单栏样式（非必要）
    //        [SSUIShareActionSheetStyle setActionSheetBackgroundColor:[UIColor colorWithRed:249/255.0 green:0/255.0 blue:12/255.0 alpha:0.5]];
    //        [SSUIShareActionSheetStyle setActionSheetColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor whiteColor]];
    //        [SSUIShareActionSheetStyle setItemNameColor:[UIColor whiteColor]];
    //        [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
    //        [SSUIShareActionSheetStyle setCurrentPageIndicatorTintColor:[UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setPageIndicatorTintColor:[UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1.0]];
    
    //2、分享
    [ShareSDK showShareActionSheet:view
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           [theController showLoadingView:YES];
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           //Facebook Messenger、WhatsApp等平台捕获不到分享成功或失败的状态，最合适的方式就是对这些平台区别对待
                           if (platformType == SSDKPlatformTypeFacebookMessenger)
                           {
                               break;
                           }
                           
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"broswer_share_success", nil)
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"broswer_share_failed", nil)
                                                                               message:NSLocalizedString(@"broswer_share_error1", nil)
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"broswer_share_failed", nil)
                                                                               message:NSLocalizedString(@"broswer_share_error2", nil)
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"broswer_share_failed", nil)
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
//                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
//                                                                               message:nil
//                                                                              delegate:nil
//                                                                     cancelButtonTitle:@"确定"
//                                                                     otherButtonTitles:nil];
//                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
                   
                   if (state != SSDKResponseStateBegin)
                   {
                       [theController showLoadingView:NO];
                   }
                   
               }];
    
    //另附：设置跳过分享编辑页面，直接分享的平台。
    //        SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:view
    //                                                                         items:nil
    //                                                                   shareParams:shareParams
    //                                                           onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
    //                                                           }];
    //
    //        //删除和添加平台示例
    //        [sheet.directSharePlatforms removeObject:@(SSDKPlatformTypeWechat)];
    //        [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeSinaWeibo)];
    
}
#pragma mark -

/**
 *  显示加载动画
 *
 *  @param flag YES 显示，NO 不显示
 */
- (void)showLoadingView:(BOOL)flag
{
    if (flag)
    {
        [self.view addSubview:self.panelView];
        [self.loadingView startAnimating];
    }
    else
    {
        [self.panelView removeFromSuperview];
    }
}



-(void)doSomethingInSegment:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index)
    {
        case 0:
            if (is_photo_choose==NO) {
                [_editBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_albumObject readFileFromAlbum:albumName];
                });
            }
            is_photo_choose=YES;
            break;
        case 1:
            if (is_photo_choose) {
                [_editBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
                [self Get_Video];
            }
            is_photo_choose=NO;
            break;
        default:
            break;
    }
}

- (void)readFileFromAlbum:(ALAssetsGroup *)group
{
    [Medias removeAllObjects];
    if (group) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index,BOOL *stop) {
            if ([result thumbnail] != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
                {
                    NSString *date= [self DateToString:[result valueForProperty:ALAssetPropertyDate]];
                    UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                    NSString *fileName = [[result defaultRepresentation] filename];
                    NSString *url = [[[result defaultRepresentation] url] absoluteString];
                    UIImage *fullImage=[UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                    //int64_t fileSize = [[result defaultRepresentation] size];
                    //NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[result valueForProperty:ALAssetPropertyDate] timeIntervalSince1970]];
                    is_grouped=false;
                    [Medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        MediaGroup *get_group=Medias[idx];
                        //已分组则将数据添加到对应组
                        if ([date compare:[get_group getName]]==NSOrderedSame ) {
                            is_grouped=true;
                            MediaData *get_media=[MediaData initWithDate:date andName:fileName andUrl:url andTimesamp:@"" andImage:image andFullImage:fullImage];
                            [get_group.medias addObject:get_media];
                        }
                    }];
                    //未分组则添加一组，并将数据添加进去
                    if (is_grouped==false) {
                        MediaData *media=[MediaData initWithDate:date andName:fileName andUrl:url andTimesamp:@"" andImage:image andFullImage:fullImage];
                        MediaGroup *group=[MediaGroup initWithName:date andMedias:[NSMutableArray arrayWithObjects:media, nil]];
                        [Medias addObject:group];
                    }
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [selectedDic removeAllObjects];
            [photoImages removeAllObjects];
            [shareImg removeAllObjects];
            [self.collectionView reloadData];
        });
    }
}

BOOL _isExist;
- (void)Get_Video
{
    [Medias removeAllObjects];
    __weak BrowseViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [weakSelf.groupArrays addObject:group];
            } else {
                [weakSelf.groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if ([result thumbnail] != nil) {
                            // 照片
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                                
                            }
                            // 视频
                            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ){
                                NSString *date= [self DateToString:[result valueForProperty:ALAssetPropertyDate]];
                                UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                                //UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                                NSString *fileName = [[result defaultRepresentation] filename];
                                NSString *url = [[[result defaultRepresentation] url] absoluteString];
                                UIImage *fullImage=[UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                                int64_t fileSize = [[result defaultRepresentation] size];
                                NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[result valueForProperty:ALAssetPropertyDate] timeIntervalSince1970]];
                                
                                NSLog(@"date = %@",date);
                                NSLog(@"fileName = %@",fileName);
                                NSLog(@"url = %@",url);
                                NSLog(@"fileSize = %lld",fileSize);
                                NSMutableArray *videos=[self Get_Paths:@"video_flag"];
                                _isExist=false;
                                for(int i=0;i<[videos count];i++)
                                {
                                    if ([timeSp compare:videos[i]]==NSOrderedSame) {
                                        _isExist=true;
                                        break;
                                    }
                                }
                                
                                if (_isExist)
                                {
                                    is_grouped=false;
                                    [Medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                        MediaGroup *get_group=Medias[idx];
                                        //已分组则将数据添加到对应组
                                        if ([date compare:[get_group getName]]==NSOrderedSame ) {
                                            is_grouped=true;
                                            MediaData *get_media=[MediaData initWithDate:date andName:fileName andUrl:url andTimesamp:timeSp andImage:image andFullImage:fullImage];
                                            [get_group.medias addObject:get_media];
                                        }
                                    }];
                                    //未分组则添加一组，并将数据添加进去
                                    if (is_grouped==false) {
                                        MediaData *media=[MediaData initWithDate:date andName:fileName andUrl:url andTimesamp:timeSp andImage:image andFullImage:fullImage];
                                        MediaGroup *group=[MediaGroup initWithName:date andMedias:[NSMutableArray arrayWithObjects:media, nil]];
                                        [Medias addObject:group];
                                    }
                                }
                            }
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_collectionView reloadData];
                            });
                        }
                    }];
                }];
                
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
        {
            
            NSString *errorMessage = nil;
            
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:
                    errorMessage = @"The user refused to visit the album, please open in < privacy >";
                    break;
                    
                default:
                    errorMessage = @"Reason unknown.";
                    break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Unable to access"
                                                                   message:errorMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil,nil];
                [alertView show];
            });
        };
        
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}


- (NSString *)DateToString:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSLog(@"%@", strDate);
    //[dateFormatter release];
    return strDate;
}

- (NSString *)Get_Paths:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

- (void)Save_Paths:(NSString *)Timesamp :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:Timesamp forKey:key];
    [defaults synchronize];
}


#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    MediaGroup *group1=Medias[section];
    return group1.medias.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return Medias.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    MediaGroup *group=Medias[indexPath.section];
    MediaData *contact=group.medias[indexPath.row];
    cell.text.text=[contact getDate];
    return cell;
}

//每个UICollectionView展示的内容
NSString *_lastDate=@"";
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    [cell layoutIfNeeded];
    
    MediaGroup *group=Medias[indexPath.section];
    MediaData *contact=group.medias[indexPath.row];
    cell.selectImageView.tag = indexPath.row;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[contact getImage] forKey:@"img"];
    if ([_editBtn.titleLabel.text compare:NSLocalizedString(@"edit", nil)]==NSOrderedSame){
        [dic setObject:@"" forKey:@"flag"];
    }
    else{
        [dic setObject:@"0" forKey:@"flag"];
    }
    
    [photoImages addObject:dic];
    [cell sendValue:dic];
    if (!is_photo_choose) {
        [cell sendVideoValue:[self getMovieDuration:[contact getUrl]]];
    }
    
    return cell;
}

-(NSString*)getMovieDuration:(NSString*)movieStr{
    NSURL    *movieURL = [NSURL URLWithString:movieStr];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset=[AVURLAsset URLAssetWithURL:movieURL options:opts];  // 初始化视频媒体文件
    int minute = 0, second = 0;
    second = (int)(urlAsset.duration.value / urlAsset.duration.timescale); // 获取视频总时长,单位秒
    if (second >= 60) {
        int index = second / 60;
        minute = index;
        second = second - index*60;
    }
    return [NSString stringWithFormat:@"%02d:%02d",minute,second];
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width*119/totalWeight, self.view.frame.size.height*119/totalHeight);
}
//定义每个UICollectionView 的间距

//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:()section
//{
//    return UIEdgeInsetsMake(0, 0,0, 0);
//}

//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    NSLog(@"选择%ld",indexPath.row);
    NSInteger sec = indexPath.section;
    NSInteger row = indexPath.row;
    NSMutableArray *media=[Medias[sec] getMedias];
    MediaGroup *group=Medias[indexPath.section];
    MediaData *contact=group.medias[indexPath.row];
    
    if ([_editBtn.titleLabel.text compare:NSLocalizedString(@"edit", nil)]==NSOrderedSame){
        if (is_photo_choose) {
            PlayPhotoViewController *v = [[PlayPhotoViewController alloc] init];
            v.imageUrl=[contact getUrl];
            [self.navigationController pushViewController: v animated:true];
        }
        else{
            PlayVideoViewController *v = [[PlayVideoViewController alloc] init];
            v.Videourl=[contact getUrl];
            [self.navigationController pushViewController: v animated:true];
        }
    }
    else{
        id dic = [photoImages objectAtIndex:indexPath.row];
        BOOL flag = [[dic objectForKey:@"flag"] boolValue];
        if (!flag)
        {
            [dic setObject:@"1" forKey:@"flag"];
            [selectedDic addObject:[media[row] getName]];
            NSLog(@"[contact getUrl]=%@",[contact getUrl]);
            [shareImg addObject:[contact getFullImage]];
        } else {
            [dic setObject:@"0" forKey:@"flag"];
            [selectedDic removeObject:[media[row] getName]];
            [shareImg removeObject:[contact getFullImage]];
        }
        [cell setSelectFlag:!flag];
    }
}

UIImage *_getImage=nil;
- (UIImage*)getImage:(NSString *)urlStr
{
    _getImage=nil;
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    NSURL *url=[NSURL URLWithString:urlStr];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
        _getImage=[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
        
    }failureBlock:^(NSError *error) {
        NSLog(@"error=%@",error);
    }];
    return _getImage;
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) myHandleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint pointTouch = [gestureRecognizer locationInView:self.collectionView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
    }
}

//Set StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden//for iOS7.0
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
