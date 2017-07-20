//
//  NSString+Extention.m
//  presentationLiveDemo
//
//  Created by tc on 7/20/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "NSString+Extention.h"

@implementation NSString (Extention)
-(BOOL)IsChinese
{
    for(int i=0; i < [self length]; i++)
    {
        int a = [self characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}
@end
