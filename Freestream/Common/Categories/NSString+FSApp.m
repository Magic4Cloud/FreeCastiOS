//
//  NSString+FSApp.m
//  Freestream
//
//  Created by Frank Li on 2017/12/6.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "NSString+FSApp.h"

@implementation NSString (FSApp)
- (BOOL)hasContainsChineseCharacter {
    
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
