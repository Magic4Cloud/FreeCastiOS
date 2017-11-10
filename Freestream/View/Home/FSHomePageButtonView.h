//
//  FSHomePageButtonView.h
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FSHomePageButtonTag) {
    FSHomePageButtonLiveView,
    FSHomePageButtonStream,
    FSHomePageButtonConfigure,
    FSHomePageButtonBrowse,
};

@protocol FSHomePageButtonViewDelegate <NSObject>
- (void)buttonViewDidSelected:(FSHomePageButtonTag)tag;
@end

@interface FSHomePageButtonView : CoreDesignableXibUIView

- (void)setupButtonViewWithTag:(FSHomePageButtonTag)tag;

@property (nonatomic, weak) id <FSHomePageButtonViewDelegate> delegate;

@end
