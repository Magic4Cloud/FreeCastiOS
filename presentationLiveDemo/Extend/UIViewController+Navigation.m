//
//  UIViewController+Navigation.m
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "UIViewController+Navigation.h"
#import "MBProgressHUD.h"
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
    _backBtn.frame = CGRectMake(0, 20, 44, 44);
    [_backBtn setImage:[UIImage imageNamed:@"icon_back_blue"] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(TTbackBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    UILabel * _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, ScreenWidth - 80*2, 44)];
    
    _titleLabel.text = @"Stream";
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
    
}

@end
