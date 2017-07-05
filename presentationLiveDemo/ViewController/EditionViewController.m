//
//  EditionViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/26.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "EditionViewController.h"
#import "CommanParameter.h"
#import "UpdateFirmwareViewController.h"
#import "Rak_Lx52x_Device_Control.h"
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "CommanParameters.h"

Rak_Lx52x_Device_Control *_firmwareScan;
@interface EditionViewController ()
{
    bool _Exit;
    UIAlertView *waitAlertView;
}
@end

@implementation EditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _Exit=NO;
    self.view.backgroundColor=[UIColor colorWithRed:244/255.0 green:245/255.0 blue:247/255.0 alpha:1.0];
    
    //顶部
//    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav bar_bg@3x.png"]];
    _topBg=[[UIImageView alloc]init];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*67/totalHeight);
    _topBg.backgroundColor = [UIColor whiteColor];
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
//    _titleLabel.text = NSLocalizedString(@"edition", nil);
    _titleLabel.text = @"Version";
    _titleLabel.font = [UIFont boldSystemFontOfSize: viewH*22.5/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    
    _topLogo=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo@3x.png"]];
    _topLogo.frame = CGRectMake(0, viewH*117/totalHeight,viewH*73.5/totalHeight, viewH*73.5/totalHeight);
    _topLogo.center=CGPointMake(viewW*0.5, _topLogo.center.y);
    _topLogo.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topLogo];

    _topName=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav_title_image@3x.png"]];
    _topName.frame = CGRectMake(0, viewH*17/totalHeight+_topLogo.frame.size.height+_topLogo.frame.origin.y, viewH*20*474/totalHeight/60, viewH*17.5/totalHeight);
    _topName.center=CGPointMake(viewW*0.5-viewW*25/totalWeight, _topName.center.y);
    _topName.contentMode=UIViewContentModeScaleToFill;
    //[self.view addSubview:_topName];
    
    _appVersionLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH*17.5/totalHeight)];
    _appVersionLabel.center=CGPointMake(_appVersionLabel.center.x, _topName.center.y);
    _appVersionLabel.text = [NSString stringWithFormat:@"Freecast %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    _appVersionLabel.font = [UIFont systemFontOfSize: viewH*17.5/totalHeight*0.8];
    _appVersionLabel.backgroundColor = [UIColor clearColor];
    _appVersionLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _appVersionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _appVersionLabel.textAlignment=UITextAlignmentCenter;
    _appVersionLabel.numberOfLines = 0;
    [self.view addSubview:_appVersionLabel];
    
    //ID
    _deviceIdView=[[UIView alloc]init];
    _deviceIdView.frame=CGRectMake(0, viewH*75/totalHeight+_appVersionLabel.frame.size.height+_appVersionLabel.frame.origin.y, viewW, viewH*47.5/totalHeight);
    _deviceIdView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_deviceIdView];
    
    _deviceIdLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH*17.5/totalHeight)];
    _deviceIdLabel.text = NSLocalizedString(@"version_id_text", nil);;
    _deviceIdLabel.backgroundColor = [UIColor clearColor];
    _deviceIdLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _deviceIdLabel.lineBreakMode = UILineBreakModeWordWrap;
    _deviceIdLabel.textAlignment=UITextAlignmentCenter;
    _deviceIdLabel.numberOfLines = 0;
    [_deviceIdView addSubview:_deviceIdLabel];
    
    _deviceIdValue= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*5/totalHeight+_deviceIdLabel.frame.origin.y+_deviceIdLabel.frame.size.height, viewW, viewH*25/totalHeight)];
    _deviceIdValue.text = @"";
    _deviceIdValue.backgroundColor = [UIColor clearColor];
    _deviceIdValue.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _deviceIdValue.lineBreakMode = UILineBreakModeWordWrap;
    _deviceIdValue.textAlignment=UITextAlignmentCenter;
    _deviceIdValue.font = [UIFont systemFontOfSize:viewH*25/totalHeight*0.8];
    _deviceIdValue.numberOfLines = 0;
    [_deviceIdView addSubview:_deviceIdValue];
    
    //IP
    _deviceIpView=[[UIView alloc]init];
    _deviceIpView.frame=CGRectMake(0, viewH*75/totalHeight+_deviceIdView.frame.size.height+_deviceIdView.frame.origin.y, viewW, viewH*47.5/totalHeight);
    _deviceIpView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_deviceIpView];
    
    _deviceIpLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH*17.5/totalHeight)];
    _deviceIpLabel.text = NSLocalizedString(@"version_ip_text", nil);;
    _deviceIpLabel.backgroundColor = [UIColor clearColor];
    _deviceIpLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _deviceIpLabel.lineBreakMode = UILineBreakModeWordWrap;
    _deviceIpLabel.textAlignment=UITextAlignmentCenter;
    _deviceIpLabel.numberOfLines = 0;
    [_deviceIpView addSubview:_deviceIpLabel];
    
    _deviceIpValue= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*5/totalHeight+_deviceIdLabel.frame.origin.y+_deviceIdLabel.frame.size.height, viewW, viewH*25/totalHeight)];
    _deviceIpValue.text = @"";
    _deviceIpValue.backgroundColor = [UIColor clearColor];
    _deviceIpValue.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _deviceIpValue.lineBreakMode = UILineBreakModeWordWrap;
    _deviceIpValue.textAlignment=UITextAlignmentCenter;
    _deviceIpValue.font = [UIFont systemFontOfSize:viewH*25/totalHeight*0.8];
    _deviceIpValue.numberOfLines = 0;
    [_deviceIpView addSubview:_deviceIpValue];
    
    
    //Upgrade Firmware
    UILabel *firmwareUpgradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,_deviceIpView.frame.origin.y+_deviceIpView.frame.size.height+viewH*60.5/totalHeight,viewW*299/totalWeight,viewH*72/totalHeight)];
    firmwareUpgradeLabel.center=CGPointMake(viewW*0.5, firmwareUpgradeLabel.center.y);
    firmwareUpgradeLabel.layer.cornerRadius = 5;
    firmwareUpgradeLabel.layer.borderColor = MAIN_COLOR.CGColor;
    firmwareUpgradeLabel.layer.borderWidth = 2;
    firmwareUpgradeLabel.userInteractionEnabled = YES;
    [self.view addSubview:firmwareUpgradeLabel];
    
    UILabel *linelabel = [[UILabel alloc] initWithFrame:CGRectMake(2,viewH*36/totalHeight - 1,viewW*296/totalWeight,2)];
    linelabel.backgroundColor = MAIN_COLOR;
    [firmwareUpgradeLabel addSubview:linelabel];
    
    
    //Upgrade Firmware
    _firmwareUpgradeView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(2,0,viewW*296/totalWeight,viewH*36/totalHeight)];
    _firmwareUpgradeView.backgroundColor=[UIColor clearColor];
    _firmwareUpgradeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_firmwareUpgradeViewClick)];
    [_firmwareUpgradeView addGestureRecognizer:singleTap];
    [firmwareUpgradeLabel addSubview:_firmwareUpgradeView];
    
    _firmwareUpgradeLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/totalWeight, 0, viewW*296/totalWeight, viewH*36/totalHeight)];
    _firmwareUpgradeLabel.text = NSLocalizedString(@"version_ip_upgrade_firmware", nil);
    _firmwareUpgradeLabel.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _firmwareUpgradeLabel.backgroundColor = [UIColor clearColor];
    _firmwareUpgradeLabel.textColor = MAIN_COLOR;
    _firmwareUpgradeLabel.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareUpgradeLabel.textAlignment=UITextAlignmentLeft;
    _firmwareUpgradeLabel.numberOfLines = 0;
    [_firmwareUpgradeView addSubview:_firmwareUpgradeLabel];
    
    _firmwareUpgradeValue= [[UILabel alloc] initWithFrame:CGRectMake(viewW*296/totalWeight-viewW*144/totalWeight, 0, viewW*100/totalWeight, viewH*36/totalHeight)];
    _firmwareUpgradeValue.text = @"";
    _firmwareUpgradeValue.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _firmwareUpgradeValue.backgroundColor = [UIColor clearColor];
    _firmwareUpgradeValue.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _firmwareUpgradeValue.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareUpgradeValue.textAlignment=UITextAlignmentCenter;
    _firmwareUpgradeValue.numberOfLines = 0;
    [_firmwareUpgradeView addSubview:_firmwareUpgradeValue];
    
    _firmwareUpgradeImg=[[UIImageView alloc]init];
    _firmwareUpgradeImg.frame = CGRectMake(viewW*296/totalWeight-viewW*30.5/totalWeight, viewH*8/totalHeight, viewH*20/totalHeight, viewH*20/totalHeight);
    [_firmwareUpgradeImg setImage:[UIImage imageNamed:@"icon_right"]];
