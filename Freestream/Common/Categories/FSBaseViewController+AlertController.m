//
//  FSBaseViewController+AlertController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/28.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSBaseViewController+AlertController.h"
#import "FSAlertController.h"

@implementation FSBaseViewController (AlertController)

- (void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)msg cancelText:(NSString *)cancelText confirmText:(NSString *)confirmText cancelHandler:(void (^)(UIAlertAction *action))cancelHandler confirmHandler:(void (^)(UIAlertAction *action))confirmHandler {
    
    FSAlertController * alertController = [FSAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:cancelHandler];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:confirmHandler];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    //    setting For ipad
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;
    
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

- (void)showAlertSheetWithTitle:(NSString *)title Message:(NSString *)msg action1text:(NSString *)action1Text action2text:(NSString *)action2Text action3text:(NSString *)action3Text action1Handler:(void (^)(UIAlertAction *action))action1Handler action2Handler:(void (^)(UIAlertAction *action))action2Handler action3Handler:(void (^)(UIAlertAction *action))action3Handler {
    
    
    FSAlertController *alertController = [FSAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:action1Text style:UIAlertActionStyleDefault handler:action1Handler];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:action2Text style:UIAlertActionStyleDefault handler:action2Handler];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:action3Text style:UIAlertActionStyleDefault handler:action3Handler];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;
    
    [self presentViewController:alertController animated:YES completion:^{}];
}
@end
