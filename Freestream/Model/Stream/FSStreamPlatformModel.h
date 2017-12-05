//
//  FSStreamPlatformModel.h
//  Freestream
//
//  Created by Frank Li on 2017/12/5.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FSStreamPlatform) {
    FSStreamPlatformFaceBook = 0,
    FSStreamPlatformYouTube,
    FSStreamPlatformTwitch,
    FSStreamPlatformCustom,
};

typedef NS_ENUM(NSInteger, FSStreamPlatformButtonStatus) {
    FSStreamPlatformButtonStatusNormal = 0,
    FSStreamPlatformButtonStatusSelected = 1,
    FSStreamPlatformButtonStatusActivation = 2,
};

@interface FSStreamPlatformModel : NSObject

@property (nonatomic,assign,readonly) FSStreamPlatform             streamPlatform;
@property (nonatomic,assign)          FSStreamPlatformButtonStatus buttonStatus;
@property (nonatomic,assign)          BOOL                         streamKayBeUsed;
@property (nonatomic,copy)            NSString                     *streamAdress;
@property (nonatomic,copy)            NSString                     *streamKey;

@property (nonatomic,copy)            NSString                     *normalImageName;
@property (nonatomic,copy)            NSString                     *highlightedImageName;
@property (nonatomic,copy)            NSString                     *activationImageName;

- (instancetype)initWithStreamPlatform:(FSStreamPlatform)streamPlatform;

//- (NSString *)getNormalImageNameWithStreamPlatform:(FSStreamPlatform)streamPlatform;
//- (NSString *)getHighlightedImageNameWithStreamPlatform:(FSStreamPlatform)streamPlatform;
//- (NSString *)getActivationImageNameWithStreamPlatform:(FSStreamPlatform)streamPlatform;

//@property (nonatomic,assign) BOOL                           canBeSelected;
//@property (nonatomic,assign) BOOL                           selected;

@end
