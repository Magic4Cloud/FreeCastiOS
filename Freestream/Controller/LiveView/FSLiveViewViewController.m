//
//  FSLiveViewViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/16.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSLiveViewViewController.h"
#import "CommonAppHeader.h"

//controller
#import "FSStreamViewController.h"



#import <Photos/Photos.h>

//URLS
#import "FSDeviceConfigureAPIRESTfulService.h"

#import "WisView.h"

//检测流量用
#import <ifaddrs.h>
#import <net/if.h>

typedef NS_ENUM(NSInteger, FSLiveViewSource) {
    FSLiveViewSourceFreestreamDevice,
    FSLiveViewSourceBackCamera,
};

#define FSLiveViewVideoType @"h264"
static NSString *const fsLiveViewVideoFormat = @"h264";//视频格式
static NSInteger const configPort = 80;//端口号
static NSInteger const searchDurationMax = 8;


@interface FSLiveViewViewController ()<LFLiveSessionDelegate,WisViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;

//topBar
@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (weak, nonatomic) IBOutlet UIImageView *wifiImageView;
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIImageView *audioModelImageView;
@property (weak, nonatomic) IBOutlet UIImageView *powerStatusImageView;

//center
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoCenterImageView;
@property (weak, nonatomic) IBOutlet UIButton *liveStopButton;

//bottomBar
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *streamButton;
@property (weak, nonatomic) IBOutlet UIButton *browserButton;
@property (weak, nonatomic) IBOutlet UIButton *configureButton;
@property (weak, nonatomic) IBOutlet UIButton *platformButton;

@property (nonatomic,strong) UITapGestureRecognizer *contentViewTapGesture;

@property (nonatomic,strong) UITapGestureRecognizer *videoViewTapGesture;
@property (nonatomic,strong) WisView          *videoView;

@property (nonatomic,assign) BOOL             topBarAndBottomBarIsHiden;//隐藏上面的条和下面的条
@property (nonatomic,assign) BOOL             isLiving;//是否正在直播中
@property (nonatomic,assign) BOOL             liveViewIsPlaying;//liveView是否在播放
@property (nonatomic,assign) BOOL             isExit;//是否已退出
@property (nonatomic,assign) NSInteger        increaseSearchDuration;//搜索时间(随着重搜次数增长1秒)
@property (nonatomic,assign) FSLiveViewSource liveViewSource;

@property (nonatomic,  copy) NSString         *userConnectingDeviceIP;//用户正在连接的设备的IP
@property (nonatomic,  copy) NSString         *userID;
@property (nonatomic,assign) CGFloat          resolution;
@property (nonatomic,assign) CGFloat          quality;
@property (nonatomic,assign) CGFloat          fps;

@property (nonatomic,strong) LFLiveSession    *session;
//@property (nonatomic,strong) UIView           *livePreView;

@end

@implementation FSLiveViewViewController

#pragma mark - Setters/Getters

- (WisView *)videoView {
    if (!_videoView) {
        _videoView = [[WisView alloc] initWithFrame:CGRectMake(0, 0, FSAbsoluteLong, FSAbsoluteShort)];
        [_videoView delegate:self];
        [_videoView addGestureRecognizer:self.videoViewTapGesture];
        [self.view insertSubview:_videoView belowSubview:self.contentView];
        
        [_videoView set_log_level:2];
    }
    return _videoView;
}

- (UITapGestureRecognizer *)videoViewTapGesture {
    if (!_videoViewTapGesture) {
        _videoViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentView)];
    }
    return _videoViewTapGesture;
}

- (UITapGestureRecognizer *)contentViewTapGesture {
    if (!_contentViewTapGesture) {
        _contentViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(tapContentView)];
    }
    return _contentViewTapGesture;
}


//- (void)startLive {
//    LFLiveStreamInfo *streamInfo = [[LFLiveStreamInfo alloc] init];
//    streamInfo.url = @"your server rtmp url";
//    [self.session startLive:streamInfo];
//}
//
//- (void)stopLive {
//    [self.session stopLive];
//}


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self userInterfaceSettings];
    [self setDefaultValue];
    [self addApplicationActiveNotifications];
    
    
