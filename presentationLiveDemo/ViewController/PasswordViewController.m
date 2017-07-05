//
//  PasswordViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/17.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "PasswordViewController.h"
#import "CommanParameter.h"
#import "HttpRequest.h"
#import "Rak_Lx52x_Device_Control.h"
#import "MBProgressHUD.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CommanParameters.h"

Rak_Lx52x_Device_Control *_configScan;
@interface PasswordViewController ()
{
    bool _Exit;
    UIAlertView *waitAlertView;
    int configPort;
    NSString* configIP;
}
@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:244/255.0 green:245/255.0 blue:247/255.0 alpha:1.0];
    configPort=80;
    
    //顶部
    _topBg=[[UIImageView alloc]init];
    _topBg.backgroundColor = [UIColor whiteColor];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*67/totalHeight);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
    UIImageView *_Bg=[[UIImageView alloc]init];
    _Bg.frame = CGRectMake(0, 0, viewW, viewH*20/totalHeight);
    _Bg.contentMode=UIViewContentModeScaleToFill;
    _Bg.backgroundColor=[UIColor blackColor];
    _Bg.alpha=0.1;
//    [self.view addSubview:_Bg];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(viewW*10.5/totalHeight, viewH*32.5/totalHeight, viewH*24.5/totalHeight, viewH*24.5/totalHeight);
    [_backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtn.frame.origin.x+_backBtn.frame.size.width, diff_top, viewW-_backBtn.frame.origin.x-_backBtn.frame.size.width-2*diff_x, viewH*44/totalHeight)];
//    _titleLabel.center=CGPointMake(self.view.center.x, _backBtn.center.y);
//    _titleLabel.text = NSLocalizedString(@"password_title", nil);
//    _titleLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
//    _titleLabel.backgroundColor = [UIColor clearColor];
//    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _titleLabel.textColor = MAIN_COLOR;
//    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _titleLabel.textAlignment=UITextAlignmentCenter;
//    _titleLabel.numberOfLines = 0;
//    [self.view addSubview:_titleLabel];
//
    
    //设置分段控件点击相应事件
    NSArray *segmentedData = [[NSArray alloc]initWithObjects:NSLocalizedString(@"configure_video_title", nil),NSLocalizedString(@"password_title", nil),nil];
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedData];
    segmentedControl.frame = CGRectMake(0,0,viewW*152/totalWeight,viewH*29/totalHeight);
    segmentedControl.center=CGPointMake(viewW*0.5, _backBtn.center.y);
    
    segmentedControl.backgroundColor=[UIColor whiteColor];
    segmentedControl.tintColor = [UIColor whiteColor];
    segmentedControl.layer.borderWidth = 2.0;
    segmentedControl.layer.borderColor = MAIN_COLOR.CGColor;
    segmentedControl.layer.cornerRadius = viewW*5/totalWeight;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segmentedControl.selectedSegmentIndex = 0;//默认选中的按钮索引
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:MAIN_COLOR,UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,GRAY_COLOR,UITextAttributeTextShadowColor ,nil];
    [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    
    NSDictionary *highlightedAttributes2 = [NSDictionary dictionaryWithObjectsAndKeys:GRAY_COLOR,UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,MAIN_COLOR,UITextAttributeTextShadowColor ,nil];
    
    [segmentedControl setTitleTextAttributes:highlightedAttributes2 forState:UIControlStateNormal];
    [segmentedControl addTarget:self action:@selector(doSomethingInSegment:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    UILabel *videoline =  [[UILabel alloc] initWithFrame:CGRectMake(0,0,2,segmentedControl.frame.size.height)];
    videoline.center = segmentedControl.center;
    videoline.backgroundColor = MAIN_COLOR;
    [self.view addSubview:videoline];

    
    //Password
    _passwordView=[[UIView alloc]init];
    _passwordView.userInteractionEnabled=YES;
    _passwordView.frame=CGRectMake(0, _topBg.frame.origin.y+_topBg.frame.size.height, viewW, viewH-_topBg.frame.origin.y-_topBg.frame.size.height);
    [self.view  addSubview:_passwordView];
    
    _passwordImg=[[UIImageView alloc]init];
    _passwordImg.frame = CGRectMake(0, 0, viewW, viewH*156.5/totalHeight);
    [_passwordImg setImage:[UIImage imageNamed:@"configure_password_banner_image@3x.png"]];
//    [_passwordView  addSubview:_passwordImg];
    
    //SSID
//    _ssidView=[[UIView alloc] initWithFrame:CGRectMake( viewW*15/totalWeight, _passwordImg.frame.origin.y+_passwordImg.frame.size.height+viewH*13/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
//    [[_ssidView layer] setBorderWidth:1.0];//画线的宽度
//    [[_ssidView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
//    [[_ssidView layer]setCornerRadius:viewW*14/totalWeight];//圆角
//    _ssidView.backgroundColor=[UIColor whiteColor];
//    [_ssidView.layer setMasksToBounds:YES];
//    [_passwordView addSubview:_ssidView];
    
    _ssidLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*37/totalWeight, viewW*53.5/totalWeight, viewW*110/totalWeight, viewH*17.5/totalHeight)];
    _ssidLabel.text = NSLocalizedString(@"password_ssid_label", nil);
    _ssidLabel.font = [UIFont systemFontOfSize: viewH*17.5/totalHeight*0.8];
    _ssidLabel.backgroundColor = [UIColor clearColor];
    _ssidLabel.textColor = MAIN_COLOR;
    _ssidLabel.lineBreakMode = UILineBreakModeWordWrap;
    _ssidLabel.numberOfLines = 0;
    [_passwordView addSubview:_ssidLabel];
    
    UIView *_ssidLine=[[UIView alloc]init];
    _ssidLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
    _ssidLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_ssidView addSubview:_ssidLine];
    
    _ssidText=[[UITextField alloc]init];
    _ssidText.frame=CGRectMake(viewW*37/totalWeight,_ssidLabel.frame.origin.y+_ssidLabel.frame.size.height+viewH*10/totalHeight, viewW*180/totalWeight, viewH*15/totalHeight);
    _ssidText.backgroundColor = [UIColor clearColor];
    _ssidText.enabled=NO;
    _ssidText.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _ssidText.placeholder=NSLocalizedString(@"password_ssid_hint", nil);
    _ssidText.delegate=self;
    [_passwordView addSubview:_ssidText];
    
    _ssidImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_password_setting@3x.png"]];
    _ssidImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_ssidImgClick)];
    [_ssidImg addGestureRecognizer:singleTap0];
    _ssidImg.frame = CGRectMake(viewW*313/totalWeight, _ssidLabel.frame.origin.y+_ssidLabel.frame.size.height+viewH*5/totalHeight, viewH*25/totalHeight, viewH*25/totalHeight);
    _ssidImg.contentMode=UIViewContentModeScaleToFill;
    [_passwordView addSubview:_ssidImg];
    
    //Init Password
//    _initPasswordView=[[UIView alloc] initWithFrame:CGRectMake( viewW*15/totalWeight, _ssidView.frame.origin.y+_ssidView.frame.size.height+viewH*15/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
//    [[_initPasswordView layer] setBorderWidth:1.0];//画线的宽度
//    [[_initPasswordView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
//    [[_initPasswordView layer]setCornerRadius:viewW*14/totalWeight];//圆角
//    _initPasswordView.backgroundColor=[UIColor whiteColor];
//    [_initPasswordView.layer setMasksToBounds:YES];
//    [_passwordView addSubview:_initPasswordView];
    
    _initPasswordLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*37/totalWeight, viewH*119.5/totalHeight, viewW*120/totalWeight, viewH*17.5/totalHeight)];
    _initPasswordLabel.text = NSLocalizedString(@"password_initial_label", nil);
    _initPasswordLabel.font = [UIFont systemFontOfSize: viewH*17.5/totalHeight*0.8];
    _initPasswordLabel.backgroundColor = [UIColor clearColor];
    _initPasswordLabel.textColor = MAIN_COLOR;
    _initPasswordLabel.lineBreakMode = UILineBreakModeWordWrap;
    _initPasswordLabel.numberOfLines = 0;
    [_passwordView addSubview:_initPasswordLabel];
    