//    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI);
//    [_firmwareUpgradeImg setTransform:rotate];
    [_firmwareUpgradeView  addSubview:_firmwareUpgradeImg];

    //Upgrade APP
    _newVersionView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(2,_firmwareUpgradeView.frame.origin.y+_firmwareUpgradeView.frame.size.height+1,viewW*296/totalWeight,viewH*36/totalHeight)];
    _newVersionView.backgroundColor=[UIColor clearColor];
    _newVersionView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_newVersionViewClick)];
    [_newVersionView addGestureRecognizer:singleTap2];
    [firmwareUpgradeLabel addSubview:_newVersionView];
    
    _newVersionLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*15/totalWeight, 0, viewW*296/totalWeight, viewH*36/totalHeight)];
    _newVersionLabel.text = NSLocalizedString(@"version_ip_upgrade_app", nil);
    _newVersionLabel.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _newVersionLabel.backgroundColor = [UIColor clearColor];
    _newVersionLabel.textColor = MAIN_COLOR;
    _newVersionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _newVersionLabel.textAlignment=UITextAlignmentLeft;
    _newVersionLabel.numberOfLines = 0;
    [_newVersionView addSubview:_newVersionLabel];
    
    _newVersionImg=[[UIImageView alloc]init];
    _newVersionImg.frame = CGRectMake(viewW*296/totalWeight-viewW*30.5/totalWeight, viewH*8/totalHeight, viewH*20/totalHeight, viewH*20/totalHeight);
    [_newVersionImg setImage:[UIImage imageNamed:@"icon_right"]];
