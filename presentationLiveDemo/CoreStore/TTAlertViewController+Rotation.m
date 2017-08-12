//
//  TTAlertViewController+Rotation.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/11.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "TTAlertViewController+Rotation.h"

@implementation TTAlertViewController (Rotation)
#pragma mark self rotate
- (BOOL)shouldAutorotate {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ( orientation == UIDeviceOrientationPortrait
        | orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        return YES;
    }
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIDevice* device = [UIDevice currentDevice];
    if (device.orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown;
    }
    return UIInterfaceOrientationPortrait;
}

@end
