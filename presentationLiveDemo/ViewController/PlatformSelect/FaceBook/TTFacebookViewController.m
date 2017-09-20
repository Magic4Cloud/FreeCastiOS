//
//  TTFacebookViewController.m
//  presentationLiveDemo
//
//  Created by FrankLi on 2017/9/19.
//  Copyright © 2017年 FrankLi. All rights reserved.
//验证流程:
//1.获取一个user_code(可以理解为一个时效性为420秒的facebook验证参数)
//2.登录facebook,登录成功,填入之前获取的user_code,然后用户授权。注意，我们要申请的五个权限必须要通过facebook的应用审核，需要很复杂的审核（这个并不是申请应用，而是权限的应用审核）。
//3.

#import "TTFacebookViewController.h"
#import "CommonAppHeaders.h"
#import "FacebookWebViewController.h"
#import "WebViewController.h"
#import "TTNetMannger.h"
#import "TTCoreDataClass.h"

static NSString const*app_id           = @"115586109153322";
static NSString const*app_secret       = @"fd18fde29cdc12290fe08ad0672b7a0a";
static NSString const*client_token     = @"766ef0f7747b190ca998851d5e277bce";

static NSString const*access_token_key = @"access_token";
static NSString const*code_key         = @"code";
static NSString const*scope_key        = @"scope";
static NSString const*user_code_key    = @"user_code";
static NSString const*stream_url_key   = @"stream_url";
static NSString const*verification_uri_key = @"verification_uri";
//请求的直播权限 包含以下五点
#define Scope_value @"public_profile,publish_actions,manage_pages,publish_pages,user_managed_groups,user_events"
//请求验证码时候 用这个作为access_token
#define Access_token_value [NSString stringWithFormat:@"%@|%@",app_id,client_token]

@interface TTFacebookViewController ()

@property (weak, nonatomic) IBOutlet UILabel *linkLabel;

@property (weak, nonatomic) IBOutlet UIButton *codeButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity2;

@property (nonatomic, strong)NSDictionary * verificationDic;

@property (nonatomic, copy) NSString * streamKey;

@property (nonatomic, copy) NSString * accesstoken;

@property (nonatomic, copy) NSString * userID;


@end

@implementation TTFacebookViewController

#pragma mark - Setters/Getters

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestVerificationData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_verificationDic) {
        [self getAccesstoken];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods
//从facebook获取校验数据
//responseData:{
//    code = a90d5ee718ee48c6bc37891baeb0ffab;
//    "expires_in" = 420;
//    interval = 5;
//    "user_code" = 9MT8FB3A;
//    "verification_uri" = "https://www.facebook.com/device";
//}
- (void)requestVerificationData {
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:Access_token_value forKey:access_token_key];
    [paramDic setObject:Scope_value forKey:scope_key];
    
    NSString * url = [NSString stringWithFormat:@"https://graph.facebook.com/v2.6/device/login"];
    
    [_activityView startAnimating];
    
    [TTNetMannger postWithUrl:url param:paramDic headerDic:nil complete:^(NSDictionary *dic) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dic[user_code_key]) {
                _verificationDic = dic;
                [_codeButton setTitle:dic[user_code_key] forState:UIControlStateNormal];
            } else {
                
            }
            [_activityView stopAnimating];
        });
    }];
}


- (void)getAccesstoken {
    
    NSString *url = @"https://graph.facebook.com/v2.6/device/login_status";
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_verificationDic[code_key] forKey:code_key];
    [paramDic setObject:Access_token_value forKey:access_token_key];
    [self showLoading];
    
    [TTNetMannger postWithUrl:url param:paramDic headerDic:nil complete:^(NSDictionary *dic) {
        
        if (dic[access_token_key]) {
            _accesstoken = dic[access_token_key];
            [self getId];
        } else {
            [self hideLoading];
            [self showHudMessage:dic[@"error"][@"error_user_msg"]];
        }
    }];
}

- (void)getId {
    
    NSString *urlStr = [NSString stringWithFormat:@"https://graph.facebook.com/v2.10/me?fields=id&access_token=%@",_accesstoken];
    [TTNetMannger getRequestUrl:urlStr param:nil headerDic:nil completionHandler:^(NSDictionary *dic) {
        if (dic[@"error"]) {
            
            [self showHudMessage:dic[@"error"][@"message"]];
            //如果请求失败  再次请求
            static int requestcount = 0;
            requestcount ++;
            if (requestcount<2) {
                [self getId];
            } else {
                [self hideLoading];
            }
        } else {
            _userID = dic[@"id"];
            [self getstream];
        }
    }];
}

- (void)getstream {
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_accesstoken forKey:@"access_token"];
    
    NSString * url = [NSString stringWithFormat:@"https://graph.facebook.com/v2.10/%@/live_videos",_userID];
    
    [TTNetMannger postWithUrl:url param:paramDic headerDic:nil complete:^(NSDictionary *dic) {
        
        if (dic[@"error"]) {
            [self showHudMessage:dic[@"error"][@"message"]];
            //如果请求失败  再次请求
            static int requestcount = 0;
            requestcount ++;
            if (requestcount<2) {
                [self getstream];
            } else {
                [self hideLoading];
            }
        } else {
            NSLog(@"----------------%@",dic);
            NSString *streamUrlString = dic[stream_url_key];
            
            NSRange range = [streamUrlString rangeOfString:@"rtmp/"];
            
            NSString * rmtpUrlString = [streamUrlString substringToIndex:range.location + range.length];
            NSString *streamKey = [streamUrlString substringFromIndex:range.location + range.length];
            _streamKey = streamKey;
            
            [[TTCoreDataClass shareInstance] updatePlatformWithName:faceBook rtmp:rmtpUrlString streamKey:streamKey customString:nil enabel:YES selected:YES];
            
            [self hideLoading];
            [self showHudMessage:@"get streamkey success!"];
        }
    }];
}

#pragma mark – Private methods

- (void)initUI {
    [self configNavigationWithTitle:@"Authentication" rightButtonTitle:@"Done"];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"Go to http://www.facebook.com/device and paste the code displayed above"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor TTLightBlueColor] range:NSMakeRange(5, 31)];
    
    _linkLabel.attributedText = string;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkLabelClick)];
    [_linkLabel addGestureRecognizer:tap];
    _linkLabel.userInteractionEnabled = YES;
    
    _codeButton.layer.cornerRadius = 15;
    
}

#pragma mark – Target action methods

- (void)linkLabelClick {
    WebViewController * vc = [[WebViewController alloc] init];
    vc.url = _verificationDic[verification_uri_key];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showLoading {
    [_activity2 startAnimating];
    [self showHudLoading];
}

- (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activity2 stopAnimating];
        [self hideHudLoading];
        [self hideHudLoading];
    });
}

#pragma mark - IBActions

- (IBAction)copyCodeButtonClick:(id)sender {
    
    UIButton * button = (UIButton *)sender;
    
    if (![button.currentTitle isEqualToString:@"Loading..."])
    {
        UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = button.currentTitle;
        
        [self showHudMessage:@"Copy successful!"];
    } else {
        [self showHudMessage:@"Wating for a code!"];
    }
}

//done
- (void)TTRightButtonClick
{
    
    if (_streamKey)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self showHudMessage:NSLocalizedString(@"getyoutubeStreamKeyError", nil)];
    }
}

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate

@end
