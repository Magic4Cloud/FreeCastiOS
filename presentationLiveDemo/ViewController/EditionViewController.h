//
//  EditionViewController.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/26.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewLinkmanTouch.h"

@interface EditionViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIImageView *_topLogo;
    UIImageView *_topName;
    UILabel *_appVersionLabel;
    
    UIView *_deviceIdView;
    UILabel *_deviceIdLabel;
    UILabel *_deviceIdValue;
    
    UIView *_deviceIpView;
    UILabel *_deviceIpLabel;
    UILabel *_deviceIpValue;
    
    UIViewLinkmanTouch *_firmwareUpgradeView;
    UILabel *_firmwareUpgradeLabel;
    UILabel *_firmwareUpgradeValue;
    UIImageView *_firmwareUpgradeImg;
    
    UIViewLinkmanTouch *_newVersionView;
    UILabel *_newVersionLabel;
    UIImageView *_newVersionImg;
}
@end
