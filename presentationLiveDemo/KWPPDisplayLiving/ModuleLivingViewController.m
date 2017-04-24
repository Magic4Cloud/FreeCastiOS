//
//  ModuleLivingViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 16/9/23.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "ModuleLivingViewController.h"
#import "MBProgressHUD.h"
#import "LX520View.h"
#include "LFLiveStreamInfo.h"
#import "LFLiveKit.h"
#import "LFLiveSessionWithPicSource.h"
#import "PicToBufferToPic.h"

LX520View *VideoView;
NSString *_deviceIP=nil;
NSString *_deviceID=nil;
int _devicePort=554;
bool _isPlaying=NO;
bool _isLiving=NO;
bool _useTcp = NO;
bool _audioIsEnable = NO;
NSMutableArray *_pipeValue;
NSMutableArray *_reslutionValue;
NSString *_videoCodec;
NSString *_audioCodec;
NSString *_transport;

@interface ModuleLivingViewController ()

@property(strong, nonatomic) UIButton *captureDataLiveButton;
@property(strong, nonatomic) UILabel *networkStatusLable;
@property(strong, nonatomic) LFLiveSessionWithPicSource *session;
@end

@implementation ModuleLivingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self view_init];
    //状态标签
    self.networkStatusLable  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [self.networkStatusLable setTextColor:[UIColor blackColor]];
    [self.view addSubview: self.networkStatusLable];
    
    //开始直播
    self.captureDataLiveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-100, self.view.bounds.size.width-40, 30)];
    [self.captureDataLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
    [self.captureDataLiveButton setTag:0];
    [self.captureDataLiveButton setBackgroundColor:[UIColor colorWithRed:147/255.0 green:224/255.0 blue:255/255.0 alpha:1.0]];
    [self.captureDataLiveButton addTarget:self action:@selector(livingOperating:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureDataLiveButton];
    
    //停止直播
    UIButton *stopLivingButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-50, self.view.bounds.size.width-40, 30)];
    stopLivingButton.tag = -1;
    [stopLivingButton setBackgroundColor:[UIColor colorWithRed:147/255.0 green:224/255.0 blue:255/255.0 alpha:1.0]];
    [stopLivingButton setTitle:@"结束直播" forState:UIControlStateNormal];
    [stopLivingButton addTarget:self action:@selector(livingOperating:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopLivingButton];
}

//重写构造器：构造直播会话，包括配置录制的音视频格式数据
-(LFLiveSessionWithPicSource *)session{
    if(!_session){
        /**
         *  构造音频配置器
         *  双声道， 128Kbps的比特率，44100HZ的采样率
         */
        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
        audioConfiguration .numberOfChannels =2;
        audioConfiguration .audioBitrate = LFLiveAudioBitRate_128Kbps;
        audioConfiguration .audioSampleRate = LFLiveAudioSampleRate_44100Hz;
        
        /**
         * 构造视频配置
         * 窗体大小，比特率，最大比特率，最小比特率，帧率，最大间隔帧数，分辨率（注意视频大小一定要小于分辨率）
         */
        LFLiveVideoConfiguration  *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration .videoSize = CGSizeMake(480, 640);  //视频大小
        videoConfiguration .videoBitRate = 800*1024;        //比特率
        videoConfiguration .videoMaxBitRate = 1000*1024;    //最大比特率
        videoConfiguration .videoMinBitRate = 500*1024;     //最小比特率
        videoConfiguration .videoFrameRate = 24;            //帧率
        videoConfiguration .videoMaxKeyframeInterval = 30; //最大关键帧间隔数
        videoConfiguration .sessionPreset =2;          //分辨率：0：360*540 1：540*960 2：720*1280
        videoConfiguration .landscape = NO;
        
        
        //默认音视频配置
        LFLiveAudioConfiguration *defaultAudioConfiguration = [LFLiveAudioConfiguration defaultConfiguration];
        LFLiveVideoConfiguration *defaultVideoConfiguration = [LFLiveVideoConfiguration defaultConfiguration];
        
        //利用两设备配置 来构造一个直播会话
        //_session = [[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        _session =[[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:defaultAudioConfiguration videoConfiguration:defaultVideoConfiguration];
        _session.delegate  = self;
        _session.isRAK=YES;
        _session.running =YES;
        //_session.preView =self.view;
    }
    return _session;
}

