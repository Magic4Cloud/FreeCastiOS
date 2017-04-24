//
//  ViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/9.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainImageViewBtn.h"

@interface ViewController : UIViewController
{
    UIImageView *_Bg;
    UIImageView *_topBg;
    UIButton *_menuBtn;
    UIImageView *_topFlag;
    
    UIImageView *_liveView;
    UIImageView *_liveViewCamera;
    UILabel *_liveViewLabel;
    UIButton *_liveViewImg;
    
    UIImageView *_browse;
    UIImageView *_browseView;
    UILabel *_browseLabel;
    
    UIImageView *_liveStream;
    UIImageView *_liveStreamView;
    UILabel *_liveStreamLabel;
    
    UIImageView *_configure;
    UIImageView *_configureView;
    UILabel *_configureLabel;
    
    UIImageView *_bottomBg;
    UIButton *_liveViewBtn;
    UIButton *_browseBtn;
    UIButton *_liveStreamBtn;
    UIButton *_configureBtn;
    
    MainImageViewBtn *_liveViewImgBtn;
    MainImageViewBtn *_streamImgBtn;
    MainImageViewBtn *_configureImgBtn;
    MainImageViewBtn *_browseImgBtn;
}

@end

