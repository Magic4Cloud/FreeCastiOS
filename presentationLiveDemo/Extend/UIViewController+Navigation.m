//
//  UIViewController+Navigation.m
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "UIViewController+Navigation.h"
#import "MBProgressHUD.h"
#import "TTAlertViewController.h"

@implementation UIViewController (Navigation)
- (void)configNavigationWithTitle:(NSString *)title rightButtonTitle:(NSString *)buttonTitle
{
    
    //顶部
    UIImageView *  _topBg=[[UIImageView alloc] initWithImage:nil];
    _topBg.backgroundColor = [UIColor whiteColor];
    _topBg.frame = CGRectMake(0, 0, ScreenWidth, 64);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
    UIButton * _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(16, 32, 24, 24);

    [_backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(TTbackBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    UILabel * _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, ScreenWidth - 80*2, 44)];
    
    _titleLabel.text = title;
    _titleLabel.font = [UIFont systemFontOfSize: 20];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor TTLightBlueColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    if (buttonTitle) {
        UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setTitleColor:[UIColor TTLightBlueColor] forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [rightButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.view addSubview:rightButton];
        rightButton.frame = CGRectMake(ScreenWidth - 70, 20, 70, 44);
        [rightButton addTarget:self action:@selector(TTRightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    

}

- (void)TTbackBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)showHudMessage:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = string;
        HUD.mode = MBProgressHUDModeText;
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
            [HUD removeFromSuperview];
            //[HUD release];
            //HUD = nil;
        }];
    });
}

- (void)showHudLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeIndeterminate;
        [HUD show:YES];
    });
}

- (void)hideHudLoading
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)showAlertWithTitile:(NSString *)title message:(NSString *)message leftButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rightTitle leftButtonClickHandler:(void (^ )(UIAlertAction * action))leftButtonClick rightButtonClickHandler:(void (^ )(UIAlertAction * action))rightButtonClick
{
    TTAlertViewController * alertVc = [TTAlertViewController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * leftAction = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleCancel handler:leftButtonClick];
    
    UIAlertAction * rightAction = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:rightButtonClick];
    
    [alertVc addAction:leftAction];
    [alertVc addAction:rightAction];
    [self presentViewController:alertVc animated:YES completion:^{
        
    }];
}



@end
