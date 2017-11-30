//
//  FSHomeViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSHomeViewController.h"
#import "FSHomePageButtonView.h"
#import "CommonAppHeader.h"

//controllers
#import "FSLiveViewViewController.h"

@interface FSHomeViewController ()<FSHomePageButtonViewDelegate>
@property (weak, nonatomic) IBOutlet UIView               *effectView;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *liveViewButton;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *streamButton;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *configureButton;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *browseButton;

@property (strong, nonatomic) FBSDKLoginButton *loginButton;

@end

@implementation FSHomeViewController

#pragma mark - Setters/Getters

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtonViews];
    [self addEffectViewForBgImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    启用侧滑手势
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
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

#pragma mark – Private methods
- (void)setupButtonViews{

    [self.liveViewButton  setupButtonViewWithTag:FSHomePageButtonLiveView];
    [self.streamButton    setupButtonViewWithTag:FSHomePageButtonStream];
    [self.configureButton setupButtonViewWithTag:FSHomePageButtonConfigure];
    [self.browseButton    setupButtonViewWithTag:FSHomePageButtonBrowse];
    
    self.liveViewButton.delegate  = self;
    self.streamButton.delegate    = self;
    self.configureButton.delegate = self;
    self.browseButton.delegate    = self;
}

- (void)addEffectViewForBgImage {
    //实现模糊效果
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //毛玻璃视图
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    visualEffectView.alpha = 0.4;
    [self.effectView addSubview:visualEffectView];
    visualEffectView.frame = [UIScreen mainScreen].bounds;

}
#pragma mark – Target action methods

- (IBAction)showLeftMenu:(UIButton *)sender {
    
//    [self.mm_drawerController toggleLeftViewAnimated:nil];
    [self.mm_drawerController openDrawerSide: MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate
- (void)buttonViewDidSelected:(FSHomePageButtonTag)tag {
    switch (tag) {
        case FSHomePageButtonLiveView: {
            
            FSLiveViewViewController *liveViewController = [[FSLiveViewViewController alloc] init];
//            FSNavigationViewController *naviVC = [[FSNavigationViewController alloc] initWithRootViewController:liveViewController];
            [self presentViewController:liveViewController animated:YES completion:^{}];
            
//            [self.navigationController pushViewController:naviVC animated:NO];
//            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//            [login
//             logInWithPublishPermissions: @[@"publish_actions",@"publish_pages",]
//             fromViewController:self
//             handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//                 if (error) {
//                     NSLog(@"Process error");
//                 } else if (result.isCancelled) {
//                     NSLog(@"Cancelled");
//                 } else {
//                     NSString *tokenString = result.token.tokenString;
//                     NSLog(@"----------------tokenString %@",tokenString);
//
//                 }
//             }];
        }
            break;
        case FSHomePageButtonStream: {
//            [[FSFaceBookAPIRESTfulService sharedSingleton] requestVerificationUriAndUserCodeRestultBlock:^(ServiceResultInfo *statusInfo) {
//                NSLog(@"----------------%@",statusInfo);
//            }];
            
            
//            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//            [login
//             logInWithReadPermissions: @[@"",@"manage_pages",@"user_managed_groups",@"user_events"]
//             fromViewController:self
//             handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//                 if (error) {
//                     NSLog(@"Process error");
//                 } else if (result.isCancelled) {
//                     NSLog(@"Cancelled");
//                 } else {
//                     NSString *tokenString = result.token.tokenString;
//                     NSLog(@"----------------tokenString %@",tokenString);
//
//                 }
//             }];

        }   break;
        case FSHomePageButtonConfigure: {
            
//            FSBaseWebViewController * webVC = [[FSBaseWebViewController alloc] init];
//            webVC.urlString = [NSString stringWithFormat:@"https://www.facebook.com/device?access_token=%@",FBSDKAccessToken.currentAccessToken.tokenString];
//            [self.navigationController pushViewController:webVC animated:NO];
        }
            break;
        case FSHomePageButtonBrowse:
            
            break;
    }
}

@end