//    LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
//    streamInfo.url = @"rtmp://live-api-a.facebook.com:80/rtmp/2006270569650246_0?ds=1&a=ATjuPr7v49Oq6-Xs";
//    [self.session startLive:streamInfo];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].idleTimerDisabled = YES; //不让手机休眠
//    self.isExit = NO;
    [self updateUI];
    [self connectFreestreamDevice];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self stopSearchDevice];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;//屏幕取消常亮
}


#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

#pragma mark – Private methods

- (void)userInterfaceSettings {
    [self hidenCenterViews];
    [self.contentView addGestureRecognizer:self.contentViewTapGesture];
}

- (void)setDefaultValue {
    self.increaseSearchDuration = 5;

}

- (void)connectFreestreamDevice {
    [self showSearchAndConnectTips];
    if ([CoreStore sharedStore].cacheUseDeviceIP.length > 0) {
        self.userConnectingDeviceIP = [CoreStore sharedStore].cacheUseDeviceIP;
        [self startReceiveVideoViewWithDeviceIP:self.userConnectingDeviceIP];
    }
        [self beginSearchDevice];
}

- (void)updateUI {
    [self updateWifiName];
    [self showTopBarAndBottomBar];
}


- (void)updateWifiName {
    NSString *wifiName = [self getWifiName];
    if (wifiName.length < 1) {
        wifiName = NSLocalizedString(@"No wireless LAN connection", nil);
    }
    self.wifiNameLabel.text = wifiName;
}

- (void)hidenCenterViews {
    self.tipLabel.hidden = YES;
    self.logoCenterImageView.hidden = YES;
    self.liveStopButton.hidden = YES;
}

- (void)showSearchAndConnectTips {
    
    self.tipLabel.text = NSLocalizedString(@"Search And Connect", nil);
    self.tipLabel.hidden = NO;
    self.logoCenterImageView.hidden = NO;
}

- (void)showNoDeviceResultTips {
    
    self.tipLabel.text = NSLocalizedString(@"No Device Found", nil);
    self.tipLabel.hidden = NO;
    self.logoCenterImageView.hidden = NO;
}


- (void)hidenSearchAndConnectTips {
    self.tipLabel.hidden = YES;
    self.logoCenterImageView.hidden = YES;
}

- (void)beginSearchDevice {
    if (self.isExit) {
        return;
    }
//    [self showSearchAndConnectTips];
    [self disableButtons];

    WEAK(self);
    
    [[FSSearchDeviceManager shareInstance] beginSearchDeviceDuration:_increaseSearchDuration completionHandle:^(Scanner *resultInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakself scanDeviceOver:resultInfo];
            [weakself enableButtons];
        });
    }];
    
    //小于最大搜索时间,每次重新搜索的时间间隔+1秒
    self.increaseSearchDuration = (self.increaseSearchDuration < searchDurationMax) ? (self.increaseSearchDuration + 1) : self.increaseSearchDuration;
}

- (void)scanDeviceOver:(Scanner *)result {

    if (self.isExit) {
        return;
    }
    
    if (result.Device_IP_Arr.count < 1) {
        [self showNoDeviceResultTips];
        [self showActionSheet];
        return;
    }

//    使用扫描到的第一个设备
    self.userConnectingDeviceIP = [result.Device_IP_Arr objectAtIndex:0];
//    self.userID = [result.Device_ID_Arr objectAtIndex:0];
    
    if (![self.userConnectingDeviceIP isEqualToString:[CoreStore sharedStore].cacheUseDeviceIP]) {
        //    缓存这个新的IP
        [CoreStore sharedStore].cacheUseDeviceIP = [result.Device_IP_Arr objectAtIndex:0];
        //    接收videoView使用新的ip
        [self startReceiveVideoViewWithDeviceIP:self.userConnectingDeviceIP];
    } else {
        if (self.liveViewIsPlaying && !self.tipLabel.isHidden) {
            [self hidenSearchAndConnectTips];
        }
    }
}

