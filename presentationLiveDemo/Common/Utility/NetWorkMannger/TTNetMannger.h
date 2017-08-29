//
//  TTNetMannger.h
//  twitchtest
//
//  Created by tc on 6/26/17.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^completionHandler)(NSDictionary * dic);

@interface TTNetMannger : NSObject

+ (void)getRequestUrl:(NSString *)urlString param:(NSDictionary *)paramDic headerDic:(NSDictionary *)headerDic completionHandler:(completionHandler )completionHandler;

+ (void)postWithUrl:(NSString *)urlString param:(NSDictionary *)parameDic headerDic:(NSDictionary *)headerDic complete:(completionHandler )comletionHandler;
@end
