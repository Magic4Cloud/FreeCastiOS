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
//
//- (void)layoutIfNeeded {
//    [super layoutIfNeeded];
//    self.clipsToBounds = YES;
//    self.layer.masksToBounds = YES;
//}
//
//- (void)layoutSubviews{
//    [super layoutSubviews];
//    self.clipsToBounds = YES;
//    self.layer.masksToBounds = YES;
//}

- (CGRect)textRectForBounds:(CGRect)bounds {
    // Not show truncation text for secureTextEntry,like ****...
    
    [super textRectForBounds:bounds];
    CGRect rect = bounds;
    
    if (self.text.length > 0) {
        if (self.secureTextEntry && ![self isFirstResponder]) {
            
            CGSize textSize = [self.text sizeWithFont:self.font andMaxSize:CGSizeMake(CGFLOAT_MAX,CGRectGetHeight(rect))];
//            [self.text sizeOfFont:self.font andWidth:CGFLOAT_MAX];
//            rect.size.width = MAX(textSize.width, bounds.size.width);
            rect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect),600, CGRectGetHeight(bounds));
            NSLog(@"rect.size.width = %lf----------------textsize.width = %lf,bounds.size.width = %lf",rect.size.width,textSize.width,bounds.size.width);
            return rect;
        }
    }
    return rect;
}


@end
