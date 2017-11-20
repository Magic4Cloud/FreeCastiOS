//
//  LGSideMenuController+Rotation.m
//  Freestream
//
//  Created by Frank Li on 2017/11/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "LGSideMenuController+Rotation.h"
#import "FSNavigationViewController.h"
@implementation LGSideMenuController (Rotation)

- (FSNavigationViewController *)getFSNavigationController {
    return (FSNavigationViewController *)self.rootViewController;
}

//根视图控制器是否旋转 调用navigation是否旋转 
-(BOOL)shouldAutorotate
{
    return [[self getFSNavigationController] shouldAutorotate];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return [[self getFSNavigationController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return [[self getFSNavigationController] preferredInterfaceOrientationForPresentation];
}
-(BOOL)prefersStatusBarHidden{
    
    return [[self getFSNavigationController] prefersStatusBarHidden];
}



@end
