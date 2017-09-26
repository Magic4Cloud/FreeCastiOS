//
//  PrivacyPolicyViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/26.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "PrivacyPolicyViewController.h"
#import "CommanParameters.h"

@interface PrivacyPolicyViewController ()

@end

@implementation PrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
    //顶部
    _topBg=[[UIImageView alloc]init];
    _topBg.backgroundColor = [UIColor whiteColor];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*67/totalHeight);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(viewW*10.5/totalHeight, viewH*32.5/totalHeight, viewH*24.5/totalHeight, viewH*24.5/totalHeight);
    [_backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    [_backBtn setImage:[UIImage imageNamed:@"back_pre@3x.png"] forState:UIControlStateHighlighted];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtn.frame.origin.x+_backBtn.frame.size.width, diff_top, viewW-_backBtn.frame.origin.x-_backBtn.frame.size.width-2*diff_x, viewH*44/totalHeight)];
    _titleLabel.center=CGPointMake(self.view.center.x, _backBtn.center.y);
    _titleLabel.text = @"Privacy Policy";
//    _titleLabel.text = NSLocalizedString(@"privacy_policy", nil);
    _titleLabel.font = [UIFont boldSystemFontOfSize: viewH*22.5/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    _privacyPolicyLabel = [[UITextView alloc] initWithFrame:CGRectMake(diff_x,_topBg.frame.size.height+_topBg.frame.origin.y, viewW-2*diff_x, viewH-_topBg.frame.size.height-_topBg.frame.origin.y)];
    _privacyPolicyLabel.scrollEnabled = YES;
    _privacyPolicyLabel.editable = NO;
    _privacyPolicyLabel.backgroundColor=[UIColor clearColor];
    [_privacyPolicyLabel setTextAlignment:NSTextAlignmentLeft];
    [_privacyPolicyLabel setContentMode:UIViewContentModeTopLeft];
    _privacyPolicyLabel.text = NSLocalizedString(@"privacy_policy_content", nil);
    [self.view addSubview:_privacyPolicyLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//屏幕常亮
}


//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
