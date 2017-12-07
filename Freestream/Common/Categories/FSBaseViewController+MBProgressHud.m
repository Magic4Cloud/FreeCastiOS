//
//  FSBaseViewController+MBProgressHud.m
//  Freestream
//
//  Created by Frank Li on 2017/12/6.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSBaseViewController+MBProgressHud.h"
#import "CommonAppHeader.h"
@implementation FSBaseViewController (MBProgressHud)
- (void)showHudMessage:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text =string;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [hud hideAnimated:YES];
        });
    });
}

- (void)showHudLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
    });
}

- (void)hideHudLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}
@end
