//
//  UIColor+App.m
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "UIColor+App.h"
#import "CommonAppHeader.h"
@implementation UIColor (App)

+ (UIColor *)FSMainTextNormalColor {
    return CORE_RGBCOLOR(0, 179, 227);
}

+ (UIColor *)FSMainTextHighlightedColor {
    return CORE_RGBCOLOR(255, 255, 255);
}

+ (CGColorRef)FSLeftBgColor1 {
    return CORE_RGBACOLOR(52, 52, 52, 1).CGColor;
}

+ (CGColorRef)FSLeftBgColor2 {
    return CORE_RGBACOLOR(29, 27, 27, 1).CGColor;
}

+ (UIColor *)FSPlatformButtonSelectedBackgroundColor {
    return CORE_RGBCOLOR(0, 178, 225);
}

+ (UIColor *)FSExpireLabelNormalColor {
    return CORE_RGBCOLOR(102, 255, 225);
}

+ (UIColor *)FSExpireLabelAlertColor {
    return [UIColor redColor];
}

+ (UIColor *)FSAuthenticationCodeLabelNormalColor {
   return CORE_RGBCOLOR(0, 122, 255);
}

+ (UIColor *)FSAuthenticationCodeLabelAlertColor {
    return [UIColor redColor];
}

@end
