//
//  LiveViewViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/10.
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
#import "Rak_Lx52x_Device_Control.h"
//#import "AppDelegate.h"

#define MAIN_COLOR [UIColor colorWithRed:(0 / 255.0f) green:(179 / 255.0f) blue:(227 / 255.0f) alpha:1.0]

/**
 摄像头获取源
 */
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
static NSInteger scanCount = 0;
static NSInteger playCount = 0;

static const NSString *video_type = @"h264";
static enum ButtonEnable SavePictureEnable;
static enum ButtonEnable RecordVideoEnable;


NSString* _userid = nil;
NSString* _userip = nil;
NSString* _username = nil;
NSString* _userpassword = nil;
NSTimer* CheckVideoPlay = nil;
NSTimer* timer;


bool audioisEnable = YES;
bool _isExit=NO;
bool _isUser=NO;
bool play_success=NO;



@interface LiveViewViewController ()<LFLiveSessionWithPicSourceDelegate,LX520Delegate>

@property (nonatomic, strong) LX520View * videoView;
@property (nonatomic, strong) Rak_Lx52x_Device_Control * device_Scan;//搜索manager
@property (nonatomic, strong) PlatformModel *selectedPlatformModel;
@property (nonatomic, strong) LFLiveSessionWithPicSource *session;

@property (nonatomic, strong) UIButton *platformButton;
/** 系统摄像头 展示view */
@property (nonatomic, strong) UIView *livingPreView;
/** 视频数据来源 */
@property (nonatomic, assign) CameraSource liveCameraSource;
@property (nonatomic, assign) LivingState livingState;

@property (nonatomic, strong) NSMutableArray *video_timesamp;//时间戳数组
@property (nonatomic, strong) AlbumObject *albumObject;

@property (nonatomic, strong) NSTimer *uploadTimer;
@property (nonatomic, strong) UIAlertView *waitAlertView;

@property (nonatomic, assign) BOOL isIphoneAudio;
@property (nonatomic, assign) BOOL videoisplaying;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isConfig;
@property (nonatomic, assign) BOOL isBroswer;
@property (nonatomic, assign) BOOL isShowBanner;
@property (nonatomic, assign) BOOL isShowSubtitle;

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
{
    SubtitleViewController *_subtitleViewController;
    BannerViewController   *_bannerViewController;
    AudioViewController    *_audioViewController;
    NetworkViewController  *_networkViewController;
    
//    UIAlertView *_waitAlertView;
//    AlbumObject *_albumObject;
//    BOOL _isPlaying;
//    BOOL _isConfig;
//    BOOL _isBroswer;
//    CGFloat _viewH;
//    CGFloat _viewW;
//    CGFloat _temp;
//    CGFloat _tempviewW;
//    CGFloat _tempviewH;
//    CGFloat _totalWeight;//各部分比例
//    CGFloat _totalHeight;
//    int _livingState;//0:停止 1:直播中 2:暂停

//    NSTimer *_uploadTimer;
//    int _count_duration;
//    int _count_interval;
//    int _duration;
//    int _interval;
////    float _imgAlpha;
//    int _subtitle_count_duration;
//    int _subtitle_count_interval;
//    int _subtitle_duration;
//    int _subtitle_interval;
    
//    BOOL _isShowBanner;
//    BOOL _isShowSubtitle;
    
    //推流相关参数
//    NSString* url;
//    CGFloat _l_control_pos;
//    CGFloat _c_control_pos;
//    CGFloat _r_control_pos;
//    NSMutableArray *_recordUrl;
    
//    NSString *_resolution;
//    NSString *_fps;
//    NSString *_quality;
}


- (NSMutableArray *)video_timesamp{
    if (!_video_timesamp) {
        _video_timesamp = @[].mutableCopy;
    }
    return _video_timesamp;
}

#pragma mark - ------------------lifeCycle----
- (void)viewDidLoad {
    //[self _scaleBtnClick:1];
    [super viewDidLoad];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor blackColor];
    _viewH = self.view.frame.size.width;
    _viewW = self.view.frame.size.height;
    _totalWeight = 64+71+149+149+149+80+5;//各部分比例
    _totalHeight = 375;//各部分比例
    
    _userip = @"192.168.100.1";
    _username = @"admin";
    _userpassword = @"admin";
    audioisEnable=YES;
    _isExit=NO;
    _isUser=NO;
    _isConfig=NO;
    _isBroswer=NO;
    self.videoisplaying = NO;
    _recordUrl=[[NSMutableArray alloc]init];
    _recordUrl = [self Get_Urls:@"STREAMURL"];
    _device_Scan = [[Rak_Lx52x_Device_Control alloc] init];
    
    _subtitleViewController = [[SubtitleViewController alloc] init];
    _bannerViewController   = [[BannerViewController alloc] init];
    _audioViewController    = [[AudioViewController alloc] init];
    _networkViewController  = [[NetworkViewController alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    [self prefersStatusBarHidden:YES];
    
    //添加系统相机展示view
    _livingPreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _livingPreView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesImage)];
    [_livingPreView addGestureRecognizer:singleTap];
    [self.view addSubview:_livingPreView];
    _livingPreView.hidden = YES;
    
    [self liveViewInit];
    
    [self streamViewInit];
    
    if (_isLiveView) {
        _streamView.hidden=YES;
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    }else{
        _streamView.hidden=NO;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [self prefersStatusBarHidden:YES];
    }
    
    
    
    if (play_success==NO){
        [self scanDevice];
    }
    _liveCameraSource = ExternalDevices;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //判断设备的音频输入是不是手机麦克风
    NSUserDefaults * standDefaults = [NSUserDefaults standardUserDefaults];
    if ([standDefaults objectForKey:AudioSourceIsIphone]) {
        _isIphoneAudio = (BOOL)[standDefaults objectForKey:AudioSourceIsIphone];
        if (_session) {
            _session.isIphoneAudio = _isIphoneAudio;
        }
    }
    
    [self getSelectedPlatform];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isBroswer) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        _isBroswer=NO;
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES; //不让手机休眠

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;//屏幕取消常亮
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _isExit=YES;
    if (_isLiveView){
        [_tipLabel removeFromSuperview];
        [self stopActivityIndicatorView];
        [ActivityIndicatorView removeFromSuperview];
    }
    else{
        if (([_streamingAddress.text compare:@""]!=NSOrderedSame)&&
            ([_streamingAddress.text compare:NSLocalizedString(@"address_text", nil)]!=NSOrderedSame)) {
            [self Save_Paths:_streamingAddress.text :STREAM_URL_KEY];
            [self addUrls];
        }
    }
}


- (void)getSelectedPlatform
{
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"---------receiceMemoryWarning.....");
}
/**
 *  直播界面初始化
 */
