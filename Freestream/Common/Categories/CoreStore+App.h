//
//  CoreStore+App.h
//  Freestream
//
//  Created by Frank Li on 2017/11/28.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>
#import "FSAudioInputInfo.h"
#import "FSDeviceConfigureInfo.h"
//typedef NS_ENUM(NSInteger, FSSubtitleTypeSelected) {
//    FSSubtitleTypeSelectedNone = 0,
//    FSSubtitleTypeSelectedFix,
//    FSSubtitleTypeSelectedRoll,
//};
@interface CoreStore (App)

#define APP_CACHE_USER_DEVICE_IP            @"cache_user_device_ip"
#define APP_CACHE_USER_DEVICE_ID            @"cache_user_device_id"
#define APP_SELECTED_AUDIO_INPUT         @"app_selected_audio_input"
#define APP_IS_SELECTED_AUDIO            @"app_is_selected_audio"
#define APP_IS_CHANGED_CUSTOM_VALUES     @"app_is_changed_custom_values"
#define APP_RESOLUTION                   @"app_resolution"
#define APP_BIT_RATE                     @"app_bit_rate"
#define APP_FRAME_RATE                   @"app_frame_rate"
//#define APP_SUBTITLE_TYPE                @"app_subtitle_type"
#define APP_FB_USER_ACCESS_TOKEN         @"app_fb_user_access_token"


@property (nonatomic, copy)      NSString                   *cacheUseDeviceIP;
@property (nonatomic, copy)      NSString                   *cacheUseDeviceID;
@property (nonatomic, assign)    FSAudioInputMode           audioInput;
@property (nonatomic, assign)    BOOL                       isSelectedAudio;//是否选过
@property (nonatomic, assign)    BOOL                       isChangedCustomValues;
@property (nonatomic, assign)    FSResolution               resolution;
@property (nonatomic, assign)    NSInteger                  frameRate;
@property (nonatomic, assign)    NSInteger                  bitRate;
//@property (nonatomic, assign)    FSSubtitleTypeSelected     subtitleType;
@property (nonatomic, copy)      NSString                   *fbUserAccessToken;
@end
