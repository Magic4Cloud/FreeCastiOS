//
//  TTFacebookViewController.m
//  presentationLiveDemo
//
//  Created by 周恒 on 2017/7/14.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "TTFacebookViewController.h"
#import "FacebookWebViewController.h"
#import "TTNetMannger.h"
#import "TTCoreDataClass.h"

static const NSString * client_id = @"107704292745179";

static const NSString * client_secret = @"38053202e1a5fe26c80c753071f0b573";

@interface TTFacebookViewController ()

@property (weak, nonatomic) IBOutlet UILabel *linkLabel;

@property (weak, nonatomic) IBOutlet UIButton *codeButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity2;

@property (nonatomic, strong)NSDictionary * dict;

@property (nonatomic, strong)NSDictionary * accessTokenDic;

@property (nonatomic, copy) NSString * boundStreamId;

@property (nonatomic, copy) NSString * streamName;

@property (nonatomic, copy) NSString * accesstoken;


@end

@implementation TTFacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self deviceSigin];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (_dict) {
        [self getaccesstoken];
    }
}
- (void)getaccesstoken
{
    
    NSString * device_code = _dict[@"device_code"];
    //2.根据会话对象创建task
    NSString *url = @"https://www.googleapis.com/oauth2/v4/token";
    NSDictionary * paramDic = [NSDictionary dictionaryWithObjectsAndKeys:client_id,@"client_id",client_secret,@"client_secret",device_code,@"code", @"http://oauth.net/grant_type/device/1.0",@"grant_type",nil];
    [self showLoading];
    
    [TTNetMannger postWithUrl:url param:paramDic headerDic:nil complete:^(NSDictionary *dic) {
        _accessTokenDic = dic;
        if (dic[@"access_token"])
        {
            _accesstoken = dic[@"access_token"];
            [self getstream];
        }
        else
        {
            [self hideLoading];
            [self showHudMessage:dic[@"error_description"]];
        }
        
    }];
    
}

- (void)showLoading
{
    [_activity2 startAnimating];
    [self showHudLoading];
    
}

- (void)hideLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activity2 stopAnimating];
        [self hideHudLoading];
    });
}


- (void)getstream
{
    
    NSString * accessToken =  [NSString stringWithFormat:@"Bearer %@",_accesstoken];
    NSDictionary * headerDic = [NSDictionary dictionaryWithObject:accessToken forKey:@"Authorization"];
    NSString * url = @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=contentDetails&broadcastStatus=all&broadcastType=persistent";
    [TTNetMannger getRequestUrl:url param:nil headerDic:headerDic completionHandler:^(NSDictionary *dic) {
        
        if (dic[@"error"]) {
            
            [self showHudMessage:dic[@"error"][@"message"]];
            //如果请求失败  再次请求
            static int requestcount = 0;
            requestcount ++;
            if (requestcount<2)
            {
                [self getstream];
            }
            else
            {
                [self hideLoading];
            }
        }
        
        NSArray * item = dic[@"items"];
        NSDictionary * firstDic = [item firstObject];
        NSDictionary * contentDetails = firstDic[@"contentDetails"];
        if (contentDetails) {
            _boundStreamId = contentDetails[@"boundStreamId"];
            [self getStreamKey];
        }
        else
        {
            [self hideLoading];
        }
        
        
    }];
    
    
    
}

- (void)getStreamKey
{
    
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setValue:@"id,snippet,cdn" forKey:@"part"];
    [paramDic setValue:_boundStreamId forKey:@"id"];
    
    NSString * accessToken =  [NSString stringWithFormat:@"Bearer %@",_accesstoken];
    
    [TTNetMannger getRequestUrl:@"https://www.googleapis.com/youtube/v3/liveStreams" param:paramDic headerDic:@{@"Authorization":accessToken} completionHandler:^(NSDictionary *dic) {
        
        
        if (dic[@"error"])
        {
            [self showHudMessage:dic[@"error"][@"message"]];
            static int requestcount2 = 0;
            requestcount2 ++;
            if (requestcount2<2)
            {
                [self getStreamKey];
            }
            else
            {
                [self hideLoading];
            }
            //如果请求失败  再次请求
        }
        else
        {
            NSArray * item = dic[@"items"];
            NSDictionary * firstDic = [item firstObject];
            NSDictionary * cdn = firstDic[@"cdn"];
            NSDictionary * ingestionInfo = cdn[@"ingestionInfo"];
            NSString * streamKey = ingestionInfo[@"streamName"];
            _streamName = streamKey;
            
            NSString * ingestionAddress = ingestionInfo[@"ingestionAddress"];
            [[TTCoreDataClass shareInstance] updatePlatformWithName:youtubu rtmp:ingestionAddress streamKey:_streamName customString:nil enabel:YES selected:YES];
            [self hideLoading];
            [self showHudMessage:@"get streamkey success!"];
        }
        
    }];
}



- (void)deviceSigin
{
    
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/dialog/oauth"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    NSString * body = [NSString stringWithFormat:@"client_id=%@&response_type=code&scope=user_friends",client_id];
    //5.设置请求体
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [_activityView startAnimating];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            return ;
        }
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dict[@"user_code"]) {
                _dict = dict;
                [_codeButton setTitle:dict[@"user_code"] forState:UIControlStateNormal];
            }
            else
            {
                
            }
            
            [_activityView stopAnimating];
        });

    }];
    
    //7.执行任务
    [dataTask resume];
    
    
    
    
}

- (void)initUI
{
    [self configNavigationWithTitle:@"Authentication" rightButtonTitle:@"Done"];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"Go to http://www.facebook.com/device and paste the code displayed above"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor TTLightBlueColor] range:NSMakeRange(5, 31)];
    
    _linkLabel.attributedText = string;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkLabelClick)];
    [_linkLabel addGestureRecognizer:tap];
    _linkLabel.userInteractionEnabled = YES;
    
    _codeButton.layer.cornerRadius = 15;
    
    
}

#pragma mark - actions
//done
- (void)TTRightButtonClick
{
    
    if (_streamName)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self showHudMessage:NSLocalizedString(@"getyoutubeStreamKeyError", nil)];
    }
}


- (void)linkLabelClick
{
    FacebookWebViewController * vc = [[FacebookWebViewController alloc] init];
//    vc.url = _dict[@"verification_url"];
    vc.url = @"http://www.facebook.com/device";
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)copyCodeButtonClick:(id)sender {
    
    UIButton * button = (UIButton *)sender;
    
    if (![button.currentTitle isEqualToString:@"Loading..."])
    {
        UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = button.currentTitle;
        
        [self showHudMessage:@"Has been copied!"];
    }
    else
    {
        [self showHudMessage:@"wating for get code!"];
    }
}






@end









