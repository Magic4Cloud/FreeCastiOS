//
//  FSLeftSideModel.m
//  Freestream
//
//  Created by Frank Li on 2017/11/10.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSLeftSideModel.h"

@implementation FSLeftSideModel

+ (NSArray <NSString *>*)getLeftSideTableViewCellTitles {
    
   return @[NSLocalizedString(@"Version", nil),
            NSLocalizedString(@"Disclaimer", nil),
            NSLocalizedString(@"Privacy Policy", nil),
            NSLocalizedString(@"Copyright", nil),];
}

+ (NSArray <NSString *>*)getLeftSideViewControllersContents {
    
    return @[@"nil",
             NSLocalizedString(@"Disclaimer_content", nil),
             NSLocalizedString(@"Privacy_policy_content", nil),
             NSLocalizedString(@"Copyright_content", nil),];
}

@end
