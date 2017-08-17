//
//  LiveViewViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/10.
//             👆 Fuck code!!!!
//  refactor by Frank.  on 2017/8/1
//  Copyright © 2016年 rak. All rights reserved.
//

#import "LiveViewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <netinet/in.h>
#import <netdb.h>
#import <net/if.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import <arpa/inet.h>
#import <ifaddrs.h>
//Controllers
#import "PasswordViewController.h"
#import "TTPlatformSelectViewController.h"
#import "NetworkViewController.h"
#import "AudioViewController.h"
#import "BrowseViewController.h"
#import "SubtitleViewController.h"
#import "BannerViewController.h"
#import "PauseScreenViewController.h"
//others
#import "AlbumObject.h"
#import "TTCoreDataClass.h"
#import "TTSearchDeviceClass.h"
#import "CommanParameter.h"
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "LFLiveStreamInfo.h"
#import "LFLiveKit.h"
#import "LFLiveSessionWithPicSource.h"
#import "PicToBufferToPic.h"
#import "Scanner.h"
#import "CoreStore.h"
#import "CoreStore+App.h"
//#import "AppDelegate.h"
//#import "UIAlertController+Rotation.h"
//#import "TTAlertViewController+Rotation.h"

#define MAIN_COLOR [UIColor colorWithRed:(0 / 255.0f) green:(179 / 255.0f) blue:(227 / 255.0f) alpha:1.0]

/** 摄像头获取源 */
typedef NS_ENUM(NSInteger, CameraSource) {
    ExternalDevices  = 0 ,   // 外接硬件设备
    IphoneBackCamera = 1 ,  // 手机后置摄像头
};

typedef NS_ENUM(NSInteger, ButtonEnable){
    Enable,
    Unable
};

typedef NS_ENUM(NSUInteger, LivingState) {
    LivingStateStop = 0,//停止
    LivingStateLiving,  //直播中
    LivingStatePause,   //暂停
};

static NSInteger kWidth = 1280;
static NSInteger kHeight = 720;
static NSInteger configPort=80;//端口号
static const NSString *video_type = @"h264";
static enum ButtonEnable SavePictureEnable;
static enum ButtonEnable RecordVideoEnable;

@interface LiveViewViewController ()<LFLiveSessionWithPicSourceDelegate,WisViewDelegate,CAAutoFillDelegate,AlbumDelegate>

@property (nonatomic, strong) WisView *videoView;
@property (nonatomic, strong) PlatformModel *selectedPlatformModel;
@property (nonatomic, strong) LFLiveSessionWithPicSource *session;
@property (nonatomic, strong) UIAlertView *waitAlertView;
@property (nonatomic, strong) UIButton *platformButton;
/** 系统摄像头 展示view */
@property (nonatomic, strong) UIView *livingPreView;
/** 视频数据来源 */
@property (nonatomic, assign) CameraSource liveCameraSource;
@property (nonatomic, assign) LivingState livingState;
@property (nonatomic, strong) AlbumObject *albumObject;

@property (nonatomic, strong) NSTimer *uploadTimer;
@property (nonatomic, strong) NSTimer *recordVideoTimer;
@property (nonatomic, strong) NSTimer *updateUITimer;

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *userip;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userpassword;

@property (nonatomic, assign) BOOL isIphoneAudio;
@property (nonatomic, assign) BOOL videoisplaying;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isConfig;
@property (nonatomic, assign) BOOL isBroswer;
@property (nonatomic, assign) BOOL isShowBanner;
@property (nonatomic, assign) BOOL isShowSubtitle;
@property (nonatomic, assign) BOOL audioisEnable;
@property (nonatomic, assign) BOOL isExit;
@property (nonatomic, assign) BOOL isUser;
@property (nonatomic, assign) BOOL play_success;
@property (nonatomic, assign) BOOL searchDeviceHasResult;//default is NO
@property (nonatomic, assign) BOOL isGetedData;//获取到数据了
//@property (nonatomic, assign) BOOL videoViewIsNill;

@property (nonatomic, assign) CGFloat viewH;
@property (nonatomic, assign) CGFloat viewW;
@property (nonatomic, assign) CGFloat temp;
@property (nonatomic, assign) CGFloat tempviewW;
@property (nonatomic, assign) CGFloat tempviewH;
@property (nonatomic, assign) CGFloat totalWeight;//各部分比例
@property (nonatomic, assign) CGFloat totalHeight;
@property (nonatomic, assign) CGFloat imgAlpha;

@property (nonatomic, assign) NSInteger count_duration;
@property (nonatomic, assign) NSInteger count_interval;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, assign) NSInteger subtitle_count_duration;
@property (nonatomic, assign) NSInteger subtitle_count_interval;
@property (nonatomic, assign) NSInteger subtitle_duration;
@property (nonatomic, assign) NSInteger subtitle_interval;
@property (nonatomic, assign) NSInteger scanCount;
@property (nonatomic, assign) NSInteger playCount;

@property (nonatomic, strong) NSMutableArray *video_timesamp;
//** 推流相关参数 */
@property (nonatomic, strong) NSMutableArray *recordUrl;
@property (nonatomic, assign) CGFloat l_control_pos;
@property (nonatomic, assign) CGFloat c_control_pos;
@property (nonatomic, assign) CGFloat r_control_pos;

@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, copy) NSString *fps;
@property (nonatomic, copy) NSString *quality;

@end

@implementation LiveViewViewController

#pragma mark - getter/setter/lazy load property

- (NSMutableArray *)video_timesamp {
    if (!_video_timesamp) {
        _video_timesamp = @[].mutableCopy;
    }
    return _video_timesamp;
}

- (UIView *)livingPreView {
    if (!_livingPreView) {
        //添加系统相机展示view
        _livingPreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _livingPreView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesImage)];
        [_livingPreView addGestureRecognizer:singleTap];
        [self.view addSubview:_livingPreView];
    }
    return _livingPreView;
}

- (WisView *)videoView {
    if (!_videoView) {
        _videoView = [[WisView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _videoView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesImage)];
        [_videoView addGestureRecognizer:singleTap];
        _videoView.backgroundColor = [UIColor blackColor];
        
        [_videoView set_log_level:2];
        [_videoView sound:YES];
        [_videoView delegate:self];
        [self.view insertSubview:_videoView atIndex:0];
    }
    return _videoView;
}


#pragma mark - ------------------lifeCycle----

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewControllerSettings];
    
    [self addApplicationActiveNotifications];
    
    [self propertysInitialAndSetDefaultValue];
    
    [self liveViewInit];
    
    if (_play_success == NO){
        [self scanDevice];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    //判断设备的音频输入是不是手机麦克风
    NSUserDefaults * standDefaults = [NSUserDefaults standardUserDefaults];
    if ([standDefaults objectForKey:AudioSourceIsIphone]) {
        _isIphoneAudio = (BOOL)[standDefaults objectForKey:AudioSourceIsIphone];
        if (_session) {
            _session.isIphoneAudio = _isIphoneAudio;
        }
    }
    [self getSelectedPlatform];
    
    [self replayVideoView];
    [super viewDidAppear:animated];
    if (_isBroswer) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        _isBroswer=NO;
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES; //不让手机休眠
}


- (void)replayVideoView {
    
    if (!_searchDeviceHasResult) {//没有搜索结果
        return;
    }
         [self getDeviceConfig];
    NSString *urlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
//    NSLog(@"----------------log%@",urlString);
    
//    _videoView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//    [_videoView setView1Frame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//    [_videoView delegate:self];
    [self.videoView play:urlString useTcp:NO];
    [self.videoView sound:YES];
    [self.videoView startGetYUVData:YES];
    [self.videoView startGetAudioData:YES];
    [self.videoView startGetH264Data:YES];
    [self.videoView show_view:YES];
    self.videoisplaying = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(self.isBroswer){
        NSLog(@"-----_________---------%s",__func__);
        [self stopVideo];
    }
}

/**
 * 停止获取视频
 */
- (void)stopVideo {
    if (_isPlaying) {
        NSLog(@"-----_________---------%s",__func__);
        [self.videoView sound:NO];
        [self.videoView stop];
        _isPlaying=NO;
        self.videoisplaying = NO;
        _livingState = 0;
    }else{
        [self.videoView sound:NO];
        [self.videoView stop];
        _livingState = 0;
        NSLog(@"----------------xxxxxxxxxxxxxxxxx没有播放你就退出了");
    }
}
/** 返回*/
- (void)backBtnOnClicked{
    _backBtn.enabled = NO;
    NSLog(@"-----_________---------%s",__func__);
    self.isExit = YES;
    [self closeLivingSession];
    [self stopVideo];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [self prefersStatusBarHidden:YES];
    [self back];
    
}

/** 返回上个界面*/
-(void)back {
    NSLog(@"-----_________---------%s",__func__);
    [self timersInvalidate];
    
    self.videoisplaying = NO;
    self.isShowBanner = NO;
    self.isPlaying = NO;
    self.play_success=NO;
    self.isExit = YES;
    self.videoView = nil;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;//屏幕取消常亮
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if(_isLiveView){
//        [_tipLabel removeFromSuperview];
    }
    else{
        if ([_streamingAddress.text isEqualToString:@""]&&
            [_streamingAddress.text isEqualToString:@"address_text"]) {
            [self Save_Paths:_streamingAddress.text :STREAM_URL_KEY];
            [self addUrls];
        }
    }

}

- (void)didReceiveMemoryWarning {
    NSLog(@"---------receiceMemoryWarning.....");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)propertysInitialAndSetDefaultValue {
    _viewH = self.view.frame.size.width;
    _viewW = self.view.frame.size.height;
    _totalWeight = 64+71+149+149+149+80+5;//各部分比例
    _totalHeight = 375;//各部分比例
    
    _userip = @"192.168.100.1";
    _username = @"admin";
    _userpassword = @"admin";
    _audioisEnable=YES;//是否播放声音
    _isExit=NO;
    _isUser=NO;
    _isConfig=NO;
    _isBroswer=NO;
    _videoisplaying = NO;
    _recordUrl=[[NSMutableArray alloc]init];
    _recordUrl = [self Get_Urls:@"STREAMURL"];
    
    _count_duration=0;
    _count_interval=0;
    _duration=0;
    _interval=0;
    _imgAlpha=1.0;
    _subtitle_count_duration=0;
    _subtitle_count_interval=0;
    _subtitle_duration=0;
    _subtitle_interval=0;
    _isShowBanner=NO;
    _isShowSubtitle=NO;
    [_albumObject delegate:nil];
    _albumObject = nil;
    _albumObject = [[AlbumObject alloc]init];
    [_albumObject delegate:self];
    SavePictureEnable = Unable;
    RecordVideoEnable = Unable;
    _scanCount=0;
    
    _liveCameraSource = ExternalDevices;
    
    //调用手机摄像头显示画面才显示出来
    self.livingPreView.hidden = YES;
}

