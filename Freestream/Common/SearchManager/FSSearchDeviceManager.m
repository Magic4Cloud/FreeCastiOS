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
    
    if (_isSearching) {
        return;
    }
    NSLog(@"--------开始搜索--------");
    _completionBlock = completionHandle;
    _isSearching = YES;
    NSLog(@"__________searchDuration=%lf____",duration);
//    WEAK(self);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        __block Scanner *resultInfo = [self.scanner ScanDeviceWithTime:duration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _isSearching = NO;
            if (_completionBlock) {
                _completionBlock(resultInfo);
            }
        });
    });
}

- (void)stopSearchDevice {
//    _isSearching = NO;
//    _completionBlock = nil;
}

@end
