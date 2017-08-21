//
//  CoreStore+App.h
//  Patrol
//
//  Created by Benjamin on 4/6/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "CoreStore.h"
typedef NS_ENUM(NSInteger, AudioInputSelected) {
    AudioInputSelectedNoAudio = 0,
    AudioInputSelectedHDMIAudio,
    AudioInputSelectedExternAudio,
    AudioInputSelectedInternalAudio,
};
typedef NS_ENUM(NSInteger, FSResolution) {
    FSResolution480P = 0,
    FSResolution720P,
    FSResolution1080P,
};

@interface CoreStore (App)

#define APP_CURRENT_DEVICE_ID            @"app_current_device_id"
#define APP_SELECTED_AUDIO_INPUT         @"app_selected_audio_input"
#define APP_IS_SELECTED_AUDIO            @"app_is_selected_audio"
#define APP_IS_CHANGED_CUSTOM_VALUES     @"app_is_changed_custom_values"
#define APP_RESOLUTION                   @"app_resolution"
#define APP_BIT_RATE                     @"app_bit_rate"
#define APP_FRAME_RATE                   @"app_frame_rate"

@property (nonatomic, copy)      NSString           *currentUseDeviceID;
@property (nonatomic, assign)    AudioInputSelected audioInput;
@property (nonatomic, assign)    BOOL               isSelectedAudio;//是否选择过
@property (nonatomic, assign)    BOOL               isChangedCustomValues;
@property (nonatomic, assign)    FSResolution       resolution;
@property (nonatomic, assign)    NSInteger          frameRate;
@property (nonatomic, assign)    NSInteger          bitRate;
@end
