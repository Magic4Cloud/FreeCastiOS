//
//  NSString+Size.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/16.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)
+ (CGSize)sizeWithString:(NSString*)str andFont:(UIFont*)font andMaxSize:(CGSize)size;
- (CGSize)sizeWithFont:(UIFont*)font   andMaxSize:(CGSize)size;
@end
