//
//  FSFaceBookAPIURL.h
//  Freestream
//
//  Created by Frank Li on 2017/11/13.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#ifndef FSFaceBookAPIURL_h
#define FSFaceBookAPIURL_h

#import "CommonAppHeader.h"
#import "FSBaseAPIURL.h"

//STEP 1. The encoder sends a request to Facebook for a VERIFICATION_URI and a USER_CODE:
#define URL_POST_Device_Login [NSString stringWithFormat:@"%@device/login", RESTFUL_BASE_HOST]



#endif /* FSFaceBookAPIURL_h */
