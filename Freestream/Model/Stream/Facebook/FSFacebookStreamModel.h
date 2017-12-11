//
//  FSFacebookStreamModel.h
//  Freestream
//
//  Created by Frank Li on 2017/12/11.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>

@interface FSFacebookStreamModel : ModelBaseClass

@end
//    code = a90d5ee718ee48c6bc37891baeb0ffab;
//    "expires_in" = 420;
//    interval = 5;
//    "user_code" = 9MT8FB3A;      //需要copy的验证码
//    "verification_uri" = "https://www.facebook.com/device";
@interface FSFacebookVerificationDataModel : ModelBaseClass
@property (nonatomic,copy)   NSString             *Code;
@property (nonatomic,copy)   NSString             *UserCode;
@property (nonatomic,copy)   NSString             *VerificationUri;

@property (nonatomic,assign) NSInteger            ExpiresIn;
@property (nonatomic,assign) NSInteger            IntervalLoop;
@end


