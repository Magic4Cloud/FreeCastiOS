//
//  MCRecordManager.m
//  Patrol
//
//  Created by hades on 2017/5/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "MCRecordManager.h"
#import "MCRecordEncoder.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "MCVideoTools.h"
#import "MCMotionManager.h"

@interface MCRecordManager () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate, CAAnimationDelegate> {
    CMTime _timeOffset;//录制的偏移CMTime
    CMTime _lastVideo;//记录上一次视频数据文件的CMTime
    CMTime _lastAudio;//记录上一次音频数据文件的CMTime
    
    NSInteger _cx;//视频分辨的宽
    NSInteger _cy;//视频分辨的高
    int _channels;//音频通道
    Float64 _samplerate;//音频采样率
}

@property (strong, nonatomic) MCRecordEncoder            *recordEncoder;//录制编码
@property (strong, nonatomic) AVCaptureSession           *recordSession;//捕获视频的会话
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
@property (strong, nonatomic) AVCaptureDeviceInput       *backCameraInput;//后置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *frontCameraInput;//前置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *currentCameraInput;
@property (strong, nonatomic) AVCaptureDeviceInput       *audioMicInput;//麦克风输入
@property (copy  , nonatomic) dispatch_queue_t           captureQueue;//录制的队列
@property (strong, nonatomic) AVCaptureConnection        *audioConnection;//音频录制连接
@property (strong, nonatomic) AVCaptureConnection        *videoConnection;//视频录制连接
@property (strong, nonatomic) AVCaptureConnection        *imageConnection;//照片拍摄连接
@property (strong, nonatomic) AVCaptureVideoDataOutput   *videoOutput;//视频输出
@property (strong, nonatomic) AVCaptureAudioDataOutput   *audioOutput;//音频输出
@property (strong, nonatomic) AVCaptureStillImageOutput  *stillImageOutput; //照片输出
@property (strong, nonatomic) MCMotionManager            *motionManager;
@property (atomic, assign) BOOL isCapturing;//正在录制
@property (atomic, assign) BOOL isPaused;//是否暂停
@property (atomic, assign) BOOL discont;//是否中断
@property (atomic, assign) CMTime startTime;//开始录制的时间
@property (atomic, assign) CGFloat currentRecordTime;//当前录制时间

@end

@implementation MCRecordManager
- (void)dealloc {
    [_recordSession stopRunning];
    _captureQueue     = nil;
    _recordSession    = nil;
    _previewLayer     = nil;
    _backCameraInput  = nil;
    _frontCameraInput = nil;
    _audioOutput      = nil;
    _videoOutput      = nil;
    _audioConnection  = nil;
    _videoConnection  = nil;
    _recordEncoder    = nil;
    _motionManager    = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxRecordTime = 60.0f;
        self.isBackCamera = YES;
    }
    return self;
}

#pragma mark - 公开的方法

- (void)startTakePhoto
{
    [self.recordSession startRunning];
}

#pragma mark - Video Handle
- (void)startVideoRunning
{
    self.startTime = CMTimeMake(0, 0);
    self.isCapturing = NO;
    self.isPaused = NO;
    self.discont = NO;
    [self.recordSession startRunning];
    
    if (!_motionManager) {
        _motionManager = [[MCMotionManager alloc] init];
    }
}

- (void)stopVideoRunning
{
    if (self.recordSession) {
        [self.recordSession stopRunning];
    }
}

#pragma mark - Video Record
//开始录制
- (void) startCapture
{
    @synchronized(self) {
        if (!self.isCapturing) {
            self.recordEncoder = nil;
            self.isPaused = NO;
            self.discont = NO;
            _timeOffset = CMTimeMake(0, 0);
            self.isCapturing = YES;
        }
    }
}

//暂停录制
- (void) pauseCapture
{
    @synchronized(self) {
        if (self.isCapturing) {
            self.isPaused = YES;
            self.discont = YES;
        }
    }
}

//继续录制
- (void) resumeCapture {
    @synchronized(self) {
        if (self.isPaused) {
            self.isPaused = NO;
        }
    }
}

- (void)stopCaptureHandler
{
    @synchronized(self) {
        if (self.isCapturing) {
            NSString* path = self.recordEncoder.path;
            NSURL* url = [NSURL fileURLWithPath:path];
            self.isCapturing = NO;
            dispatch_async(_captureQueue, ^{
                [self.recordEncoder finishWithCompletionHandler:^{
                    self.isCapturing = NO;
                    self.recordEncoder = nil;
                    self.startTime = CMTimeMake(0, 0);
                    self.currentRecordTime = 0;
                    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                        });
                    }
                    
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        NSLog(@"保存成功");
                    }];
                    [self movieToImageHandler];
                }];
            });
        }
    }
}