//使用DeviceIP配置Url,接收Freestream设备传回的画面和音频
- (void)startReceiveVideoViewWithDeviceIP:(NSString *)connectingDeviceIP {
    if (self.isExit) {
        return;
    }
    
    NSString *liveViewUrlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", connectingDeviceIP,fsLiveViewVideoFormat];
    
    [self.videoView play:liveViewUrlString useTcp:YES];
    [self.videoView sound:YES];
    [self.videoView startGetYUVData:YES];
    [self.videoView startGetAudioData:YES];
    [self.videoView startGetH264Data:YES];
    [self.videoView show_view:YES];
    
    [self getDeviceConfigure];
}


//当搜索没有结果的时候显示提示菜单
- (void)showActionSheet {
    
    WEAK(self);
    [self showAlertSheetWithTitle:@"" Message:NSLocalizedString(@"NoResultAlert", nil) action1text:NSLocalizedString(@"Continue Search", nil) action2text:NSLocalizedString(@"Use iPhone Camera", nil) action3text:NSLocalizedString(@"Cancel", nil) action1Handler:^(UIAlertAction * _Nullable action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself beginSearchDevice];
        });
    } action2Handler:^(UIAlertAction * _Nullable action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself configCameraSession];
        });
    } action3Handler:^(UIAlertAction * _Nullable action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself backButtonDidClicked:nil];
        });
    }];
}

- (void)getDeviceConfigure {
    
    NSString *resolutionUrl = [FSDeviceConfigureAPIRESTfulService getDeviceConfiguerResolutionWithConfigureIp:self.userConnectingDeviceIP configurePort:configPort];
    
    NSString *qualityUrl = [FSDeviceConfigureAPIRESTfulService getDeviceConfiguerQualityWithConfigureIp:self.userConnectingDeviceIP configurePort:configPort];
    
    NSString *fpsUrl = [FSDeviceConfigureAPIRESTfulService getDeviceConfiguerFPSWithConfigureIp:self.userConnectingDeviceIP configurePort:configPort];
    
    __block CGFloat resolution;
    __block CGFloat quality;
    __block CGFloat fps;
    __block BOOL    getFaild;
    
    dispatch_group_t getConfigureGroup = dispatch_group_create();
    dispatch_group_enter(getConfigureGroup);
    [FSNetWorkManager getRequestUrl:resolutionUrl param:nil headerDic:nil completionHandler:^(NSDictionary *dic) {
        if([dic[@"info"] isEqualToString:@"suc"]){
            resolution = [dic[@"value"] floatValue];
        } else {
            getFaild = YES;
        }
        dispatch_group_leave(getConfigureGroup);
    }];
    
    dispatch_group_enter(getConfigureGroup);
    [FSNetWorkManager getRequestUrl:qualityUrl param:nil headerDic:nil completionHandler:^(NSDictionary *dic) {
        if([dic[@"info"] isEqualToString:@"suc"]){
            quality = [dic[@"value"] floatValue];
        } else {
            getFaild = YES;
        }
        dispatch_group_leave(getConfigureGroup);
    }];
    
    dispatch_group_enter(getConfigureGroup);
    [FSNetWorkManager getRequestUrl:fpsUrl param:nil headerDic:nil completionHandler:^(NSDictionary *dic) {
        if([dic[@"info"] isEqualToString:@"suc"]){
            fps = [dic[@"value"] floatValue];
        } else {
            getFaild = YES;
        }
        dispatch_group_leave(getConfigureGroup);
    }];
    
    WEAK(self);
    dispatch_group_notify(getConfigureGroup, dispatch_get_main_queue(), ^{
        if (getFaild) {
//            失败
        } else {
//            成功
            weakself.resolution = resolution;
            weakself.quality    = quality;
            weakself.fps        = fps;
            NSLog(@"----------------resolution:%lf",weakself.resolution);
            NSLog(@"----------------quality:%lf",weakself.quality*3000/52);
            NSLog(@"----------------fps:%lf",weakself.fps);
            [weakself getSessionWithRakisrak:YES];
        }
    });
}

