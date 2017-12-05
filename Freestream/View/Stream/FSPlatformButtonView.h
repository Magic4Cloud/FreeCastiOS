//
//  FSPlatformButtonView.h
//  Freestream
//
//  Created by Frank Li on 2017/12/1.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>
#import "FSStreamPlatformModel.h"

typedef void(^GotoConfigureStreamAdressBlock)(FSStreamPlatform streamPlatform);
typedef void(^SelectStreamPlatformBlock)(FSStreamPlatform streamPlatform);
@interface FSPlatformButtonView : CoreDesignableXibUIView

@property (nonatomic,strong) FSStreamPlatformModel          *model;
//@property (nonatomic,assign) FSStreamPlatformButtonStatus   buttonStatus;
//@property (nonatomic,assign) BOOL                           canBeSelected;
//@property (nonatomic,assign) FSStreamPlatform               streamPlatform;

@property (nonatomic,copy  ) GotoConfigureStreamAdressBlock goConfigureStreamAdressBlock;
@property (nonatomic,copy  ) SelectStreamPlatformBlock      selectStreamPlatformBlock;

- (void)setButtonDisselected;
@end