- (void)liveViewInit{
    _viewH = self.view.frame.size.width;
    _viewW = self.view.frame.size.height;
    if (_viewH > _viewW) {
        _viewW = self.view.frame.size.width;
        _viewH = self.view.frame.size.height;
    }
    
    _totalWeight=64+71+149+149+149+80+5;//各部分比例
    _totalHeight=375;//各部分比例
    _uploadTimer=nil;
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
    _albumObject=[[AlbumObject alloc]init];
    [_albumObject delegate:self];
    SavePictureEnable = Unable;
    RecordVideoEnable = Unable;
    
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
    [_backBtn addTarget:self action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
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
    
    [_takephotoBtn addTarget:nil action:@selector(_takephotoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg addSubview:_takephotoBtn];
    
    _recordBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _recordBtn.frame = [buttonFrameArray[1] CGRectValue];
    
    [_recordBtn setImage:[UIImage imageNamed:@"icon_play_nor"] forState:UIControlStateNormal];
    [_recordBtn setImage:[UIImage imageNamed:@"icon_play_pre"] forState:UIControlStateHighlighted];
    
    [_recordBtn addTarget:self action:@selector(_recordBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg  addSubview:_recordBtn];
    
    _liveStreamBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _liveStreamBtn.frame = [buttonFrameArray[2] CGRectValue];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"icon_plush_nor"] forState:UIControlStateNormal];
    [_liveStreamBtn setImage:[UIImage imageNamed:@"icon_plush_pre"] forState:UIControlStateHighlighted];
    [_liveStreamBtn addTarget:self action:@selector(_liveStreamBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBg  addSubview:_liveStreamBtn];
    
    
    _browserBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _browserBtn.frame = [buttonFrameArray[3] CGRectValue];
    [_browserBtn setImage:[UIImage imageNamed:@"icon_library_nor"] forState:UIControlStateNormal];
    [_browserBtn setImage:[UIImage imageNamed:@"icon_library_pre"] forState:UIControlStateHighlighted];
    [_browserBtn addTarget:self action:@selector(_browserBtnClick) forControlEvents:UIControlEventTouchUpInside];
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
    [_livePauseBtn addTarget:nil action:@selector(_livePauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_livePauseBtn];
    _livePauseBtn.hidden=YES;
    
    _liveStopBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _liveStopBtn.frame = CGRectMake((ScreenWidth - width)/2, (ScreenHeight - width)/2, width, width);
    [_liveStopBtn setImage:[UIImage imageNamed:@"stop live_nor@3x.png"] forState:UIControlStateNormal];
    [_liveStopBtn setImage:[UIImage imageNamed:@"stop live_pre@3x.png"] forState:UIControlStateHighlighted];
    _liveStopBtn.contentMode=UIViewContentModeScaleToFill;
    [_liveStopBtn addTarget:nil action:@selector(_liveStopBtnClick) forControlEvents:UIControlEventTouchUpInside];
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
    _onliveLabel.lineBreakMode = UILineBreakModeWordWrap;
    _onliveLabel.textAlignment = UITextAlignmentLeft;
    _onliveLabel.numberOfLines = 0;
    [_statusBg addSubview:_onliveLabel];
    
    _recordTimeLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, _statusBg.frame.origin.y+_statusBg.frame.size.height+_viewH*2/_totalWeight, _viewW-diff_x, _viewH*20/_totalWeight)];
    _recordTimeLabel.text = @"REC 00:00";
    _recordTimeLabel.font = [UIFont systemFontOfSize: _viewH*18/_totalHeight*0.8];
    _recordTimeLabel.backgroundColor = [UIColor clearColor];
    _recordTimeLabel.textColor = [UIColor redColor];
    _recordTimeLabel.lineBreakMode = UILineBreakModeWordWrap;
    _recordTimeLabel.textAlignment=UITextAlignmentRight;
    _recordTimeLabel.numberOfLines = 0;
    _recordTimeLabel.hidden=YES;
    [self.view addSubview:_recordTimeLabel];
    [self hiddenStatus];
    if (_isLiveView){
        [self startActivityIndicatorView];
        CheckVideoPlay = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(CheckVideoPlayTimer) userInfo:nil repeats:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            scanCount=0;
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
        });
    }
}

/**
 *  未播放隐藏状态栏
 */
- (void)hiddenStatus
{
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

/**
 *  已播放显示状态栏
 */
- (void)noHiddenStatus
{
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


/**
 *  显示或隐藏顶部和底部
 */
-(void)touchesImage{
    if(_topBg.hidden){
        [self moveInAnimation];
    }
    else{
        [self revealAnimation];
    }
}

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

/**
 *  使能相关按钮
 */
-(void)enableControl{
    _takephotoBtn.enabled=true;
    _liveStreamBtn.enabled=true;
    _recordBtn.enabled=true;
}

/**
 *  禁用相关按钮
 */
-(void)disableControl{
    _takephotoBtn.enabled=false;
    _liveStreamBtn.enabled=false;
    _recordBtn.enabled=false;
}

/**
 *  添加按钮声音效果
 */
- (void)playSound:(NSString *)sourcePath
{
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

/**
 *  记录录像时间
 */
int VideoRecordTimerTick_s = 0;
int VideoRecordTimerTick_m = 0;
bool VideoRecordIsEnable = NO;
-(void)CheckVideoPlayTimer{
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


/**
 *  返回上个界面
 */
-(void)back{
    NSLog(@"back");
    _isExit=YES;
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if (_uploadTimer!=nil){
        [_uploadTimer invalidate];
        _uploadTimer=nil;
        _isShowBanner=NO;
    }
    
    if (_isLiveView) {
        dispatch_async(dispatch_get_main_queue(),^ {
            if (_tipLabel) {
                [_tipLabel removeFromSuperview];
            }
            [self stopActivityIndicatorView];
        });
        if (_recordTimeLabel) {
            _recordTimeLabel.hidden=YES;
        }
        
        if (CheckVideoPlay) {
            [CheckVideoPlay invalidate];
            CheckVideoPlay = nil;
        }
    }
    
    if (_videoView)
    {
        [_videoView stop];
        _videoView = nil;
    }
    
    self.videoisplaying = NO;
    play_success=NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  返回
 */
- (void)_backBtnClick{
    if (_isConfig) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.view.frame=CGRectMake(0, 0, _viewW, _viewH);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        [self prefersStatusBarHidden:YES];
        _streamView.hidden=YES;
        //[self _scaleBtnClick:1];
        _isConfig=NO;
    }
    else{
        _isExit=YES;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [self prefersStatusBarHidden:YES];
        [self back];
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
-(void)_takephotoBtnClick
{
    
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

- (void)saveImageToAlbum:(BOOL)success{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [self showAllTextDialog:NSLocalizedString(@"save_photo", nil)];
        }
        else{
            [self showAllTextDialog:NSLocalizedString(@"save_photo_failed", nil)];
        }
    });
}


/**
 *  录像
 */
#pragma mark - 录像
-(void)_recordBtnClick{
    if (!play_success) {
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
 *  跳转到浏览相片和视频的界面
 */
-(void)_browserBtnClick{
    NSLog(@"浏览");
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
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    TTPlatformSelectViewController * vc = [[TTPlatformSelectViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  跳转到配置推流信息的界面
 */
-(void)_configureBtnClick
{
//    _isConfig=YES;
    _isBroswer=YES;
    
    PasswordViewController * v = [[PasswordViewController alloc] init];
    if (_userip) {
        v.configIP = _userip;
    }
    
    v.changeVideoNeedReplayBlock = ^()
    {
//        NSLog(@"改变了参数  等5秒重新播放");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *urlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
            NSLog(@"重新播放 urlString：%@",urlString);
//            [self.videoView removeFromSuperview];
//            [self.videoView delegate:nil];
//            self.videoView = nil;
//            
//            
//            _videoView = [[LX520View alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//            _videoView.userInteractionEnabled = YES;
//            
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesImage)];
//            [_videoView addGestureRecognizer:singleTap];
//            _videoView.backgroundColor = [UIColor blackColor];
//            
//            [_videoView set_log_level:4];
//            [_videoView sound:YES];
//            [_videoView delegate:self];
//            [self.view insertSubview:_videoView atIndex:0];

            
            [self.videoView play:urlString useTcp:NO];
            [self.videoView sound:audioisEnable];
            [self.videoView startGetYUVData:YES];
            [self.videoView startGetAudioData:YES];
            [self.videoView startGetH264Data:YES];
        });
    };
    
    [self.navigationController pushViewController:v animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}

/**
 *  点击直播按钮
 */
#pragma mark - 点击直播按钮
-(void)_liveStreamBtnClick{
    

    //如果是系统摄像头
    if (_liveCameraSource == IphoneBackCamera)
    {
        [NSThread detachNewThreadSelector:@selector(openLivingSession:) toTarget:self withObject:nil];
    }
    else
    {
        if (!play_success)
        {
            [self showAllTextDialog:NSLocalizedString(@"video_not_play", nil)];
            return;
        }

        //RAK设备
        if(_livingState==0)
        {
            _isExit=NO;
            [NSThread detachNewThreadSelector:@selector(openLivingSession:) toTarget:self withObject:nil];
        }
        else
        {
//            [self showAllTextDialog:NSLocalizedString(@"streaminig_on_live_tips", nil)];
        }
    }
}

/**
 *  暂停推流或开启推流
 */
-(void)_livePauseBtnClick{
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
-(void)_liveStopBtnClick{
    [self closeLivingSession];
}

/**
 *  设置横竖屏
 */
int valOrientation;
-(void)_scaleBtnClick:(int)type{
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    if(type==0){
        valOrientation = UIInterfaceOrientationPortrait;
    }
    else if(type==1){
        if (self.interfaceOrientation==UIDeviceOrientationLandscapeRight) {
//            NSLog(@"Right");
            valOrientation = UIInterfaceOrientationLandscapeLeft;
        }
        else{
//            NSLog(@"other");
            valOrientation = UIInterfaceOrientationLandscapeRight;
        }
    }
    [invocation setArgument:&valOrientation atIndex:2];
    [invocation invoke];
}

/**
 *  扫描设备
 */
#pragma mark - 扫描设备--------------------------
- (void)scanDevice
{
    if (_isExit) {
        return;
    }
    
    _tipLabel.text = NSLocalizedString(@"video_connecting", nil);
    
    [[TTSearchDeviceClass shareInstance] searDeviceWithSecond:5 CompletionHandler:^(Lx52x_Device_Info *resultinfo) {
        [self scanDeviceOver:resultinfo];
    }];
    
}


- (LX520View *)videoView
{
    if (!_videoView) {
        _videoView = [[LX520View alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _videoView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesImage)];
        [_videoView addGestureRecognizer:singleTap];
        _videoView.backgroundColor = [UIColor blackColor];
        
        [_videoView set_log_level:4];
        [_videoView sound:YES];
        [_videoView delegate:self];
        [self.view insertSubview:_videoView atIndex:0];
    }
    
    return _videoView;
}

- (void)scanDeviceOver:(Lx52x_Device_Info *)result;
{
    if (_isExit) {
        return;
    }
    
    if (result.Device_ID_Arr.count > 0) {
        
        //使用扫描到的第一个设备
        NSString *urlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", [result.Device_IP_Arr objectAtIndex:0],video_type];
        _userip = [result.Device_IP_Arr objectAtIndex:0];
        _userid = [result.Device_ID_Arr objectAtIndex:0];
        _subtitleViewController.ip=_userip;
        _bannerViewController.ip=_userip;
        _audioViewController.ip=_userip;
        _networkViewController.ip=_userip;
        //[self showAllTextDialog:_userip];
        NSLog(@"user ifo:id=%@ username=%@ userpassword=%@",_userid,_username,_userpassword);
        if (!_isLiveView){
            dispatch_async(dispatch_get_main_queue(),^ {
                [_waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
            });
            if (!_isUser) {
                _isUser=NO;
                return;
            }
        }
        
        [self getDeviceConfig];
        
        NSLog(@"start play==%@",urlString);
        [self.videoView play:urlString useTcp:NO];
        [self.videoView sound:audioisEnable];
        [self.videoView startGetYUVData:YES];
        [self.videoView startGetAudioData:YES];
        [self.videoView startGetH264Data:YES];
        
        self.videoisplaying = YES;
        if (_isLiveView) {
            
            //            [NSThread detachNewThreadSelector:@selector(GetStreamStatus) toTarget:self withObject:nil];
            //            [NSThread detachNewThreadSelector:@selector(GetAudioInput) toTarget:self withObject:nil];
            //            [NSThread detachNewThreadSelector:@selector(GetPower) toTarget:self withObject:nil];
        }
        
        
    }
    else
    {
        
        
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showActionSheetWithTitle:nil message:@"No search for equipment, whether to continue searching or using a mobile phone camera？" action1title:@"Continue Search" action2title:@"Use iPhone Camera" action3title:@"Cancel" action1Handler:^(UIAlertAction *action) {
                [self scanDevice];
            } action2Handler:^(UIAlertAction *action) {
                _tipLabel.hidden=YES;
                [self stopActivityIndicatorView];
                _session = [self getSessionWithSystemCamera];
                _livingPreView.hidden = NO;
                play_success = YES;
                _liveCameraSource = IphoneBackCamera;

            } action3Handler:^(UIAlertAction *action) {
                [self _backBtnClick];
            }];
        });

    }
}

#pragma mark - 获取设备的参数  码率 fps 等 --------------------

- (void)getDeviceConfig
{
    
    int configPort=80;
    NSString * configIP = _userip;
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_resol&type=h264&pipe=0",configIP,configPort];
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
                //                [self set720P];
            }
            else{
                //                [self set480P];
            }
        });
        NSLog(@"resolution=%@",_resolution);
    }
    
    //get quality
    URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_enc_quality&type=h264&pipe=0",configIP,configPort];
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
        NSLog(@"quality******************=%@",_quality);
    }
    else{
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"get_quality_failed", nil)];
        });
    }
    
    //get fps
    URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_max_fps&type=h264&pipe=0",configIP,configPort];
    http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        _fps=[self parseJsonString:http_request.ResponseString];
        dispatch_async(dispatch_get_main_queue(),^ {
            //            [self setVideoFrameRate:[fps intValue]];
            _session = [self getSessionWithRakisrak:YES];
        });
        
        NSLog(@"fps**************************=%@",_fps);
    }
    

    
}


