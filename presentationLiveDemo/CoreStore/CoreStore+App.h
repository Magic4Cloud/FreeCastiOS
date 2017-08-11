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
@interface CoreStore (App)

#define APP_CURRENT_DEVICE_ID            @"app_current_device_id"
#define APP_SELECTED_AUDIO_INPUT         @"app_selected_audio_input"
#define APP_IS_SELECTED_AUDIO            @"app_is_selected_audio"

@property (nonatomic, copy)      NSString           *currentUseDeviceID;
@property (nonatomic, assign)    AudioInputSelected audioInput;
@property (nonatomic, assign)    BOOL               isSelectedAudio;//是否选择过

@end