//    UIView *_initPasswordLine=[[UIView alloc]init];
//    _initPasswordLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
//    _initPasswordLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
//    [_initPasswordView addSubview:_initPasswordLine];
    
    _initPasswordImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_display_nor"]];
    _initPasswordImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_initPasswordImgShowPskClick)];
    [_initPasswordImg addGestureRecognizer:singleTap2];
    _initPasswordImg.frame = CGRectMake(viewW*318/totalWeight, _initPasswordLabel.frame.origin.y+_initPasswordLabel.frame.size.height+viewH*10/totalHeight, viewH*15/totalHeight, viewH*15/totalHeight);
    _initPasswordImg.contentMode=UIViewContentModeScaleToFill;
    [_passwordView addSubview:_initPasswordImg];
    
    _initPasswordText=[[UITextField alloc]init];
    _initPasswordText.frame=CGRectMake(viewW*37/totalWeight,_initPasswordLabel.frame.origin.y+_initPasswordLabel.frame.size.height+viewH*10/totalHeight, viewW*147/totalWeight, viewH*15/totalHeight);
    _initPasswordText.backgroundColor = [UIColor clearColor];
    _initPasswordText.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _initPasswordText.secureTextEntry = YES;
    _initPasswordText.delegate=self;
    _initPasswordText.placeholder=NSLocalizedString(@"password_initial_label", nil);
    [_passwordView addSubview:_initPasswordText];
    
    
    //Device
    UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*35.5/totalWeight, _initPasswordLabel.frame.origin.y+_initPasswordLabel.frame.size.height+viewH*103.5/totalHeight, viewW*147/totalWeight, viewH*15/totalHeight)];
    deviceLabel.text = @"Device";
    deviceLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    deviceLabel.backgroundColor = [UIColor clearColor];
    deviceLabel.textColor = MAIN_COLOR;
    deviceLabel.numberOfLines = 0;
    [_passwordView addSubview:deviceLabel];
    
    
    //New Password
//    _newPasswordView=[[UIView alloc] initWithFrame:CGRectMake( viewW*15/totalWeight, _initPasswordView.frame.origin.y+_initPasswordView.frame.size.height+viewH*15/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
//    [[_newPasswordView layer] setBorderWidth:1.0];//画线的宽度
//    [[_newPasswordView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
//    [[_newPasswordView layer]setCornerRadius:viewW*14/totalWeight];//圆角
//    _newPasswordView.backgroundColor=[UIColor whiteColor];
//    [_newPasswordView.layer setMasksToBounds:YES];
//    [_passwordView addSubview:_newPasswordView];
    
    _newPasswordLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*37/totalWeight, deviceLabel.frame.origin.y+deviceLabel.frame.size.height+viewH*20/totalHeight, viewW*110/totalWeight, viewH*17.5/totalHeight)];
    _newPasswordLabel.text = NSLocalizedString(@"password_new_label", nil);
    _newPasswordLabel.font = [UIFont systemFontOfSize: viewH*17.5/totalHeight*0.8];
    _newPasswordLabel.backgroundColor = [UIColor clearColor];
    _newPasswordLabel.textColor = MAIN_COLOR;
    _newPasswordLabel.numberOfLines = 0;
    [_passwordView addSubview:_newPasswordLabel];
    
//    UIView *_newPasswordLine=[[UIView alloc]init];
//    _newPasswordLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
//    _newPasswordLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
//    [_newPasswordView addSubview:_newPasswordLine];
    
    _newPasswordImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_display_nor"]];
    _newPasswordImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_newPasswordImgShowPskClick)];
    [_newPasswordImg addGestureRecognizer:singleTap3];
    _newPasswordImg.frame = CGRectMake(viewW*318/totalWeight, deviceLabel.frame.origin.y+deviceLabel.frame.size.height+viewH*47.5/totalHeight, viewH*15/totalHeight, viewH*15/totalHeight);
    _newPasswordImg.contentMode=UIViewContentModeScaleToFill;
    [_passwordView addSubview:_newPasswordImg];
    
    _newPasswordText=[[UITextField alloc]init];
    _newPasswordText.frame=CGRectMake(viewW*37/totalWeight, deviceLabel.frame.origin.y+deviceLabel.frame.size.height+viewH*47.5/totalHeight, viewW*147/totalWeight, viewH*15/totalHeight);
    _newPasswordText.backgroundColor = [UIColor clearColor];
    _newPasswordText.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _newPasswordText.secureTextEntry = YES;
    _newPasswordText.delegate=self;
    _newPasswordText.placeholder=NSLocalizedString(@"password_new_label", nil);
    [_passwordView addSubview:_newPasswordText];
    
    //Confirm
//    _confirmView=[[UIView alloc] initWithFrame:CGRectMake( viewW*15/totalWeight, _newPasswordView.frame.origin.y+_newPasswordView.frame.size.height+viewH*15/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
//    [[_confirmView layer] setBorderWidth:1.0];//画线的宽度
//    [[_confirmView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
//    [[_confirmView layer]setCornerRadius:viewW*14/totalWeight];//圆角
//    _confirmView.backgroundColor=[UIColor whiteColor];
//    [_confirmView.layer setMasksToBounds:YES];
//    [_passwordView addSubview:_confirmView];
    
    _confirmLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*37/totalWeight, _newPasswordLabel.frame.origin.y+_newPasswordLabel.frame.size.height+viewH*47.5/totalHeight, viewW*110/totalWeight, viewH*17.5/totalHeight)];
    _confirmLabel.text = NSLocalizedString(@"password_confirm_label", nil);
    _confirmLabel.font = [UIFont systemFontOfSize: viewH*17.5/totalHeight*0.8];
    _confirmLabel.backgroundColor = [UIColor clearColor];
    _confirmLabel.textColor = MAIN_COLOR;
    _confirmLabel.numberOfLines = 0;
    [_passwordView addSubview:_confirmLabel];
    
//    UIView *_confirmLine=[[UIView alloc]init];
//    _confirmLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
//    _confirmLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
//    [_confirmView addSubview:_confirmLine];
    
    _confirmPasswordImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_display_nor"]];
    _confirmPasswordImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_confirmImgShowPskClick)];
    [_confirmPasswordImg addGestureRecognizer:singleTap4];
    _confirmPasswordImg.frame = CGRectMake(viewW*318/totalWeight, _newPasswordLabel.frame.origin.y+_newPasswordLabel.frame.size.height+viewH*76/totalHeight, viewH*15/totalHeight, viewH*15/totalHeight);
    _confirmPasswordImg.contentMode=UIViewContentModeScaleToFill;
    [_passwordView addSubview:_confirmPasswordImg];
    
    _confirmText=[[UITextField alloc]init];
    _confirmText.frame=CGRectMake(viewW*37/totalWeight, _newPasswordLabel.frame.origin.y+_newPasswordLabel.frame.size.height+viewH*76/totalHeight, viewW*147/totalWeight, viewH*15/totalHeight);
    _confirmText.backgroundColor = [UIColor clearColor];
    _confirmText.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _confirmText.secureTextEntry = YES;
    _confirmText.delegate=self;
    _confirmText.placeholder=NSLocalizedString(@"password_confirm_label", nil);
    [_passwordView addSubview:_confirmText];

    
    
    //Modify
    _passwordModifyBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _passwordModifyBtn.frame = CGRectMake(viewW*77.5/totalWeight, viewH*534.5/totalHeight - viewH*67/totalHeight, viewW*220/totalWeight, viewH*35/totalHeight);
