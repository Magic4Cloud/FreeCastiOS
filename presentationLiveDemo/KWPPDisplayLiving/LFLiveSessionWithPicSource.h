//
//  LFLiveSessionWithPicSource.h
//  presentationLiveDemo
//
//  Created by zyh_scut on 16/8/23.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#ifndef LFLiveSession_picSource_h
#define LFLiveSession_picSource_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LFLiveStreamInfo.h"
#import "LFAudioFrame.h"
#import "LFVideoFrame.h"
#import "LFLiveAudioConfiguration.h"
#import "LFLiveVideoConfiguration.h"
#import "LFLiveDebug.h"

typedef NS_ENUM(NSInteger,LivingDataSouceType){
    //仅视频直播
    CameraOnly = 1 ,
    //仅图片直播
    PictureOnly =2,
    //图片视频一起
    CameraAndPicture =3,
    //暂停
    PauseLiving = 4
};

/**
 * 对原版本的LFLiveSession 进行改版
 */
@class LFLiveSessionWithPicSource;
@protocol LFLiveSessionWithPicSourceDelegate <NSObject>
@optional
- (void)liveSession:(nullable LFLiveSessionWithPicSource *)session liveStateDidChange:(LFLiveState)state;
- (void)liveSession:(nullable LFLiveSessionWithPicSource *)session debugInfo:(nullable LFLiveDebug*)debugInfo;
- (void)liveSession:(nullable LFLiveSessionWithPicSource*)session errorCode:(LFLiveSocketErrorCode)errorCode;

- (void)livingDataReturnByImageBufferRef:(nonnull CVPixelBufferRef)returnImageBuffer;
@end


@class LFLiveStreamInfo;
@interface LFLiveSessionWithPicSource : NSObject
//代理
@property (nullable,nonatomic, assign) id<LFLiveSessionWithPicSourceDelegate> delegate;

//是否正在运行
@property (nonatomic, assign) BOOL running;

@property (nonatomic, assign) BOOL isRAK;

//预览窗体
@property (nonatomic, strong,null_resettable) UIView *preView;

//摄像头位置，前 or 后
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

//是否美颜
@property (nonatomic, assign) BOOL beautyFace;

// 美颜程度
@property (nonatomic, assign) CGFloat beautyLevel;

//亮度
@property (nonatomic, assign) CGFloat brightLevel;

// 缩放比例 取值1.0 ~ 3.0
@property (nonatomic, assign) CGFloat zoomScale;

@property (nonatomic, assign) BOOL torch;

//成像方向，照镜子模式 还是 正常模式
@property (nonatomic, assign) BOOL mirror;

@property (nonatomic,assign) BOOL muted;

//流信息
@property (nullable,nonatomic, strong,readonly) LFLiveStreamInfo * streamInfo;

//直播状态
@property (nonatomic,assign,readonly) LFLiveState state;
@property (nonatomic,assign) BOOL showDebugInfo;

//重连间隔
@property (nonatomic,assign) NSUInteger reconnectInterval;

//重连次数
@property (nonatomic,assign) NSUInteger reconnectCount;


//直播的PPT图片: picTag 用于标记是否与上一次图片一样，如一样，直接使用上一次缓存；
@property (nonatomic, strong, nullable)UIImage *currentSlideImage;
@property (nonatomic, assign)NSInteger picTag;

//直播数据源类型
@property (nonatomic, assign)LivingDataSouceType dataSoureType;


- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

//构造函数
- (nullable instancetype)initWithAudioConfiguration:(nullable LFLiveAudioConfiguration*)audioConfiguration videoConfiguration:(nullable LFLiveVideoConfiguration*)videoConfiguration NS_DESIGNATED_INITIALIZER;

//开始直播
- (void)startLive:(nonnull LFLiveStreamInfo*)streamInfo;

- (void)pauseOrResumeLiving:(BOOL)isPausing;

//结束直播
- (void)stopLive;
- (void)upload_h264:(int)size :(Byte*)data;
- (void)upload_imageRef:(CGImageRef)imageRef;
- (void)upload_audio:(AudioBufferList)inBufferList;
- (void)upload_PauseImg;
+ (id) sharedInstance;
+ (void) setSharedInstance:(LFLiveSessionWithPicSource *) session;
@end

#endif /* LFLiveSession_picSource_h */
