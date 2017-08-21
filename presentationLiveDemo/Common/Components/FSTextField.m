//
//  FSTextField.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/16.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSTextField.h"
#import "NSString+Size.h"
@implementation FSTextField

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    // Not show truncation text for secureTextEntry,like ****...
    if (self.text.length > 0) {
        if (self.secureTextEntry && ![self isFirstResponder]) {
            CGRect rect = bounds;
            CGSize textSize = [self.text sizeWithFont:self.font andMaxSize:CGSizeMake(CGFLOAT_MAX,CGRectGetHeight(rect))];
//            [self.text sizeOfFont:self.font andWidth:CGFLOAT_MAX];
            
            rect.size.width = MAX(textSize.width, bounds.size.width);
            return rect;
        }
    }
    return [super textRectForBounds:bounds];
}

@end
