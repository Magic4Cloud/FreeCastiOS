//
//  CoreStore+App.m
//  Patrol
//
//  Created by Benjamin on 4/6/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "CoreStore+App.h"

@implementation CoreStore (App)
/////////////////////////////get///////////////////////////////////

- (NSString *)currentUseDeviceID{
    return [self stringDataForKey:APP_CURRENT_DEVICE_ID];
}

/////////////////////////////set///////////////////////////////////

- (void)setCurrentUseDeviceID:(NSString *)currentUseDeviceID{
    [self setStringData:currentUseDeviceID forKey:APP_CURRENT_DEVICE_ID];
}




@end
