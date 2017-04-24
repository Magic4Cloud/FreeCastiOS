//
//  ConfigureVideoViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/18.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigureVideoViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_videoResolutionView;
    UILabel *_videoResolutionLabel;
    UIButton *_videoResolution480p;
    UIButton *_videoResolution720p;
    UIButton *_videoResolution1080p;
    
    UIView *_videoRateView;
    UILabel *_videoRateLabel;
    UILabel *_videoRateMaxLabel;
    UILabel *_videoRateValueLabel;
    UISlider *_videoRateSlider;
    
    UIView *_videoFrameRateView;
    UILabel *_videoFrameRateLabel;
    UILabel *_videoFrameRateMaxLabel;
    UILabel *_videoFrameRateValueLabel;
    UISlider *_videoFrameRateSlider;
    
    UIButton *_videoConfirmBtn;
}
@end
