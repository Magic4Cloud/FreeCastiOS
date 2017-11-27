//
//  FSBaseViewController+WifiInfo.h
//  Freestream
//
//  Created by Frank Li on 2017/11/28.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSBaseViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface FSBaseViewController (WifiInfo)
//获取wifi名称
- (nullable NSString *)getWifiName;
//获取wifi SSID
- (nullable NSString *)getWifiSSID;
@end
