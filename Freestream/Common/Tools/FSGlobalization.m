//
//  FSGlobalization.m
//  Freestream
//
//  Created by Frank Li on 2017/12/11.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSGlobalization.h"

#define FS_LANGUE_TABLE             @"Localizable"

@implementation FSGlobalization

static NSBundle *bundle = nil;

NSString *const LanguageCodeIdIndentifier = @"LanguageCodeIdIndentifier";

+ (void)initialize {
    NSString *current = @"zh-Hans";
    [self setLanguage:current];
}

+ (void)setLanguage:(NSString *)language {
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    if (path == nil) {
        path = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
    }
    bundle = [NSBundle bundleWithPath:path];
}

+ (NSString *)currentLanguageCode {
    NSString *userSelectedLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageCodeIdIndentifier];
    if (userSelectedLanguage) {
        // Store selected language in local
        
        return userSelectedLanguage;
    }
    
    //    NSString *systemLanguage = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString * systemLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ( [systemLanguage hasPrefix:@"zh"]) {
        systemLanguage = @"zh-Hans";
    } else {
        // Update selected language in local
        systemLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    }
    return systemLanguage;
}

+ (void)userSelectedLanguage:(NSString *)selectedLanguage {
    // Store the data
    // Store selected language in local
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedLanguage forKey:LanguageCodeIdIndentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Set global language
    [FSGlobalization setLanguage:selectedLanguage];
}

+ (NSString *)get:(NSString *)key alter:(NSString *)alternate {
    NSString *str = [bundle localizedStringForKey:key value:alternate table:FS_LANGUE_TABLE];
    return str;
}

@end
