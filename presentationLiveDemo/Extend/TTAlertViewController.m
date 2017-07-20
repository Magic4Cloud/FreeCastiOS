//
//  TTAlertViewController.m
//  presentationLiveDemo
//
//  Created by tc on 7/20/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTAlertViewController.h"

@interface TTAlertViewController ()

@end

@implementation TTAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}



@end
