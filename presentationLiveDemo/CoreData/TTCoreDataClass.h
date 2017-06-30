//
//  TTCoreDataClass.h
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlatformModel+CoreDataProperties.h"

/**
 数据库操作类
 */
@interface TTCoreDataClass : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;
- (long long)getDbFileSize;

/**
 本地存储的所有平台

 @return 数组
 */
- (NSArray *)localAllPlatforms;

/**
 存储数据  插入或者更新

 @param name 平台名称  facebook。。
 @param rtmp 推流地址
 @param streamKey 推流key
 @param customString 自定义string
 @param enable 是否有效
 @param isSelected 该平台是否被用户选中
 @return
 */
- (BOOL)updatePlatformWithName:(NSString *)name rtmp:(NSString * )rtmp streamKey:(NSString *)streamKey customString:(NSString *)customString enabel:(BOOL)enable selected:(BOOL)isSelected;

/**
 清除所有数据
 */
- (void)cleanUpAllData;
+ (instancetype)shareInstance;
@end
