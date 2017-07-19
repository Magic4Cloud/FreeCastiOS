//
//  LivingViewController.m
//  presentationLiveDemo
//
//  Created by zyh_scut on 16/8/22.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "LivingViewController.h"
#import "LFLiveKit.h"
#import "LFLiveSessionWithPicSource.h"
#import "PicToBufferToPic.h"

@interface LivingViewController ()<LFLiveSessionWithPicSourceDelegate>

/**
 * 三个按钮：触发三种不同类型的直播
 */
@property(strong, nonatomic) UIButton *picDataLiveButton;
@property(strong, nonatomic) UIButton *captureDataLiveButton;
@property(strong, nonatomic) UIButton *mergerDataLiveButton;
@property(strong, nonatomic) UILabel *networkStatusLable;

//直播配置：直播回话，直播地址，直播预览视图 ， 回传效果视图
@property(strong, nonatomic) LFLiveSessionWithPicSource *session;
@property(nonatomic, copy)NSString *rtmpUrl;
@property(nonatomic, strong)UIView *livingPreView;

@property(nonatomic, copy)UIImageView *returnImageView;
@property (nonatomic,assign)BOOL isPausing;

@end

int count11 =1;

@implementation LivingViewController

#pragma mark --辅助函数

//构造预览视图，视图为设备的宽，高度-100
-(UIView *)livingPreView{
    if(!_livingPreView){
        UIView *livePreView = [[UIView alloc] initWithFrame:self.view.bounds];
        livePreView.backgroundColor = [UIColor clearColor];
        [livePreView setAutoresizingMask:0];
        livePreView.clipsToBounds =YES;
        _livingPreView = livePreView;
        
        [self.view insertSubview:_livingPreView atIndex:0];
    }
    return _livingPreView;
}

//重写构造器：构造直播会话，包括配置录制的音视频格式数据
-(LFLiveSessionWithPicSource *)session{
    if(!_session){
        /**
         *  构造音频配置器
         *  双声道， 128Kbps的比特率，44100HZ的采样率
         */
        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
        audioConfiguration .numberOfChannels = 2;
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
//        videoConfiguration .landscape = NO;
        videoConfiguration.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
        
        //默认音视频配置
        LFLiveAudioConfiguration *defaultAudioConfiguration = [LFLiveAudioConfiguration defaultConfiguration];
        LFLiveVideoConfiguration *defaultVideoConfiguration = [LFLiveVideoConfiguration defaultConfiguration];
        
        //利用两设备配置 来构造一个直播会话
        //_session = [[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        _session =[[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:defaultAudioConfiguration videoConfiguration:defaultVideoConfiguration];
        _session .delegate  = self;
        _session .running =YES;
        _session.isRAK=NO;
        _session .preView =[self livingPreView];
    }
    return _session;
}


//设置其他属性
-(void) setUp{
    _session.captureDevicePosition = AVCaptureDevicePositionFront; //前置摄像头；
    _session.dataSoureType =PictureOnly;
}

#pragma mark --事件响应函数

-(void)switchCameraPosition{
    _session.captureDevicePosition = _session.captureDevicePosition==AVCaptureDevicePositionFront? AVCaptureDevicePositionBack: AVCaptureDevicePositionFront;
}

//按钮点击响应： 直播选择
-(void)livingOperating:(UIButton *)btn{
    int tag =(int) btn.tag;
    switch (tag) {
        case 0:
            NSLog(@"图片直播");
            _livingPreView.hidden =YES;
            [self openLivingSession:2];
            break;
        case 1:
            NSLog(@"视频直播");
            _livingPreView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            _livingPreView.hidden =NO;
            [self openLivingSession:1];
            break;
        case 2:
            NSLog(@"混合直播");
            _livingPreView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            _livingPreView.hidden =NO;
            [self openLivingSession:3];
            break;
        default:
            _livingPreView.hidden =NO;
            [self closeLivingSession];
            break;
    }
}

//开始直播
-(void)openLivingSession:(LivingDataSouceType) type{
//    NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(timeToChangePic) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSDefaultRunLoopMode];
    
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new ];
    stream .url=@"rtmp://rak.uplive.ks-cdn.com/live/LIVEQU15612334A4A?vdoid=1474526229";
    self.session.dataSoureType = type;
    [self.session startLive:stream];
}