- (void)viewControllerSettings {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor=[UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    [self prefersStatusBarHidden:YES];
}

- (void)getSelectedPlatform {
    _selectedPlatformModel =  [[TTCoreDataClass shareInstance] localSelectedPlatform];
    if (_selectedPlatformModel) {
        NSString * name = _selectedPlatformModel.name;
        NSString * imageName;
        if ([name isEqualToString:youtubu]) {
            imageName = @"icon_youtube_02";
        }
        else if ([name isEqualToString:faceBook])
        {
            imageName = @"icon_facebook_02";
        }
        else if ([name isEqualToString:twitch])
        {
            imageName = @"icon_twitch";
        }
        
        else if ([name isEqualToString:uStream])
        {
            imageName = @"icon_ustream";
        }
        
        else if ([name isEqualToString:liveStream])
        {
            imageName = @"icon_livestream";
        }
        else if ([name isEqualToString:custom])
        {
            imageName = @"icon_choose";
        }
        else
        {
            imageName = @"icon_choose";
        }
        [_platformButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

- (void)getViewHAndViewWWithRightSize {
    
    _viewH = self.view.frame.size.width;
    _viewW = self.view.frame.size.height;
    if (_viewH > _viewW) {
        _viewW = self.view.frame.size.width;
        _viewH = self.view.frame.size.height;
    }
}

- (void)setUserInterfaceButtonsAndViews {
    
    //文字和角标
    _upperLeftImg=[[UIImageView alloc]init];
    _upperLeftImg.frame = CGRectMake(0, 0, _viewW, _viewH/6);
    _upperLeftImg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_upperLeftImg];
    _upperLeftImg.hidden=YES;
    
    _upperRightImg=[[UIImageView alloc]init];
    _upperRightImg.frame = CGRectMake(0, 0, _viewW, _viewH/6);
    _upperRightImg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_upperRightImg];
    _upperRightImg.hidden=YES;
    
    _lowerLeftImg=[[UIImageView alloc]init];
    _lowerLeftImg.frame = CGRectMake(0, 0, _viewW, _viewH/6);
    _lowerLeftImg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_lowerLeftImg];
    _lowerLeftImg.hidden=YES;
    
    _lowerRightImg=[[UIImageView alloc]init];
    _lowerRightImg.frame = CGRectMake(0, 0, _viewW, _viewH/6);
    _lowerRightImg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_lowerRightImg];
    _lowerRightImg.hidden=YES;
    
    _wordImg=[[UIImageView alloc]init];
    _wordImg.frame = CGRectMake(0, 0, _viewW, _viewH/6);
    _wordImg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_wordImg];
    _wordImg.hidden=YES;
    
    //顶部
    _topBg=[[UIImageView alloc]init];
    _topBg.userInteractionEnabled=YES;
    _topBg.backgroundColor=[UIColor colorWithRed:97/255.0 green:98/255.0 blue:100/255.0 alpha:0.4];
    _topBg.frame = CGRectMake(0, 0, _viewW, _viewH*55/_totalHeight);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back"]];
    backImage.frame = CGRectMake(_viewW*13/_totalHeight, _viewH*20/_totalHeight, _viewH*24.5/_totalHeight, _viewH*24.5/_totalHeight);
    [_topBg addSubview:backImage];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(0, 0, _viewW*80/_totalWeight, _viewH*64/_totalHeight);
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_backBtn addTarget:self action:@selector(backBtnOnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_topBg  addSubview:_backBtn];
    
    _connectImg=[[UIImageView alloc]init];
    _connectImg.image=[UIImage imageNamed:@"wifi"];
    _connectImg.frame = CGRectMake(_viewH*66/_totalHeight, _viewH*23/_totalHeight, _viewH*15/_totalHeight, _viewH*15/_totalHeight);
    //    _connectImg.center=CGPointMake(_connectImg.center.x, _backBtn.center.y);
    _connectImg.contentMode=UIViewContentModeScaleToFill;
    [_topBg addSubview:_connectImg];
    
    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(_viewH*88/_totalHeight, _viewH*23/_totalHeight, _viewH*150/_totalHeight, _viewH*15/_totalHeight)];
    _topLabel.text = [self getWifiName];
    _topLabel.font = [UIFont systemFontOfSize: _viewH*16/_totalHeight*0.8];
    _topLabel.backgroundColor = [UIColor clearColor];
    _topLabel.textColor = MAIN_COLOR;
    _topLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _topLabel.textAlignment = NSTextAlignmentLeft;
    _topLabel.numberOfLines = 0;
    [_topBg addSubview:_topLabel];
    
    
    NSMutableArray * buttonFrameArray = [NSMutableArray array];
    CGFloat buttonWidth = 30.f;
    CGFloat buttonMargin = 31.5;
    CGFloat firstX = (ScreenWidth - buttonWidth*6 - buttonMargin*5)/2;
    for (int i =0; i<6; i++) {
        
        CGRect rect = CGRectMake(firstX + i *(buttonWidth +buttonMargin), 12, buttonWidth, buttonWidth);
        [buttonFrameArray addObject: [NSValue valueWithCGRect:rect]];
    }
    
    //底部
    _bottomBg=[[UIImageView alloc] init];
    _bottomBg.userInteractionEnabled=YES;
    _bottomBg.backgroundColor=[UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:0.4];
    _bottomBg.frame = CGRectMake(0, _viewH-55, ScreenWidth, 55);
    _bottomBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_bottomBg];
    
    _takephotoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _takephotoBtn.frame =  [buttonFrameArray[0] CGRectValue];
    
    [_takephotoBtn setImage:[UIImage imageNamed:@"icon_camera_nor"] forState:UIControlStateNormal];
    [_takephotoBtn setImage:[UIImage imageNamed:@"icon_camera_pre"] forState:UIControlStateHighlighted];
    
    [_takephotoBtn addTarget:nil action:@selector(takephotoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg addSubview:_takephotoBtn];
    
    _recordBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _recordBtn.frame = [buttonFrameArray[1] CGRectValue];
    
    [_recordBtn setImage:[UIImage imageNamed:@"icon_play_nor"] forState:UIControlStateNormal];
    [_recordBtn setImage:[UIImage imageNamed:@"icon_play_pre"] forState:UIControlStateHighlighted];
    
    [_recordBtn addTarget:self action:@selector(recordBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg  addSubview:_recordBtn];
    
    _liveStreamBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _liveStreamBtn.frame = [buttonFrameArray[2] CGRectValue];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"icon_plush_nor"] forState:UIControlStateNormal];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"icon_plush_pre"] forState:UIControlStateHighlighted];
    [_liveStreamBtn addTarget:self action:@selector(liveStreamBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg  addSubview:_liveStreamBtn];
    
    
    _browserBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _browserBtn.frame = [buttonFrameArray[3] CGRectValue];
    [_browserBtn setImage:[UIImage imageNamed:@"icon_library_nor"] forState:UIControlStateNormal];
    [_browserBtn setImage:[UIImage imageNamed:@"icon_library_pre"] forState:UIControlStateHighlighted];
    [_browserBtn addTarget:self action:@selector(browserBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg  addSubview:_browserBtn];
    
    _configureBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _configureBtn.frame = [buttonFrameArray[4] CGRectValue];
    [_configureBtn setImage:[UIImage imageNamed:@"icon_configure_nor"] forState:UIControlStateNormal];
    [_configureBtn setImage:[UIImage imageNamed:@"icon_configure_pre"] forState:UIControlStateHighlighted];
    [_configureBtn addTarget:self action:@selector(_configureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _configureBtn.contentMode=UIViewContentModeScaleToFill;
    [_bottomBg  addSubview:_configureBtn];
    
    _platformButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_platformButton setImage:[UIImage imageNamed:@"icon_choose"] forState:UIControlStateNormal];
    _platformButton.frame = [buttonFrameArray[5] CGRectValue];
    [_platformButton addTarget:self action:@selector(platformButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg addSubview:_platformButton];
    
    
    _livePauseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = _viewH*44/_totalHeight;
    _livePauseBtn.frame = CGRectMake((ScreenWidth - width)/2, (ScreenHeight - width)/2, width, width);
    [_livePauseBtn setImage:[UIImage imageNamed:@"pause live_nor@3x.png"] forState:UIControlStateNormal];
    [_livePauseBtn setImage:[UIImage imageNamed:@"pause live_pre@3x.png"] forState:UIControlStateHighlighted];
    _livePauseBtn.contentMode=UIViewContentModeScaleToFill;
    [_livePauseBtn addTarget:nil action:@selector(livePauseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_livePauseBtn];
    _livePauseBtn.hidden=YES;
    
    _liveStopBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _liveStopBtn.frame = CGRectMake((ScreenWidth - width)/2, (ScreenHeight - width)/2, width, width);
    [_liveStopBtn setImage:[UIImage imageNamed:@"stop live_nor@3x.png"] forState:UIControlStateNormal];
    [_liveStopBtn setImage:[UIImage imageNamed:@"stop live_pre@3x.png"] forState:UIControlStateHighlighted];
    _liveStopBtn.contentMode=UIViewContentModeScaleToFill;
    [_liveStopBtn addTarget:nil action:@selector(liveStopBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_liveStopBtn];
    _liveStopBtn.hidden=YES;
    
    //视频状态栏
    _statusBg=[[UIImageView alloc]init];
    _statusBg.frame = CGRectMake(0, 0, _viewW, _viewH*44/_totalHeight);
    _statusBg.backgroundColor= [UIColor clearColor];
    _statusBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_statusBg];
    
    _powerView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"power_01@3x.png"]];
    _powerView.frame = CGRectMake(0, _statusBg.frame.origin.y, _viewH*14/_totalHeight*90/42, _viewH*14/_totalHeight);
    _powerView.center=CGPointMake(_viewW-_powerView.frame.size.width/2-diff_x, _statusBg.center.y);
    _powerView.contentMode=UIViewContentModeScaleToFill;
    [_statusBg addSubview:_powerView];
    
    _audioView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"audio mode 1@3x.png"]];
    _audioView.frame = CGRectMake(0, _statusBg.frame.origin.y, _viewH*14/_totalHeight*90/42, _viewH*14/_totalHeight);
    _audioView.center=CGPointMake(_powerView.frame.origin.x-_audioView.frame.size.width/2-_viewW*20/_totalWeight, _statusBg.center.y);
    _audioView.contentMode=UIViewContentModeScaleToFill;
    [_statusBg addSubview:_audioView];
    
    _onliveView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live view_Indicator light_gray@3x.png"]];
    _onliveView.frame = CGRectMake(0, _statusBg.frame.origin.y, _viewH*18/_totalHeight, _viewH*18/_totalHeight);
    _onliveView.center=CGPointMake(_viewW/2, _statusBg.center.y+_viewH*2/_totalHeight);
    _onliveView.contentMode=UIViewContentModeScaleToFill;
    [_statusBg addSubview:_onliveView];
    
    _onliveLabel = [[UILabel alloc] initWithFrame:CGRectMake(_onliveView.frame.origin.x+_onliveView.frame.size.width, _statusBg.frame.origin.y, _viewW*120/_totalWeight, _statusBg.frame.size.height)];
    _onliveLabel.center=CGPointMake(_onliveLabel.center.x, _statusBg.center.y);
    _onliveLabel.text = NSLocalizedString(@"not_live", nil);
    _onliveLabel.font = [UIFont systemFontOfSize: _viewH*16/_totalHeight*0.8];
    _onliveLabel.backgroundColor = [UIColor clearColor];
    _onliveLabel.textColor = [UIColor whiteColor];
    _onliveLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _onliveLabel.textAlignment = NSTextAlignmentLeft;
    _onliveLabel.numberOfLines = 0;
    [_statusBg addSubview:_onliveLabel];
    
    _recordTimeLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, _statusBg.frame.origin.y+_statusBg.frame.size.height+_viewH*2/_totalWeight, _viewW-diff_x, _viewH*20/_totalWeight)];
    _recordTimeLabel.text = @"REC 00:00";
    _recordTimeLabel.font = [UIFont systemFontOfSize: _viewH*18/_totalHeight*0.8];
    _recordTimeLabel.backgroundColor = [UIColor clearColor];
    _recordTimeLabel.textColor = [UIColor redColor];
    _recordTimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _recordTimeLabel.textAlignment = NSTextAlignmentRight;
    _recordTimeLabel.numberOfLines = 0;
    _recordTimeLabel.hidden=YES;
    [self.view addSubview:_recordTimeLabel];
    
    
    _searchDeviceImageView =[[UIImageView alloc] initWithFrame:CGRectMake(_viewW*304/_totalWeight,129*_viewH/_totalHeight, _viewW*58.5/_totalWeight, _viewW*58.5/_totalWeight)];
    
    _searchDeviceImageView.image=[UIImage imageNamed:@"logo_148"];
    
    [self.view addSubview:_searchDeviceImageView];
    
    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,129*_viewH/_totalHeight +  _viewW*58.5/_totalWeight + 10*_viewH/_totalHeight, _viewW*300/_totalWeight, _viewH*40/_totalHeight)];
    _tipLabel.center = CGPointMake(_searchDeviceImageView.center.x,_tipLabel.center.y);
    _tipLabel.text = NSLocalizedString(@"video_connecting", nil);
    _tipLabel.textColor = MAIN_COLOR;
    _tipLabel.font = [UIFont systemFontOfSize:12.5];
    //    _tipLabel.adjustsFontSizeToFitWidth = YES;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tipLabel.numberOfLines = 0;
    _tipLabel.backgroundColor=[UIColor clearColor]; //可以去掉背景色
    [self.view addSubview:_tipLabel];
    [self hidenSearchingMessageTips];
}

