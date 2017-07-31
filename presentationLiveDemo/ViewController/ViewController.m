//
//  ViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/9.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "ViewController.h"
#import "CommanParameter.h"
#import "LiveViewViewController.h"
#import "Rak_Lx52x_Device_Control.h"
#import "BrowseViewController.h"
#import "StreamViewController.h"
#import "ConfigureViewController.h"
#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "PasswordViewController.h"
#import "CommanParameters.h"

#import "TTPlatformSelectViewController.h"


Rak_Lx52x_Device_Control *_Scan;


@interface ViewController ()
{
    bool _Exit;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=MAIN_BG_COLOR;
    NSLog(@"viewH=%f,viewW=%f",viewH,viewW);
    
    _Bg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BG@3x.png"]];
    _Bg.frame = CGRectMake(0, 0, viewW, viewH);
    _Bg.contentMode=UIViewContentModeScaleToFill;
    _Bg.alpha=0.6;
    [self.view addSubview:_Bg];
    
    /**
     *   模糊效果的三种风格
     *
     *  @param UIBlurEffectStyle
     
     UIBlurEffectStyleExtraLight,//额外亮度，（高亮风格）
     UIBlurEffectStyleLight,//亮风格
     UIBlurEffectStyleDark//暗风格
     *
     */
    //实现模糊效果
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //毛玻璃视图
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    visualEffectView.frame = CGRectMake(0, 0, viewW, viewH);
    visualEffectView.alpha = 0.6;
    [self.view addSubview:visualEffectView];

    //第一栏
    _topBg=[[UIImageView alloc]init];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*20/totalHeight);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    _topBg.backgroundColor=[UIColor blackColor];
    _topBg.alpha=0.1;
//    [self.view addSubview:_topBg];
    
    _topFlag=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo@3x.png"]];
    _topFlag.frame = CGRectMake(0, viewH*80.5/totalHeight, viewH*73.5/totalHeight, viewH*73.5/totalHeight);
    _topFlag.center=CGPointMake(viewW/2, _topFlag.center.y);
    _topFlag.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topFlag];
    _topFlag.transform = CGAffineTransformIdentity;
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 3.0 animations: ^{
            _topFlag.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }];
        [UIView addKeyframeWithRelativeStartTime:1/3.0 relativeDuration:1/3.0 animations: ^{
            _topFlag.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }];
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/3.0 animations: ^{
            _topFlag.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    } completion:nil];
    
    _menuBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _menuBtn.frame = CGRectMake(viewW*40/totalWeight, viewH*45/totalHeight, viewH*15/totalHeight, viewH*25/totalHeight);
    [_menuBtn setImage:[UIImage imageNamed:@"icon_side menu"] forState:UIControlStateNormal];
