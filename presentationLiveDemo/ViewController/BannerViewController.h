//
//  BannerViewController.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface BannerViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_bannerDisplayView;
    UILabel *_bannerDisplayLabel;
    UISwitch *_bannerDisplayBtn;
    
    UIView *_bannerLayoutView;
    UILabel *_bannerLayoutUpperLeftLabel;
    UILabel *_bannerLayoutUpperRightLabel;
    UIButton *_bannerLayoutUpperLeftImg;
    UIButton *_bannerLayoutUpperRightImg;
    UILabel *_bannerLayoutLowerLeftLabel;
    UILabel *_bannerLayoutLowerRightLabel;
    UIButton *_bannerLayoutLowerLeftImg;
    UIButton *_bannerLayoutLowerRightImg;
    
    UIView *_bannerSettingsView;
    UILabel *_bannerDurationLabel;
    UITextField *_bannerDurationField;
    UILabel *_bannerDurationKit;
    UILabel *_bannerIntervalLabel;
    UITextField *_bannerIntervalField;
    UILabel *_bannerIntervalKit;
    UILabel *_bannerOpacityLabel;
    UISlider *_bannerOpacitySlider;
    UITextField *_bannerOpacityValue;
    
    UIImagePickerController *_imagePickerController;
    UIView *_chooseImgView;
}

@property (nonatomic) NSString *ip;
@end
