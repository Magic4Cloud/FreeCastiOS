//
//  CommanParameters.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2017/3/24.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAIN_BG_COLOR [UIColor colorWithRed:(11 / 255.0f) green:(14 / 255.0f) blue:(1 / 255.0f) alpha:1.0]
#define MAIN_COLOR [UIColor colorWithRed:(0 / 255.0f) green:(179 / 255.0f) blue:(227 / 255.0f) alpha:1.0]
#define MAIN_COLOR_T [UIColor colorWithRed:(0 / 255.0f) green:(179 / 255.0f) blue:(227 / 255.0f) alpha:0.6]
#define MAIN_TITLE_COLOR [UIColor colorWithRed:(92 / 255.0f) green:(108 / 255.0f) blue:(159 / 255.0f) alpha:1.0]

#define MENU_BG0_COLOR [UIColor colorWithRed:(29 / 255.0f) green:(27 / 255.0f) blue:(27 / 255.0f) alpha:1.0]
#define MENU_BG1_COLOR [UIColor colorWithRed:(52 / 255.0f) green:(52 / 255.0f) blue:(52 / 255.0f) alpha:1.0]


#define totalHeight 667  //UI设计时总高度，通过这个值和屏幕高度的比例，设置每个控件的高度
#define totalWeight 375   //UI设计时总宽度，通过这个值和屏幕宽度的比例，设置每个控件的宽度
#define viewH [UIScreen mainScreen].bounds.size.height  //屏幕高度
#define viewW [UIScreen mainScreen].bounds.size.width   //屏幕宽度

@interface CommanParameters : NSObject

+ (void)Save_String:(NSString *)value :(NSString *)key;
+ (NSString *)Get_String:(NSString *)key;
@end
