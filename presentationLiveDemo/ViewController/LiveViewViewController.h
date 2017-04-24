//
//  LiveViewViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/10.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LX520View.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewLinkmanTouch.h"
#import "CAAutoFillTextField.h"
#import "CAAutoCompleteObject.h"
#import "MarqueeLabel.h"

@interface LiveViewViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_topLabel;
    UIImageView *_connectImg;
    
    UIView *_liveView;
    UILabel *_tipLabel;
    UIImageView* ActivityIndicatorView;
    bool ActivityIndicatorViewisenable;
    UIImageView *_bottomBg;
    UIButton *_takephotoBtn;
    UIButton *_recordBtn;
    UIButton *_liveStreamBtn;
    UILabel *_liveStreamLabel;
    UIButton *_browserBtn;
    UIButton *_configureBtn;
    UIButton *_livePauseBtn;
    UIButton *_liveStopBtn;
    
    UIImageView *_statusBg;
    UIImageView *_onliveView;
    UILabel *_onliveLabel;
    UIImageView *_audioView;
    UIImageView *_powerView;
    UILabel *_recordTimeLabel;
    
    UIImageView *_upperLeftImg;
    UIImageView *_upperRightImg;
    UIImageView *_lowerLeftImg;
    UIImageView *_lowerRightImg;
    UIImageView *_wordImg;
    
    //推流界面
    UIView *_streamView;
    UILabel *_titleLabel;
    UIImageView *_topBgStream;
    UIButton *_backBtnStream;
    
    UIImageView *_streamingImg;
    UIImageView *_streamStatusImg;
    UIImageView *_streamingTitleImg;
    UIImageView *_streamingControlBgImg;
    UIImageView *_streamingControlImg;
    UIButton *_streamingStartBtn;
    UIButton *_streamingPauseBtn;
    UIButton *_streamingStopBtn;
    UILabel *_streamingTitleLabel;
    UILabel *_customStreamingLabel;
    
    UIView *_streamingConfigView;
    
    UIButton *_linkmanBtn0;
    UILabel *_linkmanLabel0;
    UIButton *_linkmanBtn1;
    UILabel *_linkmanLabel1;
    UIButton *_linkmanBtn2;
    UILabel *_linkmanLabel2;
    UIButton *_linkmanBtn3;
    UILabel *_linkmanLabel3;
    UIButton *_linkmanBtn4;
    UILabel *_linkmanLabel4;
    
    
    UILabel *_pauseScreenLabel;
    UIView *_pauseScreenView;
    UIImageView *_pauseScreenImg;
    UIButton *_pauseScreenBtn;
    
    UIView *_streamingAddressView;
    UILabel *_streamingAddressLabel;
    UIViewLinkmanTouch *_addressView;
    UIImageView *_streamingAddressImg;
    MarqueeLabel *_streamingAddress;
    UIViewLinkmanTouch *_platformView;
    UIImageView *_streamingPlatformImg;
    UILabel *_streamingPlatform;
    
    UILabel *_streamingShareLabel;
    UIView *_streamingShareView;
    UILabel *_streamingObtainLabel;
    UITextField *_streamingObtainField;
    UILabel *_streamingMannualLabel;
    UITextField *_streamingMannualField;
    UIButton *_streamingShareBtn;
    
    UIView *_choosePlatformView;
    UIView *_PlatformViewLayout;
    
    UIView *_inputAddressView;
    UIView *_inputAddressViewLayout;
    CAAutoFillTextField *myTextField;
}

@property (nonatomic) BOOL isLiveView;//true:Live View  false:Streaming View
@end
