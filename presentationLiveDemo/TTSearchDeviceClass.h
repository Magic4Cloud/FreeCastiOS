//
//  TTSearchDeviceClass.h
//  presentationLiveDemo
//
//  Created by tc on 7/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "Rak_Lx52x_Device_Control.h"
#import <Foundation/Foundation.h>

typedef void(^searchResultBlock)(Lx52x_Device_Info * resultinfo);

/**
 搜索设备 工具类
 */
@interface TTSearchDeviceClass : NSObject

+ (instancetype)shareInstance;

- (void)searDeviceWithSecond:(NSTimeInterval )seconds CompletionHandler:(searchResultBlock )completionHandler;

@end
