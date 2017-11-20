//
//  FSFaceBookAPIRESTfulService.m
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSFaceBookAPIRESTfulService.h"
#import "FSFaceBookAPIURL.h"

static FSFaceBookAPIRESTfulService * _sharedSingleton = nil;
static BOOL isFirstAccess = YES;

@implementation FSFaceBookAPIRESTfulService
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
+ (instancetype)sharedSingleton
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
    return [self sharedSingleton];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedSingleton];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedSingleton];
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

- (void)requestVerificationUriAndUserCodeRestultBlock:(void (^)(ServiceResultInfo *))completions {

//    NSMutableDictionary *param = @{}.mutableCopy;
//    [param setValue:FSfacebook_Access_token_value forKey:@"access_token"];
//    [param setValue:FSfacebook_Scope forKey:@"scope"];
//    [FSNetWorkManager postWithUrl:URL_POST_Device_Login param:param headerDic:nil complete:^(NSDictionary *dic) {
////        code = a8d078391bd3d72fb8011b94a5c3371f;
////        "expires_in" = 420;
////        interval = 5;
////        "user_code" = 34QRC3JH;
////        "verification_uri" = "https://www.facebook.com/device";
//        NSLog(@"----------------%@",dic);
//    }];
//
}

@end
