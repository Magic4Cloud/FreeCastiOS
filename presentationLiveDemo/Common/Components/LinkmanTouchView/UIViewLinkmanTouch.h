//
//  UIViewLinkmanTouch.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/14.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface  UIViewLinkmanTouch : UIView
- (void)setToucheColor:(UIColor *)color;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end