/**
 *  用于判断是否断开，需要重连
 */
- (void)isPlaying:(BOOL)playing
{
    _isPlaying=playing;
}


#pragma mark -------------------
#pragma mark LX520Delegate
- (void)state_changed:(int)state
{
    
    NSLog(@"LX520Delegatestate_changed state = %d", state);
    switch (state) {
        case 0: //STATE_IDLE
        {
            play_success = NO;
            break;
        }
        case 1: //STATE_PREPARING
        {
            play_success = NO;
            break;
        }
        case 2: //STATE_PLAYING
        {
            play_success = YES;
            self.videoisplaying=YES;
            if (_isLiveView) {
                [self enableControl];
                dispatch_async(dispatch_get_main_queue(),^ {
                    _tipLabel.hidden=YES;
                    [self noHiddenStatus];
                    [self stopActivityIndicatorView];
                });
            }
            else
            {
           
            }
            
            break;
        }
        case 3: //STATE_STOPPED
        {
            play_success = NO;
            break;
            
        }
            
        default:
            break;
    }
}

- (void)video_info:(NSString *)codecName codecLongName:(NSString *)codecLongName
{
    NSLog(@"video_info :  codecName:%@ codecLongName:%@",codecName,codecLongName);
}

- (void)audio_info:(NSString *)codecName codecLongName:(NSString *)codecLongName sampleRate:(int)sampleRate channels:(int)channels
{
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
        
    }
    else
    {
        CGImageRelease(imageRef);
    }
}

- (void)GetAudioData:(Byte*)data :(int)size//回调获取音频数据
{
    NSLog(@"GetAudioData");
    if(_livingState==1 && !_isIphoneAudio){
        
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
    NSLog(@"GetH264Data");
    if(_livingState==1){
        [self.session upload_h264:size :data];
    }
}

/**
 *  获取屏幕尺寸变化作相应适配
 */
- (void)GetYUVData:(int)width :(int)height
                  :(Byte*)yData :(Byte*)uData :(Byte*)vData
                  :(int)ySize :(int)uSize :(int)vSize
{
    NSLog(@"获取屏幕尺寸变化作相应适配 GetYUVData ");
    _isPlaying=YES;
    if(_livingState==2){
        [self.session upload_PauseImg];
    }
    
    if (_isLiveView){
        //[self addBannerSubtitle];
        
        if ((height!=kHeight)||(width!=kWidth)) {
            kHeight=height;
            kWidth=width;
            NSLog(@"_width=%d,height=%d",kWidth,kHeight);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_viewH>_viewW) {
                    _temp=_viewW;
                    _tempviewW=_viewH;
                    _tempviewH=_temp;
                }
                if (_tempviewH<_tempviewW*kHeight/kWidth) {
                    _videoView.frame =CGRectMake(0, 0, _tempviewH*kWidth/kHeight, _tempviewH);
                    [_videoView setView1Frame:CGRectMake(0, 0, _tempviewH*kWidth/kHeight, _tempviewH)];
                    NSLog(@"w3=%f,h3=%f",_videoView.frame.size.width,_videoView.frame.size.height);
                }
                else{
                    _videoView.frame =CGRectMake(0, 0, _tempviewW, _tempviewW*kHeight/kWidth);
                    [_videoView setView1Frame:CGRectMake(0, 0, _tempviewW, _tempviewW*kHeight/kWidth)];
                    NSLog(@"w4=%f,h4=%f",_videoView.frame.size.width,_videoView.frame.size.height);
                }
                _videoView.center=CGPointMake(_tempviewW*0.5, _tempviewH*0.5);
            });
        }
    }
}


- (NSString *)Get_String:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}



/**
 *  视频链接状态及重连
 */
-(void)updateUI{
    if (self.videoisplaying ==NO) {
        if (scanCount>5) {
            _tipLabel.text = NSLocalizedString(@"no_device", nil);
            scanCount=0;
        }
        
    }
    else{
        if (play_success ==NO){
            ActivityIndicatorView.hidden=YES;
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
        playCount=0;
        ActivityIndicatorView.hidden=YES;
        if (_viewW<_viewH) {
            _tipLabel.center=CGPointMake(_viewH*0.5, _tipLabel.center.y);
        }
        else{
            _tipLabel.center=CGPointMake(_viewW*0.5, _tipLabel.center.y);
        }
        _tipLabel.textAlignment=NSTextAlignmentCenter;
    }
    else{
        playCount++;
//        if (playCount>5) {
//            [_videoView stop];
//            play_success=NO;
//            NSString *url = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
//            [_videoView play:url useTcp:NO];
//            [_videoView sound:audioisEnable];
//            playCount=0;
//        }
    }
    _isPlaying=NO;
    
    if (play_success) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int netFlow = [self checkNetworkflow];
            int flow=(int)(netFlow/1024);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (flow>0) {
                    if(flow<20){
                        [self stopActivityIndicatorView];
                        _tipLabel.text=NSLocalizedString(@"no_video", nil);
                        _tipLabel.hidden=NO;
                    }else{
                        _tipLabel.hidden=YES;
                        [self stopActivityIndicatorView];
                    }
                }
            });
        });
    }
    scanCount++;
}

