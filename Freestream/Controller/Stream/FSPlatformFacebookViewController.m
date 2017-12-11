//
//  FSPlatformFacebookViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/12/5.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//
//验证流程:
//1.获取VerificationData：一个时效性为420秒的facebook验证参数包
//2.在弹出的webviewController中登录facebook,登录成功,填入之前获取的user_code,然后用户授权。PS:我们要申请的五个权限必须要通过facebook的应用权限审核，需要很复杂的审核 https://developers.facebook.com/apps/115586109153322/review-status/
//3.完成用户授权后,回到上一界面,这里第一步，获取token(只要用户在420s之内完成授权就可以成功获取到了);第二步用第一步获取到的token,获取userId;第三步用前两步获取的token和id,请求视频推流地址可得到stream_url（可以拆分出rtmp地址和stream_key）


#import "FSPlatformFacebookViewController.h"
#import "CommonAppHeader.h"

#import "FSFaceBookAPIRESTfulService.h"
#import "FSFacebookStreamModel.h"

static NSInteger k_countDownCounter = 0;
static NSInteger K_totalCount       = 8;


@interface FSPlatformFacebookViewController ()
@property (weak, nonatomic) IBOutlet UILabel                 *authenticationCodeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *authenticationCodeActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel                 *gotoFacebookWebLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *successActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton                *authenticationCodeCopyButton;
@property (weak, nonatomic) IBOutlet UILabel *expireLabel;

@property (weak, nonatomic) IBOutlet UILabel *gotoFacebookMsgLabel;

@property (nonatomic,strong) UITapGestureRecognizer  *gotoFacebookTapGestureRecognizer;

@property (nonatomic,strong) FSFacebookVerificationDataModel            *verificationDataModel;
@property (nonatomic,strong) NSTimer                                    *timer;
@property (nonatomic,  copy) NSString                *streamKey;
@property (nonatomic,  copy) NSString                *accesstoken;
@property (nonatomic,  copy) NSString                *userID;

@property (nonatomic,assign) NSInteger               countDownCounter;
@property (nonatomic,assign) NSInteger               totalCount;
@property (nonatomic,assign) BOOL                    isPushed;

@end

@implementation FSPlatformFacebookViewController

#pragma mark - Setters/Getters

- (UITapGestureRecognizer *)gotoFacebookTapGestureRecognizer {
    if (!_gotoFacebookTapGestureRecognizer) {
        _gotoFacebookTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoFacebookWebAction)];
    }
    return _gotoFacebookTapGestureRecognizer;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownCounterRuning) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
//    [self requestDataSource];
    [self requestVerificationData];

    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.isPushed) {
        [self deallocTimer];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

- (void)requestDataSource {
//    The code will expire after 60 seconds
}

#pragma mark – Request service methods
//1.获取VerificationData：一个时效性为420秒的facebook验证参数包
//responseData:{
//    code = a90d5ee718ee48c6bc37891baeb0ffab;
//    "expires_in" = 420;
//    interval = 5;
//    "user_code" = 9MT8FB3A;      //需要copy的验证码
//    "verification_uri" = "https://www.facebook.com/device";
//}
- (void)requestVerificationData {
    
    [self showHudLoading];
    self.expireLabel.hidden = YES;
    self.expireLabel.textColor = [UIColor FSExpireLabelNormalColor];
    
    [self.authenticationCodeActivityIndicatorView startAnimating];
    self.authenticationCodeLabel.textAlignment = NSTextAlignmentLeft;
    self.authenticationCodeLabel.text = NSLocalizedString(@"Loading...", nil);
    self.authenticationCodeLabel.textColor = [UIColor FSAuthenticationCodeLabelNormalColor];
    WEAK(self);
    [[FSFaceBookAPIRESTfulService sharedSingleton] requestVerificationUriAndUserCodeRestultBlock:^(FSFacebookVerificationDataModel * model) {
        if (model && model.UserCode.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.verificationDataModel = model;
                weakself.authenticationCodeLabel.text = model.UserCode;
                weakself.authenticationCodeLabel.textAlignment = NSTextAlignmentCenter;
                [weakself.authenticationCodeActivityIndicatorView stopAnimating];
                [weakself alertUseExpireTimeInterval];
                [weakself hideHudLoading];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.authenticationCodeLabel.text = NSLocalizedString(@"Refresh Code", nil);
                weakself.authenticationCodeLabel.textAlignment = NSTextAlignmentCenter;
                [weakself hideHudLoading];
                [weakself showHudMessage:NSLocalizedString(@"No Network Conection", nil)];
             });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.authenticationCodeActivityIndicatorView stopAnimating];
        });
    }];
}

- (void)alertUseExpireTimeInterval {
    self.expireLabel.hidden = NO;
    self.expireLabel.text = [NSString stringWithFormat:FSLocalizedString(@"Code Expired Interval Message"),(long)_totalCount];
    self.expireLabel.textColor = [UIColor FSExpireLabelNormalColor];
    [self.timer setFireDate:[NSDate distantPast]];
}

