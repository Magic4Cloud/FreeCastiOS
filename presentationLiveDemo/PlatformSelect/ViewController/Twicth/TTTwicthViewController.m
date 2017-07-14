//
//  TTTwicthViewController.m
//  presentationLiveDemo
//
//  Created by tc on 7/10/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTTwicthViewController.h"
#import "TTCoreDataClass.h"
static NSString * const client_id = @"8kgp38kjc5djcwp6mit4rjap9zgpqm";
@interface TTTwicthViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;

@property (nonatomic, copy) NSString * accessToken;

@property (nonatomic, copy) NSString * streamKey;

@end

@implementation TTTwicthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self configNavigationWithTitle:@"Authentication" rightButtonTitle:nil];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
    
    NSString * urlString = [NSString stringWithFormat:@"https://api.twitch.tv/kraken/oauth2/authorize?client_id=%@&redirect_uri=http://localhost&response_type=token&scope=channel_feed_read",client_id];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [self showHudLoading];
    // Do any additional setup after loading the view.
}


- (void)getStreamKey
{
    NSString * url = @"https://api.twitch.tv/kraken/channel";
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:client_id forKey:@"client_id"];
    [dic setValue:@"http://localhost" forKey:@"redirect_uri"];
    [dic setValue:@"code" forKey:@"response_type"];
    [dic setValue:@"channel_feed_read" forKey:@"scope"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/vnd.twitchtv.v5+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:client_id forHTTPHeaderField:@"Client-ID"];
    NSString * OAuth = [NSString stringWithFormat:@"OAuth %@",_accessToken];
    [manager.requestSerializer setValue:OAuth forHTTPHeaderField:@"Authorization"];
    
    
    manager.requestSerializer.timeoutInterval = 10;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript", @"text/plain", @"text/html", nil];
    
    [manager GET:url parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        /*responseObject:{
         "_id" = 160694976;
         "broadcaster_language" = "<null>";
         "broadcaster_type" = "";
         "created_at" = "2017-06-19T06:06:50Z";
         description = "";
         "display_name" = 873520982;
         email = "873520982@qq.com";
         followers = 0;
         game = "\U7684\U55efKKK";
         language = "zh-cn";
         logo = "<null>";
         mature = 0;
         name = 873520982;
         partner = 0;
         "profile_banner" = "<null>";
         "profile_banner_background_color" = "<null>";
         status = all;
         "stream_key" = "live_160694976_dPlKCbQt5uwz8iYy7deEeOooR3YYF2";
         "updated_at" = "2017-07-10T09:02:08Z";
         url = "https://www.twitch.tv/873520982";
         "video_banner" = "<null>";
         views = 22;
         }
         */
        _streamKey = [NSString stringWithFormat:@"%@?bandwidth_test=true",responseObject[@"stream_key"]];
        [self saveStreamKey];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
    }];
    
}

- (void)saveStreamKey
{
    
    BOOL save = [[TTCoreDataClass shareInstance] updatePlatformWithName:twitch rtmp:@"rtmp://live.twitch.tv/app" streamKey:_streamKey customString:nil enabel:YES selected:NO];
    if (save)
    {
        [self showHudMessage:NSLocalizedString(@"SaveSuccess", nil)];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    else
    {
        [self showHudMessage:NSLocalizedString(@"SaveFail", nil)];
    }
    
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
            //拿到accesstoken了 去拿推流地址
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
    [self hideHudLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError：%@",error);
    [self hideHudLoading];
    [self showHudMessage:error.domain];
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
