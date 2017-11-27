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

//获取wifi名
#import <SystemConfiguration/CaptiveNetwork.h>

#import <Photos/Photos.h>

//URLS
#import "FSDeviceConfigureAPIRESTfulService.h"

#import "WisView.h"


#define FSLiveViewVideoType @"h264"
static NSString *const fsLiveViewVideoFormat = @"h264";//视频格式
static NSInteger const configPort = 80;//端口号

@interface FSLiveViewViewController ()<LFLiveSessionDelegate>
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

@property (nonatomic, strong)        WisView  *videoView;

@property (nonatomic,assign) BOOL             hidenTopBarAndBottomBar;//隐藏上面的条和下面的条
@property (nonatomic,assign) BOOL             isLiving;//是否正在直播中

@property (nonatomic,  copy) NSString         *userIP;
@property (nonatomic,  copy) NSString         *userID;
@property (nonatomic,assign) CGFloat          resolution;
@property (nonatomic,assign) CGFloat          quality;
@property (nonatomic,assign) CGFloat          fps;

@property (nonatomic,strong) LFLiveSession    *session;
//@property (nonatomic,strong) UIView           *livePreView;

@end

@implementation FSLiveViewViewController

#pragma mark - Setters/Getters
//- (LFLiveSession*)session {
//    if (!_session) {
//        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
//        _session.preView = self.contentView;
//        _session.delegate = self;
//    }
//    return _session;
//}

//- (UIView *)livePreView {
//    if (!_livePreView) {
//        _livePreView = [[UIView alloc] init];
//        _livePreView.frame = [UIScreen mainScreen].bounds;
//        [self.view insertSubview:_livePreView aboveSubview:self.contentView];
//    }
//    return _livePreView;
//}

- (void)startLive {
    LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
    streamInfo.url = @"your server rtmp url";
    [self.session startLive:streamInfo];
}

- (void)stopLive {
    [self.session stopLive];
}


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self beginSearchDevice];
    
    [self requestAccessForAudio];
    [self requestAccessForVideo];
    [self configCameraSession];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    
    [self updateUI];
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
}


#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

#pragma mark – Private methods

- (void)updateUI {
    [self updateWifiName];
    [self showTopAndBottomBgView];
    [self hidenCenterViews];
    
}

- (void)updateWifiName {
    NSString *wifiName = [self getWifiName];
    if (wifiName.length < 1) {
        wifiName = NSLocalizedString(@"No wireless LAN connection", nil);
    }
    self.wifiNameLabel.text = wifiName;
}

- (NSString *)getWifiName {
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
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
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


- (void)beginSearchDevice {
    [self disableButtons];
    WEAK(self);
    [[FSSearchDeviceManager shareInstance] beginSearchDeviceDuration:5.f completionHandle:^(Scanner *resultInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself scanDeviceOver:resultInfo];
            [weakself enableButtons];
        });
    }];
}

- (void)scanDeviceOver:(Scanner *)result {
    
    if (result.Device_ID_Arr.count < 1) {
        [self showActionSheet];
        return;
    }
    //使用扫描到的第一个设备
    self.userIP = [result.Device_IP_Arr objectAtIndex:0];
    self.userID = [result.Device_ID_Arr objectAtIndex:0];
    
    NSString *liveViewUrlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", self.userIP,fsLiveViewVideoFormat];
    
    [self getDeviceConfigure];
    
}

- (void)showActionSheet {
    
}

- (void)getDeviceConfigure {
    
    NSString *resolutionUrl = [FSDeviceConfigureAPIRESTfulService getDeviceConfiguerResolutionWithConfigureIp:self.userIP configurePort:configPort];
    
    NSString *qualityUrl = [FSDeviceConfigureAPIRESTfulService getDeviceConfiguerQualityWithConfigureIp:self.userIP configurePort:configPort];
    
    NSString *fpsUrl = [FSDeviceConfigureAPIRESTfulService getDeviceConfiguerFPSWithConfigureIp:self.userIP configurePort:configPort];
    
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
//            失败了
        } else {
//            成功
            weakself.resolution = resolution;
            weakself.quality    = quality;
            weakself.fps        = fps;
            NSLog(@"----------------resolution:%lf",weakself.resolution);
            NSLog(@"----------------quality:%lf",weakself.quality*3000/52);
            NSLog(@"----------------fps:%lf",weakself.fps);
//            [self getSessionWithRakisrak:YES];
            [self configCameraSession];
        }

        
    });
}

//RAK设备的直播参数
- (LFLiveSession *)getSessionWithRakisrak:(BOOL)rak {
    
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
    if ((int)_resolution  == 3)
    {
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        videosizeWidth  = 720;
        videosizeHeight = 1280;
        bitRatevalue    = 800*1024;
        minbitrate      = 200*1024;
        maxbitRate      = 1000*1024;
        videoFrameRate  = 30;
    } else if ((int)_resolution == 2) {
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
    self.session.running = YES;
    
    self.session.preView = self.contentView;
    self.session.delegate = self;
    
    return self.session;
}

- (void)configCameraSession {
    dispatch_async(dispatch_get_main_queue(), ^{
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
        
        //                return _session;
//        self.livingPreView.hidden = NO;
//        [self hidenSearchingMessageTips];
//        [self noHiddenStatus];
//        _play_success = YES;
//        _liveCameraSource = IphoneBackCamera;
//        [self enableButtons];
    });
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
        weakself.liveStopButton.hidden = !self.isLiving;
    } completion:^(BOOL finished) {}];
    
    self.hidenTopBarAndBottomBar = !self.hidenTopBarAndBottomBar;
}

- (IBAction)backButtonDidClicked:(UIButton *)sender {
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
    
}

- (void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    
}

@end