//    [_passwordModifyBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_nor@3x.png"] forState:UIControlStateNormal];
//    [_passwordModifyBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_dis@3x.png"] forState:UIControlStateHighlighted];
    [_passwordModifyBtn setTitle: NSLocalizedString(@"password_modify_label", nil) forState: UIControlStateNormal];
    [_passwordModifyBtn setBackgroundColor:[UIColor colorWithRed:(192 / 255.0f) green:(236 / 255.0f) blue:(248 / 255.0f) alpha:1.0]];
    _passwordModifyBtn.layer.cornerRadius = viewW*18/totalWeight;
    [_passwordModifyBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _passwordModifyBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _passwordModifyBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_passwordModifyBtn addTarget:nil action:@selector(_passwordModifyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_passwordView  addSubview:_passwordModifyBtn];
    _passwordView.hidden=YES;
    
    
    //Forget
    _passwordForgetBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _passwordForgetBtn.frame = CGRectMake(viewW*187.5/totalWeight, _passwordModifyBtn.frame.size.height+_passwordModifyBtn.frame.origin.y+viewH*10/totalHeight, viewW*111.5/totalWeight, viewH*12.5/totalHeight);
    [_passwordForgetBtn setTitle: NSLocalizedString(@"password_forget_label", nil) forState: UIControlStateNormal];
    _passwordForgetBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
    _passwordForgetBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [_passwordForgetBtn addTarget:nil action:@selector(_passwordForgetBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_passwordForgetBtn setTitleColor:[UIColor colorWithRed:176.356/255.0 green:176.356/255.0 blue:176.356/255.0 alpha:1.0]forState:UIControlStateNormal];
    [_passwordForgetBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    [_passwordView  addSubview:_passwordForgetBtn];
    
    
    //恢复初始密码
    _resetBgView=[[UIView alloc]init];
    _resetBgView.frame=_passwordView.frame;
    _resetBgView.backgroundColor=[UIColor blackColor];
    _resetBgView.alpha=0.4;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesImage)];
    [_resetBgView addGestureRecognizer:singleTap];
    [self.view addSubview:_resetBgView];
    
    _resetView=[[UIView alloc]init];
    _resetView.frame=CGRectMake(0, 0, 226*viewW/totalWeight, 95*viewH/totalHeight);
    _resetView.backgroundColor=[UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
    [[_resetView layer]setCornerRadius:viewW*14/totalWeight];//圆角
    _resetView.center=self.view.center;
    [self.view addSubview:_resetView];
    
    _resetImg =[[UIImageView alloc] initWithFrame:CGRectMake(39*viewW/totalWeight, 12*viewH/totalHeight, 38*viewH/totalHeight, 38*viewH/totalHeight)];
    _resetImg.image=[UIImage imageNamed:@"06_00038.png"];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000000000000;
    [_resetImg.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"]
    ;
    [_resetView addSubview:_resetImg];
    
    _resetTitle= [[UILabel alloc] initWithFrame:CGRectMake(83*viewW/totalWeight, 12*viewH/totalHeight, 150*viewW/totalWeight, 38*viewH/totalHeight)];
    _resetTitle.text = NSLocalizedString(@"password_reset_title", nil);
    _resetTitle.font = [UIFont boldSystemFontOfSize: viewH*20/totalHeight*0.8];
    _resetTitle.backgroundColor = [UIColor clearColor];
    _resetTitle.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _resetTitle.lineBreakMode = UILineBreakModeWordWrap;
    _resetTitle.textAlignment=UITextAlignmentLeft;
    _resetTitle.numberOfLines = 0;
    [_resetView addSubview:_resetTitle];
    
    _resetLabel1= [[UILabel alloc] initWithFrame:CGRectMake(13*viewW/totalWeight, 59*viewH/totalHeight, 200*viewW/totalWeight, 20*viewH/totalHeight)];
    _resetLabel1.text = NSLocalizedString(@"password_reset_text", nil);
    _resetLabel1.font = [UIFont systemFontOfSize: viewH*14/totalHeight];
    _resetLabel1.backgroundColor = [UIColor clearColor];
    _resetLabel1.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _resetLabel1.lineBreakMode = UILineBreakModeWordWrap;
    _resetLabel1.textAlignment=UITextAlignmentCenter;
    _resetLabel1.numberOfLines = 0;
    [_resetView addSubview:_resetLabel1];
    _resetView.hidden=YES;
    _resetBgView.hidden=YES;
    
    
    //lineView
    for (int i = 0; i < 2; i ++) {
        UIView *SSIDLineView=[[UIView alloc]init];
        SSIDLineView.frame=CGRectMake(viewW*37/totalWeight, _ssidText.frame.origin.y+_ssidText.frame.size.height+viewH*2.5/totalHeight + i * viewH*65/totalHeight, viewW*298/totalWeight, 1);
        SSIDLineView.backgroundColor =[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1.0];
        [_passwordView addSubview:SSIDLineView];
        
        UIView *DeviceLineView=[[UIView alloc]init];
        DeviceLineView.frame=CGRectMake(viewW*37/totalWeight, _newPasswordText.frame.origin.y+_newPasswordText.frame.size.height+viewH*2.5/totalHeight + i * viewH*65/totalHeight, viewW*298/totalWeight, 1);
        DeviceLineView.backgroundColor =[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1.0];
        [_passwordView addSubview:DeviceLineView];
    }
    
    
#pragma mark ----------- video configure
    //video configure
    _videoView=[[UIView alloc]init];
    _videoView.userInteractionEnabled=YES;
    _videoView.frame=CGRectMake(0, _topBg.frame.origin.y+_topBg.frame.size.height, viewW, viewH-_topBg.frame.origin.y-_topBg.frame.size.height);
    [self.view  addSubview:_videoView];
    
    _videoImg=[[UIImageView alloc]init];
    _videoImg.frame = CGRectMake(0, 0, viewW, viewH*156.5/totalHeight);
    [_videoImg setImage:[UIImage imageNamed:@"IMG_0286.JPG"]];
    [_videoView  addSubview:_videoImg];
    
    _viewBtn=[[UIView alloc]init];
    _viewBtn.userInteractionEnabled=YES;
    _viewBtn.frame=CGRectMake(0, viewH*156.5/totalHeight, viewW, viewH*127/totalHeight);
    _viewBtn.backgroundColor=[UIColor orangeColor];
//    [_videoView  addSubview:_viewBtn];
    
    _videoParametersLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, _videoImg.frame.origin.y+_videoImg.frame.size.height+viewH*17/totalHeight, viewW, viewH*20/totalHeight)];
//    _videoParametersLabel.text = NSLocalizedString(@"parameters_note", nil);
    _videoParametersLabel.text = @"Image Quality";
    _videoParametersLabel.center=CGPointMake(viewW*0.5, _videoParametersLabel.center.y);
    _videoParametersLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _videoParametersLabel.backgroundColor = [UIColor clearColor];
    _videoParametersLabel.textColor = MAIN_COLOR;
    _videoParametersLabel.textAlignment=NSTextAlignmentCenter;
    _videoParametersLabel.numberOfLines = 0;
    [_videoView addSubview:_videoParametersLabel];
    
    
    //设置分段控件点击相应事件
    NSArray *VediosegmentedData = [[NSArray alloc]initWithObjects:@"Smooth",@"Good",@"Best",@"Custom",nil];
    UISegmentedControl *VediosegmentedControl = [[UISegmentedControl alloc]initWithItems:VediosegmentedData];
    VediosegmentedControl.frame = CGRectMake(viewW*37.5/totalWeight,_videoParametersLabel.frame.origin.y+_videoParametersLabel.frame.size.height+viewH*15.5/totalHeight,viewW*300/totalWeight,viewH*32.5/totalHeight);
//    VediosegmentedControl.center=CGPointMake(viewW*0.5, _backBtn.center.y);
    
    VediosegmentedControl.backgroundColor=[UIColor whiteColor];
    VediosegmentedControl.tintColor = [UIColor whiteColor];
    VediosegmentedControl.layer.borderWidth = 2.0;
    VediosegmentedControl.layer.borderColor = MAIN_COLOR.CGColor;
    VediosegmentedControl.layer.cornerRadius = viewW*5/totalWeight;
    VediosegmentedControl.selectedSegmentIndex = 1;//默认选中的按钮索引
    
    NSDictionary *VediohighlightedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:MAIN_COLOR,UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,GRAY_COLOR,UITextAttributeTextShadowColor ,nil];
    [VediosegmentedControl setTitleTextAttributes:VediohighlightedAttributes forState:UIControlStateSelected];
    
    NSDictionary *VediohighlightedAttributes2 = [NSDictionary dictionaryWithObjectsAndKeys:GRAY_COLOR,UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,MAIN_COLOR,UITextAttributeTextShadowColor ,nil];
    [VediosegmentedControl setTitleTextAttributes:VediohighlightedAttributes2 forState:UIControlStateNormal];
    [VediosegmentedControl addTarget:self action:@selector(_videoBtnClick:)forControlEvents:UIControlEventValueChanged];
    [_videoView addSubview:VediosegmentedControl];
    
    for (int i = 0; i < 3; i ++) {
        UILabel *videolineLabel =  [[UILabel alloc] initWithFrame:CGRectMake(viewW*109.5/totalWeight + i * viewW*72/totalWeight, _videoParametersLabel.frame.origin.y+_videoParametersLabel.frame.size.height+viewH*15.5/totalHeight, 2, VediosegmentedControl.frame.size.height)];
        videolineLabel.backgroundColor = MAIN_COLOR;
        [_videoView addSubview:videolineLabel];
    }
    
