//
//  MCVideoTools.m
//  Patrol
//
//  Created by hades on 2017/5/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "MCVideoTools.h"

@implementation MCVideoTools
/**
 create video cache path
 
 @return video path
 */

+ (NSString *)getCachesPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}

+ (NSString *)createVideoCachePath
{
    BOOL isDir = NO;
    NSString *cachesPath = [self getCachesPath];
    NSString *videoCache = [cachesPath stringByAppendingPathComponent:@"Videos"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    };
    return videoCache;
}

+ (NSString *)getFilePathWithFileName:(NSString *)name fileType:(NSString *)fileType
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@", name,timeStr,fileType];
    
    return [[self createVideoCachePath] stringByAppendingPathComponent:fileName];
}

+ (BOOL)removeAllFile
{
    BOOL success = NO;
    NSString *cachesDir = [self createVideoCachePath];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachesDir]) {
        success = [[NSFileManager defaultManager] removeItemAtPath:cachesDir error:&error];
    }
    return success;
}

@end
