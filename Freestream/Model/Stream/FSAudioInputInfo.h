//
//  FSAudioInputInfo.h
//  Freestream
//
//  Created by Frank Li on 2017/11/28.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FSAudioInputMode) {//Audio输出方式
    FSAudioInputModeNoAudio = 0,        //无声音
    FSAudioInputModeHDMIAudio,          //HDMI
    FSAudioInputModeExternAudio,        //外部设备
    FSAudioInputModeInternalAudio,      //无声音,做App内部判断
};

@interface FSAudioInputInfo : NSObject

@end
