//
//  FSSearchDeviceManager.m
//  Freestream
//
//  Created by Frank Li on 2017/11/20.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSSearchDeviceManager.h"
#import "CommonAppHeader.h"
static FSSearchDeviceManager * _sharedSingleton = nil;
static BOOL isFirstAccess = YES;

@interface FSSearchDeviceManager()

@property (nonatomic, strong) Scanner *scanner;
@property (nonatomic, copy)   searchResultBlock completionBlock;

@end

@implementation FSSearchDeviceManager
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self shareInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self shareInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self shareInstance];
}

- (id)copy
{
    return [[[self class] alloc] init];
}

- (id)mutableCopy
{
    return [[[self class] alloc] init];
}

- (id)init
{
    if(_sharedSingleton){
        return _sharedSingleton;
    }
    if (isFirstAccess) {
        NSAssert(NO, @"Cannot create instance of Singleton");
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    return self;
}
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

- (Scanner *)scanner {
    if (!_scanner) {
        _scanner = [[Scanner alloc] init];
    }
    return _scanner;
}

- (void)beginSearchDeviceDuration:(NSTimeInterval)duration completionHandle:(searchResultBlock)completionHandle {
    NSLog(@"想要搜索-----————————————-----");
    if (self.isSearching) {
        return;
    }
    NSLog(@"--------_____开始搜索--------");
    self.completionBlock = completionHandle;
    self.isSearching = YES;
    NSLog(@"--------searchDuration=%lf",duration);
    WEAK(self);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        __block Scanner *resultInfo = [self.scanner ScanDeviceWithTime:duration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"----------------结束搜索---+++");
            weakself.isSearching = NO;
            
            if (weakself.completionBlock) {
                weakself.completionBlock(resultInfo);
            }
        });
    });
}

- (void)stopSearchDevice {
    
}

@end
