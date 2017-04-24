//
//  LivingView.m
//  presentationLiveDemo
//
//  Created by zyh_scut on 16/8/28.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LivingView.h"
#import "LFLiveKit.h"
#import "LFLiveSessionWithPicSource.h"
#import "PicToBufferToPic.h"

@interface LivingView () <LFLiveSessionWithPicSourceDelegate>

/**
 * 三个按钮：触发三种不同类型的直播
 */
@property (strong, nonatomic) UIButton *PPTDataLiveButton;          //PPT直播
@property (strong, nonatomic) UIButton *switchCammeraButton;        //切换摄像头
@property (strong, nonatomic) UIButton *mergerDataLiveButton;       //PPT+摄像头 直播
@property (strong, nonatomic) UIButton *stopLivingButton;           //停止直播
@property (strong, nonatomic) UILabel *timeMsgLabel;                //直播时间Label


//直播配置：直播回话，直播地址，直播预览视图 ， 回传效果视图
@property (strong, nonatomic) LFLiveSessionWithPicSource *session;   //直播会话
@property (nonatomic, copy)NSString *rtmpUrl;                        //直播推流服务器地址
@property (nonatomic, strong)UIView *livingPreView;                  //预览视图，本文件没 调用[self insertSubviewAtIndex:0];

@property (nonatomic, assign)BOOL isPausing;                         //是否已暂停
@property (nonatomic, assign)BOOL isNowPPTLiving;                    //是否在PPT直播
@property (nonatomic, assign)BOOL isNowCameraAndPPTLiving;           //是否摄像头与PPT 一起直播 （与上一属性互斥）
@property (nonatomic, assign)int lastTouchButtonTag;                 //上一次点击按钮
@property (nonatomic, assign)BOOL isFirstTimeStart;                  //是否第一次点 直播 按钮

@end


#pragma mark --全局变量
int count =1;  //临时使用，可以删除

@implementation LivingView
@synthesize isLivingStarted;

# pragma  mark --公共函数接口
-(instancetype)init{
   // CGSize screamSize = [UIScreen mainScreen].bounds.size;
    CGRect defaultViewSize = CGRectMake(0, 50, 130, 150);
    self = (LivingView *)[self initWithFrame:defaultViewSize];
    _rtmpUrl= @"rtmp://test.uplive.ksyun.com/live/room1";
    return self;
}

/** 构造函数 参数为 ：rtmp服务器地址 **/
-(instancetype) initLivingViewWithLivingServerAddress:(NSString *)rtmpServerAddress{
   // CGSize screamSize = [UIScreen mainScreen].bounds.size;
    CGRect defaultViewSize = CGRectMake(0, 50, 130, 150);
    self = (LivingView *)[self initWithFrame:defaultViewSize];
    _rtmpUrl=rtmpServerAddress;
    return self;
}

/** 重写父类函数，由于效果需要，已限定self.frame的大小 **/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius=4.0f;
        self.userInteractionEnabled = YES;
        [self setBackgroundColor: [UIColor lightGrayColor]];
        
        [self addSubItems];
        [self setUp];
        self.isLivingStarted = NO;                             //一构造会话，则表示进入待直播状态，用于标记ppt展示切换时，是否更新图片到session
    }
    return self;
}

/** 
 *切换PPT 的幻灯片图片
 * 参数1：新幻灯片图片
 * 参数2：幻灯片的序号
 */
-(void)refreshPPTSlideImage:(UIImage *)newSlideImage withNewImageIndex:(int)newIndex{
    self.session.currentSlideImage = newSlideImage;
    self.session.picTag = newIndex;
}

/**
 * 更新时间标签内容
 * 参数：新内容
 */
-(void)refreshTimeLableWithNewContent:(NSString *)newContent{
    _timeMsgLabel.text = newContent;
}


