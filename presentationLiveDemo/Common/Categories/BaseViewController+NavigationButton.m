//
//  BaseViewController+NavigationButton.m
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "BaseViewController+NavigationButton.h"

#import "AppDelegate.h"
#import "CommonAppHeaders.h"

@implementation BaseViewController (NavigationButton)

- (void) setupNavigationButtonBack {
    if( self.navigationController.viewControllers.count > 1 ){
        UIButton *backBtn = [self setupNavigationBarButton:NavigationButtonStyleBack target:self aciton:@selector(backButtonTapped:) sidePosition:ButtonInLeftNavigationBar];
        self.navigationItem.backBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

//- (void) setupNavigationButtonMenu {
//    UIButton *menuBtn = [self setupNavigationBarButton:NavigationButtonStyleMenu target:self aciton:@selector(gotoMenuViewControllers:) sidePosition:ButtonInLeftNavigationBar];
//    self.navigationItem.backBarButtonItem = nil;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
//}
//
//- (void) setupNavigationButtonContact {
//    UIButton *contactBtn = [self setupNavigationBarButton:NavigationButtonStyleContact target:self aciton:@selector(gotoContactViewControllers:) sidePosition:ButtonInRightNavigationBar];
//    self.navigationItem.backBarButtonItem = nil;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:contactBtn];
//}

//- (void) setupNavigationButtonAccount {
//    
//}
//
//- (void) setupNavigationButtonMsgCenter {
//    
//}
//
//- (void) setupNavigationButtonSettings {
//    
//}
//
//- (void) setupNavigationButtonShare {
//    
//}

- (UIButton *)setupNavigationBarButton:(NavigationButtonStyle) btnStyle
                                target:(id)target
                                aciton:(SEL)actionSeletor
                          sidePosition:(NavigationButtonSide) side {
    UIImage *normalImage = nil;
    UIImage *highlightedImage = nil;
    
    switch (btnStyle) {
        case NavigationButtonStyleBack: {
            normalImage = [UIImage imageNamed:@"icon_back"];
            highlightedImage = [UIImage imageNamed:@"icon_back"];
            break;
        }
//        case NavigationButtonStyleMenu: {
//            normalImage = [UIImage imageNamed:@"nav_btn_menu_nor"];
//            highlightedImage = [UIImage imageNamed:@"nav_btn_menu_pre"];
//            break;
//        }
//        case NavigationButtonStyleContact: {
//            normalImage = [UIImage imageNamed:@"nav_btn_telephone_nor"];
//            highlightedImage = [UIImage imageNamed:@"nav_btn_telephone_pre"];
//            break;
//        }
//        case NavigationButtonStyleAccount:{
//            normalImage = [UIImage imageNamed:@"nav_btn_personal"];
//            highlightedImage = [UIImage imageNamed:@"nav_btn_personal_pre"];
//            break;
//        }
//        case NavigationButtonStyleSettings:{
//            normalImage = [UIImage imageNamed:@"nav_btn_setting"];
//            highlightedImage = [UIImage imageNamed:@"nav_btn_setting_pre"];
//            break;
//        }
//        case NavigationButtonStyleMsg:{
//            normalImage = [UIImage imageNamed:@"nav_btn_msg"];
//            highlightedImage = [UIImage imageNamed:@"nav_btn_msg_pre"];
//            break;
//        }
//        case NavigationButtonStyleXinteng:{
//            normalImage = [UIImage imageNamed:@"nav_btn_xinteng"];
//            highlightedImage = [UIImage imageNamed:@"nav_btn_xinteng_pre"];
//            break;
//        }
    }
    
    UIButton *barButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [barButton setImage:normalImage forState:UIControlStateNormal];
    [barButton setImage:highlightedImage forState:UIControlStateHighlighted];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    // UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    if (side == ButtonInRightNavigationBar) {
        insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, -10.0f);
        [barButton setImageEdgeInsets:insets];//Offset
    }
    else if (side == ButtonInLeftNavigationBar) {
        insets = UIEdgeInsetsMake(0.0f, -10.0f, 0.0f, 10.0f);
        [barButton setImageEdgeInsets:insets];//Offset
    }
    
    [barButton addTarget:target action:actionSeletor forControlEvents:UIControlEventTouchUpInside];
    
    return barButton;
}

- (void) backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
