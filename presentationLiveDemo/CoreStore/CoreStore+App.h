//
//  CoreStore+App.h
//  Patrol
//
//  Created by Benjamin on 4/6/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "CoreStore.h"

@interface CoreStore (App)

#define APP_CURRENT_DEVICE_ID       @"app_current_device_id"

@property (nonatomic, copy)      NSString       *currentUseDeviceID;

@end
