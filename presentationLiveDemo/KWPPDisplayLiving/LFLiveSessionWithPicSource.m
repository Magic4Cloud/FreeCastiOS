//
// LFLiveSessionWithPicSource.m
//  presentationLiveDemo
//
//  Created by zyh_scut on 16/8/23.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFLiveSessionWithPicSource.h"
#import "LFVideoCapture.h"
#import "LFAudioCapture.h"
#import "LFHardwareVideoEncoder.h"
#import "LFHardwareAudioEncoder.h"
#import "LFStreamRtmpSocket.h"
#import "LFLiveStreamInfo.h"
#import "LFGPUImageBeautyFilter.h"
#import "PicToBufferToPic.h"
#import "CommanParameter.h"
#import "H264HardwareCodec.h"


@interface LFLiveSessionWithPicSource ()<LFAudioCaptureDelegate,LFVideoCaptureDelegate,LFAudioEncodingDelegate,LFVideoEncodingDelegate,LFStreamSocketDelegate>
{
    dispatch_semaphore_t _lock;
    H264HardwareCodec *_h264HardwareCodec;
}

///音频配置 视频配置
@property (nonatomic, strong) LFLiveAudioConfiguration *audioConfiguration;
@property (nonatomic, strong) LFLiveVideoConfiguration *videoConfiguration;
/// 声音采集 视频采集
@property (nonatomic, strong) LFAudioCapture *audioCaptureSource;
@property (nonatomic, strong) LFVideoCapture *videoCaptureSource;
/// 音频编码  视频编码
@property (nonatomic, strong) id<LFAudioEncoding> audioEncoder;
@property (nonatomic, strong) id<LFVideoEncoding> videoEncoder;
/// 上传
@property (nonatomic, strong) id<LFStreamSocket> socket;

//其他辅助属性
@property (nonatomic, copy) dispatch_block_t reportBlock;
@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) LFLiveStreamInfo *streamInfo;
@property (nonatomic, assign) BOOL uploading;
@property (nonatomic,assign,readwrite) LFLiveState state;

@property (nonatomic,assign)ScaleSizeLevel scaleLevel;

//图像处理
@property (nonatomic, assign) CVImageBufferRef buffer;
@property (nonatomic, assign) BOOL  isPausing;

//
@property (nonatomic, assign) uint64_t timestamp;
@property (nonatomic, assign) BOOL isFirstFrame;
@property (nonatomic, assign) uint64_t currentTimeStamp;

@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;


@end

#define NOW (CACurrentMediaTime()*1000)
NSInteger lastPicTag =-1;  //全局变量，用于标记当前图片是否有变更；
NSInteger pauseTimeLen=0;


@implementation LFLiveSessionWithPicSource
//声明一个全局唯一的静态对象，也是AccountManager类型
static LFLiveSessionWithPicSource * _sharedInstance;
//方法实现
+ (id) sharedInstance {
    return _sharedInstance;
} 
+ (void) setSharedInstance:(LFLiveSessionWithPicSource *) session{
    _sharedInstance=session;
}
#pragma mark --默认配置
- (instancetype)initWithAudioConfiguration:(LFLiveAudioConfiguration *)audioConfiguration videoConfiguration:(LFLiveVideoConfiguration *)videoConfiguration{
    _h264HardwareCodec=[[H264HardwareCodec alloc]init];
    if(!audioConfiguration || !videoConfiguration) @throw [NSException exceptionWithName:@"LFLiveSession init error" reason:@"audioConfiguration or videoConfiguration is nil " userInfo:nil];
    if(self = [super init]){
        _audioConfiguration = audioConfiguration;
        _videoConfiguration = videoConfiguration;
        _lock = dispatch_semaphore_create(1);
        
        _scaleLevel =3; //默认 为 25%
        _currentSlideImage = [UIImage imageNamed:@"3.png"];
        _picTag = -100000;
        self.mirror =NO;
        _isPausing =NO;
    }
    return self;
}

