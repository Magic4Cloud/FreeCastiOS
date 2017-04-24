//
//  CommanParameters.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2017/3/24.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "CommanParameters.h"

@implementation CommanParameters

+ (void)Save_String:(NSString *)value :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

+ (NSString *)Get_String:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

@end
