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

- (void)showPromptAlertWithTitile:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle buttonClickHandler:(void (^ )(UIAlertAction * action))buttonClick;
- (void)showAlertWithTitile:(NSString *)title message:(NSString *)message leftButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rightTitle leftButtonClickHandler:(void (^ )(UIAlertAction * action))leftButtonClick rightButtonClickHandler:(void (^ )(UIAlertAction * action))rightButtonClick;
- (void)showActionSheetWithTitle:(NSString *)title message:(NSString *)message action1title:(NSString *)action1title action2title:(NSString *)action2title action3title:(NSString *)action3title action1Handler:(void(^ )(UIAlertAction * action))action1Click action2Handler:(void(^ )(UIAlertAction * action))action2Click  action3Handler:(void(^ )(UIAlertAction * action))action3Click;

@end
