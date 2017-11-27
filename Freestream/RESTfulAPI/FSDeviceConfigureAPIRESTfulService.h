//
//  FSDeviceConfigureAPIRESTfulService.h
//  Freestream
//
//  Created by Frank Li on 2017/11/23.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FSDevice_Get_Resolution       @"get_resol"
#define FSDevice_Get_Quality          @"get_enc_quality"
#define FSDevice_Get_FPS              @"get_max_fps"

@interface FSDeviceConfigureAPIRESTfulService : NSObject

//** 传入获取到的设备Ip和端口号,获取resolutionURL*/
+ (NSString *)getDeviceConfiguerResolutionWithConfigureIp:(NSString *)ip configurePort:(NSInteger)port;

//** 传入获取到的设备Ip和端口号,获取qualityURL*/
+ (NSString *)getDeviceConfiguerQualityWithConfigureIp:(NSString *)ip configurePort:(NSInteger)port;

//** 传入获取到的设备Ip和端口号,获取FPSURL*/
+ (NSString *)getDeviceConfiguerFPSWithConfigureIp:(NSString *)ip configurePort:(NSInteger)port;

@end
