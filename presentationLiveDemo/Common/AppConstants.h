//
//  AppConstants.h
//  Patrol
//
//  Created by Benjamin on 4/6/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#define     SCREENWIDTH                 [UIScreen mainScreen].bounds.size.width
#define     SCREENHEIGHT                [UIScreen mainScreen].bounds.size.height
///2X图尺寸乘上Ratio
#define     RATIO                       [UIScreen mainScreen].bounds.size.height / 667.f

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//platform
#define faceBook    @"facebook"
#define youtubu     @"youtube"
#define twitch      @"twitch"
#define uStream     @"ustream"
#define liveStream  @"livestream"
#define custom      @"custom"

//appkey or cilentid
#define album_name  @"FREESTREAM"

#define AudioSourceIsIphone @"isIphoneAudio"

#define bugly_appid  @"3027ad3ed7"
#define bugly_appkey @"df17f5a7-64d5-49b6-8883-ee78d1daf121"

