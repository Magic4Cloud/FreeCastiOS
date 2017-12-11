//
//  FSFaceBookAPIRESTfulService.m
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSFaceBookAPIRESTfulService.h"
#import "FSFaceBookAPIURL.h"
#import "FSFacebookStreamModel.h"
#import "CommonAppHeader.h"


static NSString *fb_app_id                  = @"115586109153322";
static NSString *fb_app_secret              = @"fd18fde29cdc12290fe08ad0672b7a0a";
static NSString *fb_client_token            = @"766ef0f7747b190ca998851d5e277bce";

static NSString *key_access_token           = @"access_token";
static NSString *key_code                   = @"code";
static NSString *key_scope                  = @"scope";
static NSString *key_user_code              = @"user_code";
static NSString *key_stream_url             = @"stream_url";
static NSString *key_verification_uri       = @"verification_uri";


static NSString *requestVerificationDataUrl = @"https://graph.facebook.com/device/login";
static NSString *requestAccessTokenUrl      = @"https://graph.facebook.com/device/login_status";

//请求验证码时候 用这个作为access_token
#define value_access_token [NSString stringWithFormat:@"%@|%@",fb_app_id,fb_client_token]

//请求的直播权限 包含以下五点
#define value_scope @"public_profile,publish_actions,manage_pages,publish_pages,user_managed_groups,user_events"

@interface FSFaceBookAPIRESTfulService()

@end

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

//        code = a8d078391bd3d72fb8011b94a5c3371f;
//        "expires_in" = 420;
//        interval = 5;
//        "user_code" = 34QRC3JH;
//        "verification_uri" = "https://www.facebook.com/device";
- (void)requestVerificationUriAndUserCodeRestultBlock:(void (^)(FSFacebookVerificationDataModel *))completions {

    NSMutableDictionary *param = @{}.mutableCopy;
    [param setValue:value_access_token  forKey:key_access_token];
    [param setValue:value_scope         forKey:key_scope];
    
    [FSNetWorkManager postWithUrl:requestVerificationDataUrl param:param headerDic:nil completionHandler:^(NSDictionary * _Nullable dic) {
        
        if (dic) {
           FSFacebookVerificationDataModel *model = (FSFacebookVerificationDataModel *)[FSFacebookVerificationDataModel yy_modelWithDictionary:dic];
            completions(model);
        }else {
            completions(nil);
        }
    }];

}

@end