-(void)showLivingAddress{
    NSString *url = _rtmpUrl;
    url = [url stringByReplacingOccurrencesOfString:@"rtmp" withString:@"http"];
    url =  [url stringByReplacingOccurrencesOfString:@"1935" withString:@"8080"];
    url = [url stringByAppendingString:@".html"];
    
    url = [NSString stringWithFormat:@"%@ \n播放器访问：%@",url,_rtmpUrl ];
    _rtmpUrl=@"rtmp://rak.uplive.ks-cdn.com/live/LIVEQU15612334A4A?vdoid=1474526229";
    
    UILabel * addressLabel=[[UILabel alloc] initWithFrame:CGRectMake(130, 5, [UIScreen mainScreen].bounds.size.width, 100)];
    [addressLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:addressLabel];
    addressLabel.numberOfLines=0;
    addressLabel.text =[NSString stringWithFormat:@"浏览器访问：%@", url ];
    addressLabel.textAlignment = NSTextAlignmentLeft;
    
    CATransition *transition = [CATransition animation];
    transition.type = @"push";
    transition.subtype = @"fromTop";
    [addressLabel.layer addAnimation:transition forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        addressLabel.hidden =YES;
    });
}

#pragma mark --事件响应函数

/** 用户点击按钮 操作事件 **/
-(void)livingOpearationBySender:(UIButton *)btn{
    LivingOperationType tag = btn .tag;
  
    switch(tag){
        case PPTLiving:
            self.session.dataSoureType =PictureOnly;
            if(_isNowPPTLiving){                            //如果当前正在PPT直播状态，则变为暂停状态
                _isNowPPTLiving =NO;
                _isPausing = YES;
                [self pauseOrResumeLiving];
            }
            else{                                           //如果当前不是PPT直播状态(则有三种：直播未启动，已暂停，正在摄像头直播)，则直接切换为PPT直播状态
                if(_isNowCameraAndPPTLiving){
                    _isNowCameraAndPPTLiving =NO;
                }
                _isNowPPTLiving =YES;
                
                _isPausing =NO;
                if(_isFirstTimeStart){                      //如果当前直播未启动状态，则需要构造直播会话，其他两种状态时，直接恢复直播即可
                    _isFirstTimeStart =NO;
                    self.isLivingStarted =YES;              //当前已进入直播状态
                    self.session .running =YES;
                    [self pptLiving];
                }
                else{
                    [self pauseOrResumeLiving];
                }
            }
            break;
        case MixPPTandCameraLiving:
            self.session.dataSoureType =CameraAndPicture;
            if(_isNowCameraAndPPTLiving){                   //如果当前正在PPT+摄像头的混合直播，则变为暂停状态
                _isNowCameraAndPPTLiving =NO;
                _isPausing = YES;
                [self pauseOrResumeLiving];
            }
            else{                                           //否则，则为其他三种状态：直播未启动，直播已暂停，正在PPT直播，该情况下，直接切换为PPT+摄像头的混合直播模式
                if(_isNowPPTLiving){
                    _isNowPPTLiving =NO;
                }
                _isNowCameraAndPPTLiving =YES;
                _isPausing =NO;
                
                if(_isFirstTimeStart){                      //当前是否第一次启动直播，是则需构造直播会话，否则直接回复直播状态
                    _isFirstTimeStart =NO;
                    self.isLivingStarted =YES;              //当前已进入直播状态
                    self.session .running =YES;
                    [self mergeLiving];
                }
                else{
                    [self pauseOrResumeLiving];
                }
            }
            break;
        case SwitchLivingCamera:                            //切换摄像头
            [self switchCamera];
            break;
        case StopLiving:                                    //停止直播；
            _isFirstTimeStart =YES;
            [self stopLiving];
            break;
        default:
            break;
    }
    [self resetOtherButtonNoSelected];                      //更新按钮 高亮状态
}

/** 切换摄像头 **/
-(void)switchCamera{
     NSLog(@"切换摄像头");
    self.session.captureDevicePosition = self.session.captureDevicePosition==AVCaptureDevicePositionFront? AVCaptureDevicePositionBack: AVCaptureDevicePositionFront;
}

/** 停止直播 **/
-(void)stopLiving{
     NSLog(@"停止直播");
    [self closeLivingSession];
}

/** 直播PPT内容 **/
-(void)pptLiving{
    [self showLivingAddress];
    [self openLivingSession:PictureOnly];
}

/** 混合直播  **/
-(void)mergeLiving{
    NSLog(@"混合直播");
    [self showLivingAddress];
    [self openLivingSession:CameraAndPicture];
}