//RAK设备的直播参数
- (void)getSessionWithRakisrak:(BOOL)rak {
    
    /**
     *  构造音频配置器
     */
    LFLiveAudioConfiguration *audioConfiguration = [[LFLiveAudioConfiguration alloc] init];
    audioConfiguration.numberOfChannels = 2;
    audioConfiguration.audioBitrate = LFLiveAudioBitRate_Default;
    audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_48000Hz;//非默认？？
  
    /**
     * 构造视频配置
     * 窗体大小，比特率，最大比特率，最小比特率，帧率，最大间隔帧数，分辨率（注意视频大小一定要小于分辨率）
     */
    LFLiveVideoConfiguration *videoConfiguration = [[LFLiveVideoConfiguration alloc] init];

    CGFloat videosizeWidth;
    CGFloat videosizeHeight;
    NSInteger bitRatevalue;  //设备的比特率
    NSInteger maxbitRate;
    NSInteger minbitrate;
    NSInteger videoFrameRate;//设备的fps
    //设备的分辨率
    if ((int)self.resolution  == 3)
    {
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        videosizeWidth  = 720;
        videosizeHeight = 1280;
        bitRatevalue    = 800*1024;
        minbitrate      = 200*1024;
        maxbitRate      = 1000*1024;
        videoFrameRate  = 30;
    } else if ((int)self.resolution == 2) {
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        videosizeWidth  = 720;
        videosizeHeight = 1280;
        bitRatevalue    = 800*1024;
        minbitrate      = 200*1024;
        maxbitRate      = 1000*1024;
        videoFrameRate  = 30;
    } else {
        videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
        videosizeWidth  = 540;
        videosizeHeight = 960;
        bitRatevalue    = 500*1024;
        minbitrate      = 200*1024;
        maxbitRate      = 700*1024;
        videoFrameRate  = 20;
    }
    
    
    videoConfiguration.videoBitRate    = bitRatevalue;    //比特率
    videoConfiguration.videoMaxBitRate = maxbitRate;      //最大比特率
    videoConfiguration.videoMinBitRate = minbitrate;      //最小比特率
    videoConfiguration.videoFrameRate  = videoFrameRate;  //帧率
    
    videoConfiguration.videoMaxKeyframeInterval = videoFrameRate * 2; //最大关键帧间隔数
    videoConfiguration.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
    
    //分辨率：0：360*540 1：540*960 2：720*1280 3:1920*1080
    //    videoConfiguration .sessionPreset = LFCaptureSessionPreset720x1280;
    
    if (videoConfiguration.landscape) {
        videoConfiguration.videoSize = CGSizeMake(videosizeHeight, videosizeWidth);  //视频大小
    } else {
        videoConfiguration.videoSize = CGSizeMake(videosizeWidth, videosizeHeight);  //视频大小
    }
    
    //利用两设备配置 来构造一个直播会话
//    _session.isRAK=rak;
//    _session.isIphoneAudio = _isIphoneAudio;
    
    [self requestAccessForAudio];
    
    self.session.running = YES;
    self.liveViewSource = FSLiveViewSourceFreestreamDevice;
    self.session.preView = self.contentView;
    self.session.delegate = self;

}

- (void)configCameraSession {
    
    [self requestAccessForVideo];
    [self requestAccessForAudio];
    /**
     *  构造音频配置器
     */
    LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_High];
    
    LFLiveVideoConfiguration * videoConfiguration = [LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_High1 outputImageOrientation:UIInterfaceOrientationLandscapeRight];
    
    //利用两设备配置 来构造一个直播会话
    _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
    _session.captureDevicePosition = AVCaptureDevicePositionBack;
    _session.delegate  = self;
