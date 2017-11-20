//
//  FSNavigationViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSNavigationViewController.h"
#import "CommonAppHeader.h"
#import "FSLiveViewViewController.h"
@interface FSNavigationViewController ()

@end

@implementation FSNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 如果滑动移除控制器的功能失效，清空代理(让导航控制器重新设置这个功能)
    self.interactivePopGestureRecognizer.delegate = nil;
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor FSMainTextNormalColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:20]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//navigation是否旋转
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    
//    if ([[self.viewControllers lastObject] isKindOfClass:[FSLiveViewViewController class]]) {
//        return UIInterfaceOrientationMaskLandscapeRight;
//    }
    return UIInterfaceOrientationMaskPortrait;
//    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    if ([[self.viewControllers lastObject] isKindOfClass:[FSLiveViewViewController class]]) {
//        return UIInterfaceOrientationLandscapeRight;
//    }
    return UIInterfaceOrientationPortrait;
//    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

- (BOOL)shouldAutorotate{
//    if ([[self.viewControllers lastObject] isKindOfClass:[FSLiveViewViewController class]]) {
//        return NO;
//    }
    return NO;
//        return [[self.viewControllers lastObject] shouldAutorotate];
}

-(BOOL)prefersStatusBarHidden{
//    if ([[self.viewControllers lastObject] isKindOfClass:[FSLiveViewViewController class]]) {
//        return NO;
//    }
    return NO;
//    return [[self.viewControllers lastObject] prefersStatusBarHidden];
}
@end
