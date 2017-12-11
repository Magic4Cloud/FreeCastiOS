//
//  FSGlobalization.h
//  Freestream
//
//  Created by Frank Li on 2017/12/11.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

//带参数字符串的国际化
//使用方法举例
//"Code Expired Interval Message" = "The code will expire after %ld seconds";
//"Code Expired Interval Message" = "设备用户码将会在 %ld 秒后过期";
//[NSString stringWithFormat:FSLocalizedString(@"Code Expired Interval Message"),_totalCount];

#define FSLocalizedString(key)        [FSGlobalization get:key alter:nil]

@interface FSGlobalization : NSObject

+ (void)initialize;

+ (void)setLanguage:(NSString *)language;

+ (NSString*)currentLanguageCode;

+ (void)userSelectedLanguage:(NSString *)selectedLanguage;

+ (NSString *)get:(NSString *)key alter:(NSString *)alternate;

@end
