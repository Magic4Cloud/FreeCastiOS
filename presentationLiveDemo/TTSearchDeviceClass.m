//
//  TTSearchDeviceClass.m
//  presentationLiveDemo
//
//  Created by tc on 7/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTSearchDeviceClass.h"

static TTSearchDeviceClass * _instance;

@interface TTSearchDeviceClass()

@property (nonatomic, strong) Rak_Lx52x_Device_Control * searchControl;

@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, copy) searchResultBlock completionBlock;
@end

@implementation TTSearchDeviceClass

- (void)searDeviceWithSecond:(NSTimeInterval )seconds CompletionHandler:(searchResultBlock )completionHandler
{
    _completionBlock = completionHandler;
    NSLog(@"想要搜索设备");
    if (_isSearching) {
        return;
    }
    NSLog(@"开始搜索设备");
    _isSearching = YES;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        __block Lx52x_Device_Info * resultInfo = [self.searchControl ScanDeviceWithTime:seconds];
        dispatch_async(dispatch_get_main_queue(), ^{
            _isSearching = NO;
            NSLog(@"结束搜索设备");
            if (_completionBlock) {
                _completionBlock(resultInfo);
            }
        });
    });
   
}

#pragma mark - getter
- (Rak_Lx52x_Device_Control *)searchControl
{
    if (!_searchControl) {
        _searchControl = [[Rak_Lx52x_Device_Control alloc] init];
    }
    return _searchControl;
}

#pragma mark - 单例
+ (instancetype)shareInstance
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [TTSearchDeviceClass shareInstance];
}

- (instancetype)copy
{
    return [TTSearchDeviceClass shareInstance];
}

@end