/**
 *  停止手机采集音视频
 */
- (void)dealloc{
    self.audioCaptureSource.running = NO;
    self.videoCaptureSource.running = NO;
}




#pragma mark --
//LiveStreamInfo类只有默认构造函数， 类中两个属性：音频配置，视频配置均使用默认的值
//startLive函数： 先将本类initWithAudionConfiguration videoComfiguration 所获取的 音频视频配置 赋值给 本类的属性_streamInfo， 然后启动socket。
- (void)startRecord
{

    [_videoCaptureSource startRecording];
}

- (void)stopRecord
{
    [_videoCaptureSource stopRecording];
}

/**
 *  开始直播
 */
- (void)startLive:(LFLiveStreamInfo*)streamInfo{
    if(!streamInfo) return;
    _streamInfo = streamInfo;
    _streamInfo.videoConfiguration = _videoConfiguration;
    _streamInfo.audioConfiguration = _audioConfiguration;
    NSLog(@"streamInfo.url==>%@",streamInfo.url);
    [self.socket start];
}

/**
 *  停止直播
 */
- (void)stopLive{
    self.uploading = NO;
    if (uploadTimer!=nil){
        [uploadTimer invalidate];
        uploadTimer=nil;
        isShowBanner=NO;
    }
    [self.socket stop];
}

/**
 *  定时显示字幕或角标及间隔时间
 */
