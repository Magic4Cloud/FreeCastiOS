//
//  CoreStore+App.m
//  Freestream
//
//  Created by Frank Li on 2017/11/28.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "CoreStore+App.h"

@implementation CoreStore (App)
/////////////////////////////get///////////////////////////////////

- (NSString *)currentUseDeviceID {
    return [self stringDataForKey:APP_CURRENT_DEVICE_ID];
}

- (FSAudioInputMode)audioInput {
    return [self integerDataForKey:APP_SELECTED_AUDIO_INPUT];
}

- (BOOL)isSelectedAudio {
    return [self BOOLDataForKey:APP_IS_SELECTED_AUDIO];
}

- (BOOL)isChangedCustomValues {
    return [self BOOLDataForKey:APP_IS_CHANGED_CUSTOM_VALUES];
}

- (FSResolution)resolution {
    return [self integerDataForKey:APP_RESOLUTION];
}

- (NSInteger)bitRate {
    return [self integerDataForKey:APP_BIT_RATE];
}

- (NSInteger)frameRate {
    return  [self integerDataForKey:APP_FRAME_RATE];
}

- (NSString *)fbUserAccessToken {
    return [self stringDataForKey:APP_FB_USER_ACCESS_TOKEN];
}

/////////////////////////////set///////////////////////////////////

- (void)setCurrentUseDeviceID:(NSString *)currentUseDeviceID {
    [self setStringData:currentUseDeviceID forKey:APP_CURRENT_DEVICE_ID];
}

- (void)setAudioInput:(FSAudioInputMode)audioInput {
    [self setIntegerData:audioInput forKey:APP_SELECTED_AUDIO_INPUT];
}

- (void)setIsSelectedAudio:(BOOL)isSelectedAudio {
    [self setBOOLData:isSelectedAudio forKey:APP_IS_SELECTED_AUDIO];
}

- (void)setIsChangedCustomValues:(BOOL)isChangedCustomValues {
    [self setBOOLData:isChangedCustomValues forKey:APP_IS_CHANGED_CUSTOM_VALUES];
}

- (void)setResolution:(FSResolution)resolution {
    [self setIntegerData:resolution forKey:APP_RESOLUTION];
}

- (void)setBitRate:(NSInteger)bitRate {
    [self setIntegerData:bitRate forKey:APP_BIT_RATE];
}

- (void)setFrameRate:(NSInteger)frameRate {
    [self setIntegerData:frameRate forKey:APP_FRAME_RATE];
}

- (void)setFbUserAccessToken:(NSString *)fbUserAccessToken {
    [self setStringData:fbUserAccessToken forKey:APP_FB_USER_ACCESS_TOKEN];
}
@end