- (void)hidenSearchingMessageTips {
    _tipLabel.hidden = YES;
    _searchDeviceImageView.hidden = YES;
}

- (void)showSearchingMessagesTips {
    _tipLabel.hidden = NO;
    _searchDeviceImageView.hidden = NO;
}

/** 直播界面初始化*/
- (void)liveViewInit{
    
    [self getViewHAndViewWWithRightSize];
    
    [self setUserInterfaceButtonsAndViews];
    
    [self hiddenStatus];
    
    
    _recordVideoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordVideoTimerLoop) userInfo:nil repeats:YES];
    _updateUITimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
}

/** 未播放隐藏topview状态栏*/
- (void)hiddenStatus {
    _statusBg.hidden=YES;
    _onliveView.hidden=YES;
    _onliveLabel.hidden=YES;
    _audioView.hidden=YES;
    _powerView.hidden=YES;
    //    _takephotoBtn.alpha=0.4;
    //    _recordBtn.alpha=0.4;
    //    _browserBtn.alpha=0.4;
    //    _configureBtn.alpha=0.4;
}

/** 已播放显示状态栏*/
- (void)noHiddenStatus {
    _statusBg.hidden=NO;
    _onliveView.hidden=NO;
    _onliveLabel.hidden=NO;
    _audioView.hidden=NO;
    _powerView.hidden=NO;
    _takephotoBtn.alpha=1.0;
    _recordBtn.alpha=1.0;
    _browserBtn.alpha=1.0;
    _configureBtn.alpha=1.0;
}

/** 显示或隐藏顶部和底部*/
-(void)touchesImage{
    if(_topBg.hidden){
        [self moveInAnimation];
    }else{
        [self revealAnimation];
    }
}

/** 使能相关按钮 */
-(void)enableControl{
    _takephotoBtn.enabled=true;
    _liveStreamBtn.enabled=true;
    _recordBtn.enabled=true;
    _configureBtn.enabled = YES;
}

/** 禁用相关按钮 */
-(void)disableControl{
    _takephotoBtn.enabled=false;
    _liveStreamBtn.enabled=false;
    _recordBtn.enabled=false;
    _configureBtn.enabled = NO;
}

/** 添加按钮声音效果 */
- (void)playSound:(NSString *)sourcePath {
    //1.获得音效文件的全路径
    NSURL *url=[[NSBundle mainBundle]URLForResource:sourcePath      withExtension:nil];
    //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
    SystemSoundID soundID=0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    //3.播放音效文件
    //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
    //AudioServicesPlayAlertSound(soundID);
    AudioServicesPlaySystemSound(soundID);
}

/** 记录录像时间 */
int VideoRecordTimerTick_s = 0;
int VideoRecordTimerTick_m = 0;
bool VideoRecordIsEnable = NO;
- (void)recordVideoTimerLoop {
    
    if (RecordVideoEnable == Unable) {
        return;
    }
    VideoRecordTimerTick_s ++;
    if (VideoRecordTimerTick_s > 59) {
        VideoRecordTimerTick_m++;
        VideoRecordTimerTick_s = 0;
    }
    if (VideoRecordTimerTick_m > 59) {
        VideoRecordTimerTick_m = 0;
    }
    _recordTimeLabel.text = [NSString stringWithFormat:@"REC %.2d:%.2d",VideoRecordTimerTick_m,VideoRecordTimerTick_s];
}

- (void)timersInvalidate {
    if (_updateUITimer) {
        [_updateUITimer invalidate];
        _updateUITimer = nil;
    }
    
    if (_uploadTimer) {
        [_uploadTimer invalidate];
        _uploadTimer=nil;
    }
    
    if (_recordVideoTimer) {
        [_recordVideoTimer invalidate];
        _recordVideoTimer = nil;
    }
}



/** 跳转到配置推流信息的界面*/
-(void)_configureBtnClick
{
    if (_liveCameraSource == IphoneBackCamera) {
        return;
    }
    
    //    _isConfig = YES;
    _isBroswer=YES;
    [self stopVideo];
    
    PasswordViewController * v = [[PasswordViewController alloc] init];
    if (_userip) {
        v.configIP = _userip;
    }
    
    v.changeVideoNeedReplayBlock = ^(){
       
    };
    
    [self.navigationController pushViewController:v animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}



///** 设置横竖屏*/
//int valOrientation;
//-(void)_scaleBtnClick:(int)type{
//    SEL selector = NSSelectorFromString(@"setOrientation:");
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//    [invocation setSelector:selector];
//    [invocation setTarget:[UIDevice currentDevice]];
//    if(type==0){
//        valOrientation = UIInterfaceOrientationPortrait;
//    }
//    else if(type==1){
//        if (self.interfaceOrientation==UIDeviceOrientationLandscapeRight) {
//
//            valOrientation = UIInterfaceOrientationLandscapeLeft;
//        }
//        else{
////            NSLog(@"other");
//            valOrientation = UIInterfaceOrientationLandscapeRight;
//        }
//    }
//    [invocation setArgument:&valOrientation atIndex:2];
//    [invocation invoke];
//}

/**
 *  扫描设备
 */
#pragma mark - 扫描设备--------------------------
- (void)scanDevice {
    if (_isExit) {
        return;
    }
    _tipLabel.text = NSLocalizedString(@"video_connecting", nil);
    [self showSearchingMessagesTips];
    [_updateUITimer setFireDate:[NSDate distantPast]];//启动
    [self disableControl];
    [[TTSearchDeviceClass shareInstance] searDeviceWithSecond:5 CompletionHandler:^(Scanner *resultinfo) {
        [self scanDeviceOver:resultinfo];
    }];
}

- (void)scanDeviceOver:(Scanner *)result {
    if (_isExit) {
        return;
    }
    
    if (result.Device_ID_Arr.count > 0) {
        self.scanCount = 0;
        _searchDeviceHasResult = YES;
        //使用扫描到的第一个设备
        _userip = [result.Device_IP_Arr objectAtIndex:0];
        _userid = [result.Device_ID_Arr objectAtIndex:0];
        NSString *urlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
        //        NSLog(@"??????????????????????????scan userip=%@",urlString);
        
        [self getDeviceConfig];
        
        [self.videoView play:urlString useTcp:NO];
        [self.videoView sound:YES];
        [self.videoView startGetYUVData:YES];
        [self.videoView startGetAudioData:YES];
        [self.videoView startGetH264Data:YES];
        [self.videoView show_view:YES];
        self.videoisplaying = YES;
        
        [self enableControl];
    } else {
        _searchDeviceHasResult = NO;
        [_updateUITimer setFireDate:[NSDate distantFuture]];
        self.videoisplaying = NO;
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showActionSheetWithTitle:nil message:@"No search for equipment, whether to continue searching or using a mobile phone camera？" action1title:@"Continue Search" action2title:@"Use iPhone Camera" action3title:@"Cancel" action1Handler:^(UIAlertAction *action) {
                self.scanCount = 0;
                [self scanDevice];
            } action2Handler:^(UIAlertAction *action) {
                
                _session = [self getSessionWithSystemCamera];
                self.livingPreView.hidden = NO;
                [self hidenSearchingMessageTips];
                [self noHiddenStatus];
                _play_success = YES;
                _liveCameraSource = IphoneBackCamera;
                [self enableControl];
            } action3Handler:^(UIAlertAction *action) {
                [self backBtnOnClicked];
            }];
        });
    }
}

#pragma mark -------------------
#pragma mark WisviewDelegate


/**
 *  获取屏幕尺寸变化作相应适配
 */