/**
 *  视频连接动画
 */
CGFloat ix ;
CGFloat iy ;
-(void)startActivityIndicatorView{
    if (ActivityIndicatorViewisenable == YES) {
        return;
    }
    NSLog(@"startActivityIndicatorView");
    ix = self.view.frame.origin.x+(_viewW/2-25);
    iy = self.view.frame.origin.y+(_viewH/2-25);
    //    ActivityIndicatorView =[[UIImageView alloc] initWithFrame:CGRectMake(ix-90, iy, 50, 50)];
    ActivityIndicatorView =[[UIImageView alloc] initWithFrame:CGRectMake(_viewW*304/_totalWeight,129*_viewH/_totalHeight, _viewW*58.5/_totalWeight, _viewW*58.5/_totalWeight)];
    
    ActivityIndicatorView.image=[UIImage imageNamed:@"logo_148"];
    //    CABasicAnimation* rotationAnimation;
    //    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    //    rotationAnimation.duration = 0.5;
    //    rotationAnimation.cumulative = YES;
    //    rotationAnimation.repeatCount = 10000000000000;
    //    [ActivityIndicatorView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"]
    ;
    [self.view addSubview:ActivityIndicatorView];
    ActivityIndicatorViewisenable = YES;
    
    //    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(ix-30,iy, viewW, 50)];
    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(_viewW*295/_totalWeight,202.5*_viewH/_totalHeight, _viewW*79.5/_totalWeight, _viewH*12.5/_totalHeight)];
    //    _tipLabel.text = NSLocalizedString(@"video_connecting", nil);
    _tipLabel.text = @"Connecting…";
    _tipLabel.textColor = MAIN_COLOR;
    _tipLabel.font = [UIFont systemFontOfSize:12.5];
    _tipLabel.adjustsFontSizeToFitWidth = YES;
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _tipLabel.numberOfLines = 1;
    _tipLabel.backgroundColor=[UIColor clearColor]; //可以去掉背景色
    [self.view addSubview:_tipLabel];
}

-(void)stopActivityIndicatorView{
    if (ActivityIndicatorViewisenable == NO) {
        return;
    }
    NSLog(@"stopActivityIndicatorView");
    dispatch_async(dispatch_get_main_queue(),^ {
        if (_tipLabel) {
            [_tipLabel removeFromSuperview];
        }
        
        if (ActivityIndicatorView) {
            [ActivityIndicatorView removeFromSuperview];
            
        }
    });
    ActivityIndicatorViewisenable = NO;
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark-- Toast显示示例
-(void)showAllTextDialog:(NSString *)str{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //更新UI操作
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *_signal=[self parseJsonString:http_request.ResponseString];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *_signal=[self parseJsonString:http_request.ResponseString];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *_signal=[self parseJsonString:http_request.ResponseString];
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
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *_signal=[self parseJsonString:http_request.ResponseString];
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
    _session.isRAK=NO;
    _session.running =YES;
    _session.preView =_livingPreView;
    return _session;
}

//RAK设备的直播参数

- (LFLiveSessionWithPicSource *)getSessionWithRakisrak:(BOOL)rak
{
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
    _session.preView =_livingPreView;
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
    }
    
    else
    {
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
 * 停止获取视频
 */
- (void)stopVideo
{
    if (_isPlaying) {
        _livingState=0;
        _isPlaying=NO;
        [_videoView stop];
        NSLog(@"stop play");
    }
}


/**
 *  关闭直播
 */
-(void)closeLivingSession{
    if (_isLiveView) {
        
    }
    else{
        
        [self stopVideo];
    }
    [self setStopStreamStatus];
    
    if(self.session.state == LFLivePending || self.session.state ==LFLiveStart){
        [self.session stopLive];
        [self.session setRunning:NO];
    }
}


#pragma mark --LFStreamingSessionDelegate
-(void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo{
    
}

-(void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString *networkStatusInfo;
    
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPromptAlertWithTitile:@"Connect server error!" message:@"Connect error please check rtmp address or network" buttonTitle:@"OK" buttonClickHandler:^(UIAlertAction *action) {
                    if (_session) {
                        [_session stopLive];
                    }
                    
                }];
                [self setStopStreamStatus];
            });
          
        }
            break;
        default:
            break;
    }
    
    if (networkStatusInfo)
    {
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
    _livingState=1;
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
    
    [_videoView take_imageRef:NO];
    
    _takephotoBtn.enabled = YES;
    _recordBtn.enabled = YES;
    _livingState=2;
}

-(void)setStopStreamStatus{
    //直播界面
    [_liveStreamBtn setImage:[UIImage imageNamed:@"start live_nor@3x.png"] forState:UIControlStateNormal];
    
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
    
    [_videoView take_imageRef:NO];
    
    _takephotoBtn.enabled = YES;
    _recordBtn.enabled = YES;

    _livingState=0;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                _uploadTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFunction) userInfo:nil repeats:YES];
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
 *  推流界面初始化
 */
