//
//  MCRecordManager.h
//  Patrol
//
//  Created by hades on 2017/5/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

@protocol MCRecordEngineDelegate <NSObject>
@optional
- (void)recordProgress:(CGFloat)progress;

- (void)recordFinishedWithPath:(NSString *)path andCoverImage:(UIImage *)image;

- (void)recordFinishedWithPath:(NSString *)path andCoverImagePath:(NSString *)coverPath;

- (void)takePhotoFinishedWithPath:(NSString *)path andImage:(UIImage *)image;
@end

@interface MCRecordManager : NSObject
@property (atomic, assign, readonly) BOOL isCapturing;//正在录制
@property (atomic, assign, readonly) BOOL isPaused;//是否暂停
@property (atomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (atomic, assign) BOOL isBackCamera;
@property (atomic, assign) CGFloat maxRecordTime;//录制最长时间
@property (nonatomic, weak) id <MCRecordEngineDelegate>delegate;
@property (atomic, strong) NSString *videoPath;//视频路径


- (AVCaptureVideoPreviewLayer *)previewLayer;

/************ Video Handle ************/
- (void)startVideoRunning;

- (void)stopVideoRunning;


- (void)takePhoto;

/**
 take photo
 
 @param complete block return image path
 */
- (void)takePhotoWithComplete:(void (^)(NSString *filePath))complete;

//open flashlight
- (void)openFlashLight;

//close flashlight
- (void)closeFlashLight;

//change Camera direction
//- (void)changeCameraInputDeviceisFront:(BOOL)isFront;changeCameraDirection
- (void)changeCameraDirection;

/************ Video Record ************/
//start record
- (void) startCapture;

//pause record
- (void) pauseCapture;

//resume record
- (void) resumeCapture;

- (void)stopCaptureHandler;

/**
 stop record
 
 @param handler  return block with Video Cover return
 */
- (void) stopCaptureHandler:(void (^)(UIImage *movieImage, NSString *filePath))handler; 

/**
 change Video type to MP4
 
 @param mediaURL origin video path
 @param handler block with Video Cover return
 */
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage, NSString *filePath))handler;
@end