- (void)GetYUVData:(int)width :(int)height
                  :(Byte*)yData :(Byte*)uData :(Byte*)vData
                  :(int)ySize :(int)uSize :(int)vSize
{
    CGFloat resultW = width;
    CGFloat resultH = height;
    //    NSLog(@"获取屏幕尺寸变化作相应适配 GetYUVData ");
    _isPlaying=YES;
    if(_livingState==2){
        [self.session upload_PauseImg];
    }
    
    if (_isLiveView){
        [self addBannerSubtitle];
        if ((resultH!=kHeight)||(resultW!=kWidth)) {
            
            CGFloat videoviewH = (MIN(height, width) > kHeight)? _viewH: _viewH * (resultW/resultH);
            CGFloat videoviewW = (MAX(height, width) > kWidth )? _viewW: _viewW * (resultH/resultW);
            
            self.videoView.frame = CGRectMake((_viewW - videoviewW)/2.f, (_viewH - videoviewH)/2.f, _viewW  , _viewH);
//            NSLog(@"=++++++++=========+%@,,,%@",NSStringFromCGRect(self.videoView.frame),NSStringFromCGRect(self.view.frame));
            [self.videoView setView1Frame:self.videoView.frame];
            //            self.videoView.center = CGPointMake( _viewH*0.5,_viewW*0.5);
            //            NSLog(@"_width=%ld,height=%ld",(long)kWidth,(long)kHeight);
            //
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                if (_viewH>_viewW) {
            //                    _temp=_viewW;
            //                    _tempviewW=_viewH;
            //                    _tempviewH=_temp;
            //                }
            //                if (_tempviewH<_tempviewW*kHeight/kWidth) {
            //                    self.videoView.frame =CGRectMake(0, 0, _tempviewH*kWidth/kHeight, _tempviewH);
            //                    [self.videoView setView1Frame:CGRectMake(0, 0, _tempviewH*kWidth/kHeight, _tempviewH)];
            //                    NSLog(@"w3=%f,h3=%f",self.videoView.frame.size.width,self.videoView.frame.size.height);
            //                }
            //                else{
            //                    self.videoView.frame =CGRectMake(0, 0, _tempviewW, _tempviewW*kHeight/kWidth);
            //                    [self.videoView setView1Frame:CGRectMake(0, 0, _tempviewW, _tempviewW*kHeight/kWidth)];
            //                    NSLog(@"w4=%f,h4=%f",_videoView.frame.size.width,_videoView.frame.size.height);
            //                }
            //                self.videoView.center=CGPointMake(_tempviewW*0.5, _tempviewH*0.5);
            //            });
        }
    }
}



- (void)state_changed:(int)state {
    NSLog(@"WisviewDelegate state_changed state = %d", state);
    switch (state) {
        case 0: //STATE_IDLE
        {
            _play_success = NO;
            break;
        }
        case 1: //STATE_PREPARING
        {
            _play_success = NO;
            break;
        }
        case 2: //STATE_PLAYING
        {
            _play_success = YES;
            self.videoisplaying=YES;
            if (_isLiveView) {
                [self enableControl];
                dispatch_async(dispatch_get_main_queue(),^ {
                    [self noHiddenStatus];
                    [self hidenSearchingMessageTips];
                });
            }
            break;
        }
        case 3: //STATE_STOPPED
        {
            _play_success = NO;
            break;
        }
        case 4: //STATE_OPEN_URL_FAILED
        {
            _play_success = NO;
            NSLog(@"STATE_OPEN_URL_FAILED");
            dispatch_async(dispatch_get_main_queue(),^ {
                [self replayVideoView];
            });
            
            break;
        }
        default:
            break;
    }
}

- (void)video_info:(NSString *)codecName codecLongName:(NSString *)codecLongName {
    NSLog(@"video_info :  codecName:%@ codecLongName:%@",codecName,codecLongName);
}

- (void)audio_info:(NSString *)codecName codecLongName:(NSString *)codecLongName sampleRate:(int)sampleRate channels:(int)channels {
    NSLog(@"audio_info : codecName:%@ codecLongName:%@ sampleRate:%d channels:%d",codecName,codecLongName,sampleRate,channels);
}

/**
 *  回调获取视频imageRef
 */
- (void)take_imageRef:(CGImageRef)imageRef{
    debugMethod();
    if(_livingState==1){
        if (_isTakePhoto) {
            _isTakePhoto=NO;
            [_albumObject saveImageToAlbum: [UIImage imageWithCGImage:imageRef] albumName:album_name];
        }
        [self.session upload_imageRef:imageRef];
    } else {
        CGImageRelease(imageRef);
    }
}

- (void)GetAudioData:(Byte*)data :(int)size//回调获取音频数据
{
//    NSLog(@"GetAudioData");
    if(_livingState == LivingStateLiving && !_isIphoneAudio){
        
        AudioBufferList audioBufferList;
        audioBufferList.mNumberBuffers = 1;
        audioBufferList.mBuffers[0].mNumberChannels=2;
        audioBufferList.mBuffers[0].mDataByteSize=size;
        audioBufferList.mBuffers[0].mData = data;
        
        [self.session upload_audio:audioBufferList];
    }
}

- (void)GetH264Data:(int)width :(int)height :(int)size :(Byte*)data//回调获取H264数据
{
//    NSLog(@"GetH264Data");
    if(_livingState == LivingStateLiving){
        [self.session upload_h264:size :data];
    }
}
/**
 *  视频链接状态及重连
 */
-(void)updateUI{
    
    if (self.videoisplaying ==NO) {
        if (_scanCount >= 5) {
            _tipLabel.text = NSLocalizedString(@"no_device", nil);
            _scanCount = 0;
        }
    }else{
        if (_play_success ==NO){
            //            ActivityIndicatorView.hidden=YES;
            if (_viewW<_viewH) {
                _tipLabel.center=CGPointMake(_viewH*0.5, _tipLabel.center.y);
            }
            else{
                _tipLabel.center=CGPointMake(_viewW*0.5, _tipLabel.center.y);
            }
            _tipLabel.textAlignment=NSTextAlignmentCenter;
            _tipLabel.text = NSLocalizedString(@"no_video", nil);
        }
    }
    
    if (_isPlaying) {
        _playCount=0;
        //        ActivityIndicatorView.hidden=YES;
        if (_viewW<_viewH) {
            _tipLabel.center=CGPointMake(_viewH*0.5, _tipLabel.center.y);
        }
        else{
            _tipLabel.center=CGPointMake(_viewW*0.5, _tipLabel.center.y);
        }
        _tipLabel.textAlignment=NSTextAlignmentCenter;
    } else {
        _playCount++;
    }
    //_isPlaying=NO;
    __weak typeof(self) weakself = self;
    if (_play_success) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int netFlow = [weakself checkNetworkflow];
            int flow=(int)(netFlow/1024);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (flow>0) {
                    if(flow<20){
                        _tipLabel.text=NSLocalizedString(@"no_video", nil);
                        [weakself showSearchingMessagesTips];
                    }else{
                        [weakself hidenSearchingMessageTips];
                    }
                }
            });
        });
    }
    _scanCount++;
}

/**
 *  监测流量判断是否接入相机并作相应的提示
 */
-(int)checkNetworkflow{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return 0;
    }
    uint32_t iBytes     = 0;
    uint32_t oBytes     = 0;
    uint32_t allFlow    = 0;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        // Not a loopback device.
        // network flow
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }
    }
    freeifaddrs(ifa_list);
    static int lastFlow = -1;
    static int flow = 0;
    if (lastFlow == -1) {
        lastFlow = allFlow;
    }
    flow = allFlow - lastFlow;
    NSString *networkFlow      = [self bytesToAvaiUnit:flow];
    lastFlow = allFlow;
    //    NSLog(@"networkFlow==%@",networkFlow);
    return flow;
}

-(NSString *)bytesToAvaiUnit:(int)bytes
{
    if(bytes < 1024)		// B
    {
        return [NSString stringWithFormat:@"%dB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024)	// KB
    {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)	// MB
    {
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }
    else	// GB
    {
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}


//Set StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden:(BOOL)hidden//for iOS7.0
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return  UIInterfaceOrientationLandscapeLeft;
}

#pragma mark-- Toast显示示例
-(void)showAllTextDialog:(NSString *)str{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //更新UI操作
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [weakself.view addSubview:HUD];
        HUD.labelText = str;
        HUD.mode = MBProgressHUDModeText;
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
            [HUD removeFromSuperview];
            //[HUD release];
            //HUD = nil;
        }];
        
    });
    
}

#pragma mark-- 获取电量
-(void)GetPower{
    while(!_isExit){
        NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_adc&type=h264&pipe=0",_userip,80];
        HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
        NSLog(@"====>%@",http_request.ResponseString);
        if(http_request.StatusCode==200)
        {
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *_signal=[weakself parseJsonString:http_request.ResponseString];
                int strength=0;
                if (([_signal compare:@"76"] == NSOrderedAscending)) {
                    strength=1;
                }
                else if (([_signal compare:@"75"] == NSOrderedDescending)
                         &&([_signal compare:@"51"] == NSOrderedAscending)) {
                    strength=2;
                }
                else if (([_signal compare:@"50"] == NSOrderedDescending)
                         &&([_signal compare:@"26"] == NSOrderedAscending)) {
                    strength=3;
                }
                else if (([_signal compare:@"25"] == NSOrderedDescending)) {
                    strength=4;
                }
                
                NSString *param = [NSString stringWithFormat:@"power_01@3x.png", strength];
                _powerView.image = [UIImage imageNamed:param];
            });
        }
        
        [NSThread sleepForTimeInterval:5.0f];
    }
}

#pragma mark-- 获取音频输入
-(void)GetAudioInput{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_audio_source&type=h264&pipe=0",_userip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *_signal=[weakself parseJsonString:http_request.ResponseString];
            if (([_signal compare:@"0"] == NSOrderedSame)) {
                
            }
            else if (([_signal compare:@"1"] == NSOrderedSame)) {
                _audioView.image=[UIImage imageNamed:@"audio mode 1@3x.png"];
            }
            else if (([_signal compare:@"2"] == NSOrderedSame)) {
                _audioView.image=[UIImage imageNamed:@"audio mode 2@3x.png"];
            }
        });
    }
}

#pragma mark-- 获取直播状态
-(void)GetStreamStatus{
    
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=is_pipe_live&type=h264&pipe=0",_userip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *_signal=[weakself parseJsonString:http_request.ResponseString];
            if (([_signal compare:@"0"] == NSOrderedSame)) {
                _onliveLabel.text = NSLocalizedString(@"not_live", nil);
                _onliveView.image=[UIImage imageNamed:@"live view_Indicator light_gray@3x.png"];
            }
            else if (([_signal compare:@"1"] == NSOrderedSame)) {
                _onliveLabel.text = NSLocalizedString(@"on_live", nil);
                _onliveView.image=[UIImage imageNamed:@"live view_pilot lamp_on@3x.png"];
            }
            else if (([_signal compare:@"2"] == NSOrderedSame)) {
                
            }
        });
    }
}

#pragma mark-- 停止或开启直播
//option:0 表示停止直播； 1表示开始直播； 2 表示暂停直播
-(void)SetStreamStatus:(int)option{
    NSString *URL;
    
    if (option==0) {
        URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=stop_live&type=h264&pipe=0",_userip,80];
    }
    else if (option==1) {
        URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=start_live_pipe&type=h264&pipe=0&pipeip=%@",_userip,80,[self getDeviceIPIpAddresses]];
    }
    else if (option==2) {
        URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=hold_live_pipe&type=h264&pipe=0",_userip,80];
    }
    
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    NSLog(@"----------------%d",http_request.StatusCode);
    if(http_request.StatusCode==200)
    {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *_signal=[weakself parseJsonString:http_request.ResponseString];
            if (([_signal compare:@"0"] == NSOrderedSame)) {
                if ([_onliveLabel.text compare:NSLocalizedString(@"on_live", nil)]==NSOrderedSame){
                    _onliveLabel.text = NSLocalizedString(@"not_live", nil);
                    _onliveView.image=[UIImage imageNamed:@"live view_Indicator light_gray@3x.png"];
                }
                else{
                    _onliveLabel.text = NSLocalizedString(@"on_live", nil);
                    _onliveView.image=[UIImage imageNamed:@"live view_pilot lamp_on@3x.png"];
                }
            }
        });
    }
}

-(NSString*)parseJsonString:(NSString *)srcStr{
    NSString *Str=@"";
    NSString *keyStr=@"\"value\":\"";
    NSString *endStr=@"\"";
    NSRange range=[srcStr rangeOfString:keyStr];
    if (range.location != NSNotFound) {
        int i=(int)range.location;
        srcStr=[srcStr substringFromIndex:i+keyStr.length];
        NSRange range1=[srcStr rangeOfString:endStr];
        if (range1.location != NSNotFound) {
            int j=(int)range1.location;
            NSRange diffRange=NSMakeRange(0, j);
            Str=[srcStr substringWithRange:diffRange];
        }
    }
    return Str;
}

/**
 *  获取手机的ip地址
 */