#pragma mark --init view
- (void) view_init{
    CGFloat viewW=self.view.frame.size.width;
    CGFloat viewH=self.view.frame.size.height;
    
    //Video View
    VideoView = [[LX520View alloc] initWithFrame:CGRectMake(0, 0, viewW, viewW*720/1280)];
    VideoView.center=self.view.center;
    VideoView.backgroundColor = [UIColor blackColor];
    [VideoView set_log_level:2];
    [VideoView delegate:self];
    [self.view addSubview:VideoView];
    
    _deviceIP=@"192.168.1.122";
    NSString *url = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/h264", _deviceIP];
    [self playVideo:url];
}

//#pragma mark Play video
- (void)playVideo:(NSString *)url
{
    if (_deviceIP==nil) {
        [self showAllTextDialog: @"Device IP is invalid,Please Scan first"];
        return;
    }
    NSLog(@"start play");
    [VideoView play:url useTcp:_useTcp];
    [VideoView sound:_audioIsEnable];
    if (_useTcp) {
        _transport=@"tcp";
    }
    else{
        _transport=@"udp";
    }
}

- (void)take_imageRef:(CGImageRef)imageRef{
    if(_isLiving)
        [self.session upload_imageRef:imageRef];
}


#pragma mark LX520Delegate
- (void)state_changed:(int)state
{
    NSLog(@"state = %d", state);
    switch (state) {
        case 0: //STATE_IDLE
        {
            NSLog(@"STATE_IDLE");
            _isPlaying=NO;
            break;
        }
        case 1: //STATE_PREPARING
        {
            NSLog(@"STATE_PREPARING");
            _isPlaying=NO;
            break;
        }
        case 2: //STATE_PLAYING
        {
            NSLog(@"STATE_PLAYING");
            _isPlaying=YES;
            [VideoView take_imageRef:YES];
            break;
        }
        case 3: //STATE_STOPPED
        {
            NSLog(@"STATE_STOPPED");
            _isPlaying=NO;
            break;
        }
            
        default:
            break;
    }
}

- (void)video_info:(NSString *)codecName codecLongName:(NSString *)codecLongName
{
    _videoCodec=codecLongName;
}

- (void)audio_info:(NSString *)codecName codecLongName:(NSString *)codecLongName sampleRate:(int)sampleRate channels:(int)channels
{
    _audioCodec=codecLongName;
}

- (void)stopVideo
{
    if (_isPlaying) {
        _isLiving=NO;
        _isPlaying=NO;
        [VideoView stop];
        NSLog(@"stop play");
    }
}


//按钮点击响应： 直播选择
-(void)livingOperating:(UIButton *)btn{
    
    int tag =(int) btn.tag;
    switch (tag) {
        case 0:
            NSLog(@"视频直播");
            [self openLivingSession:1];
            break;
        default:
            [self closeLivingSession];
            break;
    }
}

//开始直播
-(void)openLivingSession:(LivingDataSouceType) type{
//    NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(timeToChangePic) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSDefaultRunLoopMode];
    
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    stream.url=@"rtmp://rak.uplive.ks-cdn.com/live/LIVEQU15612334A4A?vdoid=1474526229";
    //stream.url=@"rtmp://115.231.182.113:1935/livestream/daxvab6i";//哔哩哔哩
    //stream.url=@"rtmp://live-send.acg.tv/live/ive_15244440_8483360?streamname=live_15244440_8483360&key=e0431c91c2457efdeb6a02986299973e";
    self.session.dataSoureType = type;
    [self.session startLive:stream];
}

//关闭直播
-(void)closeLivingSession{
    [self stopVideo];
    if(self.session.state == LFLivePending || self.session.state ==LFLiveStart){
        [self.session stopLive];
        [self.session setRunning:NO];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark --LFStreamingSessionDelegate
-(void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo{
    
}

-(void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString *networkStatusInfo;
    switch (state) {
        case LFLiveReady:
            networkStatusInfo = @"准备....";
            break;
        case LFLivePending:
            networkStatusInfo = @"连接中...";
            break;
        case LFLiveStart:
            networkStatusInfo = @"已连接";
            _isLiving=YES;
            break;
        case LFLiveStop:
            networkStatusInfo  =@"已断开";
            break;
        case LFLiveError:
            networkStatusInfo =@"连接出错";
            break;
        default:
            break;
    }
    
    self.networkStatusLable.text = [NSString stringWithFormat:@"连接状态：%@\n",networkStatusInfo];
    
    NSLog(@"状态信息%@",self.networkStatusLable.text);
}


-(void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
    self.networkStatusLable .text =[NSString stringWithFormat: @"直播错误,代码:%d",(int)errorCode ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-- Toast Show
-(void)showAllTextDialog:(NSString *)str{
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
}


@end
