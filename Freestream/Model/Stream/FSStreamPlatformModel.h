//
//  FSStreamPlatformModel.h
//  Freestream
//
//  Created by Frank Li on 2017/12/5.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>

typedef NS_ENUM(NSInteger, FSStreamPlatform) {
    FSStreamPlatformFaceBook = 0,
    FSStreamPlatformYouTube = 1,
    FSStreamPlatformTwitch = 2,
    FSStreamPlatformCustom = 3,
};

typedef NS_ENUM(NSInteger, FSStreamPlatformButtonStatus) {
    FSStreamPlatformButtonStatusNormal = 0,
    FSStreamPlatformButtonStatusSelected = 1,
    FSStreamPlatformButtonStatusActivation = 2,
};

@interface FSStreamPlatformModel : ModelBaseClass

@property (nonatomic,assign)          FSStreamPlatform             streamPlatform;
@property (nonatomic,assign)          FSStreamPlatformButtonStatus buttonStatus;
@property (nonatomic,assign)          BOOL                         streamKayBeUsed;
@property (nonatomic,copy)            NSString                     *streamAdress;
@property (nonatomic,copy)            NSString                     *streamKey;

@property (nonatomic,copy)            NSString                     *normalImageName;
@property (nonatomic,copy)            NSString                     *highlightedImageName;
@property (nonatomic,copy)            NSString                     *activationImageName;

- (instancetype)initWithStreamPlatform:(FSStreamPlatform)streamPlatform;

- (void)deselected;

@end
