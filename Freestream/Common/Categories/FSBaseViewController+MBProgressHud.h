//
//  FSBaseViewController+MBProgressHud.h
//  Freestream
//
//  Created by Frank Li on 2017/12/6.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSBaseViewController.h"

@interface FSBaseViewController (MBProgressHud)
- (void)showHudMessage:(NSString *)string;

- (void)showHudLoading;

- (void)hideHudLoading;
@end