#pragma  mark --内部函数
/**
 * 内部函数：添加元素 到self中
 */
- (void)addSubItems {
    _PPTDataLiveButton =[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 55, 55)];
    [_PPTDataLiveButton setTitle:@"PPT" forState:UIControlStateNormal];
    [_PPTDataLiveButton setBackgroundColor:[UIColor grayColor]];
    _PPTDataLiveButton.layer.cornerRadius= _PPTDataLiveButton.frame.size.width/2;
    _PPTDataLiveButton.layer.masksToBounds= _PPTDataLiveButton.frame.size.width/2;
    _PPTDataLiveButton.tag =(int)PPTLiving;
    [_PPTDataLiveButton addTarget:self action:@selector(livingOpearationBySender:) forControlEvents:UIControlEventTouchUpInside];
    
    _mergerDataLiveButton =[[UIButton alloc] initWithFrame:CGRectMake(70, 5, 55, 55)];
    [_mergerDataLiveButton setTitle:@"MIX" forState:UIControlStateNormal];
    [_mergerDataLiveButton setBackgroundColor:[UIColor grayColor]];
    _mergerDataLiveButton.layer.cornerRadius= _mergerDataLiveButton.frame.size.width/2;
    _mergerDataLiveButton.layer.masksToBounds= _mergerDataLiveButton.frame.size.width/2;
    _mergerDataLiveButton.tag = (int)MixPPTandCameraLiving;
    [_mergerDataLiveButton addTarget:self action:@selector(livingOpearationBySender:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _switchCammeraButton =[[UIButton alloc] initWithFrame:CGRectMake(10, 65, 55, 55)];
    [_switchCammeraButton setTitle:@"Cam" forState:UIControlStateNormal];
    [_switchCammeraButton setBackgroundColor:[UIColor grayColor]];
    _switchCammeraButton.layer.cornerRadius= _switchCammeraButton.frame.size.width/2;
    _switchCammeraButton.layer.masksToBounds= _switchCammeraButton.frame.size.width/2;
    _switchCammeraButton.tag = (int)SwitchLivingCamera;
    [_switchCammeraButton addTarget:self action:@selector(livingOpearationBySender:) forControlEvents:UIControlEventTouchUpInside];
    
    _stopLivingButton =[[UIButton alloc] initWithFrame:CGRectMake(70, 65, 55, 55)];
    [_stopLivingButton setTitle:@"Stop" forState:UIControlStateNormal];
    [_stopLivingButton setBackgroundColor:[UIColor grayColor]];
    _stopLivingButton .layer.cornerRadius= _stopLivingButton.frame.size.width/2;
    _stopLivingButton .layer.masksToBounds= _stopLivingButton.frame.size.width/2;
    _stopLivingButton.tag =(int)StopLiving;
    [_stopLivingButton addTarget:self action:@selector(livingOpearationBySender:) forControlEvents:UIControlEventTouchUpInside];
    
    _timeMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 125, 130, 20)];
    _timeMsgLabel.text =@"13:1:3";
    _timeMsgLabel.textColor =[UIColor redColor];
    
    
    [self addSubview:_PPTDataLiveButton];
    [self addSubview:_mergerDataLiveButton];
    [self addSubview:_switchCammeraButton];
    [self addSubview:_stopLivingButton];
    [self addSubview:_timeMsgLabel];
    
    _isFirstTimeStart =YES;         //当前直播未启动
    
}



/**  更新按钮 高亮与否 状态 **/
-(void)resetOtherButtonNoSelected{
    if(_isNowPPTLiving) [_PPTDataLiveButton setBackgroundColor:[UIColor redColor]];
    else [_PPTDataLiveButton setBackgroundColor:[UIColor grayColor]];
    
    if(_isNowCameraAndPPTLiving) [_mergerDataLiveButton setBackgroundColor:[UIColor redColor]];
    else [_mergerDataLiveButton setBackgroundColor:[UIColor grayColor]];
    
}

