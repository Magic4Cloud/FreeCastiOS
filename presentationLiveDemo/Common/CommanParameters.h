//
//  CommanParameters.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2017/3/24.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define diff_top  20
#define diff_bottom  20
#define diff_x  10
#define title_size  36
#define main_help_size  22
#define add_title_size  22
#define add_text_size  18
#define add_bg  242
#define diff_help_x 5
#define list_row_height 50
#define list_group_height 44

#define STREAM_URL_KEY @"STREAM_URL_KEY"
#define PAUSE_SCREEN_PHOTO_ENABLE_KEY @"PAUSE_SCREEN_PHOTO_ENABLE_KEY"
#define PAUSE_SCREEN_PHOTO_SRC_KEY @"PAUSE_SCREEN_PHOTO_SRC_KEY"
#define PAUSE_SCREEN_VIDEO_ENABLE_KEY @"PAUSE_SCREEN_VIDEO_ENABLE_KEY"
#define PAUSE_SCREEN_VIDEO_SRC_KEY @"PAUSE_SCREEN_VIDEO_SRC_KEY"
#define BANNER_PHOTO_ENABLE_KEY @"BANNER_PHOTO_ENABLE_KEY"
#define BANNER_UPPER_LEFT_KEY @"BANNER_UPPER_LEFT_KEY"
#define BANNER_UPPER_RIGHT_KEY @"BANNER_UPPER_RIGHT_KEY"
#define BANNER_LOWER_LEFT_KEY @"BANNER_LOWER_LEFT_KEY"
#define BANNER_LOWER_RIGHT_KEY @"BANNER_LOWER_RIGHT_KEY"
#define BANNER_UPPER_LEFT_PUSH_KEY @"BANNER_UPPER_LEFT_PUSH_KEY"
#define BANNER_UPPER_RIGHT_PUSH_KEY @"BANNER_UPPER_RIGHT_PUSH_KEY"
#define BANNER_LOWER_LEFT_PUSH_KEY @"BANNER_LOWER_LEFT_PUSH_KEY"
#define BANNER_LOWER_RIGHT_PUSH_KEY @"BANNER_LOWER_RIGHT_PUSH_KEY"
#define BANNER_DURATION_KEY @"BANNER_DURATION_KEY"
#define BANNER_INTERVAL_KEY @"BANNER_INTERVAL_KEY"
#define BANNER_OPACITY_KEY @"BANNER_OPACITY_KEY"
#define SUBTITLE_ENABLE_KEY @"SUBTITLE_ENABLE_KEY"
#define SUBTITLE_PHOTO_KEY @"SUBTITLE_PHOTO_KEY"
#define SUBTITLE_PHOTO_PUSH_KEY @"SUBTITLE_PHOTO_PUSH_KEY"
#define SUBTITLE_DURATION_KEY @"SUBTITLE_DURATION_KEY"
#define SUBTITLE_INTERVAL_KEY @"SUBTITLE_INTERVAL_KEY"
#define SUBTITLE_OPACITY_KEY @"SUBTITLE_OPACITY_KEY"
#define SUBTITLE_COLOR_KEY @"SUBTITLE_COLOR_KEY"
#define SUBTITLE_SIZE_KEY @"SUBTITLE_SIZE_KEY"
#define SUBTITLE_TEXT_KEY @"SUBTITLE_TEXT_KEY"
#define SUBTITLE_SHOW_TYPE_KEY @"SUBTITLE_SHOW_TYPE_KEY"

#define MAIN_BG_COLOR [UIColor colorWithRed:(11 / 255.0f) green:(14 / 255.0f) blue:(1 / 255.0f) alpha:1.0]
#define MAIN_COLOR [UIColor colorWithRed:(0 / 255.0f) green:(179 / 255.0f) blue:(227 / 255.0f) alpha:1.0]
#define MAIN_COLOR_T [UIColor colorWithRed:(0 / 255.0f) green:(179 / 255.0f) blue:(227 / 255.0f) alpha:0.6]
#define MAIN_TITLE_COLOR [UIColor colorWithRed:(92 / 255.0f) green:(108 / 255.0f) blue:(159 / 255.0f) alpha:1.0]

#define MENU_BG0_COLOR [UIColor colorWithRed:(29 / 255.0f) green:(27 / 255.0f) blue:(27 / 255.0f) alpha:1.0]
#define MENU_BG1_COLOR [UIColor colorWithRed:(52 / 255.0f) green:(52 / 255.0f) blue:(52 / 255.0f) alpha:1.0]

#define TEXT_BG_COLOR [UIColor colorWithRed:(192 / 255.0f) green:(236 / 255.0f) blue:(248 / 255.0f) alpha:1.0]

//灰色字体
#define GRAY_COLOR [UIColor colorWithRed:(193.43 / 255.0f) green:(236.43 / 255.0f) blue:(247.00 / 255.0f) alpha:1.0]

#define totalHeight 667  //UI设计时总高度，通过这个值和屏幕高度的比例，设置每个控件的高度
#define totalWeight 375   //UI设计时总宽度，通过这个值和屏幕宽度的比例，设置每个控件的宽度
#define viewH [UIScreen mainScreen].bounds.size.height  //屏幕高度
#define viewW [UIScreen mainScreen].bounds.size.width   //屏幕宽度

@interface CommanParameters : NSObject

+ (void)Save_String:(NSString *)value :(NSString *)key;
+ (NSString *)Get_String:(NSString *)key;
@end
