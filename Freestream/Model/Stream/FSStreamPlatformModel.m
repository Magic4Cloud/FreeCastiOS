//
//  FSStreamPlatformModel.m
//  Freestream
//
//  Created by Frank Li on 2017/12/5.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSStreamPlatformModel.h"

@implementation FSStreamPlatformModel

- (instancetype)initWithStreamPlatform:(FSStreamPlatform)streamPlatform {
    
    if (self = [super init]) {
        _streamPlatform = streamPlatform;
        _buttonStatus = FSStreamPlatformButtonStatusNormal;
        _streamKey = @"";
        _streamAdress = @"";
        _streamKayBeUsed = NO;
        _normalImageName = [self getActivationImageNameWithStreamPlatform:_streamPlatform];
        _highlightedImageName = [self getHighlightedImageNameWithStreamPlatform:_streamPlatform];
        _activationImageName = [self getNormalImageNameWithStreamPlatform:_streamPlatform];
    }
    return self;
}

- (NSString *)activationImageName {
   return [self getActivationImageNameWithStreamPlatform:self.streamPlatform];
}

- (NSString *)highlightedImageName {
   return [self getHighlightedImageNameWithStreamPlatform:self.streamPlatform];
}

- (NSString *)normalImageName {
   return  [self getNormalImageNameWithStreamPlatform:self.streamPlatform];
}

- (NSString *)getNormalImageNameWithStreamPlatform:(FSStreamPlatform)streamPlatform {
    NSArray *normalImageNames =
                          @[@"button_facebook_nor",
                            @"button_youtube_nor",
                            @"button_twitch_nor",
                            @"button_custom_nor"];
//    NSInteger idx = ;
    return normalImageNames[streamPlatform];
}

- (NSString *)getHighlightedImageNameWithStreamPlatform:(FSStreamPlatform)streamPlatform {
    NSArray *highlightedImageNames =
                                @[@"button_facebook_pre",
                                  @"button_youtube_pre",
                                  @"button_twitch_pre",
                                  @"button_custom_pre"];
    //    NSInteger idx = ;
    return highlightedImageNames[streamPlatform];
}

- (NSString *)getActivationImageNameWithStreamPlatform:(FSStreamPlatform)streamPlatform {
    NSArray *activationImageNames =
                                @[@"button_facebook_act",
                                  @"button_youtube_act",
                                  @"button_twitch_act",
                                  @"button_custom_act"];
    //    NSInteger idx = ;activation
    return activationImageNames[streamPlatform];
}

- (void)deselected {
    switch (self.buttonStatus) {
        case FSStreamPlatformButtonStatusNormal: {
            self.buttonStatus = FSStreamPlatformButtonStatusNormal;
        }
            break;
        case FSStreamPlatformButtonStatusSelected: {
            self.buttonStatus = FSStreamPlatformButtonStatusActivation;
        }
            break;
        case FSStreamPlatformButtonStatusActivation: {
            self.buttonStatus = FSStreamPlatformButtonStatusActivation;
        }
            break;
        default:
            break;
    }
}

@end
