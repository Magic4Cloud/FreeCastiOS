//
//  PauseScreenViewController.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PauseScreenViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    
    UIView *_pauseScreenPushView;
    UILabel *_pauseScreenPushLabel;
    UISwitch *_pauseScreenPushBtn;
    
    UIView *_pauseScreenPicturePushView;
    UIImageView *_pauseScreenPicturePushImg;
    UIButton *_pauseScreenPicturePushBtn;
    
    UIView *_pauseScreenVideoPushView;
    UILabel *_pauseScreenVideoPushLabel;
    UISwitch *_pauseScreenVideoPushBtn;
    
    UIView *_pauseScreenVideoView;
    UIImageView *_pauseScreenVideoImg;
    UIButton *_pauseScreenVideoBtn;
    
    UIImagePickerController *_imagePickerController;
    UIView *_chooseImgView;
}
@end