- (void)streamViewInit
{
    _viewH=self.view.frame.size.height;
    _viewW=self.view.frame.size.width;
    if (_viewH>_viewW) {
        
    }
    else{
        _viewW=self.view.frame.size.height;
        _viewH=self.view.frame.size.width;
    }
    NSLog(@"viewW1=%f,viewH1=%f",_viewW,_viewH);
    _totalHeight=64+71+149+149+149+80+5;//各部分比例
    _totalWeight=375;//各部分比例
    
    _streamView=[[UIView alloc]init];
    _streamView.frame=CGRectMake(0, 0, _viewW, _viewH);
    _streamView.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _streamView.userInteractionEnabled=YES;
    [self.view addSubview:_streamView];
    
    //顶部
    _topBgStream=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav bar_bg@3x.png"]];
    _topBgStream.frame = CGRectMake(0, 0, _viewW, _viewH*64/_totalHeight);
    _topBgStream.contentMode=UIViewContentModeScaleToFill;
    [_streamView addSubview:_topBgStream];
    
    _backBtnStream=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtnStream.frame = CGRectMake(0, diff_top, _viewH*44/_totalHeight, _viewH*44/_totalHeight);
    [_backBtnStream setImage:[UIImage imageNamed:@"back_nor@3x.png"] forState:UIControlStateNormal];
    [_backBtnStream setImage:[UIImage imageNamed:@"back_pre@3x.png"] forState:UIControlStateHighlighted];
    [_backBtnStream setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtnStream setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtnStream.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtnStream addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_streamView  addSubview:_backBtnStream];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtnStream.frame.origin.x+_backBtnStream.frame.size.width, diff_top, _viewW-_backBtnStream.frame.origin.x-_backBtnStream.frame.size.width-2*diff_x, _viewH*44/_totalHeight)];
    _titleLabel.center=CGPointMake(_viewW*0.5, _backBtnStream.center.y);
    _titleLabel.text = NSLocalizedString(@"streaminig_title", nil);
    _titleLabel.font = [UIFont boldSystemFontOfSize: _viewH*20/_totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [_streamView addSubview:_titleLabel];
    
    
    _streamingImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"IMG_2401.JPG"]];
    _streamingImg.userInteractionEnabled=YES;
    _streamingImg.frame = CGRectMake(0, _backBtnStream.frame.origin.y+_backBtnStream.frame.size.height, _viewW, _viewH*145/_totalHeight);
    _streamingImg.contentMode=UIViewContentModeScaleToFill;
    [_streamView addSubview:_streamingImg];
    
    _streamingTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,_viewH*83/_totalHeight, _viewW, _viewH*20/_totalHeight)];
    _streamingTitleLabel.center=CGPointMake(_viewW*0.5, _streamingTitleLabel.center.y);
    _streamingTitleLabel.text = NSLocalizedString(@"streaminig_title_label", nil);
    _streamingTitleLabel.font = [UIFont boldSystemFontOfSize: _viewH*20/_totalHeight*0.8];
    _streamingTitleLabel.backgroundColor = [UIColor clearColor];
    _streamingTitleLabel.textColor = [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1.0];
    _streamingTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingTitleLabel.textAlignment=UITextAlignmentCenter;
    _streamingTitleLabel.numberOfLines = 0;
    [_streamView addSubview:_streamingTitleLabel];
    
    _streamStatusImg=[[UIImageView alloc]init];
    _streamStatusImg.frame = CGRectMake(_viewW-_viewH*32/_totalHeight, _viewH*13/_totalHeight, _viewH*19/_totalHeight, _viewH*19/_totalHeight);
    _streamStatusImg.image=[UIImage imageNamed:@"live view_Indicator light_gray@3x.png"];
    //[_streamingImg  addSubview:_streamStatusImg];
    
    _streamingTitleImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live streaming_banner_text image@3x.png"]];
    _streamingTitleImg.userInteractionEnabled=YES;
    _streamingTitleImg.frame = CGRectMake(_viewW*55/_totalWeight, _viewH*29/_totalHeight, _viewW*264/_totalWeight, _viewW*264*48/_totalWeight/804);
    _streamingTitleImg.contentMode=UIViewContentModeScaleToFill;
    //[_streamingImg addSubview:_streamingTitleImg];
    
    //Control
    _streamingControlBgImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream_Slide bar_bg@3x.png"]];
    _streamingControlBgImg.userInteractionEnabled=YES;
    _streamingControlBgImg.frame = CGRectMake(0, _viewH*78/_totalHeight, _viewH*40*87/_totalHeight/12, _viewH*40/_totalHeight);
    _streamingControlBgImg.center=CGPointMake(_viewW*0.5, _streamingControlBgImg.center.y);
    _streamingControlBgImg.contentMode=UIViewContentModeScaleToFill;
    //[_streamingImg addSubview:_streamingControlBgImg];
    
    _streamingControlImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream_Slide bar_stop button@3x.png"]];
    _streamingControlImg.userInteractionEnabled=YES;
    UIPanGestureRecognizer *panGestureRecognizer= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_streamingControlImg addGestureRecognizer:panGestureRecognizer];
    _streamingControlImg.frame = CGRectMake(0, 0, _viewH*32/_totalHeight, _viewH*32/_totalHeight);
    _streamingControlImg.center=CGPointMake(_streamingControlBgImg.frame.size.width-_viewH*20/_totalHeight, _viewH*20/_totalHeight);
    _r_control_pos=_streamingControlImg.center.x;
    _streamingControlImg.center=CGPointMake(_streamingControlBgImg.frame.size.width*0.5, _viewH*20/_totalHeight);
    _c_control_pos=_streamingControlImg.center.x;
    _streamingControlImg.center=CGPointMake(_viewH*20/_totalHeight, _viewH*20/_totalHeight);
    _l_control_pos=_streamingControlImg.center.x;
    _streamingControlImg.contentMode=UIViewContentModeScaleToFill;
    //[_streamingControlBgImg addSubview:_streamingControlImg];
    
    _streamingStartBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _streamingStartBtn.frame = CGRectMake(0, _viewH*116/_totalHeight, _viewH*60/_totalHeight, _viewH*60/_totalHeight);
    _streamingStartBtn.center=CGPointMake(_viewW*0.5, _streamingStartBtn.center.y);
    [_streamingStartBtn setImage:[UIImage imageNamed:@"go live_pre@3x.png"] forState:UIControlStateNormal];
    _streamingStartBtn.contentMode=UIViewContentModeScaleToFill;
    [_streamingStartBtn addTarget:nil action:@selector(_streamingStartBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_streamView  addSubview:_streamingStartBtn];
    
    _streamingPauseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _streamingPauseBtn.frame = CGRectMake(0, _viewH*156/_totalHeight, _viewH*40/_totalHeight, _viewH*40/_totalHeight);
    _streamingPauseBtn.center=CGPointMake(_viewW*0.5-_viewH*80/_totalHeight, _streamingPauseBtn.center.y);
    [_streamingPauseBtn setImage:[UIImage imageNamed:@"puase live_dis@3x.png"] forState:UIControlStateNormal];
    _streamingPauseBtn.contentMode=UIViewContentModeScaleToFill;
    [_streamingPauseBtn addTarget:nil action:@selector(_streamingPauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_streamView  addSubview:_streamingPauseBtn];
    
    _streamingStopBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _streamingStopBtn.frame = CGRectMake(0, _viewH*156/_totalHeight, _viewH*40/_totalHeight, _viewH*40/_totalHeight);
    _streamingStopBtn.center=CGPointMake(_viewW*0.5+_viewH*80/_totalHeight, _streamingStopBtn.center.y);
    [_streamingStopBtn setImage:[UIImage imageNamed:@"stop live_dis@3x.png"] forState:UIControlStateNormal];
    _streamingStopBtn.contentMode=UIViewContentModeScaleToFill;
    [_streamingStopBtn addTarget:nil action:@selector(_streamingStopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_streamView  addSubview:_streamingStopBtn];
    
    _customStreamingLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,_streamingImg.frame.origin.y+_streamingImg.frame.size.height, _viewW, _viewH*30/_totalHeight)];
    _customStreamingLabel.center=CGPointMake(_viewW*0.5, _customStreamingLabel.center.y);
    _customStreamingLabel.text = NSLocalizedString(@"custom_streaminig_label", nil);
    _customStreamingLabel.font = [UIFont boldSystemFontOfSize: _viewH*16/_totalHeight*0.8];
    _customStreamingLabel.backgroundColor = [UIColor clearColor];
    _customStreamingLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _customStreamingLabel.lineBreakMode = UILineBreakModeWordWrap;
    _customStreamingLabel.textAlignment=UITextAlignmentCenter;
    _customStreamingLabel.numberOfLines = 0;
    [_streamView addSubview:_customStreamingLabel];
    
    //Config view2
    _streamingConfigView=[[UIView alloc]initWithFrame:CGRectMake(0,_streamingImg.frame.origin.y+_streamingImg.frame.size.height+_viewH*30/_totalHeight,_viewW,_viewH*77/_totalHeight)];
    _streamingConfigView.userInteractionEnabled=YES;
    UIPanGestureRecognizer *panGestureRecognizer2= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView2:)];
    //[_streamingConfigView addGestureRecognizer:panGestureRecognizer2];
    _streamingConfigView.backgroundColor=[UIColor whiteColor];
    [_streamView addSubview:_streamingConfigView];
    
    _linkmanBtn0=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn0.frame = CGRectMake(_viewW*72/_totalWeight, _viewH*12/_totalHeight, _viewH*40*173/165/_totalHeight, _viewH*40/_totalHeight);
    _linkmanBtn0.center=CGPointMake(_viewW*0.5-_viewW*94/_totalWeight, _linkmanBtn0.center.y);
    [_linkmanBtn0 setImage:[UIImage imageNamed:@"subtitle@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn0 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn0 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn0.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn0 addTarget:nil action:@selector(_linkmanBtn0Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn0];
    
    _linkmanLabel0 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn0.frame.origin.y+_linkmanBtn0.frame.size.height+_viewH*4/_totalHeight, _viewW*50/_totalWeight, _viewH*15/_totalHeight)];
    _linkmanLabel0.center=CGPointMake(_linkmanBtn0.center.x, _linkmanLabel0.center.y);
    _linkmanLabel0.text = NSLocalizedString(@"parameter_subtitle", nil);
    _linkmanLabel0.font = [UIFont systemFontOfSize: _viewH*14/_totalHeight*0.8];
    _linkmanLabel0.backgroundColor = [UIColor clearColor];
    _linkmanLabel0.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel0.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel0.textAlignment=UITextAlignmentCenter;
    _linkmanLabel0.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel0];
    
    UIView *_linkmanline0=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn0.frame.origin.x+_linkmanBtn0.frame.size.width+_viewW*24/_totalWeight,_viewH*18/_totalHeight,_viewW*1/_totalWeight,_viewH*40/_totalHeight)];
    _linkmanline0.center=CGPointMake(_viewW*0.5-_viewW*47/_totalWeight, _linkmanline0.center.y);
    _linkmanline0.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_streamingConfigView addSubview:_linkmanline0];
    
    _linkmanBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn1.frame = CGRectMake(0, _viewH*12/_totalHeight, _viewH*40*173/165/_totalHeight, _viewH*40/_totalHeight);
    _linkmanBtn1.center=CGPointMake(_viewW*0.5, _linkmanBtn0.center.y);
    [_linkmanBtn1 setImage:[UIImage imageNamed:@"logo_nor@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn1 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn1 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn1.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn1 addTarget:nil action:@selector(_linkmanBtn1Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn1];
    
    _linkmanLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn1.frame.origin.y+_linkmanBtn1.frame.size.height+_viewH*4/_totalHeight, _viewW*50/_totalWeight, _viewH*15/_totalHeight)];
    _linkmanLabel1.center=CGPointMake(_viewW*0.5, _linkmanLabel0.center.y);
    _linkmanLabel1.text = NSLocalizedString(@"parameter_banner", nil);
    _linkmanLabel1.font = [UIFont systemFontOfSize: _viewH*14/_totalHeight*0.8];
    _linkmanLabel1.backgroundColor = [UIColor clearColor];
    _linkmanLabel1.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel1.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel1.textAlignment=UITextAlignmentCenter;
    _linkmanLabel1.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel1];
    
    UIView *_linkmanline1=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn1.frame.origin.x+_linkmanBtn1.frame.size.width+_viewW*24/_totalWeight,_viewH*18/_totalHeight,_viewW*1/_totalWeight,_viewH*40/_totalHeight)];
    _linkmanline1.center=CGPointMake(_viewW*0.5+_viewW*47/_totalWeight, _linkmanline1.center.y);
    _linkmanline1.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_streamingConfigView addSubview:_linkmanline1];
    
    _linkmanBtn2=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn2.frame = CGRectMake(0, _viewH*12/_totalHeight, _viewH*40*173/165/_totalHeight, _viewH*40/_totalHeight);
    _linkmanBtn2.center=CGPointMake(_viewW*0.625, _linkmanBtn2.center.y);
    [_linkmanBtn2 setImage:[UIImage imageNamed:@"live stream_screen_icon@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn2 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn2 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn2.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn2 addTarget:nil action:@selector(_linkmanBtn2Click) forControlEvents:UIControlEventTouchUpInside];
    //[_streamingConfigView  addSubview:_linkmanBtn2];
    
    _linkmanLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn2.frame.origin.y+_linkmanBtn2.frame.size.height+_viewH*4/_totalHeight, _viewW*50/_totalWeight, _viewH*15/_totalHeight)];
    _linkmanLabel2.center=CGPointMake(_viewW*0.625, _linkmanLabel2.center.y);
    _linkmanLabel2.text = NSLocalizedString(@"parameter_screen", nil);
    _linkmanLabel2.font = [UIFont systemFontOfSize: _viewH*14/_totalHeight*0.8];
    _linkmanLabel2.backgroundColor = [UIColor clearColor];
    _linkmanLabel2.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel2.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel2.textAlignment=UITextAlignmentCenter;
    _linkmanLabel2.numberOfLines = 0;
    //[_streamingConfigView addSubview:_linkmanLabel2];
    
    UIView *_linkmanline2=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn2.frame.origin.x+_linkmanBtn2.frame.size.width+_viewW*24/_totalWeight,_viewH*18/_totalHeight,_viewW*1/_totalWeight,_viewH*40/_totalHeight)];
    _linkmanline2.center=CGPointMake(_viewW*3/4, _linkmanline2.center.y);
    _linkmanline2.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    //[_streamingConfigView addSubview:_linkmanline2];
    
    _linkmanBtn3=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn3.frame = CGRectMake(_viewW-_viewW*72/_totalWeight, _viewH*12/_totalHeight, _viewH*40*173/165/_totalHeight, _viewH*40/_totalHeight);
    _linkmanBtn3.center=CGPointMake(_viewW*0.5+_viewW*94/_totalWeight, _linkmanBtn0.center.y);
    [_linkmanBtn3 setImage:[UIImage imageNamed:@"audio@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn3 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn3 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn3.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn3 addTarget:nil action:@selector(_linkmanBtn3Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn3];
    
    _linkmanLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn3.frame.origin.y+_linkmanBtn3.frame.size.height+_viewH*4/_totalHeight, _viewW*50/_totalWeight, _viewH*15/_totalHeight)];
    _linkmanLabel3.center=CGPointMake(_linkmanBtn3.center.x, _linkmanLabel3.center.y);
    _linkmanLabel3.text = NSLocalizedString(@"parameter_audio", nil);
    _linkmanLabel3.font = [UIFont systemFontOfSize: _viewH*14/_totalHeight*0.8];
    _linkmanLabel3.backgroundColor = [UIColor clearColor];
    _linkmanLabel3.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel3.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel3.textAlignment=UITextAlignmentCenter;
    _linkmanLabel3.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel3];
    
    UIView *_linkmanline3=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn3.frame.origin.x+_linkmanBtn3.frame.size.width+_viewW*24/_totalWeight,_viewH*18/_totalHeight,_viewW*1/_totalWeight,_viewH*40/_totalHeight)];
    _linkmanline3.center=CGPointMake(_viewW-10*_totalWeight/_viewW, _linkmanline3.center.y);
    _linkmanline3.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    //[_streamingConfigView addSubview:_linkmanline3];
    
    _linkmanBtn4=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn4.frame = CGRectMake(0, _viewH*12/_totalHeight, _viewH*40*132/123/_totalHeight, _viewH*40/_totalHeight);
    _linkmanBtn4.center=CGPointMake(_viewW*1.125, _linkmanBtn0.center.y);
    [_linkmanBtn4 setImage:[UIImage imageNamed:@"live stream_network_icon@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn4 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn4 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn4.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn4 addTarget:nil action:@selector(_linkmanBtn4Click) forControlEvents:UIControlEventTouchUpInside];
    //[_streamingConfigView  addSubview:_linkmanBtn4];
    
    _linkmanLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn4.frame.origin.y+_linkmanBtn4.frame.size.height+_viewH*4/_totalHeight, _viewW*50/_totalWeight, _viewH*15/_totalHeight)];
    _linkmanLabel4.center=CGPointMake(_viewW*1.125, _linkmanLabel4.center.y);
    _linkmanLabel4.text = NSLocalizedString(@"parameter_network", nil);
    _linkmanLabel4.font = [UIFont systemFontOfSize: _viewH*14/_totalHeight*0.8];
    _linkmanLabel4.backgroundColor = [UIColor clearColor];
    _linkmanLabel4.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel4.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel4.textAlignment=UITextAlignmentCenter;
    _linkmanLabel4.numberOfLines = 0;
    //[_streamingConfigView addSubview:_linkmanLabel4];
    
    //platform
    _streamingAddressLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, _viewW, _viewH*30/_totalHeight)];
    _streamingAddressLabel.center=CGPointMake(_viewW*0.5, _streamingConfigView.frame.origin.y+_streamingConfigView.frame.size.height+_viewH*15/_totalHeight);
    _streamingAddressLabel.text = NSLocalizedString(@"streaminig_address", nil);
    _streamingAddressLabel.font = [UIFont boldSystemFontOfSize: _viewH*16/_totalHeight*0.8];
    _streamingAddressLabel.backgroundColor = [UIColor clearColor];
    _streamingAddressLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _streamingAddressLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingAddressLabel.textAlignment=UITextAlignmentCenter;
    _streamingAddressLabel.numberOfLines = 0;
    [_streamView addSubview:_streamingAddressLabel];
    
    _streamingAddressView=[[UIView alloc]initWithFrame:CGRectMake(0,_streamingAddressLabel.frame.origin.y+_streamingAddressLabel.frame.size.height,_viewW,_viewH*135/_totalHeight)];
    _streamingAddressView.backgroundColor=[UIColor whiteColor];
    _streamingAddressView.userInteractionEnabled = YES;
    [_streamView addSubview:_streamingAddressView];
    
    _platformView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(_viewW*15/_totalWeight,_streamingAddressLabel.frame.origin.y+_streamingAddressLabel.frame.size.height+_viewH*15/_totalHeight,_viewW*124/_totalWeight,_viewH*105/_totalHeight)];
    _platformView.userInteractionEnabled = YES;
    _platformView.center=CGPointMake(_viewW*1/4, _platformView.center.y);
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformViewClick)];
    [_platformView addGestureRecognizer:singleTap2];
    [_streamView addSubview:_platformView];
    
    _streamingPlatformImg=[[UIImageView alloc]init];
    _streamingPlatformImg.frame = CGRectMake((_platformView.frame.size.width-_viewH*66/_totalHeight*164/132)*0.5, _viewH*11/_totalHeight, _viewH*66/_totalHeight*164/132, _viewH*66/_totalHeight);
    [_streamingPlatformImg setImage:[UIImage imageNamed:@"platform@3x.png"]];
    [_platformView  addSubview:_streamingPlatformImg];
    
    _streamingPlatform = [[UILabel alloc] initWithFrame:CGRectMake(0, _streamingPlatformImg.frame.origin.y+_streamingPlatformImg.frame.size.height+_viewH*8/_totalHeight, _platformView.frame.size.width, _viewH*16/_totalHeight)];
    _streamingPlatform.text = NSLocalizedString(@"platform_text", nil);
    _streamingPlatform.font = [UIFont systemFontOfSize: _viewH*16/_totalHeight*0.8];
    _streamingPlatform.backgroundColor = [UIColor clearColor];
    _streamingPlatform.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _streamingPlatform.lineBreakMode = UILineBreakModeWordWrap;
    _streamingPlatform.textAlignment=UITextAlignmentCenter;
    _streamingPlatform.numberOfLines = 0;
    [_platformView addSubview:_streamingPlatform];
    
    UIView *line1=[[UIView alloc]initWithFrame:CGRectMake(_viewW*187/_totalWeight,_streamingAddressView.frame.origin.y+_viewH*21/_totalHeight,_viewW*1/_totalWeight,_streamingAddressView.frame.size.height-_viewH*42/_totalHeight)];
    line1.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_streamView addSubview:line1];
    
    //Address View
    _addressView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(_viewW*219/_totalWeight,_streamingAddressLabel.frame.origin.y+_streamingAddressLabel.frame.size.height+_viewH*15/_totalHeight,_viewW*124/_totalWeight,_viewH*105/_totalHeight)];
    _addressView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_addressViewClick)];
    [_addressView addGestureRecognizer:singleTap3];
    _addressView.center=CGPointMake(_viewW*3/4, _addressView.center.y);
    [_streamView addSubview:_addressView];
    
    _streamingAddressImg=[[UIImageView alloc]init];
    _streamingAddressImg.frame = CGRectMake(_viewW*26/_totalWeight, _viewH*11/_totalHeight, _viewH*66/_totalHeight*164/132, _viewH*66/_totalHeight);
    _streamingAddressImg.center=CGPointMake(_addressView.frame.size.width*0.5, _streamingAddressImg.center.y);
    [_streamingAddressImg setImage:[UIImage imageNamed:@"fill in@3x.png"]];
    [_addressView  addSubview:_streamingAddressImg];
    
    _streamingAddress = [[MarqueeLabel alloc] initWithFrame: CGRectMake(0, _streamingAddressImg.frame.origin.y+_streamingAddressImg.frame.size.height+_viewH*3/_totalHeight, _addressView.frame.size.width, _viewH*28/_totalHeight) duration:7.0 andFadeLength:10.0f];
    _streamingAddress.text= [self Get_Paths:STREAM_URL_KEY];
    if ([_streamingAddress.text compare:@""]==NSOrderedSame) {
        _streamingAddress.text = NSLocalizedString(@"address_text", nil);
    }
    _streamingAddress.font = [UIFont systemFontOfSize: _viewH*16/_totalHeight*0.8];
    _streamingAddress.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _streamingAddress.center=CGPointMake(_addressView.frame.size.width*0.5, _streamingAddress.center.y);
    _streamingAddress.textAlignment=UITextAlignmentCenter;
    _streamingAddress.numberOfLines = 1;
    _streamingAddress.opaque = NO;
    _streamingAddress.enabled = YES;
    _addressView.userInteractionEnabled=YES;
    _streamingAddress.shadowOffset = CGSizeMake(0.0, -1.0);
    [_addressView addSubview:_streamingAddress];
    
    //streamingAddress
    _streamingShareLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, _viewW, _viewH*30/_totalHeight)];
    _streamingShareLabel.center=CGPointMake(_viewW*0.5, _streamingAddressView.frame.origin.y+_streamingAddressView.frame.size.height+_viewH*15/_totalHeight);
    _streamingShareLabel.text = NSLocalizedString(@"address_dialog_title", nil);
    _streamingShareLabel.font = [UIFont boldSystemFontOfSize: _viewH*16/_totalHeight*0.8];
    _streamingShareLabel.backgroundColor = [UIColor clearColor];
    _streamingShareLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _streamingShareLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingShareLabel.textAlignment=UITextAlignmentCenter;
    _streamingShareLabel.numberOfLines = 0;
    [_streamView addSubview:_streamingShareLabel];
    
    _streamingShareView=[[UIView alloc]initWithFrame:CGRectMake(0,_streamingShareLabel.frame.origin.y+_streamingShareLabel.frame.size.height,_viewW,_viewH*155/_totalHeight)];
    _streamingShareView.backgroundColor=[UIColor whiteColor];
    [_streamView addSubview:_streamingShareView];
    
    _streamingObtainLabel=[[UILabel alloc] initWithFrame:CGRectMake(_viewW*20/_totalWeight,_viewH*16/_totalHeight, _viewW*67/_totalWeight, _viewH*32/_totalHeight)];
    _streamingObtainLabel.text = NSLocalizedString(@"streaminig_obtain", nil);
    _streamingObtainLabel.font = [UIFont systemFontOfSize: _viewH*20/_totalHeight*0.8];
    _streamingObtainLabel.backgroundColor = [UIColor clearColor];
    _streamingObtainLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _streamingObtainLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingObtainLabel.textAlignment=UITextAlignmentRight;
    _streamingObtainLabel.numberOfLines = 0;
    [_streamingShareView addSubview:_streamingObtainLabel];
    
    _streamingObtainField = [[UITextField alloc] initWithFrame:CGRectMake(_viewW*91/_totalWeight, _viewH*16/_totalHeight, _viewW-_viewW*123/_totalWeight, _viewH*32/_totalHeight)];
    _streamingObtainField.placeholder = NSLocalizedString(@"address_live_tips", nil);
    _streamingObtainField.font = [UIFont systemFontOfSize: _viewH*18/_totalHeight*0.8];
    _streamingObtainField.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _streamingObtainField.delegate = self;
    _streamingObtainField.textColor = MAIN_COLOR;
    _streamingObtainField.textAlignment=UITextAlignmentLeft;
    [_streamingShareView addSubview:_streamingObtainField];
    
    _streamingMannualLabel=[[UILabel alloc] initWithFrame:CGRectMake(_viewW*20/_totalWeight,_viewH*69/_totalHeight, _viewW*67/_totalWeight, _viewH*32/_totalHeight)];
    _streamingMannualLabel.text = NSLocalizedString(@"streaminig_manual", nil);
    _streamingMannualLabel.font = [UIFont systemFontOfSize: _viewH*20/_totalHeight*0.8];
    _streamingMannualLabel.backgroundColor = [UIColor clearColor];
    _streamingMannualLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _streamingMannualLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingMannualLabel.textAlignment=UITextAlignmentRight;
    _streamingMannualLabel.numberOfLines = 0;
    [_streamingShareView addSubview:_streamingMannualLabel];
    
    _streamingMannualField = [[UITextField alloc] initWithFrame:CGRectMake(_viewW*91/_totalWeight, _viewH*69/_totalHeight, _viewW-_viewW*123/_totalWeight, _viewH*32/_totalHeight)];
    _streamingMannualField.placeholder = @"http://";
    _streamingMannualField.font = [UIFont systemFontOfSize: _viewH*18/_totalHeight*0.8];
    _streamingMannualField.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _streamingMannualField.textColor = MAIN_COLOR;
    _streamingMannualField.delegate = self;
    _streamingMannualField.textAlignment=UITextAlignmentLeft;
    [_streamingShareView addSubview:_streamingMannualField];
    
    _streamingShareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _streamingShareBtn.frame = CGRectMake(_viewW*135/_totalWeight, _viewH*113/_totalHeight, _viewW*106/_totalWeight, _viewH*32/_totalHeight);
    [_streamingShareBtn setBackgroundImage:[UIImage imageNamed:@"live stream_address_button_nor@3x.png"] forState:UIControlStateNormal];
    [_streamingShareBtn setBackgroundImage:[UIImage imageNamed:@"live stream_address_button_pre@3x.png"] forState:UIControlStateHighlighted];
    [_streamingShareBtn setTitle: NSLocalizedString(@"streaminig_share", nil) forState: UIControlStateNormal];
    [_streamingShareBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _streamingShareBtn.titleLabel.font = [UIFont systemFontOfSize: _viewH*18/_totalHeight*0.8];
    _streamingShareBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_streamingShareBtn addTarget:nil action:@selector(_streamingShareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_streamingShareView  addSubview:_streamingShareBtn];
    
    //Choose Platform View
    [self platformViewInit];
    
    //Input Address View
    [self inputAddressViewInit];
}