//    [_menuBtn setImage:[UIImage imageNamed:@"function menu_pre@3x.png"] forState:UIControlStateHighlighted];
    _menuBtn.contentMode=UIViewContentModeScaleAspectFill;
    _menuBtn.center=CGPointMake(_menuBtn.center.x, _topFlag.center.y);
    _menuBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [_menuBtn addTarget:nil action:@selector(_menuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_menuBtn];
    
    
    
/*
    //第二栏
    _liveView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"home_top_bd@3x.png"]];
    _liveView.frame = CGRectMake(0, _topFlag.frame.size.height+_topFlag.frame.origin.y+viewH*1/totalHeight, viewW, viewH*71/totalHeight);
    _liveView.contentMode=UIViewContentModeScaleToFill;
    _liveView.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_liveViewClick)];
    [_liveView addGestureRecognizer:singleTap1];
    [self.view addSubview:_liveView];
    
    _liveViewCamera=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live view_gopro_icon_not connect@3x.png"]];
    _liveViewCamera.image=[UIImage imageNamed:@"live view_gopro_icon_connect@3x.png"];
    _liveViewCamera.frame = CGRectMake(0, 0, viewH*46/totalHeight*141/126, viewH*46/totalHeight);
    _liveViewCamera.center=CGPointMake(_liveViewCamera.frame.size.width/2+viewW*30/375, _liveView.center.y);
    _liveViewCamera.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_liveViewCamera];

    _liveViewImg=[UIButton buttonWithType:UIButtonTypeCustom];
    _liveViewImg.frame = CGRectMake(0, 0, viewH*44/totalHeight, viewH*44/totalHeight);
    _liveViewImg.center=CGPointMake(viewW-_liveViewImg.frame.size.width/2-viewW*21/375, _liveView.center.y);
    [_liveViewImg setImage:[UIImage imageNamed:@"live view_icon_next_connect@3x.png"] forState:UIControlStateNormal];
    [_liveViewImg setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_liveViewImg setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _liveViewImg.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_liveViewImg addTarget:nil action:@selector(_liveViewClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_liveViewImg];
    
    _liveViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(_liveViewCamera.frame.size.width+_liveViewCamera.frame.origin.x+diff_x, _liveView.frame.origin.y, _liveViewImg.frame.origin.x-_liveViewCamera.frame.size.width-_liveViewCamera.frame.origin.x-diff_x, viewH*71/totalHeight)];
    _liveViewLabel.text = NSLocalizedString(@"live_view_label", nil);
    _liveViewLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _liveViewLabel.backgroundColor = [UIColor clearColor];
    //_liveViewLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _liveViewLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    _liveViewLabel.lineBreakMode = UILineBreakModeWordWrap;
    _liveViewLabel.numberOfLines = 0;
    [self.view addSubview:_liveViewLabel];
    
    //第三栏
    _browse=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"browse_bg@3x.png"]];
    _browse.frame = CGRectMake(0, _liveView.frame.size.height+_liveView.frame.origin.y+viewH*1/totalHeight, viewW, viewH*176/totalHeight);
    _browse.contentMode=UIViewContentModeScaleToFill;
    _browse.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_browseClick)];
    [_browse addGestureRecognizer:singleTap2];
    [self.view addSubview:_browse];
    
    _browseView=[[UIImageView alloc]init];
    _browseView.frame = CGRectMake(0, _browse.frame.origin.y, viewW, viewH*26/totalHeight);
    _browseView.contentMode=UIViewContentModeScaleToFill;
    _browseView.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    [self.view addSubview:_browseView];
    
    _browseLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/375, _browse.frame.origin.y, viewW-diff_x, viewH*26/totalHeight)];
    _browseLabel.text = NSLocalizedString(@"browse_label", nil);
    _browseLabel.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _browseLabel.backgroundColor = [UIColor clearColor];
    _browseLabel.textColor = [UIColor whiteColor];
    _browseLabel.lineBreakMode = UILineBreakModeWordWrap;
    _browseLabel.numberOfLines = 0;
    [self.view addSubview:_browseLabel];
    
    //第四栏
    _liveStream=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live streaming_bg@3x.png"]];
    _liveStream.frame = CGRectMake(0, _browse.frame.size.height+_browse.frame.origin.y+viewH*1/totalHeight, viewW, viewH*176/totalHeight);
    _liveStream.contentMode=UIViewContentModeScaleToFill;
    _liveStream.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_liveStreamClick)];
    [_liveStream addGestureRecognizer:singleTap3];
    [self.view addSubview:_liveStream];
    
    _liveStreamView=[[UIImageView alloc]init];
    _liveStreamView.frame = CGRectMake(0, _liveStream.frame.origin.y, viewW, viewH*26/totalHeight);
    _liveStreamView.contentMode=UIViewContentModeScaleToFill;
    _liveStreamView.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    [self.view addSubview:_liveStreamView];
    
    _liveStreamLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/375, _liveStream.frame.origin.y, viewW-diff_x, viewH*26/totalHeight)];
    _liveStreamLabel.text = NSLocalizedString(@"live_stream_label", nil);
    _liveStreamLabel.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _liveStreamLabel.backgroundColor = [UIColor clearColor];
    _liveStreamLabel.textColor = [UIColor whiteColor];
    _liveStreamLabel.lineBreakMode = UILineBreakModeWordWrap;
    _liveStreamLabel.numberOfLines = 0;
    [self.view addSubview:_liveStreamLabel];

    //第五栏
    _configure=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"configure_bg@3x.png"]];
    _configure.frame = CGRectMake(0, _liveStream.frame.size.height+_liveStream.frame.origin.y+viewH*1/totalHeight, viewW, viewH*176/totalHeight);
    _configure.contentMode=UIViewContentModeScaleToFill;
    _configure.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_configureClick)];
    [_configure addGestureRecognizer:singleTap4];
    [self.view addSubview:_configure];
    
    _configureView=[[UIImageView alloc]init];
    _configureView.frame = CGRectMake(0, _configure.frame.origin.y, viewW, viewH*26/totalHeight);
    _configureView.contentMode=UIViewContentModeScaleToFill;
    _configureView.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    [self.view addSubview:_configureView];
    
    _configureLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/375, _configure.frame.origin.y, viewW-diff_x, viewH*26/totalHeight)];
    _configureLabel.text = NSLocalizedString(@"configure_label", nil);
    _configureLabel.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _configureLabel.backgroundColor = [UIColor clearColor];
    _configureLabel.textColor = [UIColor whiteColor];
    _configureLabel.lineBreakMode = UILineBreakModeWordWrap;
    _configureLabel.numberOfLines = 0;
    [self.view addSubview:_configureLabel];
*/

    //注册该页面可以执行滑动切换
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    
    _liveViewImgBtn=[[MainImageViewBtn alloc]initWithFrame:CGRectMake(0, viewH*205/totalHeight, viewW*303.5/totalWeight, viewH*115/totalHeight)];
    _liveViewImgBtn.userInteractionEnabled=YES;
    _liveViewImgBtn.center=CGPointMake(viewW/2, _liveViewImgBtn.center.y);
    _liveViewImgBtn.imgView.frame=CGRectMake(viewW*111.5/totalWeight, viewH*17.5/totalHeight, viewW*80/totalWeight, viewW*80/totalWeight);
//    _liveViewImgBtn.imgView.center=CGPointMake(_liveViewImgBtn.frame.size.width/2, _liveViewImgBtn.imgView.center.y);
    _liveViewImgBtn.imgView.image=[UIImage imageNamed:@"button_view_nor"];
//    _liveViewImgBtn.text.text=NSLocalizedString(@"live_view_label", nil);
    [_liveViewImgBtn addTarget:nil action:@selector(_liveViewClick) forControlEvents:UIControlEventTouchUpInside];
    [_liveViewImgBtn addTarget:nil action:@selector(_liveViewDown) forControlEvents:UIControlEventTouchDown];
    [_liveViewImgBtn addTarget:nil action:@selector(_liveViewCancel) forControlEvents:UIControlEventTouchUpOutside];
    [_liveViewImgBtn addTarget:nil action:@selector(_liveViewCancel) forControlEvents:UIControlEventTouchDragInside];
    [_liveViewImgBtn addTarget:nil action:@selector(_liveViewCancel) forControlEvents:UIControlEventTouchDragOutside];
    [_liveViewImgBtn addTarget:nil action:@selector(_liveViewCancel) forControlEvents:UIControlEventTouchDragEnter];
    [self.view addSubview:_liveViewImgBtn];
    
    
    _streamImgBtn=[[MainImageViewBtn alloc]initWithFrame:CGRectMake(0, viewH*335/totalHeight, viewW*303.5/totalWeight, viewH*115/totalHeight)];
    _streamImgBtn.userInteractionEnabled=YES;
    _streamImgBtn.center=CGPointMake(viewW/2, _streamImgBtn.center.y);
    _streamImgBtn.imgView.frame=CGRectMake(viewW*111.5/totalWeight, viewH*17.5/totalHeight, viewW*80/totalWeight, viewW*80/totalWeight);
//    _streamImgBtn.imgView.center=CGPointMake(_streamImgBtn.frame.size.width/2, _streamImgBtn.imgView.center.y);
    _streamImgBtn.imgView.image=[UIImage imageNamed:@"button_stream_nor"];
//    _streamImgBtn.text.text=NSLocalizedString(@"live_stream_label", nil);
    [_streamImgBtn addTarget:nil action:@selector(_liveStreamClick) forControlEvents:UIControlEventTouchUpInside];
    [_streamImgBtn addTarget:nil action:@selector(_liveStreamDown) forControlEvents:UIControlEventTouchDown];
    [_streamImgBtn addTarget:nil action:@selector(_liveStreamCancel) forControlEvents:UIControlEventTouchUpOutside];
    [_streamImgBtn addTarget:nil action:@selector(_liveStreamCancel) forControlEvents:UIControlEventTouchDragInside];
    [_streamImgBtn addTarget:nil action:@selector(_liveStreamCancel) forControlEvents:UIControlEventTouchDragOutside];
    [_streamImgBtn addTarget:nil action:@selector(_liveStreamCancel) forControlEvents:UIControlEventTouchDragEnter];
    [self.view addSubview:_streamImgBtn];
    
    
    _configureImgBtn=[[MainImageViewBtn alloc]initWithFrame:CGRectMake(viewW*36/totalWeight, viewH*465/totalHeight, viewW*145/totalWeight, viewH*145/totalHeight)];
    _configureImgBtn.userInteractionEnabled=YES;
    _configureImgBtn.imgView.frame=CGRectMake(viewW*32.5/totalWeight, viewH*32.5/totalHeight, viewW*80/totalWeight, viewW*80/totalWeight);
//    _configureImgBtn.imgView.center=CGPointMake(_configureImgBtn.frame.size.width/2, _configureImgBtn.center.y);
    _configureImgBtn.imgView.image=[UIImage imageNamed:@"button_configure_nor"];
//    _configureImgBtn.text.text=NSLocalizedString(@"configure_label", nil);
    [_configureImgBtn addTarget:nil action:@selector(_configureClick) forControlEvents:UIControlEventTouchUpInside];
    [_configureImgBtn addTarget:nil action:@selector(_configureDown) forControlEvents:UIControlEventTouchDown];
    [_configureImgBtn addTarget:nil action:@selector(_configureCancel) forControlEvents:UIControlEventTouchUpOutside];
    [_configureImgBtn addTarget:nil action:@selector(_configureCancel) forControlEvents:UIControlEventTouchDragInside];
    [_configureImgBtn addTarget:nil action:@selector(_configureCancel) forControlEvents:UIControlEventTouchDragOutside];
    [_configureImgBtn addTarget:nil action:@selector(_configureCancel) forControlEvents:UIControlEventTouchDragEnter];
    [self.view addSubview:_configureImgBtn];
    
    
    _browseImgBtn=[[MainImageViewBtn alloc]initWithFrame:CGRectMake(viewW*194.5/totalWeight, viewH*465/totalHeight, viewW*145/totalWeight, viewH*145/totalHeight)];
    _browseImgBtn.userInteractionEnabled=YES;
    _browseImgBtn.imgView.frame=CGRectMake(viewW*32.5/totalWeight, viewH*32.5/totalHeight, viewW*80/totalWeight, viewW*80/totalWeight);
//    _browseImgBtn.imgView.center=CGPointMake(_browseImgBtn.frame.size.width/2, _browseImgBtn.imgView.center.y);
    _browseImgBtn.imgView.image=[UIImage imageNamed:@"button_browse_nor"];
//    _browseImgBtn.text.text=NSLocalizedString(@"browse_label", nil);
    [_browseImgBtn addTarget:nil action:@selector(_browseClick) forControlEvents:UIControlEventTouchUpInside];
    [_browseImgBtn addTarget:nil action:@selector(_browseDown) forControlEvents:UIControlEventTouchDown];
    [_browseImgBtn addTarget:nil action:@selector(_browseCancel) forControlEvents:UIControlEventTouchUpOutside];
    [_browseImgBtn addTarget:nil action:@selector(_browseCancel) forControlEvents:UIControlEventTouchDragInside];
    [_browseImgBtn addTarget:nil action:@selector(_browseCancel) forControlEvents:UIControlEventTouchDragOutside];
    [_browseImgBtn addTarget:nil action:@selector(_browseCancel) forControlEvents:UIControlEventTouchDragEnter];
    [self.view addSubview:_browseImgBtn];
    
    _Exit=NO;
    _Scan = [[Rak_Lx52x_Device_Control alloc] init];
}

