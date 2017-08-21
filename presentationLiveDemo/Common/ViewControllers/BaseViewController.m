//
//  BaseViewController.m
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "BaseViewController.h"
#import "CommonAppHeaders.h"
#import "BaseViewController+NavigationButton.h"


@interface BaseViewController ()

@end

@implementation BaseViewController

- (void) setup {
    [super setup];
    self.needBackNaviButton = YES;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.needBackNaviButton ){
        [self setupNavigationButtonBack];
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark – Public methods
- (void)showErrorMsg:(NSString *)errorMsg{
    
    [SVProgressHUD showErrorWithStatus:errorMsg];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}
- (void)showSuccessMsg:(NSString *)successMsg{
    [SVProgressHUD showSuccessWithStatus:successMsg];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)showCommonAlertControllerWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmHandler:(void (^)(UIAlertAction *action))confirmHandler cancelHandler:(void (^)(UIAlertAction *action))canceHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert showViewController:self sender:nil];
    UIAlertAction *confirmBtn = [UIAlertAction actionWithTitle:confirmTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:confirmHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:canceHandler];
    [alert addAction:confirmBtn];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