/**
 * 选择平台弹窗
 */
-(void)platformViewInit{
    _choosePlatformView=[[UIView alloc]initWithFrame:CGRectMake(0,_viewH,_viewW,_viewH)];
    _choosePlatformView.backgroundColor=[UIColor clearColor];
    _choosePlatformView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutCancelClick)];
    [_choosePlatformView addGestureRecognizer:singleTap];
    [_streamView addSubview:_choosePlatformView];
    
    _PlatformViewLayout=[[UIView alloc]initWithFrame:CGRectMake(_viewW*10/_totalWeight,_viewH*476/_totalHeight,_viewW*355/_totalWeight,_viewH*116/_totalHeight)];
    [[_PlatformViewLayout layer]setCornerRadius:_viewW*10/_totalWeight];//圆角
    _PlatformViewLayout.backgroundColor=[UIColor whiteColor];
    _PlatformViewLayout.userInteractionEnabled = YES;
    [_choosePlatformView addSubview:_PlatformViewLayout];
    
    for (int i=0; i<4; i++) {
        UIViewLinkmanTouch *_platformLayoutView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(_viewW*13*(i+1)/_totalWeight+_viewW*70*i/_totalWeight,_viewH*15/_totalHeight,_viewW*20/_totalWeight+_viewH*60/_totalHeight,_viewH*90/_totalHeight)];
        
        _platformLayoutView.tag=i;
        _platformLayoutView.userInteractionEnabled = YES;
        [_PlatformViewLayout addSubview:_platformLayoutView];
        UIImageView *_platformLayoutImg=[[UIImageView alloc]init];
        _platformLayoutImg.frame = CGRectMake(_viewW*10/_totalWeight, _viewH*5/_totalHeight, _viewH*60/_totalHeight, _viewH*60/_totalHeight);
        [_platformLayoutImg setImage:[UIImage imageNamed:@"Youtube@3x.png"]];
        [_platformLayoutView  addSubview:_platformLayoutImg];
        
        UILabel *_platformLayoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(_platformLayoutImg.frame.origin.x, _platformLayoutImg.frame.origin.y+_platformLayoutImg.frame.size.height+_viewH*7/_totalHeight, _viewH*60/_totalHeight, _viewH*13/_totalHeight)];
        _platformLayoutLabel.text = NSLocalizedString(@"youtube", nil);
        _platformLayoutLabel.font = [UIFont systemFontOfSize: _viewH*13/_totalHeight];
        _platformLayoutLabel.backgroundColor = [UIColor clearColor];
        _platformLayoutLabel.textColor = [UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1.0];
        _platformLayoutLabel.lineBreakMode = UILineBreakModeWordWrap;
        _platformLayoutLabel.textAlignment=UITextAlignmentCenter;
        _platformLayoutLabel.numberOfLines = 0;
        [_platformLayoutView addSubview:_platformLayoutLabel];
        switch (i) {
            case 0:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"Youtube@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"youtube", nil);
                UITapGestureRecognizer *singleTap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick0)];
                [_platformLayoutView addGestureRecognizer:singleTap0];
            }
                break;
            case 1:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"facebook@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"facebook", nil);
                UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick1)];
                [_platformLayoutView addGestureRecognizer:singleTap1];
            }
                break;
            case 2:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"Yi Live@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"yi_live", nil);
                UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick2)];
                [_platformLayoutView addGestureRecognizer:singleTap2];
            }
                break;
            case 3:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"MuDu Live@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"mudu_live", nil);
                UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick3)];
                [_platformLayoutView addGestureRecognizer:singleTap3];
            }
                break;
                
            default:
                break;
        }
    }
    
    UIButton *_platformLayoutCancel=[UIButton buttonWithType:UIButtonTypeCustom];
    _platformLayoutCancel.frame = CGRectMake(_viewW*10/_totalWeight, _viewH*600/_totalHeight, _viewW*355/_totalWeight, _viewH*57/_totalHeight);
    _platformLayoutCancel.backgroundColor=[UIColor whiteColor];
    [_platformLayoutCancel setTitleColor:[UIColor colorWithRed:67/255.0 green:77/255.0 blue:87/255.0 alpha:1.0]forState:UIControlStateNormal];
    [_platformLayoutCancel setTitleColor:[UIColor lightGrayColor]forState:UIControlStateHighlighted];
    [[_platformLayoutCancel layer]setCornerRadius:_viewW*10/_totalWeight];
    [_platformLayoutCancel setTitle:NSLocalizedString(@"share_cancel", nil) forState:UIControlStateNormal];
    _platformLayoutCancel.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_platformLayoutCancel addTarget:nil action:@selector(_platformLayoutCancelClick) forControlEvents:UIControlEventTouchUpInside];
    _platformLayoutCancel.titleLabel.font=[UIFont systemFontOfSize:_viewH*23/_totalHeight*0.8];
    [_choosePlatformView  addSubview:_platformLayoutCancel];
}

