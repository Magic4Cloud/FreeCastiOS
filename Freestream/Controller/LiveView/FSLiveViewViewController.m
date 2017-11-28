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


#define FSLiveViewVideoType @"h264"
static NSString *const fsLiveViewVideoFormat = @"h264";//视频格式
static NSInteger const configPort = 80;//端口号
static NSInteger const searchDurationMax = 8;
NSInteger increaseSearchDuration = 5;

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

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *contentViewTapGesture;

@property (nonatomic, strong)        WisView  *videoView;

@property (nonatomic,assign) BOOL             hidenTopBarAndBottomBar;//隐藏上面的条和下面的条
@property (nonatomic,assign) BOOL             isLiving;//是否正在直播中

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
        [self.view insertSubview:_videoView belowSubview:self.contentView];
        self.contentViewTapGesture.enabled = YES;
    }
    return _videoView;
}

- (void)startLive {
    LFLiveStreamInfo *streamInfo = [[LFLiveStreamInfo alloc] init];
    streamInfo.url = @"your server rtmp url";
    [self.session startLive:streamInfo];
}

- (void)stopLive {
    [self.session stopLive];
}


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self userInterfaceSettings];
    
//    NSLog(@"-------wifiSsid---------%@",[self getWifiSSID]);
    
//    在初始化界面的时候都禁用tap手势,避免在创建videoview的时候卡顿,这时候继续点击,会导致点击的布局不对。
    self.contentViewTapGesture.enabled = NO;
    
//    LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
//    streamInfo.url = @"rtmp://live-api-a.facebook.com:80/rtmp/2006270569650246_0?ds=1&a=ATjuPr7v49Oq6-Xs";
//    [self.session startLive:streamInfo];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].idleTimerDisabled = YES; //不让手机休眠
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
}

- (void)connectFreestreamDevice {
    
    if ([CoreStore sharedStore].cacheUseDeviceIP.length > 0) {
        self.userConnectingDeviceIP = [CoreStore sharedStore].cacheUseDeviceIP;
        [self startReceiveVideoViewWithDeviceIP:self.userConnectingDeviceIP];
    } else {
      [self beginSearchDevice];
    }
}

- (void)updateUI {
    [self updateWifiName];
    [self showTopAndBottomBgView];
}


- (void)updateWifiName {
    NSString *wifiName = [self getWifiName];
    if (wifiName.length < 1) {
        wifiName = NSLocalizedString(@"No wireless LAN connection", nil);
    }
    self.wifiNameLabel.text = wifiName;
}

- (void)showTopAndBottomBgView {
    self.hidenTopBarAndBottomBar = YES;
    [self performSelector:@selector(tapContentView:) withObject:nil];
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

- (void)beginSearchDevice {
    
    [self disableButtons];
    [self showSearchAndConnectTips];

    WEAK(self);
    [[FSSearchDeviceManager shareInstance] beginSearchDeviceDuration:increaseSearchDuration completionHandle:^(Scanner *resultInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself scanDeviceOver:resultInfo];
            [weakself enableButtons];
        });
    }];
    
    //小于最大搜索时间,每次重新搜索的时间间隔+1秒
    increaseSearchDuration = (increaseSearchDuration < searchDurationMax) ? (increaseSearchDuration + 1) : increaseSearchDuration;
}

- (void)scanDeviceOver:(Scanner *)result {
    
    if (result.Device_IP_Arr.count < 1) {
        [self showActionSheet];
        return;
    }

//    使用扫描到的第一个设备
    self.userConnectingDeviceIP = [result.Device_IP_Arr objectAtIndex:0];
//    self.userID = [result.Device_ID_Arr objectAtIndex:0];
    
//    缓存这个IP
    [CoreStore sharedStore].cacheUseDeviceIP = [result.Device_IP_Arr objectAtIndex:0];

    [self startReceiveVideoViewWithDeviceIP:self.userConnectingDeviceIP];
}

//使用DeviceIP配置Url,接收Freestream设备传回的画面和音频
- (void)startReceiveVideoViewWithDeviceIP:(NSString *)connectingDeviceIP {
    NSString *liveViewUrlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", connectingDeviceIP,fsLiveViewVideoFormat];
    
    [self.videoView play:liveViewUrlString useTcp:YES];
    [self.videoView sound:YES];
    [self.videoView startGetYUVData:YES];
    [self.videoView startGetAudioData:YES];
    [self.videoView startGetH264Data:YES];
    [self.videoView show_view:YES];
    
    [self hidenCenterViews];
    
    
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
    
    self.session.preView = self.contentView;
    self.session.delegate = self;

}

- (void)configCameraSession {
    
    [self requestAccessForVideo];
        /**
         *  构造音频配置器**/
        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_High];
        
        LFLiveVideoConfiguration * videoConfiguration = [LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_High1 outputImageOrientation:UIInterfaceOrientationLandscapeRight];
        
        //利用两设备配置 来构造一个直播会话
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        _session.captureDevicePosition = AVCaptureDevicePositionBack;
        _session.delegate  = self;
//        _session.isRAK = NO;
        _session.running = YES;
        _session.preView = self.contentView;
        
        self.contentViewTapGesture.enabled = YES;
        
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
    self.backButton.userInteractionEnabled      = enable;
    
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
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.session setRunning:YES];
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



#pragma mark – Target action methods

#pragma mark - IBActions

- (IBAction)tapContentView:(UITapGestureRecognizer *)sender {
    
    CGFloat topBgViewHeight = CGRectGetHeight(self.topBgView.frame);
    CGFloat bottomBgViewHeight = CGRectGetHeight(self.bottomBgView.frame);

    if(self.hidenTopBarAndBottomBar == YES) {
        topBgViewHeight    = -topBgViewHeight;
        bottomBgViewHeight = -bottomBgViewHeight;
    }
    WEAK(self);
    [UIView animateWithDuration:0.2 animations:^{
        weakself.topBgView.originY = weakself.topBgView.originY - topBgViewHeight;
        weakself.bottomBgView.originY = weakself.bottomBgView.originY + bottomBgViewHeight;
        weakself.liveStopButton.hidden = !weakself.isLiving;
    } completion:^(BOOL finished) {}];
    weakself.hidenTopBarAndBottomBar = !weakself.hidenTopBarAndBottomBar;
}

- (IBAction)backButtonDidClicked:(UIButton *)sender {
    [self videoViewStop];
    
    [self.videoView removeFromSuperview];
    [self.topBgView removeFromSuperview];
    [self.bottomBgView removeFromSuperview];
    [self.recordLabel removeFromSuperview];
    [self.logoCenterImageView removeFromSuperview];
    [self.tipLabel removeFromSuperview];
    [self.liveStopButton removeFromSuperview];
    [sender removeFromSuperview];
    
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
    
}

- (void)GetH264Data:(int)width :(int)height :(int)size :(Byte*)data {//回调获取H264数据
    
}

@end