//停止录制
- (void) stopCaptureHandler:(void (^)(UIImage *movieImage, NSString *filePath))handler
{
    @synchronized(self) {
        if (self.isCapturing) {
            NSString* path = self.recordEncoder.path;
            NSURL* url = [NSURL fileURLWithPath:path];
            self.isCapturing = NO;
            dispatch_async(_captureQueue, ^{
                [self.recordEncoder finishWithCompletionHandler:^{
                    self.isCapturing = NO;
                    self.recordEncoder = nil;
                    self.startTime = CMTimeMake(0, 0);
                    self.currentRecordTime = 0;
                    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                        });
                    }
                    
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        NSLog(@"保存成功");
                    }];
                    [self movieToImageHandler:handler];
                }];
            });
        }
    }
}

- (void)movieToImageHandler
{
    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                NSString *path = [self.videoPath stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"];
                BOOL success = [UIImagePNGRepresentation(thumbImg) writeToFile:path atomically:YES];

                if (success) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishedWithPath:andCoverImagePath:)]) {
                        [self.delegate recordFinishedWithPath:self.videoPath andCoverImagePath:path];
                    }
                }
            });
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
     [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
}

//获取视频第一帧的图片
- (void)movieToImageHandler:(void (^)(UIImage *movieImage, NSString *filePath))handler {
    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(thumbImg, self.videoPath);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
     [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
}

#pragma mark - Take Photo
- (void)takePhoto
{
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                           
                                                           UIImage *image = [UIImage imageWithData:data];

                                                           NSString *path = [MCVideoTools getFilePathWithFileName:@"image" fileType:@"png"];

                                                           BOOL success = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];

                                                           if (success) {
                                                               if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoFinishedWithPath:andImage:)]) {
                                                                   [self.delegate takePhotoFinishedWithPath:path andImage:image];
                                                               }
                                                           }
                                                           
                                                           [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                                               PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:data]];
                                                           } completionHandler:^(BOOL success, NSError * _Nullable error) {
                                                               
                                                           }];
                                                       }];
}

- (void)takePhotoWithComplete:(void (^)(NSString *filePath))complete
{
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                           
                                                           UIImage *image = [UIImage imageWithData:data];
                                                           NSString *path = [MCVideoTools getFilePathWithFileName:@"image" fileType:@"jpeg"];
                                                           BOOL success = [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
                                                           if (success) {
                                                               complete(path);
                                                           }
                                                           
                                                           [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                                               PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:data]];
                                                           } completionHandler:^(BOOL success, NSError * _Nullable error) {
                                                               
                                                           }];
                                                       }];
}

#pragma mark - set、get方法
//捕获视频的会话
- (AVCaptureSession *)recordSession {
    if (_recordSession == nil) {
        _recordSession = [[AVCaptureSession alloc] init];
        _recordSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        //添加后置摄像头的输出
        if ([_recordSession canAddInput:self.backCameraInput]) {
            [_recordSession addInput:self.backCameraInput];
            self.currentCameraInput = self.backCameraInput;
        }
        //添加后置麦克风的输出
        if ([_recordSession canAddInput:self.audioMicInput]) {
            [_recordSession addInput:self.audioMicInput];
        }
        //添加视频输出
        if ([_recordSession canAddOutput:self.videoOutput]) {
            [_recordSession addOutput:self.videoOutput];
            //设置视频的分辨率
            _cx = 480;
            _cy = 640;
        }
        //添加音频输出
        if ([_recordSession canAddOutput:self.audioOutput]) {
            [_recordSession addOutput:self.audioOutput];
        }
        
        if ([_recordSession canAddOutput:self.stillImageOutput]) {
            [_recordSession addOutput:self.stillImageOutput];
        }
        //设置视频录制的方向
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _recordSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败~");
        }
    }
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败~");
        }
    }
    return _frontCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"获取麦克风失败~");
        }
    }
    return _audioMicInput;
}

//视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _videoOutput.videoSettings = setcapSettings;
    }
    return _videoOutput;
}

//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _audioOutput;
}

- (AVCaptureStillImageOutput *)stillImageOutput
{
    if (_stillImageOutput == nil) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
    }
    return _stillImageOutput;
}

//视频连接
- (AVCaptureConnection *)videoConnection {
    _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    return _videoConnection;
}

//音频连接
- (AVCaptureConnection *)audioConnection {
    if (_audioConnection == nil) {
        _audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    }
    return _audioConnection;
}

- (AVCaptureConnection *)imageConnection
{
    if (_imageConnection == nil) {
        _imageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        [_imageConnection setVideoScaleAndCropFactor:1];
    }
    return _imageConnection;
}

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //通过AVCaptureSession初始化
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.recordSession];
        //设置比例为铺满全屏
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}

//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("com.cloud4magic.capture", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

#pragma mark - 视频相关
//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


//切换前后置摄像头
- (void)changeCameraDirection {
    self.isBackCamera = !self.isBackCamera;
    
    [self.recordSession beginConfiguration];
    if (!self.isBackCamera) {
        [self.recordSession removeInput:self.backCameraInput];
        if ([self.recordSession canAddInput:self.frontCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.frontCameraInput];
            self.currentCameraInput = self.frontCameraInput;
        }
    }else {
        [self.recordSession removeInput:self.frontCameraInput];
        if ([self.recordSession canAddInput:self.backCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.backCameraInput];
            self.currentCameraInput = self.backCameraInput;
        }
    }
    [self.recordSession commitConfiguration];
    
    [self resetOutput];
}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//开启闪光灯
- (void)openFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOff) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOn;
        backCamera.flashMode = AVCaptureFlashModeOn;
        [backCamera unlockForConfiguration];
    }
}
//关闭闪光灯
- (void)closeFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOn) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.flashMode = AVCaptureTorchModeOff;
        [backCamera unlockForConfiguration];
    }
}

