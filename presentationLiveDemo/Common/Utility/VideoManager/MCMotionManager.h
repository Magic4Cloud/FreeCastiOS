//
//  MCMotionManager.h
//  Patrol
//
//  Created by hades on 2017/5/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface MCMotionManager : NSObject
@property(nonatomic, assign) UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
@end
