//
//  NetworkViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "NetworkViewController.h"
#import "HttpRequest.h"
#import "CommanParameters.h"

@interface NetworkViewController ()
{
    int _enableDhcp;
    NSString *setIp;
    NSString *setMask;
    NSString *setGateway;
    NSString *setDNS;
}
@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    //顶部
    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav bar_bg@3x.png"]];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*64/totalHeight);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(0, diff_top, viewH*44/totalHeight, viewH*44/totalHeight);
    [_backBtn setImage:[UIImage imageNamed:@"back_nor@3x.png"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage imageNamed:@"back_pre@3x.png"] forState:UIControlStateHighlighted];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtn.frame.origin.x+_backBtn.frame.size.width, diff_top, viewW-_backBtn.frame.origin.x-_backBtn.frame.size.width-2*diff_x, viewH*44/totalHeight)];
    _titleLabel.center=CGPointMake(self.view.center.x, _backBtn.center.y);
    _titleLabel.text = NSLocalizedString(@"network_title", nil);
    _titleLabel.font = [UIFont boldSystemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    //Status
    _networkStatusView=[[UIView alloc]initWithFrame:CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*20/totalHeight,viewW,viewH*44/totalHeight)];
    _networkStatusView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_networkStatusView];
    
    _networkTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*20/totalHeight, viewW*150/totalWeight, viewH*44/totalHeight)];
    _networkTextLabel.text = NSLocalizedString(@"network_state_label", nil);
    _networkTextLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _networkTextLabel.backgroundColor = [UIColor clearColor];
    _networkTextLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _networkTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    _networkTextLabel.textAlignment=UITextAlignmentLeft;
    _networkTextLabel.numberOfLines = 0;
    [self.view addSubview:_networkTextLabel];
    
    _networkStatusLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*235/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*20/totalHeight,viewW*125/totalWeight, viewH*44/totalHeight)];
    _networkStatusLabel.text = NSLocalizedString(@"network_not_connected", nil);
    _networkStatusLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _networkStatusLabel.backgroundColor = [UIColor clearColor];
    _networkStatusLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _networkStatusLabel.lineBreakMode = UILineBreakModeWordWrap;
    _networkStatusLabel.textAlignment=UITextAlignmentRight;
    _networkStatusLabel.numberOfLines = 0;
    [self.view addSubview:_networkStatusLabel];
    
    //DHCP
    _networkDHCPView=[[UIView alloc]initWithFrame:CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*84/totalHeight,viewW,viewH*44/totalHeight)];
    _networkDHCPView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_networkDHCPView];
    
    _networkDHCPLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*84/totalHeight, viewW*150/totalWeight, viewH*44/totalHeight)];
    _networkDHCPLabel.text = NSLocalizedString(@"network_dhcp", nil);
    _networkDHCPLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _networkDHCPLabel.backgroundColor = [UIColor clearColor];
    _networkDHCPLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _networkDHCPLabel.lineBreakMode = UILineBreakModeWordWrap;
    _networkDHCPLabel.textAlignment=UITextAlignmentLeft;
    _networkDHCPLabel.numberOfLines = 0;
    [self.view addSubview:_networkDHCPLabel];
    
    _networkDHCPBtn= [[UISwitch alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*84/totalHeight,viewW*51/totalWeight, viewH*31/totalHeight)];
    _networkDHCPBtn.center=CGPointMake(viewW*342/totalWeight, _networkDHCPLabel.center.y);
    _networkDHCPBtn.on = NO;
    _networkDHCPBtn.onTintColor =MAIN_COLOR;
    [_networkDHCPBtn addTarget:self action:@selector(_networkDHCPBtnAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_networkDHCPBtn];
    
    //IP
    _networkIPView=[[UIView alloc] initWithFrame:CGRectMake( viewW*17/totalWeight, _networkDHCPView.frame.origin.y+_networkDHCPView.frame.size.height+viewH*15/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
    [[_networkIPView layer] setBorderWidth:1.0];//画线的宽度
    [[_networkIPView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
    [[_networkIPView layer]setCornerRadius:viewW*14/totalWeight];//圆角
    _networkIPView.backgroundColor=[UIColor whiteColor];
    [_networkIPView.layer setMasksToBounds:YES];
    [self.view addSubview:_networkIPView];
    
    _networkIPLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*10/totalWeight, 0, viewW*110/totalWeight, viewH*40/totalHeight)];
    _networkIPLabel.text = NSLocalizedString(@"network_ip", nil);
    _networkIPLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkIPLabel.backgroundColor = [UIColor clearColor];
    _networkIPLabel.textColor = MAIN_COLOR;
    _networkIPLabel.lineBreakMode = UILineBreakModeWordWrap;
    _networkIPLabel.textAlignment=UITextAlignmentCenter;
    _networkIPLabel.numberOfLines = 0;
    [_networkIPView addSubview:_networkIPLabel];
    
    UIView *_ssidLine=[[UIView alloc]init];
    _ssidLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
    _ssidLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_networkIPView addSubview:_ssidLine];
    
    _networkIPText=[[UITextField alloc]init];
    _networkIPText.frame=CGRectMake(viewW*154/totalWeight,0, viewW*180/totalWeight, viewH*40/totalHeight);
    _networkIPText.backgroundColor = [UIColor whiteColor];
    _networkIPText.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkIPText.placeholder=NSLocalizedString(@"network_ip", nil);
    [_networkIPView addSubview:_networkIPText];
    
    //Mask
    _networkMaskView=[[UIView alloc] initWithFrame:CGRectMake( viewW*15/totalWeight, _networkIPView.frame.origin.y+_networkIPView.frame.size.height+viewH*15/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
    [[_networkMaskView layer] setBorderWidth:1.0];//画线的宽度
    [[_networkMaskView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
    [[_networkMaskView layer]setCornerRadius:viewW*14/totalWeight];//圆角
    _networkMaskView.backgroundColor=[UIColor whiteColor];
    [_networkMaskView.layer setMasksToBounds:YES];
    [self.view addSubview:_networkMaskView];
    
    _networkMaskLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*10/totalWeight, 0, viewW*120/totalWeight, viewH*40/totalHeight)];
    _networkMaskLabel.text = NSLocalizedString(@"network_mask", nil);
    _networkMaskLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkMaskLabel.backgroundColor = [UIColor clearColor];
    _networkMaskLabel.textColor = MAIN_COLOR;
    _networkMaskLabel.lineBreakMode = UILineBreakModeWordWrap;
    _networkMaskLabel.textAlignment=UITextAlignmentCenter;
    _networkMaskLabel.numberOfLines = 0;
    [_networkMaskView addSubview:_networkMaskLabel];
    
    UIView *_initPasswordLine=[[UIView alloc]init];
    _initPasswordLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
    _initPasswordLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_networkMaskView addSubview:_initPasswordLine];
    
    _networkMaskText=[[UITextField alloc]init];
    _networkMaskText.frame=CGRectMake(viewW*154/totalWeight,0, viewW*180/totalWeight, viewH*40/totalHeight);
    _networkMaskText.backgroundColor = [UIColor whiteColor];
    _networkMaskText.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkMaskText.placeholder=NSLocalizedString(@"network_mask", nil);
    [_networkMaskView addSubview:_networkMaskText];
    
    //Gateway
    _networkGatewayView=[[UIView alloc] initWithFrame:CGRectMake( viewW*15/totalWeight, _networkMaskView.frame.origin.y+_networkMaskView.frame.size.height+viewH*15/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
    [[_networkGatewayView layer] setBorderWidth:1.0];//画线的宽度
    [[_networkGatewayView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
    [[_networkGatewayView layer]setCornerRadius:viewW*14/totalWeight];//圆角
    _networkGatewayView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_networkGatewayView];
    
    _networkGatewayLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*10/totalWeight, 0, viewW*110/totalWeight, viewH*40/totalHeight)];
    _networkGatewayLabel.text = NSLocalizedString(@"network_gateway", nil);
    _networkGatewayLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkGatewayLabel.backgroundColor = [UIColor clearColor];
    _networkGatewayLabel.textColor = MAIN_COLOR;
    _networkGatewayLabel.lineBreakMode = UILineBreakModeWordWrap;
    _networkGatewayLabel.textAlignment=UITextAlignmentCenter;
    _networkGatewayLabel.numberOfLines = 0;
    [_networkGatewayView addSubview:_networkGatewayLabel];
    
    UIView *_newPasswordLine=[[UIView alloc]init];
    _newPasswordLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
    _newPasswordLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_networkGatewayView addSubview:_newPasswordLine];
    
    _networkGatewayText=[[UITextField alloc]init];
    _networkGatewayText.frame=CGRectMake(viewW*154/totalWeight,0, viewW*180/totalWeight, viewH*40/totalHeight);
    _networkGatewayText.backgroundColor = [UIColor whiteColor];
    _networkGatewayText.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkGatewayText.placeholder=NSLocalizedString(@"network_gateway", nil);
    [_networkGatewayView addSubview:_networkGatewayText];

    //DNS
    _networkDNSView=[[UIView alloc] initWithFrame:CGRectMake( viewW*15/totalWeight, _networkGatewayView.frame.origin.y+_networkGatewayView.frame.size.height+viewH*15/totalHeight,viewW*345/totalWeight, viewH*40/totalHeight)];
    [[_networkDNSView layer] setBorderWidth:1.0];//画线的宽度
    [[_networkDNSView layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0].CGColor];//颜色
    [[_networkDNSView layer]setCornerRadius:viewW*14/totalWeight];//圆角
    _networkDNSView.backgroundColor=[UIColor whiteColor];
    [_networkDNSView.layer setMasksToBounds:YES];
    [self.view addSubview:_networkDNSView];
    
    _networkDNSLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*10/totalWeight, 0, viewW*110/totalWeight, viewH*40/totalHeight)];
    _networkDNSLabel.text = NSLocalizedString(@"network_dns", nil);
    _networkDNSLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkDNSLabel.backgroundColor = [UIColor clearColor];
    _networkDNSLabel.textColor = MAIN_COLOR;
    _networkDNSLabel.lineBreakMode = UILineBreakModeWordWrap;
    _networkDNSLabel.textAlignment=UITextAlignmentCenter;
    _networkDNSLabel.numberOfLines = 0;
    [_networkDNSView addSubview:_networkDNSLabel];
    
    UIView *_confirmLine=[[UIView alloc]init];
    _confirmLine.frame=CGRectMake(viewW*141/totalWeight,0, 1, viewH*40/totalHeight);
    _confirmLine.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_networkDNSView addSubview:_confirmLine];
    
    _networkDNSText=[[UITextField alloc]init];
    _networkDNSText.frame=CGRectMake(viewW*154/totalWeight,0, viewW*180/totalWeight, viewH*40/totalHeight);
    _networkDNSText.backgroundColor = [UIColor whiteColor];
    _networkDNSText.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkDNSText.placeholder=NSLocalizedString(@"network_dns", nil);
    [_networkDNSView addSubview:_networkDNSText];
    
    //Confirm
    _networkConfirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _networkConfirmBtn.frame = CGRectMake(viewW*30/totalWeight,viewH*514/totalHeight , viewW*316/totalWeight, viewH*44/totalHeight);
    [_networkConfirmBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_nor@3x.png"] forState:UIControlStateNormal];
    [_networkConfirmBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_dis@3x.png"] forState:UIControlStateHighlighted];
    [_networkConfirmBtn setTitle: NSLocalizedString(@"network_confirm", nil) forState: UIControlStateNormal];
    [_networkConfirmBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _networkConfirmBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _networkConfirmBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_networkConfirmBtn addTarget:nil action:@selector(_networkConfirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_networkConfirmBtn];
    [NSThread detachNewThreadSelector:@selector(GetNetworkFormart) toTarget:self withObject:nil];
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

- (void)_networkDHCPBtnAction:(UISwitch*)sender{
    if (sender.on) {
        NSLog(@"_networkDHCPBtn is on");
        _networkIPText.enabled=NO;
        _networkMaskText.enabled=NO;
        _networkGatewayText.enabled=NO;
        _networkDNSText.enabled=NO;
        _enableDhcp=1;
    }
    else{
        NSLog(@"_networkDHCPBtn is off");
        _networkIPText.enabled=YES;
        _networkMaskText.enabled=YES;
        _networkGatewayText.enabled=YES;
        _networkDNSText.enabled=YES;
        _enableDhcp=0;
    }
}

- (void)_networkConfirmBtnClick{
    NSLog(@"_networkConfirmBtnClick");
    [NSThread detachNewThreadSelector:@selector(SetNetworkFormart) toTarget:self withObject:nil];
}

#pragma mark-- 设置网络ip
-(void)SetNetworkFormart
{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_ip&auto_ip=%d&ip_addr=%@&subnet_mask=%@&gateway=%@&dns1=%@&dns2=%@",_ip,80,_enableDhcp,setIp,setMask,setGateway,setDNS,setIp];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        //        NSString *_value=[self parseJsonString:http_request.ResponseString];
        //        if (([_value compare:@"1"] == NSOrderedSame)) {
        //
        //        }
        //        else{
        //
        //        }
    }
}

#pragma mark-- 获取网络ip设置
-(void)GetNetworkFormart
{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_ip",_ip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([http_request.ResponseString compare:@""]==NSOrderedSame) {
                return;
            }
            _enableDhcp=[[self parseJsonString2:http_request.ResponseString :@"\"autoip\": \""] intValue];
            if (_enableDhcp==0) {
                _networkDHCPBtn.on=NO;
            }
            else{
               _networkDHCPBtn.on=YES;
            }
            _networkIPText.text=[self parseJsonString2:http_request.ResponseString :@"\"ip_addr\": \""];
            _networkMaskText.text=[self parseJsonString2:http_request.ResponseString :@"\"subnet_mask\": \""];
            _networkGatewayText.text=[self parseJsonString2:http_request.ResponseString :@"\"gateway\": \""];
            _networkDNSText.text=[self parseJsonString2:http_request.ResponseString :@"\"dns1\": \""];
        });
    }
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

-(NSString *)parseJsonString2:(NSString *)srcStr :(NSString *)keyStr{
    NSString *Str=@"";
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
    [_networkIPText resignFirstResponder];
    [_networkMaskText resignFirstResponder];
    [_networkGatewayText resignFirstResponder];
    [_networkDNSText resignFirstResponder];
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

@end
