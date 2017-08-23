//
//  FSAlertController.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/23.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSAlertController.h"

@interface FSAlertController ()

@end

@implementation FSAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    
    //    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
//    if ( orientation == UIDeviceOrientationPortrait
//        | orientation == UIDeviceOrientationPortraitUpsideDown) {
//        
//        return YES;
//    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
        if (orientation == (UIInterfaceOrientationLandscapeRight)) {
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    //    UIDevice* device = [UIDevice currentDevice];
    //    if (device.orientation == UIInterfaceOrientationPortraitUpsideDown) {
    //        return UIInterfaceOrientationPortraitUpsideDown;
    //    }
    //    return UIInterfaceOrientationPortrait;
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        return UIInterfaceOrientationLandscapeRight;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}

@end
