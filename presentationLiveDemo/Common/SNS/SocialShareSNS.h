//
//  SocialShareSNS.h
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIActivityViewController;


#define     TITILE_KEY      @"title_key"
#define     CONTENT_KEY     @"content_key"
#define     URL_KEY         @"url_key"
#define     IMAGE_KEY       @"image_key"

@interface SocialShareSNS : NSObject

+ (UIActivityViewController *) shareToSocialActivityWithTitle:(NSString *) title contentText:(NSString *) content shareURL:(NSString *) url iconImgURL:(NSString *) imgURL;

@end