//    CGFloat init_X=viewW*16/totalWeight;
//    CGFloat init_Y=viewH*35/totalHeight;
////
//    _smoothBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _smoothBtn.frame = CGRectMake(init_X+viewW*90*0/totalWeight, init_Y, viewW*72/totalWeight, viewH*77/totalHeight);
//    _smoothBtn.tag=0;
//    [_smoothBtn setTitle: NSLocalizedString(@"smooth", nil) forState: UIControlStateNormal];
//    [_smoothBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_smoothBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateHighlighted];
//    [_smoothBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
//    _smoothBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
//    _smoothBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
//    [_smoothBtn addTarget:nil action:@selector(_videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_viewBtn  addSubview:_smoothBtn];
//
//    _goodBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _goodBtn.frame = CGRectMake(init_X+viewW*90*1/totalWeight, init_Y, viewW*72/totalWeight, viewH*77/totalHeight);
//    _goodBtn.tag=1;
//    [_goodBtn setTitle: NSLocalizedString(@"good", nil) forState: UIControlStateNormal];
//    [_goodBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_goodBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateHighlighted];
//    [_goodBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
//    _goodBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
//    _goodBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
//    [_goodBtn addTarget:nil action:@selector(_videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_viewBtn  addSubview:_goodBtn];
//    [_goodBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateNormal];
//    [_goodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    _bestBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _bestBtn.frame = CGRectMake(init_X+viewW*90*2/totalWeight, init_Y, viewW*72/totalWeight, viewH*77/totalHeight);
//    _bestBtn.tag=2;
//    [_bestBtn setTitle: NSLocalizedString(@"best", nil) forState: UIControlStateNormal];
//    [_bestBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_bestBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateHighlighted];
//    [_bestBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
//    _bestBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
//    _bestBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
//    [_bestBtn addTarget:nil action:@selector(_videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_viewBtn  addSubview:_bestBtn];
//    
//    _customBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _customBtn.frame = CGRectMake(init_X+viewW*90*3/totalWeight, init_Y, viewW*72/totalWeight, viewH*77/totalHeight);
//    _customBtn.tag=3;
//    [_customBtn setTitle: NSLocalizedString(@"custom", nil) forState: UIControlStateNormal];
//    [_customBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_customBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateHighlighted];
//    [_customBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
//    _customBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
//    _customBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
//    [_customBtn addTarget:nil action:@selector(_videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_viewBtn  addSubview:_customBtn];
    
    
//    _videoLabelView=[[UIView alloc]init];
//    _videoLabelView.frame=CGRectMake(viewW*63/totalWeight, viewH*272/totalHeight, viewW*256/totalWeight, viewH*91/totalHeight);
//    [[_videoLabelView layer] setBorderWidth:1.0];//画线的宽度
//    [[_videoLabelView layer] setBorderColor:[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0].CGColor];//颜色
//    [[_videoLabelView layer]setCornerRadius:viewW*14/totalWeight];//圆角
//    [_videoLabelView.layer setMasksToBounds:YES];
    //[_videoView  addSubview:_videoLabelView];
    
//    _videoLabel1= [[UILabel alloc] initWithFrame:CGRectMake(0, 2*viewH/totalHeight, _videoLabelView.frame.size.width, 20*viewH/totalHeight)];
//    _videoLabel1.text = NSLocalizedString(@"smooth_text", nil);
//    _videoLabel1.font = [UIFont systemFontOfSize: viewH*14/totalHeight];
//    _videoLabel1.backgroundColor = [UIColor clearColor];
//    _videoLabel1.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _videoLabel1.lineBreakMode = UILineBreakModeWordWrap;
//    _videoLabel1.textAlignment=UITextAlignmentCenter;
//    _videoLabel1.numberOfLines = 0;
//    [_videoLabelView addSubview:_videoLabel1];
//    
//    _videoLabel2= [[UILabel alloc] initWithFrame:CGRectMake(0, 24*viewH/totalHeight, _videoLabelView.frame.size.width, 20*viewH/totalHeight)];
//    _videoLabel2.text = NSLocalizedString(@"good_text", nil);
//    _videoLabel2.font = [UIFont systemFontOfSize: viewH*14/totalHeight];
//    _videoLabel2.backgroundColor = [UIColor clearColor];
//    _videoLabel2.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _videoLabel2.lineBreakMode = UILineBreakModeWordWrap;
//    _videoLabel2.textAlignment=UITextAlignmentCenter;
//    _videoLabel2.numberOfLines = 0;
//    [_videoLabelView addSubview:_videoLabel2];
//    _videoLabel2.textColor = [UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
//    
//    _videoLabel3= [[UILabel alloc] initWithFrame:CGRectMake(0, 46*viewH/totalHeight, _videoLabelView.frame.size.width, 20*viewH/totalHeight)];
//    _videoLabel3.text = NSLocalizedString(@"best_text", nil);
//    _videoLabel3.font = [UIFont systemFontOfSize: viewH*14/totalHeight];
//    _videoLabel3.backgroundColor = [UIColor clearColor];
//    _videoLabel3.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _videoLabel3.lineBreakMode = UILineBreakModeWordWrap;
//    _videoLabel3.textAlignment=UITextAlignmentCenter;
//    _videoLabel3.numberOfLines = 0;
//    [_videoLabelView addSubview:_videoLabel3];
//    
//    _videoLabel4= [[UILabel alloc] initWithFrame:CGRectMake(0, 68*viewH/totalHeight, _videoLabelView.frame.size.width, 20*viewH/totalHeight)];
//    _videoLabel4.text = NSLocalizedString(@"custom_text", nil);
//    _videoLabel4.font = [UIFont systemFontOfSize: viewH*14/totalHeight];
//    _videoLabel4.backgroundColor = [UIColor clearColor];
//    _videoLabel4.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _videoLabel4.lineBreakMode = UILineBreakModeWordWrap;
//    _videoLabel4.textAlignment=UITextAlignmentCenter;
//    _videoLabel4.numberOfLines = 0;
//    [_videoLabelView addSubview:_videoLabel4];
    
    
    //Modify
    _videoModifyBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoModifyBtn.frame = CGRectMake(viewW*77.5/totalWeight, viewH-viewH*96/totalHeight-viewH*35/totalHeight, viewW*220/totalWeight, viewH*35/totalHeight);