//    [_newVersionImg setTransform:rotate];
    [_newVersionView  addSubview:_newVersionImg];
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

- (void) viewDidAppear:(BOOL)animated
{
    _Exit=NO;
    _firmwareScan = [[Rak_Lx52x_Device_Control alloc] init];
    [self scanDevice];
    [super viewDidAppear:animated];
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
    Lx52x_Device_Info *result = [_firmwareScan ScanDeviceWithTime:1.0f];
    [self performSelectorOnMainThread:@selector(scanDeviceOver:) withObject:result waitUntilDone:NO];
}

NSString *version;
- (void)scanDeviceOver:(Lx52x_Device_Info *)result;
{
    if (result.Device_ID_Arr.count > 0) {
        dispatch_async(dispatch_get_main_queue(),^ {
            _deviceIpValue.text=[result.Device_IP_Arr objectAtIndex:0];
            [self Save_Paths:_deviceIpValue.text :@"DEVICEIP"];
            _deviceIdValue.text=[result.Device_ID_Arr objectAtIndex:0];
            //get version
            NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_version",_deviceIpValue.text,80];
            HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
            if(http_request.StatusCode==200)
            {
                http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
                version=[self parseJsonString:http_request.ResponseString];
                dispatch_async(dispatch_get_main_queue(),^ {
                    _firmwareUpgradeValue.text=version;
                    [self Save_Paths:_firmwareUpgradeValue.text :@"DEVICEVERSION"];
                    NSRange range=[version rangeOfString:@"_V"];
                    if (range.location != NSNotFound) {
                        int i=(int)range.location;
                        version=[version substringFromIndex:i+1];
                        _firmwareUpgradeValue.text=version;
                    }
                    else{
                        range=[version rangeOfString:@"_v"];
                        if (range.location != NSNotFound) {
                            int i=(int)range.location;
                            version=[version substringFromIndex:i+1];
                            _firmwareUpgradeValue.text=version;
                        }
                    }
                });
                NSLog(@"version=%@",version);
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
    _Exit=NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_firmwareUpgradeViewClick{
    NSLog(@"_firmwareUpgradeViewClick");
    if ([_deviceIpValue.text compare:@""]==NSOrderedSame) {
        [self showAllTextDialog:NSLocalizedString(@"main_scan_failed", nil)];
        return;
    }
    UpdateFirmwareViewController *v = [[UpdateFirmwareViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

-(void)_newVersionViewClick{
    NSLog(@"_newVersionViewClick");
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

- (void)Save_Paths:(NSString *)value :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

- (NSString *)Get_Paths:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}
@end