/**
 * 选择平台：youtube
 */
-(void)_platformLayoutViewClick0{
    NSLog(@"Youtube");
    _streamingPlatform.text=NSLocalizedString(@"youtube", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
    _streamingPlatform.textColor = MAIN_COLOR;
}

/**
 * 选择平台：facebook
 */
-(void)_platformLayoutViewClick1{
    NSLog(@"Facebook");
    _streamingPlatform.text=NSLocalizedString(@"facebook", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
    _streamingPlatform.textColor = MAIN_COLOR;
}

/**
 * 选择平台：yi live
 */
-(void)_platformLayoutViewClick2{
    NSLog(@"Yi Live");
    _streamingPlatform.text=NSLocalizedString(@"yi_live", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
    _streamingPlatform.textColor = MAIN_COLOR;
}

/**
 * 选择平台：mudu
 */
-(void)_platformLayoutViewClick3{
    NSLog(@"MuDu Live");
    _streamingPlatform.text=NSLocalizedString(@"mudu_live", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
    _streamingPlatform.textColor = MAIN_COLOR;
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mudu.tv/login"]];
}

/**
 * 取消选择平台
 */
-(void)_platformLayoutCancelClick{
    NSLog(@"_platformLayoutCancelClick");
    _streamingPlatform.text=NSLocalizedString(@"platform_text", nil);
    _streamingPlatform.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    [self setInfoViewFrame:_choosePlatformView :YES];
}

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

/**
 * 文字滚动相关回调
 */
- (void) CAAutoTextFillBeginEditing:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillBeginEditing");
}

- (void) CAAutoTextFillEndEditing:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillEndEditing");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([textField.txtField.text compare:@""]!=NSOrderedSame) {
            _streamingAddress.text=textField.txtField.text;
            [self Save_Paths:_streamingAddress.text :STREAM_URL_KEY];
            [self addUrls];
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
            [self _liveStreamBtnClick];
        }
        else{
            if (_userip!=nil) {
                NSString *url = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
                [_videoView play:url useTcp:NO];
                [_videoView sound:audioisEnable];
                self.videoisplaying = YES;
            }
            else{
                [self scanDevice];
                _isUser=YES;
            }
        }
    }
    else{
        [self showAllTextDialog:NSLocalizedString(@"streaminig_on_live_tips", nil)];
    }
}

