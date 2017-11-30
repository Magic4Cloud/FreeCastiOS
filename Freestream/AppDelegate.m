//
//  AppDelegate.m
//  Freestream
//
//  Created by Frank Li on 2017/11/8.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonAppHeader.h"
//controller
#import "FSHomeViewController.h"
#import "FSLeftSideMenuViewController.h"
#import "FSNavigationViewController.h"
//SDK

#import <FBSDKCoreKit/FBSDKCoreKit.h>//Facebook

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES; //不让手机休眠

//    配置facebook
//    [[FBSDKApplicationDelegate sharedInstance] application:application                       didFinishLaunchingWithOptions:launchOptions];
    [self rootViewController];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation];
    return handled;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)rootViewController {
    
    FSHomeViewController *homeVC = [[FSHomeViewController alloc] init];
    
    FSNavigationViewController *naviVC = [[FSNavigationViewController alloc] initWithRootViewController:homeVC];
    
    FSLeftSideMenuViewController *leftVC = [[FSLeftSideMenuViewController alloc] init];
    
    MMDrawerController *sideMenuController  = [[MMDrawerController alloc] initWithCenterViewController:naviVC leftDrawerViewController:leftVC];
    
    sideMenuController.openDrawerGestureModeMask = MMOpenDrawerGestureModeBezelPanningCenterView;
    sideMenuController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    sideMenuController.maximumLeftDrawerWidth = 200 *FSRATIO;
    sideMenuController.shouldStretchDrawer = NO;
    self.window.rootViewController = sideMenuController;
}

@end