- (NSString *)getDeviceIPIpAddresses
{
    int sockfd =socket(AF_INET,SOCK_DGRAM, 0);
    NSMutableArray *ips = [NSMutableArray array];
    int BUFFERSIZE =4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd,SIOCGIFCONF, &ifc) >= 0){
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            ifr = (struct ifreq *)ptr;
            int len =sizeof(struct sockaddr);
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family !=AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name,':')) != NULL) *cptr =0;
            if (strncmp(lastname, ifr->ifr_name,IFNAMSIZ) == 0)continue;
            memcpy(lastname, ifr->ifr_name,IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd,SIOCGIFFLAGS, &ifrcopy);
            if ((ifrcopy.ifr_flags &IFF_UP) == 0)continue;
            NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    close(sockfd);
    NSString *deviceIP =@"";
    for (int i=0; i < ips.count; i++)
    {
        if (ips.count >0)
        {
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    NSLog(@"deviceIP========%@",deviceIP);
    return deviceIP;
}


#pragma mark - *********************** session 推流参数配置***********************************
/**
 *  系统摄像头的直播参数
 */

- (LFLiveSessionWithPicSource *)getSessionWithSystemCamera
{
    /**
     *  构造音频配置器
     *       */
    LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_High];
    
    
    LFLiveVideoConfiguration * videoConfiguration = [LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_High1 outputImageOrientation:UIInterfaceOrientationLandscapeRight];
    //利用两设备配置 来构造一个直播会话
    _session = [[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
    _session.captureDevicePosition = AVCaptureDevicePositionBack;
    _session.delegate  = self;
    _session.isRAK = NO;
    _session.running = YES;
    _session.preView = self.livingPreView;
    return _session;
}

//RAK设备的直播参数

- (LFLiveSessionWithPicSource *)getSessionWithRakisrak:(BOOL)rak {
    /**
     *  构造音频配置器
     *       */
    LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
    audioConfiguration .numberOfChannels = 2;
    audioConfiguration .audioBitrate = LFLiveAudioBitRate_96Kbps;
    audioConfiguration .audioSampleRate = LFLiveAudioSampleRate_48000Hz;
    
    /**
     * 构造视频配置
     * 窗体大小，比特率，最大比特率，最小比特率，帧率，最大间隔帧数，分辨率（注意视频大小一定要小于分辨率）
     */
    LFLiveVideoConfiguration  *videoConfiguration = [LFLiveVideoConfiguration new];
    
    NSInteger bitRatevalue         = [_quality intValue]*3000/52.0; //设备的比特率
    NSUInteger  videoFrameRate = 30;                          //设备的fps
    NSInteger maxbitRate = 1000*1024;
    bitRatevalue =         800 *1024;
    NSInteger minbitrate = 200*1024;
    CGFloat videosizeWidth  = 0.0;
    CGFloat videosizeHeight = 0.0;
    //设备的分辨率
    if ([_resolution integerValue] == 3)
    {
        videoConfiguration .sessionPreset = LFCaptureSessionPreset720x1280;
        videosizeWidth  = 720;
        videosizeHeight = 1280;
        bitRatevalue = 800*1024;
        minbitrate   = 200*1024;
        maxbitRate = 1000*1024;
        videoFrameRate = 30;
    }
    else if ([_resolution integerValue] == 2)
    {
        videoConfiguration .sessionPreset = LFCaptureSessionPreset720x1280;
        videosizeWidth  = 720;
        videosizeHeight = 1280;
        
        bitRatevalue = 800*1024;
        minbitrate   = 200*1024;
        maxbitRate = 1000*1024;
        videoFrameRate = 30;
        
        
    }
    else
    {
        videoConfiguration .sessionPreset = LFCaptureSessionPreset540x960;
        videosizeWidth  = 540;
        videosizeHeight = 960;
        
        bitRatevalue = 500*1024;
        minbitrate   = 200*1024;
        maxbitRate = 700*1024;
        videoFrameRate = 20;
        
    }
    
    
    videoConfiguration .videoBitRate    = bitRatevalue;       //比特率
    videoConfiguration .videoMaxBitRate = maxbitRate;    //最大比特率
    videoConfiguration .videoMinBitRate = minbitrate;     //最小比特率
    videoConfiguration .videoFrameRate  = videoFrameRate;            //帧率
    
    videoConfiguration .videoMaxKeyframeInterval = videoFrameRate*2; //最大关键帧间隔数
    videoConfiguration.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
    
    //分辨率：0：360*540 1：540*960 2：720*1280 3:1920*1080
    //    videoConfiguration .sessionPreset = LFCaptureSessionPreset720x1280;
    
    if (videoConfiguration .landscape)
    {
        videoConfiguration .videoSize = CGSizeMake(videosizeHeight, videosizeWidth);  //视频大小
    }
    else
    {
        videoConfiguration .videoSize = CGSizeMake(videosizeWidth, videosizeHeight);  //视频大小
    }
    
    
    //利用两设备配置 来构造一个直播会话
    _session = [[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
    _session.delegate  = self;
    _session.isRAK=rak;
    _session.isIphoneAudio = _isIphoneAudio;
    _session.running =YES;
    _session.preView = self.livingPreView;
    return _session;
}

/**
 *  开始直播
 */
#pragma mark - 开始直播************************************
-(void)openLivingSession:(LivingDataSouceType) type{
    
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    //    stream.url=[self Get_String:STREAM_URL_KEY];
    NSString * rtmpUrl;
    
    if (_selectedPlatformModel) {
        rtmpUrl = [NSString stringWithFormat:@"%@/%@",_selectedPlatformModel.rtmp,_selectedPlatformModel.streamKey];
    }
    
    if (rtmpUrl) {
        stream.url = rtmpUrl;
    } else {
        //没有推流地址
    }

    if (stream.url==nil || stream.url.length == 0) {
        [self showAllTextDialog:NSLocalizedString(@"video_url_empty", nil)];
        return;
    }
    
    _livingState = 1;
    
    if (_session) {
        //        _session.dataSoureType = type;
        [_session startLive:stream];
    }
    
}



/**
 *  关闭直播
 */
-(void)closeLivingSession{
    if (!_isLiveView) {
        [self stopVideo];
    }
    [self setStopStreamStatus];
    
    if(self.session.state == LFLivePending || self.session.state ==LFLiveStart){
        [self.session stopLive];
//        [self.session setRunning:NO];
    }
}


#pragma mark --LFStreamingSessionDelegate
-(void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo{
    
}

-(void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString *networkStatusInfo;
    [self hideHudLoading];
    switch (state) {
        case LFLiveReady:
            networkStatusInfo = @"LiveReady....";
            break;
        case LFLivePending:
            networkStatusInfo = @"LivePending...";
            break;
        case LFLiveStart:
            networkStatusInfo = @"LiveStart";
            [self setStartStreamStatus];
            break;
        case LFLiveStop:
            networkStatusInfo  =@"LiveStop";
            [self setStopStreamStatus];
            break;
        case LFLiveError:
        {
            networkStatusInfo =@"连接出错";
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself showPromptAlertWithTitile:@"Connect server error!" message:@"Connect error please check rtmp address or network" buttonTitle:@"OK" buttonClickHandler:^(UIAlertAction *action) {
                    if (_session) {
                        [_session stopLive];
                    }
                    
                }];
                [weakself setStopStreamStatus];
            });
            
        }
            break;
        default:
            break;
    }
    
    if (networkStatusInfo){
        [self showHudMessage:networkStatusInfo];
    }
    
    
    NSLog(@"liveStateDidChange : networkStatusInfo :%@",networkStatusInfo);
    
}


-(void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
    NSLog(@"liveSession :errorCode :%lu",(unsigned long)errorCode);
    //    self.networkStatusLable .text =[NSString stringWithFormat: @"直播错误,代码:%d",(int)errorCode ];
}

-(void)setStartStreamStatus{
    //直播界面
    _onliveLabel.text = NSLocalizedString(@"on_live", nil);
    [_livePauseBtn setImage:[UIImage imageNamed:@"pause live_nor@3x.png"] forState:UIControlStateNormal];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"start live_dis@3x.png"] forState:UIControlStateNormal];
    
    _onliveView.image=[UIImage imageNamed:@"live view_pilot lamp_on@3x.png"];
    _livePauseBtn.hidden=NO;
    _liveStopBtn.hidden=NO;
    //推流界面
    [_streamingStartBtn setImage:[UIImage imageNamed:@"go live_dis@3x.png"] forState:UIControlStateNormal];
    [_streamingPauseBtn setImage:[UIImage imageNamed:@"pause live_nor@3x.png"] forState:UIControlStateNormal];
    [_streamingStopBtn setImage:[UIImage imageNamed:@"stop live_nor@3x.png"] forState:UIControlStateNormal];
    
    _streamingAddress.enabled=NO;
    _addressView.userInteractionEnabled=NO;
    _platformView.userInteractionEnabled=NO;
    
    _takephotoBtn.enabled = NO;
    _recordBtn.enabled = NO;
    _livingState=LivingStateLiving;
}

-(void)setPauseStreamStatus{
    //直播界面
    _onliveView.image=[UIImage imageNamed:@"Live view_icon_pause status@3x.png"];
    _onliveLabel.text = NSLocalizedString(@"pause_live", nil);
    [_livePauseBtn setImage:[UIImage imageNamed:@"continue live_pre@3x.png"] forState:UIControlStateNormal];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"start live_dis@3x.png"] forState:UIControlStateNormal];
    
    _livePauseBtn.hidden=NO;
    _liveStopBtn.hidden=NO;
    //推流界面
    [_streamingStartBtn setImage:[UIImage imageNamed:@"go live_dis@3x.png"] forState:UIControlStateNormal];
    [_streamingPauseBtn setImage:[UIImage imageNamed:@"continue live_nor@3x.png"] forState:UIControlStateNormal];
    [_streamingStopBtn setImage:[UIImage imageNamed:@"stop live_nor@3x.png"] forState:UIControlStateNormal];
    
    [self.videoView take_imageRef:NO];
    
    _takephotoBtn.enabled = YES;
    _recordBtn.enabled = YES;
    _livingState=LivingStatePause;
}

-(void)setStopStreamStatus{
    //直播界面
//    [_liveStreamBtn setImage:[UIImage imageNamed:@"start live_nor@3x.png"] forState:UIControlStateNormal];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"icon_plush_nor"] forState:UIControlStateNormal];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"icon_plush_pre"] forState:UIControlStateHighlighted];
    
    _onliveView.image=[UIImage imageNamed:@"live view_Indicator light_gray@3x.png"];
    _onliveLabel.text = NSLocalizedString(@"not_live", nil);
    _livePauseBtn.hidden=YES;
    _liveStopBtn.hidden=YES;
    //推流界面
    _streamingAddress.enabled=YES;
    _addressView.userInteractionEnabled=YES;
    _platformView.userInteractionEnabled=YES;
    [_streamingStartBtn setImage:[UIImage imageNamed:@"go live_pre@3x.png"] forState:UIControlStateNormal];
    [_streamingPauseBtn setImage:[UIImage imageNamed:@"puase live_dis@3x.png"] forState:UIControlStateNormal];
    [_streamingStopBtn setImage:[UIImage imageNamed:@"stop live_dis@3x.png"] forState:UIControlStateNormal];
    
    [self.videoView take_imageRef:NO];
    
    _takephotoBtn.enabled = YES;
    _recordBtn.enabled = YES;
    
    _livingState=LivingStateStop;
}

/**
 *  定时显示字幕和角标以及间隔时间
 */
