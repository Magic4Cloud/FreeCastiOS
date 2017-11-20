//
//  FSNetWorkManager.h
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^completionHandler)(NSDictionary *dic);
@interface FSNetWorkManager : NSObject

+ (void)getRequestUrl:(NSString *)urlString param:(NSDictionary *)paramDic headerDic:(NSDictionary *)headerDic completionHandler:(completionHandler )completionHandler;

+ (void)postWithUrl:(NSString *)urlString param:(NSDictionary *)parameDic headerDic:(NSDictionary *)headerDic complete:(completionHandler )completionHandler;

@end
