//
//  ConfigureViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/17.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "ConfigureViewController.h"
#import "CommanParameter.h"
#import "PasswordViewController.h"
#import "ConfigureVideoViewController.h"
#import "ConfigureAudioViewController.h"

@interface ConfigureViewController ()

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
    CGFloat viewH=self.view.frame.size.height;
    CGFloat viewW=self.view.frame.size.width;
    CGFloat totalHeight=64+71+149+149+149+80+5;//各部分比例
    CGFloat totalWeight=375;//各部分比例
    
    //顶部
    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav bar_bg@3x.png"]];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*64/totalHeight);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(0, diff_top, viewH*44/totalHeight, viewH*44/totalHeight);
    [_backBtn setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtn.frame.origin.x+_backBtn.frame.size.width, diff_top, viewW-_backBtn.frame.origin.x-_backBtn.frame.size.width-2*diff_x, viewH*44/totalHeight)];
    _titleLabel.center=CGPointMake(self.view.center.x, _backBtn.center.y);
    _titleLabel.text = NSLocalizedString(@"configure_title", nil);
    _titleLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    _configureImg=[[UIImageView alloc]init];
    _configureImg.frame = CGRectMake(0, _topBg.frame.origin.y+_topBg.frame.size.height, viewW, viewH*236/totalHeight);
    [_configureImg setImage:[UIImage imageNamed:@"configure_banner_image@3x.png"]];
    [self.view  addSubview:_configureImg];

    _configureWifi=[UIButton buttonWithType:UIButtonTypeCustom];
    _configureWifi.frame = CGRectMake(viewW*30/totalWeight, _configureImg.frame.size.height+_configureImg.frame.origin.y+viewH*30/totalHeight, viewW*316/totalWeight, viewH*44/totalHeight);
    [_configureWifi setBackgroundImage:[UIImage imageNamed:@"button_rounded_nor@3x.png"] forState:UIControlStateNormal];
    [_configureWifi setBackgroundImage:[UIImage imageNamed:@"button_rounded_dis@3x.png"] forState:UIControlStateHighlighted];
    [_configureWifi setTitle: NSLocalizedString(@"configure_password", nil) forState: UIControlStateNormal];
    _configureWifi.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _configureWifi.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_configureWifi addTarget:nil action:@selector(_configureWifiClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_configureWifi];
    
    
    _configureVideo=[UIButton buttonWithType:UIButtonTypeCustom];
    _configureVideo.frame = CGRectMake(viewW*30/totalWeight, _configureWifi.frame.size.height+_configureWifi.frame.origin.y+viewH*30/totalHeight, viewW*316/totalWeight, viewH*44/totalHeight);
    [_configureVideo setBackgroundImage:[UIImage imageNamed:@"button_rounded_nor@3x.png"] forState:UIControlStateNormal];
    [_configureVideo setBackgroundImage:[UIImage imageNamed:@"button_rounded_dis@3x.png"] forState:UIControlStateHighlighted];
    [_configureVideo setTitle: NSLocalizedString(@"configure_video", nil) forState: UIControlStateNormal];
    _configureVideo.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _configureVideo.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_configureVideo addTarget:nil action:@selector(_configureVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_configureVideo];
    
    _configureAudio=[UIButton buttonWithType:UIButtonTypeCustom];
    _configureAudio.frame = CGRectMake(viewW*30/totalWeight, _configureVideo.frame.size.height+_configureVideo.frame.origin.y+viewH*30/totalHeight, viewW*316/totalWeight, viewH*44/totalHeight);
    [_configureAudio setBackgroundImage:[UIImage imageNamed:@"button_rounded_nor@3x.png"] forState:UIControlStateNormal];
    [_configureAudio setBackgroundImage:[UIImage imageNamed:@"button_rounded_dis@3x.png"] forState:UIControlStateHighlighted];
    [_configureAudio setTitle: NSLocalizedString(@"configure_audio", nil) forState: UIControlStateNormal];
    _configureAudio.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _configureAudio.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_configureAudio addTarget:nil action:@selector(_configureAudioClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_configureAudio];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_configureWifiClick{
    NSLog(@"_configureWifiClick");
    PasswordViewController *v = [[PasswordViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

- (void)_configureVideoClick{
    NSLog(@"_configureVideoClick");
    ConfigureVideoViewController *v = [[ConfigureVideoViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

- (void)_configureAudioClick{
    NSLog(@"_configureAudioClick");
    ConfigureAudioViewController *v = [[ConfigureAudioViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
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
