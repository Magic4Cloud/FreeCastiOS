//
//  AppConstants.h
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#ifndef AppConstants_h
#define AppConstants_h

#define FSAbsoluteLong    MAX(SCREENWIDTH, SCREENHEIGHT)
#define FSAbsoluteShort   MIN(SCREENWIDTH, SCREENHEIGHT)

//weak宏定义
#define WEAK(object) __weak typeof(object) weak##object = object;

//简洁的打印输出
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d  \t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

//#define FSfacebook_Scope               @"publish_actions,publish_pages,manage_pages"
//#define FSfacebook_AppId               @"115586109153322"
//#define FSfacebook_Client_token        @"766ef0f7747b190ca998851d5e277bce"
////请求验证码时候 用这个作为access_token
//#define FSfacebook_Access_token_value  [NSString stringWithFormat:@"%@|%@",FSfacebook_AppId,FSfacebook_Client_token]



#endif /* AppConstants_h */
