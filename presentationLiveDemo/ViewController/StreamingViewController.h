//
//  StreamingViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/17.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIViewLinkmanTouch.h"
#import "CAAutoFillTextField.h"
#import "CAAutoCompleteObject.h"
#import "MarqueeLabel.h"

@interface StreamingViewController : UIViewController<UITextFieldDelegate,CAAutoFillDelegate>
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIImageView *_streamingImg;
    UIImageView *_streamStatusImg;
    UIImageView *_streamingTitleImg;
    UIImageView *_streamingControlBgImg;
    UIImageView *_streamingControlImg;
    
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
@end
