//
//  ConfigureAudioViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/18.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigureAudioViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_audioSampleRateView;
    UILabel *_audioSampleRateLabel;
    UILabel *_audioSampleRateMaxLabel;
    UILabel *_audioSampleRateValueLabel;
    UISlider *_audioSampleRateSlider;
    
    UIView *_audioRateView;
    UILabel *_audioRateLabel;
    UILabel *_audioRateMaxLabel;
    UILabel *_audioRateValueLabel;
    UISlider *_audioRateSlider;
    
    UIButton *_audioConfirmBtn;
}
@end
