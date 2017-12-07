//
//  FSLiveViewStatusView.h
//  Freestream
//
//  Created by Frank Li on 2017/12/7.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>
#import "FSLiveViewModel.h"
@interface FSLiveViewStatusView : CoreDesignableXibUIView

@property (nonatomic,assign) FSLiveViewStreamStatus   streamStatus;

@end
