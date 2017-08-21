//
//  BaseWebViewController.h
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "BaseViewController.h"

#import <WebKit/WebKit.h>

@class ShareInfoModel;


@interface BaseWebViewController : BaseViewController

@property (nonatomic, strong)    WKWebView       *webView;
@property (nonatomic, strong)    ShareInfoModel  *sharingData;

- (void)setupWebViewBackButtonNavigationBar;
- (void)shareSNS;

@end
