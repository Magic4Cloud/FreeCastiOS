//
//  AudioViewController.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_audioView;
    UIImageView *_audioHDMIImg;
    UIImageView *_audioExternalImg;
    UIButton *_audioHDMIBtn;
    UIButton *_audioExternalBtn;
    
    UILabel *_audioTips1Label;
    UILabel *_audioTips2Label;
    UILabel *_audioTips3Label;
}
@property (nonatomic) NSString *ip;

@end
