//
//  AppDelegate.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/9.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "SWRevealViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) ViewController *homePageVC;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SWRevealViewController *revealViewController;

@end