//    [_videoModifyBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_nor@3x.png"] forState:UIControlStateNormal];
//    [_videoModifyBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_dis@3x.png"] forState:UIControlStateHighlighted];
    [_videoModifyBtn setTitle: NSLocalizedString(@"password_modify_label", nil) forState: UIControlStateNormal];
    [_videoModifyBtn setBackgroundColor:[UIColor colorWithRed:(192 / 255.0f) green:(236 / 255.0f) blue:(248 / 255.0f) alpha:1.0]];
    _videoModifyBtn.layer.cornerRadius = viewW*18/totalWeight;
    [_videoModifyBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _videoModifyBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _videoModifyBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_videoModifyBtn addTarget:nil action:@selector(_videoModifyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_videoView  addSubview:_videoModifyBtn];
    
    
    
    //Rate/FPS/Reslution
    _videoParametersView=[[UIView alloc]init];
    _videoParametersView.userInteractionEnabled=YES;
    _videoParametersView.frame=CGRectMake(0,viewH*270/totalHeight, viewW, viewH*206/totalHeight);
    _videoParametersView.backgroundColor=[UIColor clearColor];
    [_videoView addSubview:_videoParametersView];

    //Resolution
    _videoResolutionView=[[UIView alloc]init];
    _videoResolutionView.frame=CGRectMake(0,viewH*6/totalHeight,viewW, viewH*44/totalHeight);
    _videoResolutionView.backgroundColor=[UIColor clearColor];
    [_videoParametersView addSubview:_videoResolutionView];
    
    _videoResolutionLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/totalWeight, 0, viewW*80/totalWeight, viewH*44/totalHeight)];
    _videoResolutionLabel.text = NSLocalizedString(@"video_resolution", nil);
    _videoResolutionLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
    _videoResolutionLabel.backgroundColor = [UIColor clearColor];
    _videoResolutionLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _videoResolutionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoResolutionLabel.textAlignment=NSTextAlignmentRight;
    _videoResolutionLabel.numberOfLines = 0;
    [_videoResolutionView addSubview:_videoResolutionLabel];
    
    _videoResolutionSlider = [[UISlider alloc] initWithFrame:CGRectMake(_videoResolutionLabel.frame.size.width+_videoResolutionLabel.frame.origin.x+viewW*22/totalWeight, 0, viewW-viewW*44/totalWeight-_videoResolutionLabel.frame.size.width-_videoResolutionLabel.frame.origin.x, viewH*44/totalHeight)];
    _videoResolutionSlider.minimumValue = 0;
    _videoResolutionSlider.maximumValue = 2;
    _videoResolutionSlider.value = 1;
    _videoResolutionSlider.thumbTintColor = MAIN_COLOR;
    _videoResolutionSlider.minimumTrackTintColor = MAIN_COLOR;
    _videoResolutionSlider.continuous=NO;
    
    UIImage *imagea=[self OriginImage:[UIImage imageNamed:@"circle"] scaleToSize:CGSizeMake(11, 11)];
    [_videoResolutionSlider  setThumbImage:imagea forState:UIControlStateNormal];
    
    [_videoResolutionSlider addTarget:self action:@selector(_videoResolutionSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_videoResolutionView addSubview:_videoResolutionSlider];
    
//    _videoResolutionMinImg=[[UIImageView alloc]init];
//    _videoResolutionMinImg.frame = CGRectMake(0, 0, viewH*44/totalHeight, viewH*44/totalHeight);
//    _videoResolutionMinImg.center=CGPointMake(_videoResolutionSlider.frame.origin.x, _videoResolutionSlider.center.y);
//    [_videoResolutionMinImg setImage:[UIImage imageNamed:@"configure_Slide_button_nor@3x.png"]];
//    [_videoResolutionView  addSubview:_videoResolutionMinImg];
    
    _videoResolutionMinLabel=[[UILabel alloc] initWithFrame:CGRectMake(_videoResolutionLabel.frame.size.width+_videoResolutionLabel.frame.origin.x+viewH*22/totalHeight, viewH*35/totalHeight, viewH*44/totalHeight, viewH*10/totalHeight)];
    _videoResolutionMinLabel.text = NSLocalizedString(@"video_480p", nil);
    _videoResolutionMinLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionMinLabel.backgroundColor = [UIColor clearColor];
    _videoResolutionMinLabel.textColor = MAIN_COLOR;
    _videoResolutionMinLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoResolutionMinLabel.textAlignment=UITextAlignmentCenter;
    _videoResolutionMinLabel.numberOfLines = 0;
    [_videoResolutionView addSubview:_videoResolutionMinLabel];
    
//    _videoResolutionMaxImg=[[UIImageView alloc]init];
//    _videoResolutionMaxImg.frame = CGRectMake(0, 0, viewH*44/totalHeight, viewH*44/totalHeight);
//    _videoResolutionMaxImg.center=CGPointMake(_videoResolutionSlider.frame.origin.x+_videoResolutionSlider.frame.size.width, _videoResolutionSlider.center.y);
//    [_videoResolutionMaxImg setImage:[UIImage imageNamed:@"configure_Slide_button_nor@3x.png"]];
//    [_videoResolutionView  addSubview:_videoResolutionMaxImg];
    
    _videoResolutionMaxLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW-viewH*66/totalHeight, viewH*35/totalHeight, viewH*50/totalHeight, viewH*10/totalHeight)];
    _videoResolutionMaxLabel.text = NSLocalizedString(@"video_1080p", nil);
    _videoResolutionMaxLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionMaxLabel.backgroundColor = [UIColor clearColor];
    _videoResolutionMaxLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoResolutionMaxLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoResolutionMaxLabel.textAlignment=UITextAlignmentCenter;
    _videoResolutionMaxLabel.numberOfLines = 0;
    [_videoResolutionView addSubview:_videoResolutionMaxLabel];
    
//    _videoResolutionValueImg=[[UIImageView alloc]init];
//    _videoResolutionValueImg.frame = CGRectMake(0, 0, viewH*44/totalHeight, viewH*44/totalHeight);
//    _videoResolutionValueImg.center=CGPointMake(_videoResolutionSlider.center.x, _videoResolutionSlider.center.y);
//    [_videoResolutionValueImg setImage:[UIImage imageNamed:@"configure_Slide_button_nor@3x.png"]];
//    [_videoResolutionView  addSubview:_videoResolutionValueImg];
//    _videoResolutionValueImg.hidden=YES;
    
    _videoResolutionValueLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*275/totalWeight, -viewH*35/totalHeight, viewW*44/totalWeight, viewH*10/totalHeight)];
    _videoResolutionValueLabel.center=CGPointMake(_videoResolutionSlider.center.x, _videoResolutionMaxLabel.center.y);
    _videoResolutionValueLabel.text = NSLocalizedString(@"video_720p", nil);
    _videoResolutionValueLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _videoResolutionValueLabel.backgroundColor = [UIColor clearColor];
    _videoResolutionValueLabel.textColor = MAIN_COLOR;
    _videoResolutionValueLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoResolutionValueLabel.textAlignment=UITextAlignmentCenter;
    _videoResolutionValueLabel.numberOfLines = 0;
    [_videoResolutionView addSubview:_videoResolutionValueLabel];

    //Rate
    _videoRateView=[[UIView alloc]init];
    _videoRateView.userInteractionEnabled=YES;
    _videoRateView.frame=CGRectMake(0,_videoResolutionView.frame.origin.y+_videoResolutionView.frame.size.height+viewH*13/totalHeight, viewW, viewH*57/totalHeight);
    _videoRateView.backgroundColor=[UIColor clearColor];
    [_videoParametersView addSubview:_videoRateView];
    
    _videoRateLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/totalWeight, viewH*13/totalHeight, viewW*80/totalWeight, viewH*44/totalHeight)];
    _videoRateLabel.text = NSLocalizedString(@"video_rate", nil);
    _videoRateLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
    _videoRateLabel.backgroundColor = [UIColor clearColor];
    _videoRateLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _videoRateLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoRateLabel.textAlignment=NSTextAlignmentRight;
    _videoRateLabel.numberOfLines = 0;
    [_videoRateView addSubview:_videoRateLabel];
    
    _videoRateSlider = [[UISlider alloc] initWithFrame:CGRectMake(_videoRateLabel.frame.size.width+_videoRateLabel.frame.origin.x+viewW*22/totalWeight, +viewH*13/totalHeight, viewW-viewW*44/totalWeight-_videoRateLabel.frame.size.width-_videoRateLabel.frame.origin.x, viewH*44/totalHeight)];
    _videoRateSlider.minimumValue = 220;
    _videoRateSlider.maximumValue = 8000;
    _videoRateSlider.value = 6000;
    _videoRateSlider.thumbTintColor = MAIN_COLOR;
    _videoRateSlider.minimumTrackTintColor = MAIN_COLOR;
    UIImage *Rateimagea=[self OriginImage:[UIImage imageNamed:@"circle"] scaleToSize:CGSizeMake(11, 11)];
    [_videoRateSlider  setThumbImage:Rateimagea forState:UIControlStateNormal];
    [_videoRateSlider addTarget:self action:@selector(_videoRateSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_videoRateView addSubview:_videoRateSlider];
    
    _videoRateMinLabel=[[UILabel alloc] initWithFrame:CGRectMake(_videoRateLabel.frame.size.width+_videoRateLabel.frame.origin.x+viewH*22/totalHeight, viewH*48/totalHeight, viewH*44/totalHeight, viewH*18/totalHeight)];
    _videoRateMinLabel.text = NSLocalizedString(@"video_rate_min", nil);
    _videoRateMinLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoRateMinLabel.backgroundColor = [UIColor clearColor];
    _videoRateMinLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoRateMinLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoRateMinLabel.textAlignment=UITextAlignmentCenter;
    _videoRateMinLabel.numberOfLines = 0;
    [_videoRateView addSubview:_videoRateMinLabel];
    
    _videoRateMaxLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW-viewH*66/totalHeight, viewH*48/totalHeight, viewH*44/totalHeight, viewH*18/totalHeight)];
    _videoRateMaxLabel.text = NSLocalizedString(@"video_rate_max", nil);
    _videoRateMaxLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoRateMaxLabel.backgroundColor = [UIColor clearColor];
    _videoRateMaxLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoRateMaxLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoRateMaxLabel.textAlignment=UITextAlignmentCenter;
    _videoRateMaxLabel.numberOfLines = 0;
    [_videoRateView addSubview:_videoRateMaxLabel];
    
    _videoRateValueLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*275/totalWeight, 0, viewW*44/totalWeight, viewH*18/totalHeight)];
    _videoRateValueLabel.center=CGPointMake(6/8.0*_videoRateSlider.frame.size.width+_videoRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoRateValueLabel.center.y);
    _videoRateValueLabel.text = @"6M";
    _videoRateValueLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoRateValueLabel.backgroundColor = [UIColor clearColor];
    _videoRateValueLabel.textColor = MAIN_COLOR;
    _videoRateValueLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoRateValueLabel.textAlignment=UITextAlignmentCenter;
    _videoRateValueLabel.numberOfLines = 0;
    [_videoRateView addSubview:_videoRateValueLabel];
    
    //Frame
    _videoFrameRateView=[[UIView alloc]init];
    _videoFrameRateView.frame=CGRectMake(0,_videoRateView.frame.origin.y+_videoRateView.frame.size.height+viewH*13/totalHeight, viewW, viewH*57/totalHeight);
    _videoFrameRateView.backgroundColor=[UIColor clearColor];
    [_videoParametersView addSubview:_videoFrameRateView];
    
    _videoFrameRateLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/totalWeight,viewH*13/totalHeight, viewW*80/totalWeight, viewH*44/totalHeight)];
    _videoFrameRateLabel.text = NSLocalizedString(@"video_framerate", nil);
    _videoFrameRateLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
    _videoFrameRateLabel.backgroundColor = [UIColor clearColor];
    _videoFrameRateLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _videoFrameRateLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoFrameRateLabel.textAlignment=NSTextAlignmentRight;
    _videoFrameRateLabel.numberOfLines = 0;
    [_videoFrameRateView addSubview:_videoFrameRateLabel];
    
    _videoFrameRateSlider = [[UISlider alloc] initWithFrame:CGRectMake(_videoFrameRateLabel.frame.size.width+_videoFrameRateLabel.frame.origin.x+viewW*22/totalWeight, +viewH*13/totalHeight, viewW-viewW*44/totalWeight-_videoFrameRateLabel.frame.size.width-_videoFrameRateLabel.frame.origin.x, viewH*44/totalHeight)];
    _videoFrameRateSlider.minimumValue = 10;
    _videoFrameRateSlider.maximumValue = 30;
    _videoFrameRateSlider.value = 25;
    _videoFrameRateSlider.thumbTintColor = MAIN_COLOR;
    _videoFrameRateSlider.minimumTrackTintColor = MAIN_COLOR;
    UIImage *Frameimagea=[self OriginImage:[UIImage imageNamed:@"circle"] scaleToSize:CGSizeMake(11, 11)];
    [_videoFrameRateSlider  setThumbImage:Frameimagea forState:UIControlStateNormal];
    [_videoFrameRateSlider addTarget:self action:@selector(_videoFrameRateSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_videoFrameRateView addSubview:_videoFrameRateSlider];
    
    _videoFrameRateMinLabel=[[UILabel alloc] initWithFrame:CGRectMake(_videoFrameRateLabel.frame.size.width+_videoFrameRateLabel.frame.origin.x+viewH*22/totalHeight, viewH*48/totalHeight, viewH*44/totalHeight, viewH*18/totalHeight)];
    _videoFrameRateMinLabel.text = NSLocalizedString(@"video_framerate_min", nil);
    _videoFrameRateMinLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoFrameRateMinLabel.backgroundColor = [UIColor clearColor];
    _videoFrameRateMinLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoFrameRateMinLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoFrameRateMinLabel.textAlignment=UITextAlignmentCenter;
    _videoFrameRateMinLabel.numberOfLines = 0;
    [_videoFrameRateView addSubview:_videoFrameRateMinLabel];
    
    _videoFrameRateMaxLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW-viewH*66/totalHeight, viewH*48/totalHeight, viewH*44/totalHeight, viewH*18/totalHeight)];
    _videoFrameRateMaxLabel.text = NSLocalizedString(@"video_framerate_max", nil);
    _videoFrameRateMaxLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoFrameRateMaxLabel.backgroundColor = [UIColor clearColor];
    _videoFrameRateMaxLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoFrameRateMaxLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoFrameRateMaxLabel.textAlignment=UITextAlignmentLeft;
    _videoFrameRateMaxLabel.numberOfLines = 0;
    [_videoFrameRateView addSubview:_videoFrameRateMaxLabel];
    
    _videoFrameRateValueLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*275/totalWeight, 0, viewW*48/totalWeight, viewH*18/totalHeight)];
    _videoFrameRateValueLabel.center=CGPointMake(25/30.0*_videoFrameRateSlider.frame.size.width+_videoFrameRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoFrameRateValueLabel.center.y);
    _videoFrameRateValueLabel.text = @"25Fps";
    _videoFrameRateValueLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoFrameRateValueLabel.backgroundColor = [UIColor clearColor];
    _videoFrameRateValueLabel.textColor = MAIN_COLOR;
    _videoFrameRateValueLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoFrameRateValueLabel.textAlignment=UITextAlignmentCenter;
    _videoFrameRateValueLabel.numberOfLines = 0;
    [_videoFrameRateView addSubview:_videoFrameRateValueLabel];
    
    _videoLabelView.center=_videoParametersView.center;
    [self set720P];
    [self setVideoRate:1500];
    [self setVideoFrameRate:25];
    _videoResolutionSlider.enabled=NO;
    _videoRateSlider.enabled=NO;
    _videoFrameRateSlider.enabled=NO;
    _videoParametersView.hidden=NO;
    _ssidText.text=[self getWifiName];
    _configScan = [[Rak_Lx52x_Device_Control alloc] init];
    [self scanDevice];
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

