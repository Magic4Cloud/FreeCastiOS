//
//  FacebookWebViewController.m
//  presentationLiveDemo
//
//  Created by 周恒 on 2017/7/14.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FacebookWebViewController.h"

@interface FacebookWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation FacebookWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configNavigationWithTitle:@"" rightButtonTitle:nil];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    
    [self showHudLoading];

    
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideHudLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideHudLoading];
    [self showHudMessage:error.domain];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self cleanCacheAndCookie];
}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

//Set StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden//for iOS7.0
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
