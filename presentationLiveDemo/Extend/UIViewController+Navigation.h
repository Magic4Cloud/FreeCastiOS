//
//  UIViewController+Navigation.h
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Navigation)
- (void)configNavigationWithTitle:(NSString *)title rightButtonTitle:(NSString *)buttonTitle;
- (void)showHudMessage:(NSString *)string;
- (void)showHudLoading;
- (void)hideHudLoading;

- (void)showAlertWithTitile:(NSString *)title message:(NSString *)message leftButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rightTitle leftButtonClickHandler:(void (^ )(UIAlertAction * action))leftButtonClick rightButtonClickHandler:(void (^ )(UIAlertAction * action))rightButtonClick;
@end
