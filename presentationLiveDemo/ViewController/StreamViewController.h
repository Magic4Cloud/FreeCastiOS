//
//  StreamViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/14.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewLinkmanTouch.h"

@interface StreamViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    UISegmentedControl *segmentedControl;
    
    UIView *_parameterView;
    UIViewLinkmanTouch *_streamView;
    UIImageView *_streamBtn;
    UILabel *_streamLabel;
    UIViewLinkmanTouch *_subscriptView;
    UIImageView *_subscriptBtn;
    UILabel *_subscriptLabel;
    UIViewLinkmanTouch *_subtitleView;
    UIImageView *_subtitleBtn;
    UILabel *_subtitleLabel;
    UIViewLinkmanTouch *_audioInputView;
    UIImageView *_audioInputBtn;
    UILabel *_audioInputLabel;
    
    UIView *_networkView;
    UIView *_networkStatusView;
    UILabel *_networkStatusText;
    UILabel *_networkStatusValue;
    UIView *_networkWayView;
    UILabel *_networkDHCPText;
    UISwitch *_networkDHCPSwitch;
    UILabel *_networkManualText;
    UISwitch *_networkManualSwitch;
    
    UIView *_addressView;
    UILabel *_addressLiveLabel;
    UITextField *_addressLiveText;
    UIImageView *_addressLiveImg;
    UILabel *_addressLiveTips;
    UIButton *_addressLiveBtn;
    UIButton *_addressShareBtn;
}
@end
