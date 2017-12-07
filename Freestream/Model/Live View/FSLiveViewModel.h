//
//  FSLiveViewModel.h
//  Freestream
//
//  Created by Frank Li on 2017/12/7.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>
#import "FSStreamPlatformModel.h"

typedef NS_ENUM(NSInteger, FSLiveViewStreamStatus) {
    FSLiveViewStreamStatusNormal = 0,//Not live
    FSLiveViewStreamStatusPending = 1,//Pending
    FSLiveViewStreamStatusLiveStart = 2,//On Live
};

@interface FSLiveViewModel : NSObject

///////////////////////////////////////platformbutton////////////////////////////
//获取当前选中的推流平台的model,如果为设置返回nil
+ (nullable FSStreamPlatformModel *)getCurrentSelectedPlatformModel;
//获取当前选中的推流平台的图片名
+ (nonnull NSString *)getSelectedPlatformImageNameWithPlatformModel:(nullable FSStreamPlatformModel *)model;

//////////////////////////////////////statusView////////////////////////////////
//根据推流状态获取推流状态圆点的图片名
+ (nonnull NSString *)getStreamStatusViewPointImageNameWithStreamStatus:(FSLiveViewStreamStatus)streamStatus;
//根据推流状态返回推流状态对应的文本
+ (nonnull NSString *)getStreamStatusViewTextWithStreamStatus:(FSLiveViewStreamStatus)streamStatus;

@end
