//
//  SubtitleViewController.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/30.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubtitleViewController : UIViewController<UITextFieldDelegate>
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_subtitleDisplayView;
    UILabel *_subtitleDisplayLabel;
    UISwitch *_subtitleDisplayBtn;
    
    UIView *_subtitleTypeView;
    UIImageView *_subtitleTypeSizeImg;
    UIButton *_subtitleTypeSizeBtn;
    UIImageView *_subtitleTypeColorImg;
    UIButton *_subtitleTypeColorBtn;
    UIButton *subtitleTypeFixedLabel;
    UIImageView *subtitleTypeFixedImg;
    UIButton *subtitleTypeRollLabel;
    UIImageView *subtitleTypeRollImg;
    
    UIView *_subtitleTextView;
    UITextField *_subtitleTextField;
    
    UILabel *subtitleTypeTipsLabel;
    
    UIView *_subtitleSettingsView;
    UILabel *_subtitleDurationLabel;
    UITextField *_subtitleDurationField;
    UILabel *_subtitleDurationKit;
    UILabel *_subtitleIntervalLabel;
    UITextField *_subtitleIntervalField;
    UILabel *_subtitleIntervalKit;
    UILabel *_subtitleOpacityLabel;
    UISlider *_subtitleOpacitySlider;
    UITextField *_subtitleOpacityValue;
    
    UIView *_subtitleSizePickerView;
    UIView *_subtitleColorPickerView;
}

@property (nonatomic) NSString *ip;
@end