-(void)_streamingPauseBtnClick{
    if (_livingState==0) {
        [self showAllTextDialog:NSLocalizedString(@"streaminig_no_start_live_tips", nil)];
    }
    else if (_livingState==1) {//暂停推流
        [self setPauseStreamStatus];
    }
    else if (_livingState==2) {//重新开始推流
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

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
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
                    [self _liveStreamBtnClick];
                }
                else{
                    if (_userip!=nil) {
                        NSString *url = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
                        [_videoView play:url useTcp:NO];
                        [_videoView sound:audioisEnable];
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
- (void) panView2:(UIPanGestureRecognizer *)panGestureRecognizer
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
 * 设置字幕
 */
- (void)_linkmanBtn0Click{
    NSLog(@"_linkmanBtn0Click");
    [self.navigationController pushViewController: _subtitleViewController animated:true];
}

/**
 * 设置角标
 */
- (void)_linkmanBtn1Click{
    NSLog(@"_linkmanBtn1Click");
    [self.navigationController pushViewController: _bannerViewController animated:true];
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
 * 设置声音
 */
- (void)_linkmanBtn3Click{
    NSLog(@"_linkmanBtn3Click");
    [self.navigationController pushViewController: _audioViewController animated:true];
}

/**
 * 设置网络
 */
- (void)_linkmanBtn4Click{
    NSLog(@"_linkmanBtn4Click");
    [self.navigationController pushViewController: _networkViewController animated:true];
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
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

@end