- (void)scanDevice
{
    if (_Exit) {
        return;
    }
    [NSThread detachNewThreadSelector:@selector(scanDeviceTask) toTarget:self withObject:nil];
}

- (void)scanDeviceTask
{
    Lx52x_Device_Info *result = [_Scan ScanDeviceWithTime:1.0f];
    [self performSelectorOnMainThread:@selector(scanDeviceOver:) withObject:result waitUntilDone:NO];
}

- (void)scanDeviceOver:(Lx52x_Device_Info *)result;
{
    if (result.Device_ID_Arr.count > 0) {
        dispatch_async(dispatch_get_main_queue(),^ {
            _liveViewCamera.image=[UIImage imageNamed:@"live view_gopro_icon_connect@3x.png"];
            _liveViewLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            _liveViewCamera.image=[UIImage imageNamed:@"live view_gopro_icon_not connect@3x.png"];
            _liveViewLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
        });
    }
    [NSThread sleepForTimeInterval:5.0];
    [self scanDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _Exit=NO;
    //[self _switchPortrait];
    //[self scanDevice];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _Exit=NO;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _Exit=YES;
}

//菜单
-(void)_menuBtnClick{
    NSLog(@"菜单");
    _Exit=YES;
    if(self.revealViewController.frontViewPosition==FrontViewPositionLeft){
        [self.revealViewController setFrontViewPosition:FrontViewPositionRight animated:YES];
    }
    else
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

//预览
-(void)_liveViewClick{
    NSLog(@"预览");
    _Exit=YES;
    _liveViewImgBtn.imgView.image=[UIImage imageNamed:@"button_view_nor"];
    _liveViewImgBtn.text.textColor=[UIColor whiteColor];
    [_liveViewImgBtn draw:MAIN_COLOR_T];
    LiveViewViewController *v = [[LiveViewViewController alloc] init];
    v.isLiveView=YES;
    [self.navigationController pushViewController: v animated:true];
    //[self presentViewController:v animated:YES completion:nil];
}

-(void)_liveViewDown{
    _liveViewImgBtn.imgView.image=[UIImage imageNamed:@"button_view_pre"];
    _liveViewImgBtn.text.textColor=MAIN_COLOR;
    [_liveViewImgBtn draw:MAIN_COLOR];
}

-(void)_liveViewCancel{
    _liveViewImgBtn.imgView.image=[UIImage imageNamed:@"button_view_nor"];
    _liveViewImgBtn.text.textColor=[UIColor whiteColor];
    [_liveViewImgBtn draw:MAIN_COLOR_T];
}

//回放
-(void)_browseClick{
    _Exit=YES;
    _browseImgBtn.imgView.image=[UIImage imageNamed:@"button_browse_nor"];
    _browseImgBtn.text.textColor=[UIColor whiteColor];
    [_browseImgBtn draw:MAIN_COLOR_T];
    BrowseViewController *v = [[BrowseViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
    NSLog(@"回放");
}

-(void)_browseDown{
    _browseImgBtn.imgView.image=[UIImage imageNamed:@"button_browse_pre"];
    _browseImgBtn.text.textColor=MAIN_COLOR;
    [_browseImgBtn draw:MAIN_COLOR];
}

-(void)_browseCancel{
    _browseImgBtn.imgView.image=[UIImage imageNamed:@"button_browse_nor"];
    _browseImgBtn.text.textColor=[UIColor whiteColor];
    [_browseImgBtn draw:MAIN_COLOR_T];
}

//直播
-(void)_liveStreamClick{
    _Exit=YES;
    _streamImgBtn.imgView.image=[UIImage imageNamed:@"button_stream_nor"];
    _streamImgBtn.text.textColor=[UIColor whiteColor];
    [_streamImgBtn draw:MAIN_COLOR_T];
    
    TTPlatformSelectViewController * vc = [[TTPlatformSelectViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
//    LiveViewViewController *v = [[LiveViewViewController alloc] init];
//    v.isLiveView=NO;
//    [self.navigationController pushViewController: v animated:true];
    NSLog(@"直播");
}

-(void)_liveStreamDown{
    _streamImgBtn.imgView.image=[UIImage imageNamed:@"button_stream_pre"];
    _streamImgBtn.text.textColor=MAIN_COLOR;
    [_streamImgBtn draw:MAIN_COLOR];
}

-(void)_liveStreamCancel{
    _streamImgBtn.imgView.image=[UIImage imageNamed:@"button_stream_nor"];
    _streamImgBtn.text.textColor=[UIColor whiteColor];
    [_streamImgBtn draw:MAIN_COLOR_T];
}

//配置
-(void)_configureClick{
    _Exit=YES;
    _configureImgBtn.imgView.image=[UIImage imageNamed:@"button_configure_nor"];
    _configureImgBtn.text.textColor=[UIColor whiteColor];
    [_configureImgBtn draw:MAIN_COLOR_T];
    PasswordViewController *v = [[PasswordViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
    NSLog(@"配置");
}

-(void)_configureDown{
    _configureImgBtn.imgView.image=[UIImage imageNamed:@"button_configure_pre"];
    _configureImgBtn.text.textColor=MAIN_COLOR;
    [_configureImgBtn draw:MAIN_COLOR];
}

-(void)_configureCancel{
    _configureImgBtn.imgView.image=[UIImage imageNamed:@"button_configure_nor"];
    _configureImgBtn.text.textColor=[UIColor whiteColor];
    [_configureImgBtn draw:MAIN_COLOR_T];
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
