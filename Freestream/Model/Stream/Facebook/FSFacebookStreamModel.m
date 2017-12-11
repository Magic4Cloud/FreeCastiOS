//
//  FSFacebookStreamModel.m
//  Freestream
//
//  Created by Frank Li on 2017/12/11.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSFacebookStreamModel.h"

@implementation FSFacebookStreamModel

@end

@implementation FSFacebookVerificationDataModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             
             @"Code"             : @"code",
             @"UserCode"         : @"user_code",
             @"VerificationUri"  : @"verification_uri",
             @"ExpiresIn"        : @"expires_in",
             @"IntervalLoop"     : @"interval",
             };
}

@end