- (void)scanDevice
{
    if (_Exit) {
        return;
    }
    waitAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"main_scan_indicator_title", nil)
                                               message:NSLocalizedString(@"main_scan_indicator", nil)
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil, nil];
    [waitAlertView show];
    [NSThread detachNewThreadSelector:@selector(scanDeviceTask) toTarget:self withObject:nil];
}

- (void)scanDeviceTask
{
    Lx52x_Device_Info *result = [_configScan ScanDeviceWithTime:1.0f];
    [self performSelectorOnMainThread:@selector(scanDeviceOver:) withObject:result waitUntilDone:NO];
}

NSString *resolution;
NSString *fps;
NSString *quality;
- (void)scanDeviceOver:(Lx52x_Device_Info *)result;
{
    if (result.Device_ID_Arr.count > 0) {
        configIP=[result.Device_IP_Arr objectAtIndex:0];
        //get resolution
        NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_resol&type=h264&pipe=0",configIP,configPort];
        HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
        if(http_request.StatusCode==200)
        {
            http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
            resolution=[self parseJsonString:http_request.ResponseString];
            dispatch_async(dispatch_get_main_queue(),^ {
                if ([resolution compare:@"3"]==NSOrderedSame) {
                    [self set1080P];
                }
                else if ([resolution compare:@"2"]==NSOrderedSame) {
                    [self set720P];
                }
                else{
                    [self set480P];
                }
            });
            NSLog(@"resolution=%@",resolution);
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"get_reslution_failed", nil)];
            });
        }
        
        //get quality
        URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_enc_quality&type=h264&pipe=0",configIP,configPort];
        http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
        if(http_request.StatusCode==200)
        {
            http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
            quality=[self parseJsonString:http_request.ResponseString];
            dispatch_async(dispatch_get_main_queue(),^ {
                float value=[quality intValue]*3000/52.0;
                if (((int)value%100)!=0) {
                    value=value+100;
                }
                [self setVideoRate:value];
            });
            NSLog(@"quality=%@",quality);
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"get_quality_failed", nil)];
            });
        }
        
        //get fps
        URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_max_fps&type=h264&pipe=0",configIP,configPort];
        http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
        if(http_request.StatusCode==200)
        {
            http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
            fps=[self parseJsonString:http_request.ResponseString];
            dispatch_async(dispatch_get_main_queue(),^ {
                [self setVideoFrameRate:[fps intValue]];
            });
            
            NSLog(@"fps=%@",fps);
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"get_fps_failed", nil)];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(),^ {
            if (([resolution compare:@"2"]==NSOrderedSame)
                &&([quality compare:@"26"]==NSOrderedSame)
                &&([fps compare:@"25"]==NSOrderedSame)) {
                [self _videoBtnClick:_goodBtn];
            }
            else if (([resolution compare:@"3"]==NSOrderedSame)
                    &&([quality compare:@"86"]==NSOrderedSame)
                    &&([fps compare:@"30"]==NSOrderedSame)) {
                [self _videoBtnClick:_bestBtn];
            }
            else if ((([resolution compare:@"0"]==NSOrderedSame)||([resolution compare:@"1"]==NSOrderedSame))
                     &&([quality compare:@"14"]==NSOrderedSame)
                     &&([fps compare:@"20"]==NSOrderedSame)) {
                [self _videoBtnClick:_smoothBtn];
            }
            else{
                [self _videoBtnClick:_customBtn];
            }
        });
    }
    else
    {
        //[self scanDevice];
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"main_scan_failed", nil)];
        });
    }
    dispatch_async(dispatch_get_main_queue(),^ {
        [waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
    });
}

