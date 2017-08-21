//
//  MCVideoTools.h
//  Patrol
//
//  Created by hades on 2017/5/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCVideoTools : NSObject
+ (NSString *)getFilePathWithFileName:(NSString *)name fileType:(NSString *)fileType;

+ (BOOL)removeAllFile;
@end