#pragma mark - 写入数据
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    BOOL isVideo = YES;
    @synchronized(self) {
        if (!self.isCapturing  || self.isPaused) {
            return;
        }
        if (captureOutput != self.videoOutput) {
            isVideo = NO;
        }
        //初始化编码器，当有音频和视频参数时创建编码器
        if ((self.recordEncoder == nil) && !isVideo) {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            [self setAudioFormat:fmt];
            self.videoPath = [MCVideoTools getFilePathWithFileName:@"video" fileType:@"mp4"];
            self.recordEncoder = [MCRecordEncoder encoderForPath:self.videoPath Height:_cy width:_cx channels:_channels samples:_samplerate transform:[self transformFromCurrentVideoOrientationToOrientation:AVCaptureVideoOrientationPortrait]];
        }
        //判断是否中断录制过
        if (self.discont) {
            if (isVideo) {
                return;
            }
            self.discont = NO;
            // 计算暂停的时间
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime last = isVideo ? _lastVideo : _lastAudio;
            if (last.flags & kCMTimeFlags_Valid) {
                if (_timeOffset.flags & kCMTimeFlags_Valid) {
                    pts = CMTimeSubtract(pts, _timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                if (_timeOffset.value == 0) {
                    _timeOffset = offset;
                }else {
                    _timeOffset = CMTimeAdd(_timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        // 增加sampleBuffer的引用计时,这样我们可以释放这个或修改这个数据，防止在修改时被释放
        CFRetain(sampleBuffer);
        if (_timeOffset.value > 0) {
            CFRelease(sampleBuffer);
            //根据得到的timeOffset调整
            sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
        }
        // 记录暂停上一次录制的时间
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        if (dur.value > 0) {
            pts = CMTimeAdd(pts, dur);
        }
        if (isVideo) {
            _lastVideo = pts;
        }else {
            _lastAudio = pts;
        }
    }
    CMTime dur = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (self.startTime.value == 0) {
        self.startTime = dur;
    }
    CMTime sub = CMTimeSubtract(dur, self.startTime);
    self.currentRecordTime = CMTimeGetSeconds(sub);
    if (self.currentRecordTime > self.maxRecordTime) {
        //        if (self.currentRecordTime - self.maxRecordTime < 0.1) {
        //            if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
        //                });
        //            }
        //        }
        [self stopCaptureHandler];
        
        //        [self stopCaptureHandler:^(UIImage *movieImage, NSString *filePath) {
        //
        //        }];
        
        return;
    }
    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
        });
    }
    // 进行数据编码
    [self.recordEncoder encodeFrame:sampleBuffer isVideo:isVideo];
    CFRelease(sampleBuffer);
}

#pragma mark - Private
- (void)resetOutput
{
    [self.recordSession beginConfiguration];
    [self.recordSession removeOutput:self.videoOutput];
    [self.recordSession removeOutput:self.stillImageOutput];
    self.videoOutput = nil;
    self.stillImageOutput = nil;
    
    if ([self.recordSession canAddOutput:self.videoOutput]) {
        [self.recordSession addOutput:self.videoOutput];
    }
    
    if ([self.recordSession canAddOutput:self.stillImageOutput]) {
        [self.recordSession addOutput:self.stillImageOutput];
    }
    [self.recordSession commitConfiguration];
    
    [self startVideoRunning];
}

// set Audio Format
- (void)setAudioFormat:(CMFormatDescriptionRef)fmt {
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    _samplerate = asbd->mSampleRate;
    _channels = asbd->mChannelsPerFrame;
}

//adjust Media Time
- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

// 旋转视频方向
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.motionManager.videoOrientation];
    
    CGFloat angleOffset;
    if (self.currentCameraInput.device.position == AVCaptureDevicePositionBack) {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    }
    else{
        //        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat angle = 0.0;
    switch (orientation)
    {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

// 调整设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

#pragma mark - 切换动画
- (void)changeCameraAnimation {
    CATransition *changeAnimation = [CATransition animation];
    changeAnimation.delegate = self;
    changeAnimation.duration = 0.45;
    changeAnimation.type = @"oglFlip";
    changeAnimation.subtype = kCATransitionFromRight;
    changeAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.previewLayer addAnimation:changeAnimation forKey:@"changeAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim {
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
}

#pragma -mark 将mov文件转为MP4文件
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage, NSString *filePath))handler {
    AVAsset *video = [AVAsset assetWithURL:mediaURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPreset1280x720];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    self.videoPath = [MCVideoTools getFilePathWithFileName:@"video" fileType:@"mp4"];
    exportSession.outputURL = [NSURL fileURLWithPath:self.videoPath];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        [self movieToImageHandler:handler];
    }];
}
@end
