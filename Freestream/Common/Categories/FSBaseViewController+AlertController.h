//
//  FSBaseViewController+AlertController.h
//  Freestream
//
//  Created by Frank Li on 2017/11/28.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSBaseViewController.h"

@interface FSBaseViewController (AlertController)

- (void)showAlertViewWithTitle:(nullable NSString *)title
                       Message:(nullable NSString *)msg
                    cancelText:(nullable NSString *)cancelText
                   confirmText:(nullable NSString *)confirmText
                 cancelHandler:(void (^ __nullable)(UIAlertAction *_Nullable action))cancelHandler
                confirmHandler:(void (^ __nullable)(UIAlertAction *_Nullable action))confirmHandler;

- (void)showAlertSheetWithTitle:(nullable NSString *)title
                        Message:(nullable NSString *)msg
                    action1text:(nullable NSString *)action1Text
                    action2text:(nullable NSString *)action2Text
                    action3text:(nullable NSString *)action3Text
                 action1Handler:(void (^ __nullable)(UIAlertAction *_Nullable action))action1Handler
                 action2Handler:(void (^ __nullable)(UIAlertAction *_Nullable action))action2Handler
                 action3Handler:(void (^ __nullable)(UIAlertAction *_Nullable action))action3Handler;
@end
