//
//  TTYoutubuViewController.m
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTYoutubuViewController.h"

#import "WebViewController.h"


#import "TTNetMannger.h"

#import "TTCoreDataClass.h"
static const NSString * client_id = @"945244505483-5ehvap33vg7mksb8b5981fmrknq82eiq.apps.googleusercontent.com";
static const NSString * client_secret = @"eGP1p47CilC4AAy3G8Gk6Mk4";

@interface TTYoutubuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;

@property (weak, nonatomic) IBOutlet UIButton *codeButton;

@property (nonatomic, strong)NSDictionary * dict;

@property (nonatomic, strong)NSDictionary * accessTokenDic;

@property (nonatomic, copy) NSString * boundStreamId;

@property (nonatomic, copy) NSString * streamName;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity2;

@end

@implementation TTYoutubuViewController


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
    
    
    
    [_activity2 startAnimating];

    [TTNetMannger postWithUrl:url param:paramDic headerDic:nil complete:^(NSDictionary *dic) {

        _accessTokenDic = dic;
        [self getstream];
    }];
    
    
    
   
}
- (void)getstream {
    
//    NSDictionary * paramDic = [NSDictionary dictionaryWithObjectsAndKeys:@"contentDetails",@"part",@"all",@"broadcastStatus",@"persistent",@"broadcastType", nil];
    
//    NSDictionary * paramDic = [NSDictionary dictionaryWithObjectsAndKeys:@"contentDetails",@"part",@"all",@"broadcastStatus", nil];
    
     NSString * accessToken =  [NSString stringWithFormat:@"Bearer %@",_accessTokenDic[@"access_token"]];
    
    NSDictionary * headerDic = [NSDictionary dictionaryWithObject:accessToken forKey:@"Authorization"];
    
    NSString * url = @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=contentDetails&broadcastStatus=all&broadcastType=persistent";
    [TTNetMannger getRequestUrl:url param:nil headerDic:headerDic completionHandler:^(NSDictionary *dic) {
    
        
        
        NSArray * item = dic[@"items"];
        NSDictionary * firstDic = [item firstObject];
        NSDictionary * contentDetails = firstDic[@"contentDetails"];
        if (contentDetails) {
            _boundStreamId = contentDetails[@"boundStreamId"];
            [self getStreamKey];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activity2 stopAnimating];
        });
        
    }];
    

    
}

- (void)getStreamKey
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setValue:@"cdn" forKey:@"part"];
    [paramDic setValue:_boundStreamId forKey:@"id"];
    
    NSString * accessToken =  [NSString stringWithFormat:@"Bearer %@",_accessTokenDic[@"access_token"]];
    
    [TTNetMannger getRequestUrl:@"https://www.googleapis.com/youtube/v3/liveStreams" param:paramDic headerDic:@{@"Authorization":accessToken} completionHandler:^(NSDictionary *dic) {
        
        NSArray * item = dic[@"items"];
        NSDictionary * firstDic = [item firstObject];
        NSDictionary * cdn = firstDic[@"cdn"];
        NSDictionary * ingestionInfo = cdn[@"ingestionInfo"];
        NSString * streamKey = ingestionInfo[@"streamName"];
        _streamName = streamKey;
        
        NSString * ingestionAddress = ingestionInfo[@"ingestionAddress"];
        [[TTCoreDataClass shareInstance] updatePlatformWithName:youtubu rtmp:ingestionAddress streamKey:_streamName customString:nil enabel:YES selected:YES];
    }];
}


- (void)deviceSigin
{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/device/code"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    NSString * body = [NSString stringWithFormat:@"client_id=%@&scope= https://www.googleapis.com/auth/youtube",client_id];
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

    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"Go to http://www.google.com/device and paste the code displayed above"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor TTLightBlueColor] range:NSMakeRange(5, 29)];
    
    _linkLabel.attributedText = string;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkLabelClick)];
    [_linkLabel addGestureRecognizer:tap];
    _linkLabel.userInteractionEnabled = YES;
    
    
}

#pragma mark - actions  
//done
- (void)TTRightButtonClick
{
    if (_streamName) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)linkLabelClick
{
    WebViewController * vc = [[WebViewController alloc] init];
    vc.url = _dict[@"verification_url"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)copyCodeButtonClick:(id)sender {
    UIButton * button = (UIButton *)sender;
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = button.currentTitle;
    
    [self showHudMessage:@"Has been copied!"];

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
