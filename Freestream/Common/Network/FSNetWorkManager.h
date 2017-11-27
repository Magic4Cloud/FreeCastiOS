//
//  FSNetWorkManager.h
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^completionHandler)(NSDictionary * _Nullable dic);

@interface FSNetWorkManager : NSObject

+ (void)getRequestUrl:(NSString *_Nonnull)urlString param:(NSDictionary *_Nullable)paramDic headerDic:(NSDictionary *_Nullable)headerDic completionHandler:(void (^ __nonnull)(NSDictionary * _Nullable dic))completionHandler;

+ (void)postWithUrl:(nonnull NSString *)urlString param:(nullable NSDictionary *)parameDic headerDic:(nullable NSDictionary *)headerDic completionHandler:(void (^ __nonnull)(NSDictionary * _Nullable dic))completionHandler;

@end
