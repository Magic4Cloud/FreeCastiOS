//
//  SocialShareSNS.m
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "SocialShareSNS.h"

@import UIKit;


@implementation SocialShareSNS

+ (UIActivityViewController *) shareToSocialActivityWithTitle:(NSString *) title contentText:(NSString *) content shareURL:(NSString *) url iconImgURL:(NSString *) imgURL {
    
    if (title == nil) {
        title = @"";
    }
    
    if (content == nil) {
        content = @"";
    }
    
    if (url == nil) {
        url = @"";
    }
    
    if (imgURL == nil) {
        imgURL = @"";
    }
    
    NSArray *excludedActivityArray = @[
                                       UIActivityTypePostToFacebook,
                                       UIActivityTypePostToTwitter,
                                       UIActivityTypePostToWeibo,
                                       UIActivityTypeMessage,
                                       UIActivityTypeMail,
                                       UIActivityTypePrint,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo,
                                       UIActivityTypePostToTencentWeibo,
                                       UIActivityTypeAirDrop
                                       ];
    
    NSDictionary *dic = @{
                          TITILE_KEY: title,
                          CONTENT_KEY: content,
                          URL_KEY: url,
                          IMAGE_KEY: imgURL,
                          };
    
    NSArray *shareItems = @[dic, title, content, url, imgURL];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:shareItems
                                                                               applicationActivities:@[
//                                                                                                       [[WeixinSessionActivity alloc] init]
//                                                                                                       ,[[WeixinTimelineActivity alloc] init]
//                                                                                                       ,[[QQSNSActivity alloc] init]
//                                                                                                       ,[[QQZoneActivity alloc] init]
//                                                                                                       ,[[WeiboSNSActivity alloc] init]
                                                                                                       ]
                                              ];
    
    activityView.excludedActivityTypes = excludedActivityArray;
    activityView.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {};
    
    return activityView;
}

@end