//倒计时
- (void)countDownCounterRuning{
    
    if (_countDownCounter < _totalCount) {
        
        self.expireLabel.text = [NSString stringWithFormat:FSLocalizedString(@"Code Expired Interval Message"),(long)(_totalCount - _countDownCounter)];
        ++_countDownCounter;
    }else{
        
        [self deallocTimer];
        
        _countDownCounter = 0;

        self.expireLabel.text = NSLocalizedString(@"Code Expired Alert Message", nil);
        self.expireLabel.textColor = [UIColor FSExpireLabelAlertColor];
        self.authenticationCodeLabel.textColor = [UIColor FSAuthenticationCodeLabelAlertColor];
    }
}

- (void)deallocTimer{
    
    if (_timer.valid) {
        [_timer invalidate];
    }
    _timer = nil;
    
}


//
////这里第一步，获取token(只要用户在420s之内完成授权,回到当前页面，利用之前的VerificationData中的code作为参数就可以成功获取到了)
//- (void)getAccesstoken {
//
////    NSString *url = @"https://graph.facebook.com/v2.6/device/login_status";
//    NSMutableDictionary *paramDic = @{}.mutableCopy;
//    [paramDic setObject:_verificationDic[code_key] forKey:code_key];
//    [paramDic setObject:Access_token_value forKey:access_token_key];
//
//    [self showLoadingStatus];
//
//    [TTNetMannger postWithUrl:requestAccessTokenUrl param:paramDic headerDic:nil complete:^(NSDictionary *dic) {
//        if (dic){
//            if (dic[access_token_key]) {
//                _accesstoken = dic[access_token_key];
//                //                存储USER_ACCESS_TOKEN
//                [CoreStore sharedStore].fbUserAccessToken = dic[access_token_key];
//                [self getId];
//            } else {
//                [self hideLoading];
//                [self showHudMessage:dic[@"error"][@"error_user_msg"]];
//            }
//        } else {
//            [self hideLoading];
//            [self showHudMessage:@"No network connection"];
//        }
//
//    }];
//}

- (void)showLoadingStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.successActivityIndicatorView startAnimating];
        [self showHudLoading];
    });
}

- (void)hideLoadingStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.successActivityIndicatorView stopAnimating];
        [self hideHudLoading];
    });
}

#pragma mark – Private methods

- (void)setupUI {
    
    self.title = NSLocalizedString(@"Authentication", nil);
    
    self.authenticationCodeCopyButton.layer.cornerRadius = CGRectGetHeight(self.authenticationCodeCopyButton.bounds) /2.f;
    
    [self.gotoFacebookWebLabel addGestureRecognizer:self.gotoFacebookTapGestureRecognizer];
    
    self.gotoFacebookWebLabel.userInteractionEnabled = YES;
    
    _countDownCounter = k_countDownCounter;
    _totalCount       = K_totalCount;
    
    [self setNavigationBarRightItem];
    
    [self localizedGotoFacebookMsgLabel];
}

- (void)setNavigationBarRightItem {

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitleColor:[UIColor FSPlatformButtonSelectedBackgroundColor] forState:UIControlStateNormal];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    [self.navigationItem setRightBarButtonItem:doneItem];
}

//由于gotoFacebookMsgLabel是富文本,所以做判断,单独进行国际化处理
- (void)localizedGotoFacebookMsgLabel {
    
    if (![[FSGlobalization currentLanguageCode] isEqualToString:@"zh-Hans"]) {
//        只对简体中文语言环境 特殊配置
        return;
    }
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"点击前往 http://www.facebook.com/device 登录账号成功之后,粘贴设备用户码进行验证"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor FSPlatformButtonSelectedBackgroundColor] range:NSMakeRange(5, 31)];
    
    self.gotoFacebookMsgLabel.attributedText = string;
}

#pragma mark – Target action methods

- (void)doneButtonDidClick {
    NSLog(@"----------------%s",__func__);
}

- (void)gotoFacebookWebAction {
    self.isPushed = YES;
    FSBaseWebViewController * vc = [[FSBaseWebViewController alloc] init];
    vc.title = self.title;
    vc.urlString = @"http://www.facebook.com/device";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - IBActions

- (IBAction)copyTheCodeAction:(UIButton *)sender {
    
    if ([self.authenticationCodeLabel.text isEqualToString:NSLocalizedString(@"Loading...", nil)]&& self.authenticationCodeActivityIndicatorView.isAnimating) {
        return;
    } else if (([self.authenticationCodeLabel.text isEqualToString:NSLocalizedString(@"Refresh Code", nil)]&& self.authenticationCodeActivityIndicatorView.isAnimating == NO) || ([self.expireLabel.text isEqualToString:NSLocalizedString(@"Code Expired Alert Message", nil)]) ) {
        [self requestVerificationData];
        return;
    }
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.authenticationCodeLabel.text;
    
    if ([pboard.string isEqualToString:self.authenticationCodeLabel.text]) {
        [self showHudMessage:NSLocalizedString(@"Copy successful", nil)];
    } else {
        [self showHudMessage:NSLocalizedString(@"Copy faild", nil)];
    }
}

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods
- (void)dealloc {
    
    [self deallocTimer];
    NSLog(@"----------------%s",__func__);
}
#pragma mark – Delegate


@end