//返回
- (void)_backBtnClick{
    _Exit=YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doSomethingInSegment:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index)
    {
        case 0:
            [self cubeAnimationLeft];
            break;
        case 1:
            [self cubeAnimationRight];
            break;
        default:
            break;
    }
}

/**
 *  立体翻滚效果
 */
-(void)cubeAnimationLeft{
    _videoView.hidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        CATransition *anima = [CATransition animation];
        anima.type = @"cube";//设置动画的类型
        anima.subtype = kCATransitionFromLeft; //设置动画的方向
        anima.duration = 0.3f;
        
        [_videoView.layer addAnimation:anima forKey:@"revealAnimation"];
    } completion:^(BOOL finished) {
        _passwordView.hidden=YES;
    }];
}

/**
 *  立体翻滚效果
 */
-(void)cubeAnimationRight{
    _passwordView.hidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        CATransition *anima = [CATransition animation];
        anima.type = @"cube";//设置动画的类型
        anima.subtype = kCATransitionFromRight; //设置动画的方向
        anima.duration = 0.3f;
        
        [_passwordView.layer addAnimation:anima forKey:@"revealAnimation"];
    } completion:^(BOOL finished) {
        _videoView.hidden=YES;
    }];
    
}

-(IBAction)_videoResolutionSliderValue:(id)sender{
    float value = _videoResolutionSlider.value; //读取滑块的值
    NSLog(@"value=%f",value);
    
    [UIView animateWithDuration:0.2 animations:^{
        _videoResolutionSlider.value=round(value);
        NSLog(@"round(value)=%f",round(value));
    } completion:^(BOOL finished){
        switch ((int)round(value)) {
            case 0:
            {
               NSLog(@"480P");
               [self set480P];
               break;
            }
            case 1:
            {
                NSLog(@"720P");
                [self set720P];
                break;
            }
            case 2:
            {
                NSLog(@"1080");
                [self set1080P];
                break;
            }
                
            default:
                break;
        }
    }];
}

- (void)set480P{
    _videoResolutionSlider.value=0;
    _videoResolutionMinLabel.textColor = MAIN_COLOR;
    _videoResolutionValueLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoResolutionMaxLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoResolutionMinLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionValueLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionMaxLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionMinImg.hidden=YES;
    _videoResolutionMaxImg.hidden=NO;
    _videoResolutionValueImg.hidden=NO;
}
- (void)set720P{
    _videoResolutionSlider.value=1;
    _videoResolutionValueLabel.textColor = MAIN_COLOR;
    _videoResolutionMinLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoResolutionMaxLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoResolutionMinLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionValueLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionMaxLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];

    _videoResolutionMinImg.hidden=NO;
    _videoResolutionMaxImg.hidden=NO;
    _videoResolutionValueImg.hidden=YES;
}
- (void)set1080P{
    _videoResolutionSlider.value=2;
    _videoResolutionMaxLabel.textColor = MAIN_COLOR;
    _videoResolutionMinLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoResolutionValueLabel.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _videoResolutionMinLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionValueLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionMaxLabel.font = [UIFont systemFontOfSize: viewH*10/totalHeight*0.8];
    _videoResolutionMinImg.hidden=NO;
    _videoResolutionMaxImg.hidden=YES;
    _videoResolutionValueImg.hidden=NO;
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

-(IBAction)_videoRateSliderValue:(id)sender{
    float value = _videoRateSlider.value; //读取滑块的值
    [self setVideoRate:value];
}

-(IBAction)_videoFrameRateSliderValue:(id)sender{
    float value = _videoFrameRateSlider.value; //读取滑块的值
    [self setVideoFrameRate:value];
}

- (void)setVideoRate:(float)value{
    _videoRateSlider.value=value;
    if(value>1000)
    {
        _videoRateValueLabel.text = [[NSString stringWithFormat:@"%.1fM",(value/1000)] stringByReplacingOccurrencesOfString:@".0" withString:@""];
    }
    else{
        _videoRateValueLabel.text = [NSString stringWithFormat:@"%dK",(int)(value)];
    }
    _videoRateValueLabel.center=CGPointMake((_videoRateSlider.value-220)/(8000-220)*_videoRateSlider.frame.size.width+_videoRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoRateValueLabel.center.y);
}

- (void)setVideoFrameRate:(float)value{
    _videoFrameRateSlider.value=value;
    _videoFrameRateValueLabel.text = [NSString stringWithFormat:@"%dFps",(int)value];
    _videoFrameRateValueLabel.center=CGPointMake((_videoFrameRateSlider.value-10)/20.0*_videoFrameRateSlider.frame.size.width+_videoFrameRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoFrameRateValueLabel.center.y);
}

-(void)_videoBtnClick:(UISegmentedControl *)Seg
{
//    [_smoothBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_smoothBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [_goodBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_goodBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [_bestBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_bestBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [_customBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_nor@3x.png"] forState:UIControlStateNormal];
//    [_customBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index)
    {
        case 0:
        {
            [self set480P];
            [self setVideoRate:800];
            [self setVideoFrameRate:20];
            _videoResolutionSlider.enabled=NO;
            _videoRateSlider.enabled=NO;
            _videoFrameRateSlider.enabled=NO;
            [_smoothBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateNormal];
            [_smoothBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            NSLog(@"smooth");
            break;
        }
        case 1:
        {
            [self set720P];
            [self setVideoRate:1500];
            [self setVideoFrameRate:25];
            _videoResolutionSlider.enabled=NO;
            _videoRateSlider.enabled=NO;
            _videoFrameRateSlider.enabled=NO;
            [_goodBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateNormal];
            [_goodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            NSLog(@"good");
            break;
        }
        case 2:
        {
            [self set1080P];
            [self setVideoRate:5000];
            [self setVideoFrameRate:30];
            _videoResolutionSlider.enabled=NO;
            _videoRateSlider.enabled=NO;
            _videoFrameRateSlider.enabled=NO;
            [_bestBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateNormal];
            [_bestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            NSLog(@"best");
            break;
        }
        case 3:
        {
            _videoResolutionSlider.enabled=YES;
            _videoRateSlider.enabled=YES;
            _videoFrameRateSlider.enabled=YES;
            [_customBtn setBackgroundImage:[UIImage imageNamed:@"configure_setting_button_sel@3x.png"] forState:UIControlStateNormal];
            [_customBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            NSLog(@"custom");
            break;
        }
        default:
            break;
    }
}

/**
 *  移入效果
 */
-(void)moveInAnimation{
    _videoParametersView.hidden=NO;
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionMoveIn;//设置动画的类型
    anima.subtype = kCATransitionFromLeft; //设置动画的方向
    anima.duration = 0.3f;
    
    [_videoParametersView.layer addAnimation:anima forKey:@"moveInAnimation"];
}

/**
 *  移出效果
 */
-(void)revealAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        CATransition *anima = [CATransition animation];
        anima.type = kCATransitionReveal;//设置动画的类型
        anima.subtype = kCATransitionFromRight; //设置动画的方向
        anima.duration = 0.3f;
        
        [_videoParametersView.layer addAnimation:anima forKey:@"revealAnimation"];
    } completion:^(BOOL finished) {
        _videoParametersView.hidden=YES;
    }];
}

bool _modifyOK=YES;
-(void)_videoModifyBtnClick{
    NSLog(@"_videoModifyBtnClick");
    _modifyOK=YES;
    //set resolution
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_resol&type=h264&pipe=0&value=%d",configIP,configPort,(int)_videoResolutionSlider.value+1];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        resolution=[self parseJsonString:http_request.ResponseString];
        if ([resolution compare:@"0"]!=NSOrderedSame) {
            _modifyOK=NO;
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"set_reslution_failed", nil)];
            });
        }
        NSLog(@"resolution=%@",resolution);
    }
    else{
        _modifyOK=NO;
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"set_reslution_failed", nil)];
        });
    }
    
    //set quality
    float qualityValue=_videoRateSlider.value*52/3000;
    if ((int)(qualityValue*100)%100!=0) {
        qualityValue=qualityValue+1;
    }
    URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_enc_quality&type=h264&pipe=0&value=%d",configIP,configPort,(int)qualityValue];
    http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        quality=[self parseJsonString:http_request.ResponseString];
        if ([quality compare:@"0"]!=NSOrderedSame) {
            _modifyOK=NO;
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"set_quality_failed", nil)];
            });
        }
        NSLog(@"quality=%@",quality);
    }
    else{
        _modifyOK=NO;
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"set_quality_failed", nil)];
        });
    }
    
    //set fps
    URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_max_fps&type=h264&pipe=0&value=%d",configIP,configPort,(int)_videoFrameRateSlider.value];
    http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        fps=[self parseJsonString:http_request.ResponseString];
        if ([fps compare:@"0"]!=NSOrderedSame) {
            _modifyOK=NO;
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"set_fps_failed", nil)];
            });
        }
        NSLog(@"fps=%@",fps);
    }
    else{
        _modifyOK=NO;
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"set_fps_failed", nil)];
        });
    }

    if (_modifyOK) {
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"set_video_success", nil)];
        });
    }
}