- (void)timeToChangePic{
    NSLog(@"定时器启动，切换图片：");
    if(count11 >20)count11 = 1;
    NSString *name = [NSString stringWithFormat:@"%d.jpg",count11];
    UIImage *newImage = [UIImage imageNamed:name];
    _session.currentSlideImage = newImage;
    _session.picTag= count11++;
}

//关闭直播
-(void)closeLivingSession{
    if(self.session.state == LFLivePending || self.session.state ==LFLiveStart){
        [self.session stopLive];
        [self.session setRunning:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pauseOrResumeLiving:(UIButton *)btn{
   // [_session pauseLive];
}

#pragma mark --系统视图函数
-(void)viewDidLoad{
    [super viewDidLoad];
    [self setUp];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //状态标签
    self.networkStatusLable  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [self.view addSubview: self.networkStatusLable];
    
    //预览视图
    _returnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 200, 400, 400)];
    [_returnImageView setBackgroundColor: [UIColor grayColor]];
    //[self.view addSubview:_returnImageView];
    
    //摄像头直播按钮
    self.captureDataLiveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-150, self.view.bounds.size.width-40, 30)];
    [self.captureDataLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
    [self.captureDataLiveButton setTag:1];
    [self.captureDataLiveButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:138/255.0 blue:131/255.0 alpha:1.0]];
    [self.captureDataLiveButton addTarget:self action:@selector(livingOperating:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureDataLiveButton];
    
    //切换摄像头按钮
    UIButton *changeCameraPosition = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-100, self.view.bounds.size.width-40, 30)];
    [changeCameraPosition setBackgroundColor:[UIColor colorWithRed:255/255.0 green:138/255.0 blue:131/255.0 alpha:1.0]];
    [changeCameraPosition setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [changeCameraPosition addTarget:self action:@selector(switchCameraPosition) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeCameraPosition];
    
    //停止直播
    UIButton *stopLivingButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-50, self.view.bounds.size.width-40, 30)];
    stopLivingButton.tag = -1;
    [stopLivingButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:138/255.0 blue:131/255.0 alpha:1.0]];
    [stopLivingButton setTitle:@"结束直播" forState:UIControlStateNormal];
    [stopLivingButton addTarget:self action:@selector(livingOperating:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopLivingButton];
    
    
    //PPT直播
    self.picDataLiveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-150, (self.view.bounds.size.width /2)-40, 30)];
    [self.picDataLiveButton setTitle:@"直播PPT" forState:UIControlStateNormal];
    [self.picDataLiveButton setTag:0];
    [self.picDataLiveButton setBackgroundColor: [UIColor grayColor]];
    [self.picDataLiveButton addTarget:self action:@selector(livingOperating:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:self.picDataLiveButton];
    
    
    
    //混合PPT和摄像头直播按钮
    self.mergerDataLiveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-100, (self.view.bounds.size.width /2)-40, 30)];
    [self.mergerDataLiveButton setTitle:@"直播混合数据" forState:UIControlStateNormal];
    [self.mergerDataLiveButton setTag:2];
    [self.mergerDataLiveButton  setBackgroundColor: [UIColor grayColor]];
    [self.mergerDataLiveButton addTarget:self action:@selector(livingOperating:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:self.mergerDataLiveButton];

    
    UIButton *pauseOrResumeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-50, self.view.bounds.size.width-40, 30)];
    [pauseOrResumeButton setBackgroundColor:[UIColor grayColor]];
    [pauseOrResumeButton setTitle:@"暂停直播" forState:UIControlStateNormal];
    [pauseOrResumeButton addTarget:self action:@selector(pauseOrResumeLiving:) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:pauseOrResumeButton];
    
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
    
    self.networkStatusLable.text = [NSString stringWithFormat:@"连接状态：%@\n RTMP:%@",networkStatusInfo, self.rtmpUrl];
    
    NSLog(@"状态信息%@",self.networkStatusLable.text);
}


-(void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
    self.networkStatusLable .text =[NSString stringWithFormat: @"直播错误,代码:%d",(int)errorCode ];
}
//代理
- (void)livingDataReturnByImageBufferRef:(nonnull CVPixelBufferRef)returnImageBuffer{
    UIImage *returnImage = [PicBufferUtil convertToImageFromCVImageBufferRef:returnImageBuffer];
    _returnImageView.image = returnImage;
}



@end
