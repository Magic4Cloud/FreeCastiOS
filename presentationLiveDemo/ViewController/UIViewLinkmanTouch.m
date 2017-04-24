//
//  UIViewLinkmanTouch.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/14.
//  Copyright © 2016年 rak. All rights reserved.
//

//
//  UIViewLinkmanTouch.m
//
#import "UIViewLinkmanTouch.h"
@implementation UIViewLinkmanTouch
UIColor *_initColor;
UIColor *_toucheColor;
//[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0]
- (void)setToucheColor:(UIColor *)color{
    _toucheColor=color;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _initColor=self.backgroundColor;
    [self setBackgroundColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0]];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setBackgroundColor:_initColor];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self setBackgroundColor:_initColor];
}
@end
