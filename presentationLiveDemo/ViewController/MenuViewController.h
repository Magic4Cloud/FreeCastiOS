//
//  MenuViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/18.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewLinkmanTouch.h"

@interface MenuViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UILabel *_supportLabel;
    
    UIViewLinkmanTouch *_useHelpView;
    UILabel *_useHelpLabel;
    UIImageView *_useHelpImg;
    
    UIViewLinkmanTouch *_technicalSupportView;
    UILabel *_technicalSupportLabel;
    UIImageView *_technicalSupportImg;
    
    UIViewLinkmanTouch *_feedbackView;
    UILabel *_feedbackLabel;
    UIImageView *_feedbackImg;
    
    UIViewLinkmanTouch *_themeView;
    UILabel *_themeLabel;
    UIImageView *_themeImg;

    
    UIViewLinkmanTouch *_upgradeView;
    UILabel *_upgradeLabel;
    UIImageView *_upgradeImg;
    
    UILabel *_aboutLabel;
    
    UIViewLinkmanTouch *_disclaimerView;
    UILabel *_disclaimerLabel;
    UIImageView *_disclaimerImg;
    
    UIViewLinkmanTouch *_privacyView;
    UILabel *_privacyLabel;
    UIImageView *_privacyImg;
    
    UIViewLinkmanTouch *_copyrightView;
    UILabel *copyrightLabel;
    UIImageView *copyrightImg;
    
    UIViewLinkmanTouch *_editionView;
    UILabel *_editionLabel;
    UIImageView *_editionImg;
}
@end
