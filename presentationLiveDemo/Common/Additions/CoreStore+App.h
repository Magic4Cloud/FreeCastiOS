//
//  CoreStore+App.h
//  Patrol
//
//  Created by Benjamin on 4/6/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "CoreStore.h"
typedef NS_ENUM(NSInteger, AudioInputSelected) {//选择Audio输出方式
    AudioInputSelectedNoAudio = 0,  //无声音
    AudioInputSelectedHDMIAudio,    //HDMI
    AudioInputSelectedExternAudio,  //外部设备
    AudioInputSelectedInternalAudio,//无声音,做App内部判断
};
typedef NS_ENUM(NSInteger, FSResolution) {
    FSResolution480P = 0,
    FSResolution720P,
    FSResolution1080P,
};

typedef NS_ENUM(NSInteger, FSSubtitleTypeSelected) {
    FSSubtitleTypeSelectedNone = 0,
    FSSubtitleTypeSelectedFix,
    FSSubtitleTypeSelectedRoll,
};

@interface CoreStore (App)

#define APP_CURRENT_DEVICE_ID            @"app_current_device_id"
#define APP_SELECTED_AUDIO_INPUT         @"app_selected_audio_input"
#define APP_IS_SELECTED_AUDIO            @"app_is_selected_audio"
#define APP_IS_CHANGED_CUSTOM_VALUES     @"app_is_changed_custom_values"
#define APP_RESOLUTION                   @"app_resolution"
#define APP_BIT_RATE                     @"app_bit_rate"
#define APP_FRAME_RATE                   @"app_frame_rate"
#define APP_SUBTITLE_TYPE                @"app_subtitle_type"

@property (nonatomic, copy)      NSString                   *currentUseDeviceID;
@property (nonatomic, assign)    AudioInputSelected         audioInput;
@property (nonatomic, assign)    BOOL                       isSelectedAudio;//是否选过
@property (nonatomic, assign)    BOOL                       isChangedCustomValues;
@property (nonatomic, assign)    FSResolution               resolution;
@property (nonatomic, assign)    NSInteger                  frameRate;
@property (nonatomic, assign)    NSInteger                  bitRate;
@property (nonatomic, assign)    FSSubtitleTypeSelected     subtitleType;
@end
