//
//  CoreStore+App.m
//  Patrol
//
//  Created by Benjamin on 4/6/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "CoreStore+App.h"

@implementation CoreStore (App)
/////////////////////////////get///////////////////////////////////

- (NSString *)currentUseDeviceID {
    return [self stringDataForKey:APP_CURRENT_DEVICE_ID];
}

- (AudioInputSelected)audioInput {
    return [self integerDataForKey:APP_SELECTED_AUDIO_INPUT];
}

- (BOOL)isSelectedAudio {
    return [self BOOLDataForKey:APP_IS_SELECTED_AUDIO];
}

/////////////////////////////set///////////////////////////////////

- (void)setCurrentUseDeviceID:(NSString *)currentUseDeviceID {
    [self setStringData:currentUseDeviceID forKey:APP_CURRENT_DEVICE_ID];
}

- (void)setAudioInput:(AudioInputSelected)audioInput {
    [self setIntegerData:audioInput forKey:APP_SELECTED_AUDIO_INPUT];
}

- (void)setIsSelectedAudio:(BOOL)isSelectedAudio {
    [self setBOOLData:isSelectedAudio forKey:APP_IS_SELECTED_AUDIO];
}

@end