/** 构造预览视图，视图为设备的宽，高度-100*/
-(UIView *)livingPreView{
    if(!_livingPreView){
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIView *livePreView = [[UIView alloc] initWithFrame:CGRectMake(screenSize.width-120, screenSize.height-160, 120, 160)];
        livePreView.backgroundColor = [UIColor clearColor];
        [livePreView setAutoresizingMask:0];
        livePreView.clipsToBounds =YES;
        _livingPreView = livePreView;
        
        [self insertSubview:_livingPreView atIndex:0];
    }
    return _livingPreView;
}

/** 重写构造器：构造直播会话，包括配置录制的音视频格式数据 **/
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
        videoConfiguration .videoSize = CGSizeMake(1280, 720);  //视频大小 (设定该值主要为：PPT普遍为方形，因此摄像头数据设为方形，能保证图片不会因为拉伸而扭曲；)
        videoConfiguration .videoBitRate = 800*1024;        //比特率
        videoConfiguration .videoMaxBitRate = 1000*1024;    //最大比特率
        videoConfiguration .videoMinBitRate = 500*1024;     //最小比特率
        videoConfiguration .videoFrameRate = 24;            //帧率
        videoConfiguration .videoMaxKeyframeInterval = 30; //最大关键帧间隔数
        videoConfiguration .sessionPreset =2;          //分辨率：0：360*540 1：540*960 2：720*1280
        videoConfiguration .landscape = NO;
        
        
        //默认音视频配置
        //LFLiveAudioConfiguration *defaultAudioConfiguration = [LFLiveAudioConfiguration defaultConfiguration];
       // LFLiveVideoConfiguration *defaultVideoConfiguration = [LFLiveVideoConfiguration defaultConfiguration];
        
        //利用两设备配置 来构造一个直播会话
        _session = [[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        //_session =[[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:defaultAudioConfiguration videoConfiguration:defaultVideoConfiguration];
        _session .delegate  = self;
        _session .preView =[self livingPreView];
    }
    return _session;
}


/** 设置其他属性 **/
-(void) setUp{
    self.session.captureDevicePosition = AVCaptureDevicePositionFront; //前置摄像头；
    self.session.dataSoureType =PictureOnly;
    
    //临时代码
    NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(timeToChangePic) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSDefaultRunLoopMode];
}

/**开始直播 **/
-(void)openLivingSession:(LivingDataSouceType) type{
    type=1;
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new ];
    stream .url = _rtmpUrl;
    self.session.dataSoureType = type;
    [self.session startLive:stream];
    
}

/**临时函数，定时器更改图片**/
- (void)timeToChangePic{
    NSLog(@"定时器启动，切换图片：");
    if(count >20)count = 1;
    NSString *name = [NSString stringWithFormat:@"%d.jpg",count];
    
    
    UIImage *newImage = [UIImage imageNamed:name];
    [self refreshPPTSlideImage:newImage withNewImageIndex:count++];
}

/**关闭直播**/
-(void)closeLivingSession{
    _isNowCameraAndPPTLiving = NO;
    _isNowPPTLiving =NO;
    [self resetOtherButtonNoSelected];
    
    if(self.isLivingStarted){
        if(self.session.state == LFLivePending || self.session.state ==LFLiveStart){
            [self.session stopLive];
            [self.session setRunning:NO];
            self.isLivingStarted   =NO;
        }
    }
    [self removeFromSuperview];
}

/** 暂停直播或者恢复直播 **/
-(void)pauseOrResumeLiving{
    [self.session pauseOrResumeLiving:_isPausing];
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
    
    _timeMsgLabel.text =[NSString stringWithFormat:@"连接状态：%@\n RTMP:%@",networkStatusInfo, self.rtmpUrl];
    
    //self.networkStatusLable.text = [NSString stringWithFormat:@"连接状态：%@\n RTMP:%@",networkStatusInfo, self.rtmpUrl];
    
    //NSLog(@"状态信息%@",self.networkStatusLable.text);
}


-(void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
    _timeMsgLabel .text =[NSString stringWithFormat: @"直播错误,代码:%d",(int)errorCode ];
}

#pragma mark --LFLiveSessionWithPicSourceDeledata
- (void)livingDataReturnByImageBufferRef:(nonnull CVPixelBufferRef)returnImageBuffer{
    /*UIImage *returnImage = [PicBufferUtil convertToImageFromCVImageBufferRef:returnImageBuffer];
    _returnImageView.image = returnImage;*/
}

@end