-(void)timerFunction{
    if([[self Get_Keys:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
        if (_isShowBanner) {
            _count_duration++;
            _count_interval=0;
        }
        else{
            _count_duration=0;
            _count_interval++;
        }
        
        if (_count_duration>_duration) {
            _isShowBanner=NO;
        }
        if (_count_interval>=_interval) {
            _isShowBanner=YES;
        }
    }
    
    if([[self Get_Keys:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
        if (_isShowSubtitle) {
            _subtitle_count_duration++;
            _subtitle_count_interval=0;
        }
        else{
            _subtitle_count_duration=0;
            _subtitle_count_interval++;
        }
        
        if (_subtitle_count_duration>_subtitle_duration) {
            _isShowSubtitle=NO;
        }
        if (_subtitle_count_interval>=_subtitle_interval) {
            _isShowSubtitle=YES;
        }
    }
    
}

- (void)getDeviceConfig {
    
    NSString * configIP = _userip;
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%ld/server.command?command=get_resol&type=h264&pipe=0",configIP,(long)configPort];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        _resolution=[self parseJsonString:http_request.ResponseString];
        dispatch_async(dispatch_get_main_queue(),^ {
            if ([_resolution compare:@"3"]==NSOrderedSame) {
                //                [self set1080P];
            }
            else if ([_resolution compare:@"2"]==NSOrderedSame) {
                //                                [self set720P];
            }
            else{
                //                [self set480P];
            }
        });
        NSLog(@"============resolution=%@",_resolution);
    }
    
    //get quality
    URL=[[NSString alloc]initWithFormat:@"http://%@:%ld/server.command?command=get_enc_quality&type=h264&pipe=0",configIP,(long)configPort];
    http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        _quality=[self parseJsonString:http_request.ResponseString];
        dispatch_async(dispatch_get_main_queue(),^ {
            float value=[_quality intValue]*3000/52.0;
            if (((int)value%100)!=0) {
                value=value+100;
            }
            //            [self setVideoRate:value];
        });
        NSLog(@"******************quality=%@",_quality);
    }
    else{
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"get_quality_failed", nil)];
        });
    }
    
    //get fps
    URL=[[NSString alloc]initWithFormat:@"http://%@:%ld/server.command?command=get_max_fps&type=h264&pipe=0",configIP,(long)configPort];
    http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        _fps=[self parseJsonString:http_request.ResponseString];
        dispatch_async(dispatch_get_main_queue(),^ {
            //                        [self setVideoFrameRate:[fps intValue]];
            _session = [self getSessionWithRakisrak:YES];
        });
        
//        NSLog(@"???????????????????????fps=%@",_fps);
    }
    
}

/**
 *  显示字幕和角标
 */
int posCount=0;
int posStep=1;
- (void)addBannerSubtitle{
    if(([[self Get_Keys:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame)||
       ([[self Get_Keys:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame)){
        
        if([[self Get_Keys:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
            _duration=[[self Get_Keys:BANNER_DURATION_KEY] intValue];
            _interval=[[self Get_Keys:BANNER_INTERVAL_KEY] intValue];
        }
        else
        {
            _isShowBanner=NO;
        }
        
        if([[self Get_Keys:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
            _subtitle_duration=[[self Get_Keys:SUBTITLE_DURATION_KEY] intValue];
            _subtitle_interval=[[self Get_Keys:SUBTITLE_INTERVAL_KEY] intValue];
        }
        else
        {
            _isShowSubtitle=NO;
        }
        if (_uploadTimer==nil) {
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                _uploadTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakself selector:@selector(timerFunction) userInfo:nil repeats:YES];
            });
            if([[self Get_Keys:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
                _isShowBanner=YES;
                _count_duration=0;
                _count_interval=0;
            }
            
            if([[self Get_Keys:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
                _isShowSubtitle=YES;
                _subtitle_count_duration=0;
                _subtitle_count_interval=0;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat newViewW=_viewW;
            CGFloat newViewH=_viewH;
            if (_viewH>_viewW) {
                newViewW=_viewH;
                newViewH=_viewW;
            }
            
            if (_isShowBanner&&_isShowSubtitle) {
                _upperLeftImg.image=[self Get_Images:BANNER_UPPER_LEFT_PUSH_KEY];
                if (CGImageGetHeight(_upperLeftImg.image.CGImage)!=0) {
                    _upperLeftImg.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, CGImageGetWidth(_upperLeftImg.image.CGImage)*newViewH/6/CGImageGetHeight(_upperLeftImg.image.CGImage), newViewH/6);
                    _upperLeftImg.hidden=NO;
                }
                
                _upperRightImg.image=[self Get_Images:BANNER_UPPER_RIGHT_PUSH_KEY];
                if (CGImageGetHeight(_upperRightImg.image.CGImage)!=0) {
                    _upperRightImg.frame=CGRectMake(newViewW-CGImageGetWidth(_upperRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_upperRightImg.image.CGImage), 0, CGImageGetWidth(_upperRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_upperRightImg.image.CGImage), newViewH/6);
                    _upperRightImg.hidden=NO;
                }
                
                _lowerLeftImg.image=[self Get_Images:BANNER_LOWER_LEFT_PUSH_KEY];
                if (CGImageGetHeight(_lowerLeftImg.image.CGImage)!=0) {
                    _lowerLeftImg.frame=CGRectMake(0, newViewH*5/6, CGImageGetWidth(_lowerLeftImg.image.CGImage)*newViewH/6/CGImageGetHeight(_lowerLeftImg.image.CGImage), newViewH/6);
                    _lowerLeftImg.hidden=NO;
                }
                
                _lowerRightImg.image=[self Get_Images:BANNER_LOWER_RIGHT_PUSH_KEY];
                if (CGImageGetHeight(_lowerRightImg.image.CGImage)!=0) {
                    _lowerRightImg.frame=CGRectMake(newViewW-CGImageGetWidth(_lowerRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_lowerRightImg.image.CGImage),newViewH*5/6, CGImageGetWidth(_lowerRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_lowerRightImg.image.CGImage), newViewH/6);
                    _lowerRightImg.hidden=NO;
                }
                
                if ([[self Get_Keys:SUBTITLE_SHOW_TYPE_KEY] isEqualToString:@"roll"]) {
                    _wordImg.image=[self Get_Images:SUBTITLE_PHOTO_PUSH_KEY];
                    _wordImg.frame=CGRectMake(newViewW-posCount*posStep, newViewH-CGImageGetHeight(_wordImg.image.CGImage)-10, CGImageGetWidth(_wordImg.image.CGImage),CGImageGetHeight(_wordImg.image.CGImage));
                    posCount++;
                    if (_wordImg.frame.origin.x+_wordImg.frame.size.width>0) {
                        posCount++;
                    }
                    else{
                        posCount=0;
                    }
                }
                else{
                    posCount=0;
                    _wordImg.image=[self Get_Images:SUBTITLE_PHOTO_PUSH_KEY];
                    _wordImg.frame=CGRectMake(0, newViewH-CGImageGetHeight(_wordImg.image.CGImage)-10, CGImageGetWidth(_wordImg.image.CGImage),CGImageGetHeight(_wordImg.image.CGImage));
                    _wordImg.center=CGPointMake(newViewW*0.5, _wordImg.center.y);
                }
                _wordImg.hidden=NO;
            }
            else if (!_isShowBanner&&_isShowSubtitle){
                _upperLeftImg.hidden=YES;
                _upperRightImg.hidden=YES;
                _lowerLeftImg.hidden=YES;
                _lowerRightImg.hidden=YES;
                
                if ([[self Get_Keys:SUBTITLE_SHOW_TYPE_KEY] isEqualToString:@"roll"]) {
                    _wordImg.image=[self Get_Images:SUBTITLE_PHOTO_PUSH_KEY];
                    _wordImg.frame=CGRectMake(newViewW-posCount*posStep, newViewH-CGImageGetHeight(_wordImg.image.CGImage)-10, CGImageGetWidth(_wordImg.image.CGImage),CGImageGetHeight(_wordImg.image.CGImage));
                    posCount++;
                    if (_wordImg.frame.origin.x+_wordImg.frame.size.width>0) {
                        posCount++;
                    }
                    else{
                        posCount=0;
                    }
                }
                else{
                    _wordImg.image=[self Get_Images:SUBTITLE_PHOTO_PUSH_KEY];
                    _wordImg.frame=CGRectMake(0, newViewH-CGImageGetHeight(_wordImg.image.CGImage)-10, CGImageGetWidth(_wordImg.image.CGImage),CGImageGetHeight(_wordImg.image.CGImage));
                    _wordImg.center=CGPointMake(newViewW*0.5, _wordImg.center.y);
                }
                _wordImg.hidden=NO;
            }
            else if (_isShowBanner&&!_isShowSubtitle) {
                _upperLeftImg.image=[self Get_Images:BANNER_UPPER_LEFT_PUSH_KEY];
                if (CGImageGetHeight(_upperLeftImg.image.CGImage)!=0) {
                    _upperLeftImg.frame=CGRectMake(0, 0, CGImageGetWidth(_upperLeftImg.image.CGImage)*newViewH/6/CGImageGetHeight(_upperLeftImg.image.CGImage), newViewH/6);
                    _upperLeftImg.hidden=NO;
                }
                
                _upperRightImg.image=[self Get_Images:BANNER_UPPER_RIGHT_PUSH_KEY];
                if (CGImageGetHeight(_upperRightImg.image.CGImage)!=0) {
                    _upperRightImg.frame=CGRectMake(newViewW-CGImageGetWidth(_upperRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_upperRightImg.image.CGImage), 0, CGImageGetWidth(_upperRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_upperRightImg.image.CGImage), newViewH/6);
                    _upperRightImg.hidden=NO;
                }
                
                _lowerLeftImg.image=[self Get_Images:BANNER_LOWER_LEFT_PUSH_KEY];
                if (CGImageGetHeight(_lowerLeftImg.image.CGImage)!=0) {
                    _lowerLeftImg.frame=CGRectMake(0, newViewH*5/6, CGImageGetWidth(_lowerLeftImg.image.CGImage)*newViewH/6/CGImageGetHeight(_lowerLeftImg.image.CGImage), newViewH/6);
                    _lowerLeftImg.hidden=NO;
                }
                
                _lowerRightImg.image=[self Get_Images:BANNER_LOWER_RIGHT_PUSH_KEY];
                if (CGImageGetHeight(_lowerRightImg.image.CGImage)!=0) {
                    _lowerRightImg.frame=CGRectMake(newViewW-CGImageGetWidth(_lowerRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_lowerRightImg.image.CGImage),newViewH*5/6, CGImageGetWidth(_lowerRightImg.image.CGImage)*newViewH/6/CGImageGetHeight(_lowerRightImg.image.CGImage), newViewH/6);
                    _lowerRightImg.hidden=NO;
                }
                
                _wordImg.hidden=YES;
                posCount=0;
            }
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            _upperLeftImg.hidden=YES;
            _upperRightImg.hidden=YES;
            _lowerLeftImg.hidden=YES;
            _lowerRightImg.hidden=YES;
            _wordImg.hidden=YES;
            posCount=0;
        });
    }
}

/**
 *  获取保存的图片
 */
- (UIImage *)Get_Images:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSData* imageData = [defaults objectForKey:key];
    UIImage* image = [UIImage imageWithData:imageData];
    return image;
}


/*****************************************************************************************
 *                                      推流界面相关
 ******************************************************************************************/


/**
 * 输入直播地址弹窗
 */
-(void)inputAddressViewInit{
    _inputAddressView=[[UIView alloc]initWithFrame:CGRectMake(0,_viewH,_viewW,_viewH)];
    _inputAddressView.backgroundColor=[UIColor clearColor];
    _inputAddressView.userInteractionEnabled = YES;
    //    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_inputAddressViewCancelClick)];
    //    [_inputAddressView addGestureRecognizer:singleTap];
    [_streamView addSubview:_inputAddressView];
    
    _inputAddressViewLayout=[[UIView alloc]initWithFrame:CGRectMake(0,0,_viewW*283/_totalWeight,_viewH*281/_totalHeight)];
    [[_inputAddressViewLayout layer]setCornerRadius:_viewW*10/_totalWeight];//圆角
    _inputAddressViewLayout.backgroundColor=[UIColor whiteColor];
    _inputAddressViewLayout.center=CGPointMake(_viewW*0.5, _viewH*0.5);
    _inputAddressViewLayout.userInteractionEnabled = YES;
    [_inputAddressView addSubview:_inputAddressViewLayout];
    
    myTextField=[[CAAutoFillTextField alloc]initWithFrame:CGRectMake(_viewW*19/_totalWeight, _viewH*30/_totalHeight, _viewW*246/_totalWeight, _viewH*40/_totalHeight)];
    myTextField.userInteractionEnabled=YES;
    [_inputAddressViewLayout addSubview:myTextField];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    _recordUrl=[self Get_Urls:@"STREAMURL"];
    for (int i = 0; i<[_recordUrl count]; i++) {
        CAAutoCompleteObject *object = [[CAAutoCompleteObject alloc] initWithObjectName:[NSString stringWithFormat:@"%@",[_recordUrl objectAtIndex:i]] AndID:i];
        [tempArray addObject:object];
    }
    [myTextField setDataSourceArray:tempArray];
    [myTextField setDelegate:self];
    myTextField.delegate = self;
    
    UIView *line=[[UIView alloc]init];
    line.frame=CGRectMake(_viewW*19/_totalWeight,_viewH*247/_totalHeight,_viewW*246/_totalWeight,1);
    line.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_inputAddressViewLayout addSubview:line];
    
    UIButton *_clearBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _clearBtn.backgroundColor=[UIColor whiteColor];
    _clearBtn.frame = CGRectMake(0, 0, _viewH*44/_totalHeight, _viewH*44/_totalHeight);
    _clearBtn.center=CGPointMake(_inputAddressViewLayout.frame.size.width*0.5, line.center.y);
    [_clearBtn setImage:[UIImage imageNamed:@"Clear the record@3x.png"] forState:UIControlStateNormal];
    //[_clearBtn setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
    _clearBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_clearBtn addTarget:nil action:@selector(_clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_inputAddressViewLayout  addSubview:_clearBtn];
}

///**
// * 文字滚动相关回调
// */
- (void) CAAutoTextFillBeginEditing:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillBeginEditing");
}

- (void) CAAutoTextFillEndEditing:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillEndEditing");
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([textField.txtField.text compare:@""]!=NSOrderedSame) {
            _streamingAddress.text=textField.txtField.text;
            [weakself Save_Paths:_streamingAddress.text :STREAM_URL_KEY];
            [weakself addUrls];
        }
        else{
            if ([[self Get_Paths:STREAM_URL_KEY] compare:@""]==NSOrderedSame) {
                _streamingAddress.text = NSLocalizedString(@"address_text", nil);
            }
        }
        [self setInfoViewFrame:_inputAddressView :YES];
    });
}

- (BOOL) CAAutoTextFillWantsToEdit:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillWantsToEdit");
    return YES;
}

/**
 * 取消输入直播地址
 */
-(void)_inputAddressViewCancelClick{
    NSLog(@"_inputAddressViewCancelClick");
    [self setInfoViewFrame:_inputAddressView :YES];
}

/**
 * 保存直播地址
 */
-(void)addUrls{
    BOOL isSame=NO;
    for (int i=0; i<[_recordUrl count]; i++) {
        if([[_recordUrl objectAtIndex:i] compare:_streamingAddress.text]==NSOrderedSame)
            isSame=YES;
    }
    if (!isSame) {
        NSMutableArray *mutaArray = [[NSMutableArray alloc] init];
        [mutaArray addObjectsFromArray:_recordUrl];
        [mutaArray addObject:_streamingAddress.text];
        [self Save_Urls:mutaArray :@"STREAMURL"];
    }
    
}

/**
 * 清空保存的直播地址
 */
-(void)_clearBtnClick{
    NSLog(@"_clearBtnClick");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STREAMURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:STREAM_URL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [myTextField clear];
}

/**
 * 弹出或取消弹窗
 */
- (void)setInfoViewFrame:(UIView*)infoView :(BOOL)isDown{
    if(isDown == NO)
    {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             [infoView setFrame:CGRectMake(0, _viewH+infoView.frame.size.height, infoView.frame.size.width, infoView.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  [infoView setFrame:CGRectMake(0, _viewH-infoView.frame.size.height, infoView.frame.size.width, infoView.frame.size.height)];
                                              }
                                              completion:^(BOOL finished) {
                                                  infoView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
                                              }];
                         }];
        
    }else
    {
        infoView.backgroundColor=[UIColor clearColor];
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             [infoView setFrame:CGRectMake(0, 0, infoView.frame.size.width, infoView.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  [infoView setFrame:CGRectMake(0, infoView.frame.size.height, infoView.frame.size.width, infoView.frame.size.height)];
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
    }
}


/**
 * 开启／停止／暂停直播
 */

-(void)_streamingStartBtnClick{
    if(_livingState==0){
        if ((([_streamingAddress.text compare:@""]==NSOrderedSame)||
             ([_streamingAddress.text compare:NSLocalizedString(@"address_text", nil)]==NSOrderedSame))  &&([_streamingPlatform.text isEqual: NSLocalizedString(@"platform_text", nil)])){
            [self showAllTextDialog:NSLocalizedString(@"streaminig_no_url_tips", nil)];
            return;
        }
        
        _isExit=NO;
        if (_isLiveView) {
            [self liveStreamBtnOnClick];
        }else{
            if (_userip!=nil) {
                NSString *url = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
                [self.videoView play:url useTcp:NO];
                [self.videoView sound:_audioisEnable];
                self.videoisplaying = YES;
            }else{
                [self scanDevice];
                _isUser=YES;
            }
        }
    }else{
        [self showAllTextDialog:NSLocalizedString(@"streaminig_on_live_tips", nil)];
    }
}

-(void)_streamingPauseBtnClick{
    if (_livingState==LivingStateStop) {
        [self showAllTextDialog:NSLocalizedString(@"streaminig_no_start_live_tips", nil)];
    }
    else if (_livingState==LivingStateLiving) {//暂停推流
        [self setPauseStreamStatus];
    }
    else if (_livingState==LivingStatePause) {//重新开始推流
        [self setStartStreamStatus];
    }
}

-(void)_streamingStopBtnClick{
    if (_livingState==0) {
        [self showAllTextDialog:NSLocalizedString(@"streaminig_no_start_live_tips", nil)];
    }
    else{
        [self setStopStreamStatus];
        [self closeLivingSession];
        _isExit=YES;
    }
}



- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}


