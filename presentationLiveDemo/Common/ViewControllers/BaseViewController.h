//
//  BaseViewController.h
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "CoreUIViewController.h"

@interface BaseViewController : CoreUIViewController

//- (void)showErrorMsg:(NSString *)errorMsg;
//- (void)showSuccessMsg:(NSString *)successMsg;

@property (nonatomic, assign) BOOL needBackNaviButton;

- (void)showCommonAlertControllerWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmHandler:(void (^)(UIAlertAction *action))confirmHandler cancelHandler:(void (^)(UIAlertAction *action))canceHandler;

@end
