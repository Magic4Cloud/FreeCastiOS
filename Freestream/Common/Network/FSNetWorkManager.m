//
//  FSNetWorkManager.m
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSNetWorkManager.h"

@implementation FSNetWorkManager

+ (void)getRequestUrl:(NSString *)urlString param:(NSDictionary *)paramDic headerDic:(NSDictionary *)headerDic completionHandler:(completionHandler )completionHandler
{
    
    NSMutableString * url = [NSMutableString stringWithString:urlString];
    [url appendString:@"?"];
    [paramDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString * keyString = [key description];
        NSString * valueString = [obj description];
        [url appendFormat:@"%@=%@&",keyString,valueString];
    }];
    [url deleteCharactersInRange:NSMakeRange(url.length-1, 1)];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [headerDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * keyString = [key description];
        NSString * objString = [obj description];
        [request addValue:objString forHTTPHeaderField:keyString];
    }];
    
    
    
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError * jsonError;
        if (!data) {
            completionHandler(nil);
            return ;
        }
        NSDictionary * responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        
        NSLog(@"get;data:%@\nresponseData:%@\nerror:%@",data,responseData,jsonError);
        completionHandler(responseData);
    }];
    NSLog(@"get request :%@",request);
    [task resume];
    
}

+ (void)postWithUrl:(NSString *)urlString param:(NSDictionary *)parameDic headerDic:(NSDictionary *)headerDic complete:(completionHandler )completionHandler
{
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    
    [headerDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * keyString = [key description];
        NSString * objString = [obj description];
        [request addValue:objString forHTTPHeaderField:keyString];
    }];
    
    NSMutableString * body = [NSMutableString string];
    if (parameDic) {
        [parameDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString * keyString = [key description];
            NSString * valueString = [obj description];
            
            
            
            [body appendFormat:@"%@=%@&",keyString,valueString];
        }];
        [body deleteCharactersInRange:NSMakeRange(body.length-1, 1)];
    }
    
    
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            completionHandler(nil);
            return ;
        }
        
        NSError *jsonError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        NSLog(@"post\nresponseData:%@\nerror:%@",dict,jsonError);
        completionHandler(dict);
        
    }];
    
    NSLog(@"post request :%@",request);
    [sessionDataTask resume];
    
}
@end
