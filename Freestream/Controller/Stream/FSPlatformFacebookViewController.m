//
//  FSPlatformFacebookViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/12/5.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSPlatformFacebookViewController.h"
#import "CommonAppHeader.h"

static NSString const*app_id               = @"115586109153322";
static NSString const*app_secret           = @"fd18fde29cdc12290fe08ad0672b7a0a";
static NSString const*client_token         = @"766ef0f7747b190ca998851d5e277bce";

static NSString const*access_token_key     = @"access_token";
static NSString const*code_key             = @"code";
static NSString const*scope_key            = @"scope";
static NSString const*user_code_key        = @"user_code";
static NSString const*stream_url_key       = @"stream_url";
static NSString const*verification_uri_key = @"verification_uri";
//请求的直播权限 包含以下五点
#define Scope_value @"public_profile,publish_actions,manage_pages,publish_pages,user_managed_groups,user_events"

//请求验证码时候 用这个作为access_token
#define Access_token_value [NSString stringWithFormat:@"%@|%@",app_id,client_token]

@interface FSPlatformFacebookViewController ()
@property (weak, nonatomic) IBOutlet UILabel                 *authenticationCodeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *authenticationCodeActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel                 *gotoFacebookWebLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *successActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton                *authenticationCodeCopyButton;

@property (nonatomic,strong) UITapGestureRecognizer  *gotoFacebookTapGestureRecognizer;
@property (nonatomic,strong) NSDictionary            *verificationDic;
@property (nonatomic,  copy) NSString                *streamKey;
@property (nonatomic,  copy) NSString                *accesstoken;
@property (nonatomic,  copy) NSString                *userID;

@end

@implementation FSPlatformFacebookViewController

#pragma mark - Setters/Getters

- (UITapGestureRecognizer *)gotoFacebookTapGestureRecognizer {
    if (!_gotoFacebookTapGestureRecognizer) {
        _gotoFacebookTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoFacebookWebAction)];
    }
    return _gotoFacebookTapGestureRecognizer;
}

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarRightItem];
    [self requestDataSource];
    
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
    
}

#pragma mark – Private methods
- (void)setNavigationBarRightItem {
    
    self.title = NSLocalizedString(@"Authentication", nil);
    
    
    self.authenticationCodeCopyButton.layer.cornerRadius = CGRectGetHeight(self.authenticationCodeCopyButton.bounds) /2.f;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitleColor:[UIColor FSPlatformButtonSelectedBackgroundColor] forState:UIControlStateNormal];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    [self.navigationItem setRightBarButtonItem:doneItem];
    
    [self.gotoFacebookWebLabel addGestureRecognizer:self.gotoFacebookTapGestureRecognizer];
    self.gotoFacebookWebLabel.userInteractionEnabled = YES;
    
}

#pragma mark – Target action methods

- (void)doneButtonDidClick {
    NSLog(@"----------------%s",__func__);
}

- (void)gotoFacebookWebAction {
    FSBaseWebViewController * vc = [[FSBaseWebViewController alloc] init];
    vc.title = self.title;
    vc.urlString = @"http://www.facebook.com/device";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - IBActions

- (IBAction)copyTheCodeAction:(UIButton *)sender {
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    NSLog(@"---------pboard.string = %@---------",self.authenticationCodeLabel.text);
    pboard.string = self.authenticationCodeLabel.text;
}

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate


@end
