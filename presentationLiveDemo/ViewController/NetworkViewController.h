//
//  NetworkViewController.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_networkStatusView;
    UILabel *_networkTextLabel;
    UILabel *_networkStatusLabel;
    
    UIView *_networkDHCPView;
    UILabel *_networkDHCPLabel;
    UISwitch *_networkDHCPBtn;
    
    UIView *_networkIPView;
    UILabel *_networkIPLabel;
    UITextField *_networkIPText;
    
    UIView *_networkMaskView;
    UILabel *_networkMaskLabel;
    UITextField *_networkMaskText;
    
    UIView *_networkGatewayView;
    UILabel *_networkGatewayLabel;
    UITextField *_networkGatewayText;
    
    UIView *_networkDNSView;
    UILabel *_networkDNSLabel;
    UITextField *_networkDNSText;
    
    UIButton *_networkConfirmBtn;
}
@property (nonatomic) NSString *ip;
@end
