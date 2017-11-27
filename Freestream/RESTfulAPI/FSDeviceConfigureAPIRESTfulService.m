//
//  FSDeviceConfigureAPIRESTfulService.m
//  Freestream
//
//  Created by Frank Li on 2017/11/23.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSDeviceConfigureAPIRESTfulService.h"

@implementation FSDeviceConfigureAPIRESTfulService

+ (NSString *)getDeviceConfiguerWithConfigureIp:(NSString *)ip configurePort:(NSInteger)port command:(NSString *)command {
    NSString * urlString = [NSString stringWithFormat:@"http://%@:%ld/server.command?type=h264&pipe=0&command=%@",ip,port,command];
    return urlString;
}

+ (NSString *)getDeviceConfiguerResolutionWithConfigureIp:(NSString *)ip configurePort:(NSInteger)port {
    return [self getDeviceConfiguerWithConfigureIp:ip configurePort:port command:FSDevice_Get_Resolution];
}

+ (NSString *)getDeviceConfiguerQualityWithConfigureIp:(NSString *)ip configurePort:(NSInteger)port {
    return [self getDeviceConfiguerWithConfigureIp:ip configurePort:port command:FSDevice_Get_Quality];
}

+ (NSString *)getDeviceConfiguerFPSWithConfigureIp:(NSString *)ip configurePort:(NSInteger)port {
    return [self getDeviceConfiguerWithConfigureIp:ip configurePort:port command:FSDevice_Get_FPS];
}

@end