-(void)touchesImage{
    _resetView.hidden=YES;
    _resetBgView.hidden=YES;
}

- (void)_passwordReseting{
    _resetTitle.frame= CGRectMake(83*viewW/totalWeight, 12*viewH/totalHeight, 150*viewW/totalWeight, 38*viewH/totalHeight);
    _resetTitle.textAlignment=UITextAlignmentLeft;
    _resetTitle.text = NSLocalizedString(@"password_reset_title", nil);
    _resetLabel1.text = NSLocalizedString(@"password_reset_text", nil);
    _resetLabel1.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _resetImg.hidden=NO;
    _resetView.hidden=NO;
    _resetBgView.hidden=NO;
}

- (void)_passwordResetComplete{
    _resetImg.hidden=YES;
    _resetTitle.frame= CGRectMake(38*viewW/totalWeight, 12*viewH/totalHeight, 150*viewW/totalWeight, 38*viewH/totalHeight);
    _resetTitle.textAlignment=UITextAlignmentCenter;
    _resetTitle.text = NSLocalizedString(@"password_complete_title", nil);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"password_complete_text", nil)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0] range:NSMakeRange(0,16)];
    [str addAttribute:NSForegroundColorAttributeName value:MAIN_COLOR range:NSMakeRange(17,8)];
    _resetLabel1.attributedText=str;
    _resetView.hidden=NO;
    _resetBgView.hidden=NO;
}

- (void)_passwordForgetBtnClick{
    NSLog(@"_passwordForgetBtnClick");
    [self _passwordReseting];
    [NSThread detachNewThreadSelector:@selector(ResetPassword) toTarget:self withObject:nil];
}

-(void)ResetPassword{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://192.168.100.1/server.command?command=reset_wifi"];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        resolution=[self parseJsonString:http_request.ResponseString];
        if ([resolution compare:@"0"]!=NSOrderedSame) {
            dispatch_async(dispatch_get_main_queue(),^ {
                [self _passwordResetComplete];
            });
        }
    }
    else{
        dispatch_async(dispatch_get_main_queue(),^ {
            _resetImg.hidden=YES;
            _resetView.hidden=YES;
            _resetBgView.hidden=YES;
            [self showAllTextDialog:NSLocalizedString(@"password_complete_failed", nil)];
        });
    }
}

- (void)_passwordModifyBtnClick{
    NSLog(@"_passwordModifyBtnClick");
    
    if([_newPasswordText.text compare:_confirmText.text]!=NSOrderedSame){
        [self showAllTextDialog:NSLocalizedString(@"password_not_same", nil)];
        return;
    }
    
    //设置STA模块的密码
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/param.cgi?action=update&group=wifi&sta_mac=0&sta_ssid=%@&sta_auth_key=%@",configIP,configPort,_ssidText.text,_newPasswordText.text];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
    if(http_request.StatusCode==200)
    {
        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
        resolution=[self parseJsonString:http_request.ResponseString];
        if ([resolution compare:@"0"]!=NSOrderedSame) {
            //设置AP模块的密码
            if ([_newPasswordText.text compare:@""]==NSOrderedSame) {
                URL=[[NSString alloc]initWithFormat:@"http://192.168.100.1/param.cgi?action=update&group=wifi&ap_auth_key=12345678&ap_auth_mode=OPEN&ap_hide_ssid=0&ap_channel=36"];
            }
            else{
                URL=[[NSString alloc]initWithFormat:@"http://192.168.100.1/param.cgi?action=update&group=wifi&ap_auth_key=%@&ap_auth_mode=WPA2PSK&ap_hide_ssid=0&ap_channel=36",_newPasswordText.text];
            }
            http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
            if(http_request.StatusCode==200)
            {
                http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
                resolution=[self parseJsonString:http_request.ResponseString];
                if ([resolution compare:@"0"]!=NSOrderedSame) {
                    dispatch_async(dispatch_get_main_queue(),^ {
                        dispatch_async(dispatch_get_main_queue(),^ {
                            [self showAllTextDialog:NSLocalizedString(@"password_modify_success", nil)];
                        });
                    });
                }
                else{
                    dispatch_async(dispatch_get_main_queue(),^ {
                        [self showAllTextDialog:NSLocalizedString(@"password_modify_failed", nil)];
                    });
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue(),^ {
                    [self showAllTextDialog:NSLocalizedString(@"password_modify_failed", nil)];
                });
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"password_modify_failed", nil)];
            });
        }
    }
    else{
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"password_modify_failed", nil)];
        });
    }
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //隐藏键盘
    [_ssidText resignFirstResponder];
    [_initPasswordText resignFirstResponder];
    [_newPasswordText resignFirstResponder];
    [_confirmText resignFirstResponder];
}
    // 开始编辑输入框时，键盘出现，视图的Y坐标向上移动offset个单位，腾出空间显示键盘
- (void)textFieldDidBeginEditing:(UITextField *)textField
    {
        
        CGRect textFrame = textField.frame;
        CGPoint textPoint = [textField convertPoint:CGPointMake(0, textField.frame.size.height) toView:self.view];// 关键的一句，一定要转换
        int offset = textPoint.y + textFrame.size.height + 216 - self.view.frame.size.height + 70;// 50是textfield和键盘上方的间距，可以自由设定
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        // 将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if (offset > 0) {
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        }
        
        [UIView commitAnimations];
    }
    
    // 用户输入时
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // 输入结束后，将视图恢复到原始状态
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    return YES;
}


-(NSString*)parseJsonString:(NSString *)srcStr{
    NSString *Str=@"";
    NSString *keyStr=@"\"value\":\"";
    NSString *endStr=@"\"";
    NSRange range=[srcStr rangeOfString:keyStr];
    if (range.location != NSNotFound) {
        int i=(int)range.location;
        srcStr=[srcStr substringFromIndex:i+keyStr.length];
        NSRange range1=[srcStr rangeOfString:endStr];
        if (range1.location != NSNotFound) {
            int j=(int)range1.location;
            NSRange diffRange=NSMakeRange(0, j);
            Str=[srcStr substringWithRange:diffRange];
        }
    }
    return Str;
}
#pragma mark-- Toast显示示例
-(void)showAllTextDialog:(NSString *)str{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = str;
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        //[HUD release];
        //HUD = nil;
    }];
}

//Get Wifi Name
-(NSString *)getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (void)_ssidImgClick{
    NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

//Show password
- (void)_initPasswordImgShowPskClick{
    if (_initPasswordText.secureTextEntry) {
        _initPasswordText.secureTextEntry = NO;
        _initPasswordImg.image=[UIImage imageNamed:@"icon_display_pre"];
    }
    else{
        _initPasswordText.secureTextEntry = YES;
        _initPasswordImg.image=[UIImage imageNamed:@"icon_display_nor"];
    }
}

- (void)_confirmImgShowPskClick{
    if (_confirmText.secureTextEntry) {
        _confirmText.secureTextEntry = NO;
        _confirmPasswordImg.image=[UIImage imageNamed:@"icon_display_pre"];
    }
    else{
        _confirmText.secureTextEntry = YES;
        _confirmPasswordImg.image=[UIImage imageNamed:@"icon_display_nor"];
    }
}

- (void)_newPasswordImgShowPskClick{
    if (_newPasswordText.secureTextEntry) {
        _newPasswordText.secureTextEntry = NO;
        _newPasswordImg.image=[UIImage imageNamed:@"icon_display_pre"];
    }
    else{
        _newPasswordText.secureTextEntry = YES;
        _newPasswordImg.image=[UIImage imageNamed:@"icon_display_nor"];
    }
}


/*
 对原来的图片的大小进行处理
 @param image 要处理的图片
 @param size  处理过图片的大小
 */
-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}
@end