//    _session.isRAK = NO;
    _session.running = YES;
    _session.preView = self.contentView;
    self.liveViewSource = FSLiveViewSourceFreestreamDevice;
//    self.contentViewTapGesture.enabled = YES;
    
        //                return _session;
//        self.livingPreView.hidden = NO;
//        [self hidenSearchingMessageTips];
//        [self noHiddenStatus];
//        _play_success = YES;
//        _liveCameraSource = IphoneBackCamera;
//        [self enableButtons];
}


- (void)disableButtons {
    [self buttonsEnable:NO];
}

- (void)enableButtons {
    [self buttonsEnable:YES];
}

- (void)buttonsEnable:(BOOL)enable {
//    self.backButton.userInteractionEnabled      = enable;
    
    self.cameraButton.userInteractionEnabled    = enable;
    self.recordButton.userInteractionEnabled    = enable;
    self.streamButton.userInteractionEnabled    = enable;
    self.browserButton.userInteractionEnabled   = enable;
    self.configureButton.userInteractionEnabled = enable;
    self.platformButton.userInteractionEnabled  = enable;
}


- (void)addApplicationActiveNotifications {
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark -- 请求权限
- (void)requestAccessForVideo {
    WEAK(self);
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.session setRunning:YES];
                        [weakself hidenSearchAndConnectTips];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.session setRunning:YES];
                [weakself hidenSearchAndConnectTips];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            
            break;
        default:
            break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}


- (void)requestAccessForPhoto
{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined:
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            }];
            break;
            //无法授权
        case PHAuthorizationStatusRestricted:
            
            break;
            //明确拒绝
        case PHAuthorizationStatusDenied:
            
            break;
            
            //已授权
        case PHAuthorizationStatusAuthorized:
            
            break;
            
        default:
            break;
    }
}

- (void)videoViewStop {
    [self.videoView sound:NO];
    [self.videoView stop];
}

- (void)setStopStreamStatus {
    
}

- (void)applicationBecomeActive {
    
    NSLog(@"----------进入前台");
    
    
    if(!self.isExit) {
        [self updateUI];
        [self performSelectorOnMainThread:@selector(viewWillAppear:) withObject:@1 waitUntilDone:YES];
    }
    
    
//
//    BOOL isSameWIfi = ([CoreStore sharedStore].currentUseDeviceID == [self getWifiSSID]);
//    BOOL isNotnil  = ([self getWifiSSID].length > 0);
//    NSLog(@"----------------%u,%u,%u",isSameWIfi,isNotnil,_searchDeviceHasResult);
//    if (([[CoreStore sharedStore].currentUseDeviceID isEqualToString:[self getWifiSSID]])&&([self getWifiSSID].length > 0)&&_searchDeviceHasResult) {
//        if(!_isExit&&!_isBroswer){
//            [self getDeviceConfig];
//            NSString *urlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", _userip,video_type];
//            NSLog(@"----------------log%@",urlString);
//
//            [self.videoView play:urlString useTcp:NO];
//            [self.videoView sound:YES];
//            [self.videoView startGetYUVData:YES];
//            [self.videoView startGetAudioData:YES];
//            [self.videoView startGetH264Data:YES];
//            [self.videoView show_view:YES];
//            self.videoisplaying = YES;
//        }
//    } else if (_liveCameraSource == IphoneBackCamera) {
//
//    } else {
//
//        [_updateUITimer setFireDate:[NSDate distantFuture]];
//        _tipLabel.text = @"PLEASE CHECK WIFI CONECT TO EXTERNAL DEVICE";
//        [self showSearchingMessagesTips];
//    }
}

- (void)applicationEnterBackground {
//    [self closeLivingSession];
//    [self stopVideo];
    
    NSLog(@"----------进入后台");
//    [CoreStore sharedStore].currentUseDeviceID = [self getWifiSSID];
//    NSLog(@"----------------+++%@",[CoreStore sharedStore].currentUseDeviceID);
}