-(void)timerFunction{
    if([[self Get_Paths:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
        if (isShowBanner) {
            count_duration++;
            count_interval=0;
        }
        else{
            count_duration=0;
            count_interval++;
        }
        
        if (count_duration>duration) {
            isShowBanner=NO;
        }
        if (count_interval>=interval) {
            isShowBanner=YES;
        }
    }
    
    if([[self Get_Paths:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
        if (isShowSubtitle) {
            subtitle_count_duration++;
            subtitle_count_interval=0;
        }
        else{
            subtitle_count_duration=0;
            subtitle_count_interval++;
        }
        
        if (subtitle_count_duration>subtitle_duration) {
            isShowSubtitle=NO;
        }
        if (subtitle_count_interval>=subtitle_interval) {
            isShowSubtitle=YES;
        }
    }
    
}

- (void)setWarterMarkView:(UIView *)warterMarkView{
    [self.videoCaptureSource setWarterMarkView:warterMarkView];
}

- (nullable UIView*)warterMarkView{
    return self.videoCaptureSource.warterMarkView;
}


NSTimer *uploadTimer=nil;
int count_duration=0;
int count_interval=0;
int duration=0;
int interval=0;
float imgAlpha=1.0;
int subtitle_count_duration=0;
int subtitle_count_interval=0;
int subtitle_duration=0;
int subtitle_interval=0;

BOOL isShowBanner=NO;
BOOL isShowSubtitle=NO;

- (void)upload_audio:(AudioBufferList)inBufferList{
    
    LFAudioFrame *audioFrame = [LFAudioFrame new];
    audioFrame.timestamp = self.currentTimestamp;

    audioFrame.data = [NSData dataWithBytes:inBufferList.mBuffers[0].mData length:inBufferList.mBuffers[0].mDataByteSize];
    
    char exeData[2];
    exeData[0] = _audioConfiguration.asc[0];
    exeData[1] = _audioConfiguration.asc[1];
    audioFrame.audioInfo = [NSData dataWithBytes:exeData length:2];

    [self audioEncoder:self.audioEncoder audioFrame:audioFrame];

}



/**
 *  将实时画面推流到指定直播地址
 */
- (void)upload_h264:(int)size :(Byte*)data{

    
    CVPixelBufferRef tbuffer =[_h264HardwareCodec deCompressedCMSampleBufferWithData:data andLength:size andOffset:0];
    [self.videoEncoder encodeVideoData:tbuffer timeStamp:self.currentTimestamp];
    CVPixelBufferRelease(tbuffer);
}


- (void)upload_imageRef:(CGImageRef)imageRef{
    //NSLog(@"take_imageRef");
//    CVImageBufferRef pixelBuffer = [self pixelBufferFromCGImage:imageRef];
//    [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:self.currentTimestamp];
//    CGImageRelease(imageRef);
//    CFRelease(pixelBuffer);
    
    UIImage *tempImage = [PicBufferUtil scaleImage:[UIImage imageWithCGImage:imageRef] toSize:CGSizeMake(1280, 720)];
    //tempImage = [self addBannerSubtitle:tempImage];
    CVPixelBufferRef tbuffer =[PicBufferUtil firstWayConvertToCVPixelBufferRefFromImage:tempImage];
    [self.videoEncoder encodeVideoData:tbuffer timeStamp:self.currentTimestamp];
    CGImageRelease(imageRef);
    CVPixelBufferRelease(tbuffer);
}

/**
 *  将暂停画面推流到指定直播地址
 */
UIImage *pauseImage=nil;
- (void)upload_PauseImg{
    NSLog(@"将暂停画面推流到指定直播地址 ");

    if([[self Get_Paths:PAUSE_SCREEN_PHOTO_ENABLE_KEY] compare:@"off"]==NSOrderedSame){
        return;
    }
    
    if([self Get_Images:PAUSE_SCREEN_PHOTO_SRC_KEY]==nil){
    }
    else{
        pauseImage=[self Get_Images:PAUSE_SCREEN_PHOTO_SRC_KEY];
    }
    pauseImage = [PicBufferUtil scaleImage:pauseImage toSize:CGSizeMake(1280, 720)];
    pauseImage = [self addBannerSubtitle:pauseImage];
    CVPixelBufferRef tbuffer =[PicBufferUtil firstWayConvertToCVPixelBufferRefFromImage:pauseImage];
    [self.videoEncoder encodeVideoData:tbuffer timeStamp:self.currentTimestamp];
    CVPixelBufferRelease(tbuffer);
    //[NSThread sleepForTimeInterval:0.1f];
}

/**
 *  显示字幕或角标
 */
- (UIImage*)addBannerSubtitle:(UIImage*)tempImage{
    if(([[self Get_Paths:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame)||
       ([[self Get_Paths:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame)){
        
        if([[self Get_Paths:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
            duration=[[self Get_Paths:BANNER_DURATION_KEY] intValue];
            interval=[[self Get_Paths:BANNER_INTERVAL_KEY] intValue];
        }
        else{
            isShowBanner=NO;
        }
        
        if([[self Get_Paths:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
            subtitle_duration=[[self Get_Paths:SUBTITLE_DURATION_KEY] intValue];
            subtitle_interval=[[self Get_Paths:SUBTITLE_INTERVAL_KEY] intValue];
        }else{
            isShowSubtitle=NO;
        }
        
        if (uploadTimer==nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFunction) userInfo:nil repeats:YES];
            });
            if([[self Get_Paths:BANNER_PHOTO_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
                isShowBanner=YES;
                count_duration=0;
                count_interval=0;
            }
            
            if([[self Get_Paths:SUBTITLE_ENABLE_KEY] compare:@"on"]==NSOrderedSame){
                isShowSubtitle=YES;
                subtitle_count_duration=0;
                subtitle_count_interval=0;
            }
            
        }
        
        if (isShowBanner&&isShowSubtitle) {
            tempImage=[PicBufferUtil putImage:[self Get_Images:BANNER_UPPER_LEFT_PUSH_KEY]
                                             :[self Get_Images:BANNER_UPPER_RIGHT_PUSH_KEY]
                                             :[self Get_Images:BANNER_LOWER_LEFT_PUSH_KEY]
                                             :[self Get_Images:BANNER_LOWER_RIGHT_PUSH_KEY]
                                             :[self Get_Images:SUBTITLE_PHOTO_PUSH_KEY]
                              onTheTopOfImage:tempImage
                                             :[self Get_Paths:SUBTITLE_SHOW_TYPE_KEY]];
        }
        else if (!isShowBanner&&isShowSubtitle){
            tempImage=[PicBufferUtil putImage:nil
                                             :nil
                                             :nil
                                             :nil
                                             :[self Get_Images:SUBTITLE_PHOTO_PUSH_KEY]
                              onTheTopOfImage:tempImage
                                             :[self Get_Paths:SUBTITLE_SHOW_TYPE_KEY]];
        }
        else if (isShowBanner&&!isShowSubtitle) {
            tempImage=[PicBufferUtil putImage:[self Get_Images:BANNER_UPPER_LEFT_PUSH_KEY]
                                             :[self Get_Images:BANNER_UPPER_RIGHT_PUSH_KEY]
                                             :[self Get_Images:BANNER_LOWER_LEFT_PUSH_KEY]
                                             :[self Get_Images:BANNER_LOWER_RIGHT_PUSH_KEY]
                                             :nil
                              onTheTopOfImage:tempImage
                                             :nil];
        }
    }
    return tempImage;
}

/**
 *  转换格式
 */
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

- (UIImage *)Get_Images:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSData* imageData = [defaults objectForKey:key];
    UIImage* image = [UIImage imageWithData:imageData];
    return image;
}

- (NSString *)Get_Paths:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

#pragma mark -- 实现委托方法
- (void)captureOutput:(nullable LFAudioCapture *)capture audioData:(nullable NSData*)audioData {
    if (_isRAK && !_isIphoneAudio) {
        return;
    }

    if (self.uploading) [self.audioEncoder encodeAudioData:audioData timeStamp:NOW];
}


- (void)captureOutput:(nullable LFVideoCapture *)capture pixelBuffer:(nullable CVPixelBufferRef)pixelBuffer {
    if (_isRAK) {
        return;
    }
    if(_isPausing)
    { //暂停时，显示暂停图片
        int num = (pauseTimeLen++/10)%8+1;
        NSString *picName = [NSString stringWithFormat:@"pauseLiving%d.png",num ];
        NSLog(@"暂停： %@",picName);
//        UIImage *tempImage = [UIImage imageNamed:picName];
        CVPixelBufferRef tbuffer = pixelBuffer;
        [self.videoEncoder encodeVideoData:tbuffer timeStamp:NOW];
        CVPixelBufferRelease(tbuffer);
    }
    else{
        pauseTimeLen =1;
        UIImage *returnImage ;
        
        if(self.dataSoureType ==PictureOnly){
            //            NSLog(@"图片直播...%ld,====%ld",(long)_picTag,(long)lastPicTag);
            CVPixelBufferRef tempBuffer =NULL;
            if(_picTag !=lastPicTag){
                
                if(_buffer !=NULL)
                    CVPixelBufferRelease(_buffer);
                CGSize size = CGSizeMake(self.currentSlideImage.size.width, self.currentSlideImage.size.height);
                UIGraphicsBeginImageContext(size);
                [self.currentSlideImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
                
                returnImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                tempBuffer= [PicBufferUtil firstWayConvertToCVPixelBufferRefFromImage:returnImage];
                _buffer = tempBuffer;
                lastPicTag =_picTag;
            }
            pixelBuffer = _buffer;
            [self.videoEncoder encodeVideoData:_buffer timeStamp:NOW];
            
        }
        else if(self.dataSoureType ==CameraAndPicture){
            //            NSLog(@"混合直播...");
            returnImage  = [PicBufferUtil convertToImageFromCVImageBufferRef:pixelBuffer];
            //returnImage = [PicBufferUtil scaleImage:returnImage toScale:_scaleLevel];
            returnImage = [PicBufferUtil scaleImage:returnImage toSize:CGSizeMake(200, 200)];
            //returnImage = [PicBufferUtil putImage:returnImage onTheTopOfImage:self.currentSlideImage];
            
            pixelBuffer= [PicBufferUtil convertToCVPixelBufferFromImage:returnImage];
            [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:self.currentTimestamp];
        }
        else
        {
            [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:NOW];
        }
    }
    
}


-(void) pauseOrResumeLiving:(BOOL)isPausing{
    _isPausing = isPausing;
}


#pragma mark -- 实现编码委托
- (void)audioEncoder:(nullable id<LFAudioEncoding>)encoder audioFrame:(nullable LFAudioFrame*)frame{
    
    if(self.uploading)
    {
        [self.socket sendFrame:frame];//<上传
    }
}

- (void)videoEncoder:(nullable id<LFVideoEncoding>)encoder videoFrame:(nullable LFVideoFrame*)frame
{

    if(self.uploading)
    {
        [self.socket sendFrame:frame];//<上传
    }
}

#pragma mark -- LFStreamTcpSocketDelegate
- (void)socketStatus:(nullable id<LFStreamSocket>)socket status:(LFLiveState)status{
    if(status == LFLiveStart){
        if(!self.uploading){
            self.timestamp = 0;
            self.isFirstFrame = YES;
            self.uploading = YES;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.state = status;
        if(self.delegate && [self.delegate respondsToSelector:@selector(liveSession:liveStateDidChange:)]){
            [self.delegate liveSession:self liveStateDidChange:status];
        }
    });
}

- (void)socketDidError:(nullable id<LFStreamSocket>)socket errorCode:(LFLiveSocketErrorCode)errorCode{

    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(liveSession:errorCode:)]){
            [self.delegate liveSession:self errorCode:errorCode];
        }
    });
}

- (void)socketDebug:(nullable id<LFStreamSocket>)socket debugInfo:(nullable LFLiveDebug*)debugInfo{
    self.debugInfo = debugInfo;
    if(self.showDebugInfo){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(liveSession:debugInfo:)]){
                [self.delegate liveSession:self debugInfo:debugInfo];
            }
        });
    }
}

- (void)socketBufferStatus:(nullable id<LFStreamSocket>)socket status:(LFLiveBuffferState)status{


    NSUInteger videoBitRate = [_videoEncoder videoBitRate];
    if(status == LFLiveBuffferIncrease){
        if(videoBitRate < _videoConfiguration.videoMaxBitRate){
            videoBitRate = videoBitRate + 50 * 1000;
            [_videoEncoder setVideoBitRate:videoBitRate];
        }
    }else{
        if(videoBitRate > _videoConfiguration.videoMinBitRate){
            videoBitRate = videoBitRate - 100 * 1000;
            [_videoEncoder setVideoBitRate:videoBitRate];
        }
    }
}

#pragma mark -- Getter Setter
- (void)setRunning:(BOOL)running{
    if(_running == running) return;
    [self willChangeValueForKey:@"running"];
    _running = running;
    [self didChangeValueForKey:@"running"];
    if (_isRAK) {
        self.videoCaptureSource.running = NO;
        self.audioCaptureSource.running = NO;
        _videoCaptureSource=nil;
        _audioCaptureSource=nil;
    }
    else{
        self.videoCaptureSource.running = _running;
        self.audioCaptureSource.running = _running;
    }
    
}

- (void)setPreView:(UIView *)preView{
    [self.videoCaptureSource setPreView:preView];
}

- (UIView*)preView{
    return self.videoCaptureSource.preView;
}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition{
    [self.videoCaptureSource setCaptureDevicePosition:captureDevicePosition];
}

- (AVCaptureDevicePosition)captureDevicePosition{
    return self.videoCaptureSource.captureDevicePosition;
}

- (void)setBeautyFace:(BOOL)beautyFace{
    [self.videoCaptureSource setBeautyFace:beautyFace];
}

- (BOOL)beautyFace{
    return self.videoCaptureSource.beautyFace;
}

- (void)setBeautyLevel:(CGFloat)beautyLevel {
    [self.videoCaptureSource setBeautyLevel:beautyLevel];
}

- (CGFloat)beautyLevel {
    return self.videoCaptureSource.beautyLevel;
}

- (void)setBrightLevel:(CGFloat)brightLevel {
    [self.videoCaptureSource setBrightLevel:brightLevel];
}

- (CGFloat)brightLevel {
    return self.videoCaptureSource.brightLevel;
}

- (void)setZoomScale:(CGFloat)zoomScale {
    [self.videoCaptureSource setZoomScale:zoomScale];
}

- (CGFloat)zoomScale {
    return self.videoCaptureSource.zoomScale;
}

- (void)setTorch:(BOOL)torch {
    [self.videoCaptureSource setTorch:torch];
}

- (BOOL)torch {
    return self.videoCaptureSource.torch;
}

- (void)setMirror:(BOOL)mirror {
    [self.videoCaptureSource setMirror:mirror];
}

- (BOOL)mirror {
    return self.videoCaptureSource.mirror;
}

- (void)setMuted:(BOOL)muted{
    [self.audioCaptureSource setMuted:muted];
}

- (BOOL)muted{
    return self.audioCaptureSource.muted;
}

- (LFAudioCapture*)audioCaptureSource{
    if (_isRAK) {
        return _audioCaptureSource;
    }
    if(!_audioCaptureSource){
        _audioCaptureSource = [[LFAudioCapture alloc] initWithAudioConfiguration:_audioConfiguration];
            _audioCaptureSource.delegate = self;
    }
    return _audioCaptureSource;
}

- (LFVideoCapture*)videoCaptureSource{
    if (_isRAK) {
        return _videoCaptureSource;
    }
    if(!_videoCaptureSource){
        _videoCaptureSource = [[LFVideoCapture alloc] initWithVideoConfiguration:_videoConfiguration];
        _videoCaptureSource.delegate = self;        
    }
    return _videoCaptureSource;
}


- (id<LFAudioEncoding>)audioEncoder{
    if(!_audioEncoder){
        _audioEncoder = [[LFHardwareAudioEncoder alloc] initWithAudioStreamConfiguration:_audioConfiguration];
        [_audioEncoder setDelegate:self];
    }
    return _audioEncoder;
}

- (id<LFVideoEncoding>)videoEncoder{
    if(!_videoEncoder){
        _videoEncoder = [[LFHardwareVideoEncoder alloc] initWithVideoStreamConfiguration:_videoConfiguration];
        [_videoEncoder setDelegate:self];
    }
    return _videoEncoder;
}

- (id<LFStreamSocket>)socket{
    if(!_socket){
        _socket = [[LFStreamRTMPSocket alloc] initWithStream:self.streamInfo reconnectInterval:self.reconnectInterval reconnectCount:self.reconnectCount];
//        _socket = [[LFStreamRTMPSocket alloc] initWithStream:self.streamInfo videoSize:self.videoConfiguration.videoSize reconnectInterval:self.reconnectInterval reconnectCount:self.reconnectCount];
        [_socket setDelegate:self];
    }
    return _socket;
}

- (LFLiveStreamInfo*)streamInfo{
    if(!_streamInfo){
        _streamInfo = [[LFLiveStreamInfo alloc] init];
    }
    return _streamInfo;
}

- (uint64_t)currentTimestamp{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    uint64_t currentts = 0;
    if(_isFirstFrame == true) {
        _timestamp = NOW;
        _isFirstFrame = false;
        currentts = 0;
    } else {
        currentts = NOW - _timestamp;
    }
    dispatch_semaphore_signal(_lock);
    return currentts;
}

@end