/**
 截屏
 */
- (UIImage *)getSnapshotImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame)), NO,0.0);
    
    [self.view drawViewHierarchyInRect:CGRectMake(0,0,CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)) afterScreenUpdates:NO];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return snapshot;
}

/**
 *  拍照
 */

#pragma mark - 拍照
-(void)takephotoBtnClicked {
    
    [self playSound:@"shutter.mp3"];
    
    if (_liveCameraSource == IphoneBackCamera) {
        
        UIImage * image = [self getSnapshotImage];
        if (image) {
            [_albumObject saveImageToAlbum:image albumName:album_name];
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_albumObject createAlbumInPhoneAlbum:album_name];
        [_albumObject getPathForRecord:album_name];
    });
    
    if (_livingState!=1) {
        [_videoView take_photo];
    }
    else{
        _isTakePhoto=YES;
    }
}

/**
 *  拍照回调
 */
bool _isTakePhoto=NO;
- (void)take_photo:(UIImage *)image
{
    _isTakePhoto=NO;
    [_albumObject saveImageToAlbum:image albumName:album_name];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary  *)contextInfo
{
    [self showAllTextDialog:NSLocalizedString(@"save_photo", nil)];
}

- (void)pressentAlertViewControllerWithError:(NSError *)error {
    //
    //    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedFailureReason preferredStyle:UIAlertControllerStyleAlert];
    //
    //
    //
    //    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [alertController dismissViewControllerAnimated:YES completion:^{
    //            nil;
    //        }];
    //    }];
    //    [alertController addAction:ok];
    //    [self presentViewController:alertController animated:YES completion:^{
    //        nil;
    //    }];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

- (void)saveImageToAlbum:(BOOL)success{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [weakself showAllTextDialog:NSLocalizedString(@"save_photo", nil)];
        }
        else{
            [weakself showAllTextDialog:NSLocalizedString(@"save_photo_failed", nil)];
        }
    });
}

- (void)readFileFromAlbum:(ALAssetsGroup *)group {
    
}

/**
 *  录像
 */
#pragma mark - 录像
-(void)recordBtnClicked{
//    [self replayVideoView];
    
    if (!_play_success) {
        [self showAllTextDialog:NSLocalizedString(@"video_not_play", nil)];
        return;
    }
    if (RecordVideoEnable == Unable) {
        [self playSound:@"begin_record.mp3"];
        RecordVideoEnable = Enable;
        [_recordBtn setImage:[UIImage imageNamed:@"video_stop"] forState:UIControlStateNormal];
        
        _takephotoBtn.enabled = NO;
        
        if (_liveCameraSource == IphoneBackCamera) {
            [self.session startRecord];
        }
        else if (_liveCameraSource == ExternalDevices)
        {
            long recordTime = [[NSDate date] timeIntervalSince1970];
            NSString *timesamp=[NSString stringWithFormat:@"%ld",recordTime];
            NSLog(@"video_timesamp:%@",timesamp);
            self.video_timesamp = [self Get_Urls:@"video_flag"];
            NSMutableArray *mutaArray = [[NSMutableArray alloc] init];
            [mutaArray addObjectsFromArray:self.video_timesamp];
            [mutaArray addObject:timesamp];
            [self Save_Urls:mutaArray :@"video_flag"];
            
            [_videoView begin_record:0];
            [_videoView set_record_frame_rate:24];
        }
        
        VideoRecordTimerTick_s = 0;
        VideoRecordTimerTick_m = 0;
        _recordTimeLabel.text = @"REC 00:00";
        _recordTimeLabel.hidden=NO;
    }
    else{
        _takephotoBtn.enabled = YES;
        [self playSound:@"end_record.mp3"];
        [self showAllTextDialog:NSLocalizedString(@"save_video", nil)];
        RecordVideoEnable = Unable;
        [_recordBtn setImage:[UIImage imageNamed:@"icon_play_nor"] forState:UIControlStateNormal];
        _recordTimeLabel.hidden=YES;
        if (_liveCameraSource == IphoneBackCamera)
        {
            [self.session stopRecord];
        }
        else if (_liveCameraSource == ExternalDevices)
        {
            [_videoView end_record];
        }
    }
}

#pragma mark - 底部按钮跳转相关界面
/**
 *  点击直播按钮
 */
