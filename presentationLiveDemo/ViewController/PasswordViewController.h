//
//  PasswordViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/17.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController<UITextFieldDelegate>
{
    UISegmentedControl *segmentedControl;
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_passwordView;
    UIImageView *_passwordImg;
    
    UIView *_ssidView;
    UIImageView *_ssidImg;
    UILabel *_ssidLabel;
    UITextField *_ssidText;
    
    UIView *_initPasswordView;
    UIImageView *_initPasswordImg;
    UILabel *_initPasswordLabel;
    UITextField *_initPasswordText;
    
    UIView *_newPasswordView;
    UIImageView *_newPasswordImg;
    UILabel *_newPasswordLabel;
    UITextField *_newPasswordText;
    
    UIView *_confirmView;
    UIImageView *_confirmPasswordImg;
    UILabel *_confirmLabel;
    UITextField *_confirmText;
    
    UIButton *_passwordForgetBtn;
    UIButton *_passwordModifyBtn;
    
    UIView *_resetBgView;
    UIView *_resetView;
    UIImageView *_resetImg;
    UILabel *_resetTitle;
    UILabel *_resetLabel1;
    UILabel *_resetLabel2;
    
    UIView *_videoView;
    UIImageView *_videoImg;
    UIView *_viewBtn;
    UIButton *_smoothBtn;
    UIButton *_goodBtn;
    UIButton *_bestBtn;
    UIButton *_customBtn;
    UISegmentedControl *VediosegmentedControl;
    
    UIView *_videoLabelView;
    UILabel *_videoLabel1;
    UILabel *_videoLabel2;
    UILabel *_videoLabel3;
    UILabel *_videoLabel4;
    
    UIView *_videoParametersView;
    UILabel *_videoParametersLabel;
    UIView *_videoResolutionView;
    UILabel *_videoResolutionLabel;
    UILabel *_videoResolutionMinLabel;
    UILabel *_videoResolutionMaxLabel;
    UILabel *_videoResolutionValueLabel;
    UISlider *_videoResolutionSlider;
    UIImageView *_videoResolutionMinImg;
    UIImageView *_videoResolutionMaxImg;
    UIImageView *_videoResolutionValueImg;
    
    UIView *_videoRateView;
    UILabel *_videoRateLabel;
    UILabel *_videoRateMinLabel;
    UILabel *_videoRateMaxLabel;
    UILabel *_videoRateValueLabel;
    UISlider *_videoRateSlider;
    
    UIView *_videoFrameRateView;
    UILabel *_videoFrameRateLabel;
    UILabel *_videoFrameRateMinLabel;
    UILabel *_videoFrameRateMaxLabel;
    UILabel *_videoFrameRateValueLabel;
    UISlider *_videoFrameRateSlider;

    
    UIButton *_videoModifyBtn;
}
@end
