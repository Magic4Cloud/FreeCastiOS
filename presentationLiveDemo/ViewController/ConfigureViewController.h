//
//  ConfigureViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/17.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigureViewController : UIViewController
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIImageView *_configureImg;
    UIButton *_configureWifi;
    UIButton *_configureVideo;
    UIButton *_configureAudio;
}
@end
