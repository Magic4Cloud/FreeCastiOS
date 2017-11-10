//
//  FSLeftSideModel.h
//  Freestream
//
//  Created by Frank Li on 2017/11/10.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>

typedef NS_ENUM(NSInteger, FSLeftSideTitle) {
    FSLeftSideTitleVersion = 0,
    FSLeftSideTitleDisclaimer,
    FSLeftSideTitlePrivacyPolicy,
    FSLeftSideTitleCopyRight,
};
@interface FSLeftSideModel : ModelBaseClass

+ (NSArray <NSString *>*)getLeftSideTableViewCellTitles;
+ (NSArray <NSString *>*)getLeftSideViewControllersContents;

@end
