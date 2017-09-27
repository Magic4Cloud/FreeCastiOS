//
//  RotateNavigationControllerViewController.m
//  CloudCompanion
//
//  Created by liweixiang on 15-1-22.
//  Copyright (c) 2015年 rak. All rights reserved.
//

#import "RotateNavigationControllerViewController.h"

@interface RotateNavigationControllerViewController ()

@end

@implementation RotateNavigationControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setHidden:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (BOOL)shouldAutorotate{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
//- (BOOL)shouldAutorotate
//{
////    NSLog(@"shouldAutorotate = %u",self.topViewController.shouldAutorotate);
//    return self.topViewController.shouldAutorotate;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    //NSLog(@"RotateNavigationControllerViewController supportedInterfaceOrientations = %i", self.topViewController.supportedInterfaceOrientations);
////    NSLog(@"？？？？？？？？？topviewcontroller = %@",self.topViewController);
////    NSLog(@"----------------%lu",(unsigned long)self.topViewController.supportedInterfaceOrientations);
//    return self.topViewController.supportedInterfaceOrientations;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    //NSLog(@"RotateNavigationControllerViewController preferredInterfaceOrientationForPresentation = %i", [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation]);
////    NSLog(@">>>>>>>>>>>%lu",(unsigned long)[self.topViewController preferredInterfaceOrientationForPresentation]);
//    return [self.topViewController preferredInterfaceOrientationForPresentation];
//    
//}
@end