#pragma mark - 点击直播按钮
-(void)liveStreamBtnOnClick{
    
    //如果是系统摄像头
    if (_liveCameraSource == IphoneBackCamera) {
        [NSThread detachNewThreadSelector:@selector(openLivingSession:) toTarget:self withObject:nil];
    }else{
        
        if (!_play_success){
            [self showAllTextDialog:NSLocalizedString(@"video_not_play", nil)];
            return;
        }
        //RAK设备
        if(_livingState==0){
            _isExit = NO;
            [NSThread detachNewThreadSelector:@selector(openLivingSession:) toTarget:self withObject:nil];
        } else {
            //            [self showAllTextDialog:NSLocalizedString(@"streaminig_on_live_tips", nil)];
        }
    }
}

/**
 *  暂停推流或开启推流
 */
-(void)livePauseBtnClicked{
    NSLog(@"暂停推流");
    if (_livingState==1) {//暂停推流
        [self setPauseStreamStatus];
    }
    else if (_livingState==2) {//重新开始推流
        [self setStartStreamStatus];
    }
}

/**
 *  停止推流
 */
-(void)liveStopBtnClicked{
    [self closeLivingSession];
}
/**
 *  跳转到浏览相片和视频的界面
 */
-(void)browserBtnClicked{
    NSLog(@"浏览");
    [self stopVideo];
    _isBroswer=YES;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    BrowseViewController *v = [[BrowseViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}


/**
 推流平台选择
 */
- (void)platformButtonClick
{
    _isBroswer=YES;
    [self stopVideo];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    TTPlatformSelectViewController * vc = [[TTPlatformSelectViewController alloc] init];
    if (_userip) {
        vc.configIP = _userip;
    }
    [self.navigationController pushViewController:vc animated:YES];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //隐藏键盘
    [_streamingObtainField resignFirstResponder];
    [_streamingMannualField resignFirstResponder];
}

// 开始编辑输入框时，键盘出现，视图的Y坐标向上移动offset个单位，腾出空间显示键盘
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect textFrame = textField.frame;
    CGPoint textPoint = [textField convertPoint:CGPointMake(0, textField.frame.size.height) toView:self.view];// 关键的一句，一定要转换
    int offset = textPoint.y + textFrame.size.height + 216 - self.view.frame.size.height + 70;// 50是textfield和键盘上方的间距，可以自由设定
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    // 将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if (offset > 0) {
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
}

// 用户输入时
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // 输入结束后，将视图恢复到原始状态
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    return YES;
}


- (NSString *)Get_Keys:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

- (void)Save_Keys:(NSString *)Timesamp :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:Timesamp forKey:key];
    [defaults synchronize];
}

- (void)Save_Paths:(NSString *)value :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

- (NSString *)Get_Paths:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

- (void)Save_Urls:(NSMutableArray *)Timesamp :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:Timesamp forKey:key];
    [defaults synchronize];
}

- (NSMutableArray *)Get_Urls:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSMutableArray *value=[defaults objectForKey:key];
    return value;
}

- (NSString *)Get_String:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

//Get Wifi Name
-(NSString *)getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
//            NSLog(@"----------------------network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (NSString *)getWifiSSID {
        NSString *wifiSSID = nil;
        CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
        if (!wifiInterfaces) {
            return nil;
        }
        
        NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
        
        for (NSString *interfaceName in interfaces) {
            CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
            
            if (dictRef) {
                NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
//                NSLog(@"----------------------network info -> %@", networkInfo);
                wifiSSID = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID];
                
                CFRelease(dictRef);
            }
        }
        
        CFRelease(wifiInterfaces);
        return wifiSSID;
}

#pragma mark - 注册通知
- (void)addApplicationActiveNotifications {
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)dealloc {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationBecomeActive {
    //    [self replayVideoView];
    NSLog(@"----------进入前台");
    _topLabel.text = [self getWifiName];
    BOOL isSameWIfi = ([CoreStore sharedStore].currentUseDeviceID == [self getWifiSSID]);
    BOOL isNotnil  = ([self getWifiSSID].length > 0);
    NSLog(@"----------------%u,%u,%u",isSameWIfi,isNotnil,_searchDeviceHasResult);
    if (([[CoreStore sharedStore].currentUseDeviceID isEqualToString:[self getWifiSSID]])&&([self getWifiSSID].length > 0)&&_searchDeviceHasResult) {
        if(!_isExit&&!_isBroswer){
        NSString *urlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
        NSLog(@"----------------log%@",urlString);
        
        [self.videoView play:urlString useTcp:NO];
        [self.videoView sound:YES];
        [self.videoView startGetYUVData:YES];
        [self.videoView startGetAudioData:YES];
        [self.videoView startGetH264Data:YES];
        [self.videoView show_view:YES];
        self.videoisplaying = YES;
        }
        
        
    } else if (_liveCameraSource == IphoneBackCamera) {
        
    } else {
        
        [_updateUITimer setFireDate:[NSDate distantFuture]];
        _tipLabel.text = @"PLEASE CHECK WIFI CONECT TO EXTERNAL DEVICE";
        [self showSearchingMessagesTips];
    }
    

}

- (void)applicationEnterBackground {
    [self stopVideo];
    NSLog(@"----------进入后台");
   [CoreStore sharedStore].currentUseDeviceID = [self getWifiSSID];
    NSLog(@"----------------+++%@",[CoreStore sharedStore].currentUseDeviceID);
}

#pragma mark - maybe not use
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  移入效果
 */
-(void)moveInAnimation{
    _topBg.hidden=NO;
    _bottomBg.hidden=NO;
    _statusBg.hidden=NO;
    if (_livingState==1) {
        _livePauseBtn.hidden=NO;
        _liveStopBtn.hidden=NO;
    }
    else if (_livingState==2) {
        _livePauseBtn.hidden=NO;
        _liveStopBtn.hidden=NO;
    }
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionMoveIn;//设置动画的类型
    anima.subtype = kCATransitionFromBottom; //设置动画的方向
    [_topBg.layer addAnimation:anima forKey:@"moveInAnimation"];
    [_statusBg.layer addAnimation:anima forKey:@"moveInAnimation"];
    
    anima.subtype = kCATransitionFromTop; //设置动画的方向
    anima.duration = 0.3f;
    [_bottomBg.layer addAnimation:anima forKey:@"moveInAnimation"];
}

/**
 *  移出效果
 */
-(void)revealAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        CATransition *anima = [CATransition animation];
        anima.type = kCATransitionReveal;//设置动画的类型
        anima.subtype = kCATransitionFromTop; //设置动画的方向
        [_topBg.layer addAnimation:anima forKey:@"revealAnimation"];
        [_statusBg.layer addAnimation:anima forKey:@"revealAnimation"];
        
        anima.subtype = kCATransitionFromBottom; //设置动画的方向
        anima.duration = 0.3f;
        [_bottomBg.layer addAnimation:anima forKey:@"revealAnimation"];
    } completion:^(BOOL finished) {
        _topBg.hidden=YES;
        _bottomBg.hidden=YES;
        _statusBg.hidden=YES;
        _livePauseBtn.hidden=YES;
        _liveStopBtn.hidden=YES;
    }];
}



- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        if (((view.center.x + translation.x)>=_l_control_pos)&&((view.center.x + translation.x)<=_r_control_pos)){
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        if (((view.center.x)>_l_control_pos)
            &&(view.center.x)<=(_l_control_pos+(_c_control_pos-_l_control_pos)/2))//停止推流
        {
            [self setStopStreamStatus];
            _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_stop button@3x.png"];
            [view setCenter:(CGPoint){_l_control_pos, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
            
            [self closeLivingSession];
            _isExit=YES;
        }
        else if (((view.center.x)>(_l_control_pos+(_c_control_pos-_l_control_pos)/2))&&(view.center.x)<=(_c_control_pos+(_r_control_pos-_c_control_pos)/2))//开始推流
        {
            if(_livingState==0){
                if ((([_streamingAddress.text compare:@""]==NSOrderedSame)||
                     ([_streamingAddress.text compare:NSLocalizedString(@"address_text", nil)]==NSOrderedSame))  &&([_streamingPlatform.text isEqual: NSLocalizedString(@"platform_text", nil)])){
                    [view setCenter:(CGPoint){_l_control_pos, view.center.y}];
                    [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
                    [self showAllTextDialog:NSLocalizedString(@"streaminig_no_url_tips", nil)];
                    return;
                }
                
                _isExit=NO;
                if (_isLiveView) {
                    [self liveStreamBtnOnClick];
                }
                else{
                    if (_userip!=nil) {
                        NSString *url = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
                        [self.videoView play:url useTcp:NO];
                        [self.videoView sound:_audioisEnable];
                        self.videoisplaying = YES;
                    }
                    else{
                        [self scanDevice];
                        _isUser=YES;
                    }
                }
            }
            else{
                [self setStartStreamStatus];
            }
            _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_star button@3x.png"];
            [view setCenter:(CGPoint){_c_control_pos, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
        else if (((view.center.x)>(_c_control_pos+(_r_control_pos-_c_control_pos)/2))&&(view.center.x)<=_r_control_pos)//暂停推流
        {
            if (_livingState==0) {
                [self showAllTextDialog:NSLocalizedString(@"streaminig_no_start_live_tips", nil)];
                [view setCenter:(CGPoint){_l_control_pos, view.center.y}];
                [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
                _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_stop button@3x.png"];
                _streamStatusImg.image=[UIImage imageNamed:@"live view_Indicator light_gray@3x.png"];
            }
            else{
                [self setPauseStreamStatus];
                _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_pause button@3x.png"];
                [view setCenter:(CGPoint){_r_control_pos, view.center.y}];
                [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
            }
        }
    }
}

/**
 * 左右滑动显示出所有直播参数设置选项
 */
- (void)panView2:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        if (((view.center.x + translation.x)>=3*_viewW/8)&&((view.center.x + translation.x)<=5*_viewW/8)){
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }
}



/**
 * 设置暂停界面
 */
- (void)_linkmanBtn2Click{
    NSLog(@"_linkmanBtn2Click");
    PauseScreenViewController *v = [[PauseScreenViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}


/**
 * 分享直播链接
 */
- (void)_streamingShareBtnClick{
    NSLog(@"_streamingShareBtnClick");
}

/**
 * 选择输入直播链接
 */
- (void)_addressViewClick{
    NSLog(@"_addressViewClick");
    myTextField.txtField.text=_streamingAddress.text;
    [self setInfoViewFrame:_inputAddressView :NO];
}

/**
 * 选择平台获取直播链接
 */
- (void)_platformViewClick{
    NSLog(@"_platformViewClick");
    [self setInfoViewFrame:_choosePlatformView :NO];
}



///**
// * 设置声音
// */
//- (void)_linkmanBtn3Click{
//    NSLog(@"_linkmanBtn3Click");
//    [self.navigationController pushViewController: self.audioViewController animated:true];
//}
//
///**
// * 设置网络
// */
//- (void)_linkmanBtn4Click{
//    NSLog(@"_linkmanBtn4Click");
//    [self.navigationController pushViewController: self.networkViewController animated:true];
//}
/**
 * 设置字幕
 */
//- (void)_linkmanBtn0Click{
//    NSLog(@"_linkmanBtn0Click");
//    [self.navigationController pushViewController: self.subtitleViewController animated:true];
//}
//
///**
// * 设置角标
// */
//- (void)_linkmanBtn1Click{
//    NSLog(@"_linkmanBtn1Click");
//    [self.navigationController pushViewController: self.bannerViewController animated:true];
//}
#pragma mark - 获取设备的参数  码率 fps 等 --------------------



@end
