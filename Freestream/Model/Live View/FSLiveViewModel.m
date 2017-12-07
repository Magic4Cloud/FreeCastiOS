//
//  FSLiveViewModel.m
//  Freestream
//
//  Created by Frank Li on 2017/12/7.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSLiveViewModel.h"
#import "CommonAppHeader.h"
@implementation FSLiveViewModel
+ (FSStreamPlatformModel *)getCurrentSelectedPlatformModel {
   NSArray <FSStreamPlatformModel *> *modelsArray = [CoreStore sharedStore].streamPlatformModels;
    if (!modelsArray) {
        return nil;
    }
    for (FSStreamPlatformModel * model in modelsArray) {
        
        if (model.buttonStatus == FSStreamPlatformButtonStatusSelected) {
            return model;
        }
    }
    return nil;
}

+ (NSString *)getSelectedPlatformImageNameWithPlatformModel:(FSStreamPlatformModel *)model {
    if (model) {
        NSArray *imageNamesArray = [self platformImageNamesArray];
        return  imageNamesArray[model.streamPlatform];
    }
    return @"icon_platform_nor";
}

+ (NSString *)getStreamStatusViewPointImageNameWithStreamStatus:(FSLiveViewStreamStatus)streamStatus {
    NSArray *imageNamesArray = [self pointImageNamesArray];
    return  imageNamesArray[streamStatus];
}

+ (NSString *)getStreamStatusViewTextWithStreamStatus:(FSLiveViewStreamStatus)streamStatus {
    NSArray *textArray = [self streamStatusTextArray];
    return  textArray[streamStatus];
}

+ (NSArray <NSString *> *)streamStatusTextArray {
    return @[NSLocalizedString(@"Not live", nil),
             NSLocalizedString(@"Pending", nil),
             NSLocalizedString(@"On live", nil)];
}

+ (NSArray <NSString *> *)pointImageNamesArray {
    return @[@"live_stream_normal",@"live_stream_prefer",@"live_stream_start"];
}

+ (NSArray <NSString *>*)platformImageNamesArray {
    return @[@"icon_facebook",@"icon_youtube",@"icon_twitch",@"icon_custom"];
}

@end