//监测流量判断是否接入相机并作相应的提示
- (int)checkNetworkflow {
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
//    NSString *networkFlow      = [self bytesToAvaiUnit:flow];
    lastFlow = allFlow;
    //    NSLog(@"networkFlow==%@",networkFlow);
    return flow;
}


- (NSString *)bytesToAvaiUnit:(int)bytes {
    if(bytes < 1024)        // B
    {
        return [NSString stringWithFormat:@"%dB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024)    // KB
    {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)    // MB
    {
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

#pragma mark – Target action methods

#pragma mark - IBActions

- (void)showTopBarAndBottomBar {
    if (self.topBarAndBottomBarIsHiden) {
        [self performSelectorOnMainThread:@selector(tapContentView) withObject:nil  waitUntilDone:YES];
    }
}

- (void)hidenTopBarAndBottomBar {
    if (!self.topBarAndBottomBarIsHiden) {
        [self performSelectorOnMainThread:@selector(tapContentView) withObject:nil waitUntilDone:YES];
    }
    
}

- (void)tapContentView{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidenTopBarAndBottomBar) object:nil];
    
    CGFloat topBgViewHeight = CGRectGetHeight(self.topBgView.frame);
    CGFloat bottomBgViewHeight = CGRectGetHeight(self.bottomBgView.frame);
    CGFloat topBgViewAddHeight;
    CGFloat bottomBgViewAddHeight;
    
    if(self.topBarAndBottomBarIsHiden == NO) {
        //        显示的时候
        topBgViewAddHeight    = -topBgViewHeight;//topBar.y减去一个高度就隐藏了
        bottomBgViewAddHeight = bottomBgViewHeight;//bottombar.y 加上一个高度就隐藏了
    } else {
        //        隐藏的时候
        topBgViewAddHeight    = topBgViewHeight;//topBar.y加一个高度就显示出来了
        bottomBgViewAddHeight = -bottomBgViewHeight;//bottombar.y 减去一个高度就显示出来了
    }
    
    //    NSLog(@"topBgViewAddHeight  = %lf,self.topBarAndBottomBarIsHiden = %u,topBgViewOriginY = %lf",topBgViewAddHeight,self.topBarAndBottomBarIsHiden ,self.topBgView.originY);
    
    WEAK(self);
    [UIView animateWithDuration:0.2 animations:^{
        weakself.topBgView.originY = weakself.topBgView.originY + topBgViewAddHeight;
        weakself.bottomBgView.originY = weakself.bottomBgView.originY + bottomBgViewAddHeight;
        weakself.liveStopButton.hidden = !weakself.isLiving;
        weakself.topBarAndBottomBarIsHiden = !weakself.topBarAndBottomBarIsHiden;
    } completion:^(BOOL finished) {
        if (weakself.topBarAndBottomBarIsHiden == NO) {
            //        如果没有隐藏 那么3s后隐藏
            [weakself performSelector:@selector(hidenTopBarAndBottomBar) withObject:nil afterDelay:3.f];
        }
    }];
}

- (IBAction)backButtonDidClicked:(UIButton *)sender {
    if (self.liveViewIsPlaying) {
        [self videoViewStop];
    }
    
//    [[FSSearchDeviceManager shareInstance] stopSearchDevice];
    self.isExit = YES;

    [self.videoView removeFromSuperview];
    [self.topBgView removeFromSuperview];
    [self.bottomBgView removeFromSuperview];
    [self.recordLabel removeFromSuperview];
    [self.logoCenterImageView removeFromSuperview];
    [self.tipLabel removeFromSuperview];
    [self.liveStopButton removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cameraButtonDidClicked:(UIButton *)sender {
    
}

- (IBAction)recordButtonDidClicked:(UIButton *)sender {
}

- (IBAction)streamButtonDidClicked:(UIButton *)sender {
}

- (IBAction)browserButtonDidClicked:(UIButton *)sender {
}

- (IBAction)configureButtonDidClicked:(UIButton *)sender {
}

- (IBAction)platformButtonDidClicked:(UIButton *)sender {
}

- (IBAction)pushVC:(UIButton *)sender {
    [self presentViewController:[[FSStreamViewController alloc
                                  ] init] animated:YES completion:nil];
}

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods
//重写父类的
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(BOOL)prefersStatusBarHidden{
    
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"--____------__________-------___________------dealloc");
}
#pragma mark – Delegate

#pragma mark – LFLiveSessionDelegate
- (void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo {
    
}

- (void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
//    LFLiveSocketError_PreView = 201,              ///< 预览失败
//    LFLiveSocketError_GetStreamInfo = 202,        ///< 获取流媒体信息失败
//    LFLiveSocketError_ConnectSocket = 203,        ///< 连接socket失败
//    LFLiveSocketError_Verification = 204,         ///< 验证服务器失败
//    LFLiveSocketError_ReConnectTimeOut = 205      ///< 重新连接服务器超时
    NSLog(@"----------------%ld",errorCode);
}

- (void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    switch (state) {
        case LFLiveReady:
            NSLog(@"----------------ready");
            break;
        case LFLivePending:
            NSLog(@"----------------pending...");
            break;
        case LFLiveStart:
            NSLog(@"----------------livestart");
            break;
        case LFLiveRefresh:
            NSLog(@"----------------refresh!!!");
            break;
        case LFLiveStop:
            NSLog(@"----------------stop!");
            break;
            
        default:
            break;
    }
}

#pragma mark - WisViewDelegate
- (void)state_changed:(int)state {//回调显示正常播放的时状态
    if (self.isExit) {//退出了本页面，不需响应任何
        return;
    }
    
    NSLog(@"WisviewDelegate state_changed state = %d", state);
    switch (state) {
        case 0: //STATE_IDLE
        {
//            _play_success = NO;
            
                self.liveViewIsPlaying = NO;
            
            break;
        }
        case 1: //STATE_PREPARING
        {
//            _play_success = NO;
            
                self.liveViewIsPlaying = NO;
            
            break;
        }
        case 2: //STATE_PLAYING
        {
//            _play_success = YES;
            
//            if (_isLiveView) {
//                [self enableControl];
                dispatch_async(dispatch_get_main_queue(),^ {
//                    [self noHiddenStatus];
                    self.liveViewIsPlaying = YES;
                    [self hidenSearchAndConnectTips];
                });
//            }
            break;
        }
        case 3: //STATE_STOPPED
        {
            
                self.liveViewIsPlaying = NO;
            
            break;
        }
        case 4: //STATE_OPEN_URL_FAILED
        {
            NSLog(@"STATE_OPEN_URL_FAILED");
            
                dispatch_async(dispatch_get_main_queue(),^ {
//                [self replayVideoView];
                    self.liveViewIsPlaying = NO;
                    [self showNoDeviceResultTips];
                    [self.videoView stop];
                });
            break;
        }
        default:
            break;
    }
}


- (void)video_info:(NSString *)codecName codecLongName:(NSString *)codecLongName {//视频格式
    
}

- (void)audio_info:(NSString *)codecName codecLongName:(NSString *)codecLongName sampleRate:(int)sampleRate channels:(int)channels {//音频格式
    
}
- (void)take_photo:(UIImage *)image {//回调获取拍照后的image

}

- (void)take_imageRef:(CGImageRef)imageRef{//回调获取rgb555 le格式的imageRef
    
}

- (void)GetYUVData:(int)width :(int)height
                  :(Byte*)yData :(Byte*)uData :(Byte*)vData
                  :(int)ySize :(int)uSize :(int)vSize {//回调获取解码后的YUV数据
    
}

- (void)GetAudioData:(Byte*)data :(int)size {//回调获取解码后的YUV数据
    NSLog(@"------------size = ----%d",size);
}

- (void)GetH264Data:(int)width :(int)height :(int)size :(Byte*)data {//回调获取H264数据
    
}

@end
