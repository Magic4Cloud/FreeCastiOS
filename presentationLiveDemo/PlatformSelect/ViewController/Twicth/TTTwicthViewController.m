//
//  TTTwicthViewController.m
//  presentationLiveDemo
//
//  Created by tc on 7/10/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTTwicthViewController.h"
static NSString * const client_id = @"8kgp38kjc5djcwp6mit4rjap9zgpqm&redirect_uri=http://localhost&response_type=token&scope=channel_feed_read";
@interface TTTwicthViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;

@property (nonatomic, copy) NSString * accessToken;

@property (nonatomic, copy) NSString * streamKey;

@end

@implementation TTTwicthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
    
    NSString * urlString = [NSString stringWithFormat:@"https://api.twitch.tv/kraken/oauth2/authorize?client_id=%@",client_id];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    // Do any additional setup after loading the view.
}


- (void)getStreamKey
{
    NSString * url = @"https://api.twitch.tv/kraken/channel";
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:@"8kgp38kjc5djcwp6mit4rjap9zgpqm" forKey:@"client_id"];
    [dic setValue:@"http://localhost" forKey:@"redirect_uri"];
    [dic setValue:@"code" forKey:@"response_type"];
    [dic setValue:@"channel_feed_read" forKey:@"scope"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/vnd.twitchtv.v5+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"8kgp38kjc5djcwp6mit4rjap9zgpqm" forHTTPHeaderField:@"Client-ID"];
    NSString * OAuth = [NSString stringWithFormat:@"OAuth %@",_accessToken];
    [manager.requestSerializer setValue:OAuth forHTTPHeaderField:@"Authorization"];
    
    
    manager.requestSerializer.timeoutInterval = 5;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript", @"text/plain", @"text/html", nil];
    
    [manager GET:url parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        _streamKey = responseObject[@"stream_key"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
    }];
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"request:%@\nnavigationType:%ld",request.URL,(long)navigationType);
    NSString * urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:@"http://localhost/"]) {
        NSRange access_tokenRange = [urlString rangeOfString:@"access_token"];
        //删除http://localhost/#access_token=
        urlString = [urlString substringFromIndex:access_tokenRange.location+access_tokenRange.length+1];
        NSArray * array = [urlString componentsSeparatedByString:@"&"];
        
        _accessToken = [[array firstObject] description];
        NSLog(@"_accessToken:%@",_accessToken);
        if (_accessToken) {
            //拿到accesstoken了
            [self getStreamKey];
        }
    }
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError：%@",error);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
