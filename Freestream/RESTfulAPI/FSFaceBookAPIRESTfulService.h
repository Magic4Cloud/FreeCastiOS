//
//  FSFaceBookAPIRESTfulService.h
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>

@interface FSFaceBookAPIRESTfulService : NSObject
+ (instancetype)sharedSingleton;

//STEP 1. The encoder sends a request to Facebook for a VERIFICATION_URI and a USER_CODE:
- (void)requestVerificationUriAndUserCodeRestultBlock:(void (^)(ServiceResultInfo *statusInfo))completions;

@end
