//
//  BaseViewController+NavigationButton.h
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, NavigationButtonStyle) {
    NavigationButtonStyleBack = 1,
//    NavigationButtonStyleMenu = 2,
//    NavigationButtonStyleContact = 3,
//    NavigationButtonStyleAccount = 2,
//    NavigationButtonStyleMsg = 3,
//    NavigationButtonStyleSettings = 4,
//    NavigationButtonStyleShare = 5,
};

typedef NS_ENUM(NSInteger, NavigationButtonSide) {
    ButtonInLeftNavigationBar = 1,
    ButtonInRightNavigationBar = 2,
};


@interface BaseViewController (NavigationButton)

- (void) setupNavigationButtonBack;
//- (void) setupNavigationButtonMenu;
//- (void) setupNavigationButtonContact;
//- (void) setupNavigationButtonAccount;
//- (void) setupNavigationButtonMsgCenter;
//- (void) setupNavigationButtonSettings;
//- (void) setupNavigationButtonShare;

- (UIButton *)setupNavigationBarButton:(NavigationButtonStyle) btnStyle
                                target:(id)target
                                aciton:(SEL)actionSeletor
                          sidePosition:(NavigationButtonSide) side;

@end
