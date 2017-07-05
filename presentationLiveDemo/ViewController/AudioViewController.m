//
//  AudioViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "AudioViewController.h"
#import "CommanParameter.h"
#import "HttpRequest.h"
#import "MBProgressHUD.h"
#import "CommanParameters.h"

@interface AudioViewController ()
{
    int _audioStatus;
}
@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
    //顶部
    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
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
//    _titleLabel.text = NSLocalizedString(@"audio_title", nil);
    _titleLabel.text = @"Audio";
    _titleLabel.font = [UIFont boldSystemFontOfSize: viewH*22.5/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    _audioView=[[UIView alloc]init];
    _audioView.frame=CGRectMake(0, _topBg.frame.origin.y+_topBg.frame.size.height, viewW, viewH*163/totalHeight);
    _audioView.userInteractionEnabled=YES;
//    _audioView.backgroundColor=[UIColor whiteColor];
    [self.view  addSubview:_audioView];
    
    _audioHDMIImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_hdmi aduio_nor"]];
    _audioHDMIImg.frame = CGRectMake(viewW*38.5/totalWeight, viewH*39.5/totalHeight, viewH*110/totalHeight, viewH*110/totalHeight);
    _audioHDMIImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_audioHDMIBtnClick)];
    [_audioHDMIImg addGestureRecognizer:singleTap];
    _audioHDMIImg.center=CGPointMake(_audioView.frame.size.width*0.25, _audioHDMIImg.center.y);
    _audioHDMIImg.contentMode=UIViewContentModeScaleToFill;
    [_audioView addSubview:_audioHDMIImg];
    
    _audioExternalImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_external aduio_nor"]];
    _audioExternalImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_audioExternalBtnClick)];
    [_audioExternalImg addGestureRecognizer:singleTap2];
    _audioExternalImg.frame = CGRectMake(viewW*38.5/totalWeight, viewH*39.5/totalHeight, viewH*110/totalHeight, viewH*110/totalHeight);
    _audioExternalImg.center=CGPointMake(_audioView.frame.size.width*0.75, _audioHDMIImg.center.y);
    _audioExternalImg.contentMode=UIViewContentModeScaleToFill;
    [_audioView addSubview:_audioExternalImg];
    
    _NOaudioImg =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_external aduio_pre"]];
    _NOaudioImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_NOaudioBtnClick)];
    [_NOaudioImg addGestureRecognizer:singleTap3];
    _NOaudioImg.frame = CGRectMake(viewW*38.5/totalWeight, viewH*39.5/totalHeight, viewH*110/totalHeight, viewH*110/totalHeight);
    _NOaudioImg.center=CGPointMake(_audioView.frame.size.width*0.75, _audioHDMIImg.center.y);
    _NOaudioImg.contentMode=UIViewContentModeScaleToFill;
    [_audioView addSubview:_NOaudioImg];

    
    
//    _audioHDMIBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _audioHDMIBtn.frame = CGRectMake(0, viewH*119/totalHeight, viewW*100/totalWeight, viewH*24/totalHeight);
//    _audioHDMIBtn.center=CGPointMake(_audioView.frame.size.width*0.25, _audioHDMIBtn.center.y);
//    [_audioHDMIBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_audioHDMIBtn setTitle:NSLocalizedString(@"audio_hdmi", nil) forState:UIControlStateNormal];
//    [[_audioHDMIBtn layer] setBorderWidth:0.0];//画线的宽度
//    _audioHDMIBtn.titleLabel.font=[UIFont systemFontOfSize:viewH*15/totalHeight*0.8];
//    [[_audioHDMIBtn layer]setCornerRadius:viewW*10/totalWeight];//圆角
//    [_audioHDMIBtn setBackgroundColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0]];
//    _audioHDMIBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
//    [_audioHDMIBtn addTarget:nil action:@selector(_audioHDMIBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [_audioView addSubview:_audioHDMIBtn];
//    
//    _audioExternalBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _audioExternalBtn.frame = CGRectMake(0, viewH*119/totalHeight, viewW*100/totalWeight, viewH*24/totalHeight);
//    _audioExternalBtn.titleLabel.font=[UIFont systemFontOfSize:viewH*15/totalHeight*0.8];
//    _audioExternalBtn.center=CGPointMake(_audioView.frame.size.width*0.75, _audioExternalBtn.center.y);
//    [_audioExternalBtn setTitle:NSLocalizedString(@"audio_external", nil) forState:UIControlStateNormal];
//    [_audioExternalBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
//    [[_audioExternalBtn layer] setBorderWidth:0.0];//画线的宽度
//    [[_audioExternalBtn layer]setCornerRadius:viewW*10/totalWeight];//圆角
//    [_audioExternalBtn setBackgroundColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0]];
//    _audioExternalBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
//    [_audioExternalBtn addTarget:nil action:@selector(_audioExternalBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [_audioView addSubview:_audioExternalBtn];
    
    UIView *line=[[UIView alloc]init];
    line.frame=CGRectMake(0, viewH*179/totalHeight, viewW, viewH*1.5/totalHeight);
    line.backgroundColor=[UIColor colorWithRed:199/255.0 green:200/255.0 blue:202/255.0 alpha:1.0];
    [_audioView addSubview:line];
    
//    UIView *line2=[[UIView alloc]init];
//    line2.frame=CGRectMake(0, viewH*371.5/totalHeight, viewW, viewH*1.5/totalHeight);
//    line2.backgroundColor=[UIColor colorWithRed:199/255.0 green:200/255.0 blue:202/255.0 alpha:1.0];
//    [_audioView addSubview:line2];
    
    UIView *line3=[[UIView alloc]init];
    line3.frame=CGRectMake(viewW*186.5/totalWeight, 0, viewW*1.5/totalWeight, viewH*179/totalHeight);
    line3.backgroundColor=[UIColor colorWithRed:199/255.0 green:200/255.0 blue:202/255.0 alpha:1.0];
    [_audioView addSubview:line3];
    
//    _audioTips1Label= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*250/totalHeight, viewW, viewH*15/totalHeight)];
//    _audioTips1Label.text = NSLocalizedString(@"audio_tips1", nil);
//    _audioTips1Label.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
//    _audioTips1Label.backgroundColor = [UIColor clearColor];
//    _audioTips1Label.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _audioTips1Label.lineBreakMode = UILineBreakModeWordWrap;
//    _audioTips1Label.textAlignment=UITextAlignmentCenter;
//    _audioTips1Label.numberOfLines = 0;
//    [self.view addSubview:_audioTips1Label];
//    
//    _audioTips2Label= [[UILabel alloc] initWithFrame:CGRectMake(0, _audioTips1Label.frame.origin.y+_audioTips1Label.frame.size.height, viewW, viewH*15/totalHeight)];
//    _audioTips2Label.text = NSLocalizedString(@"audio_tips2", nil);
//    _audioTips2Label.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
//    _audioTips2Label.backgroundColor = [UIColor clearColor];
//    _audioTips2Label.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _audioTips2Label.lineBreakMode = UILineBreakModeWordWrap;
//    _audioTips2Label.textAlignment=UITextAlignmentCenter;
//    _audioTips2Label.numberOfLines = 0;
//    [self.view addSubview:_audioTips2Label];
//    
//    _audioTips3Label= [[UILabel alloc] initWithFrame:CGRectMake(0, _audioTips2Label.frame.origin.y+_audioTips2Label.frame.size.height, viewW, viewH*15/totalHeight)];
//    _audioTips3Label.text = NSLocalizedString(@"audio_tips3", nil);
//    _audioTips3Label.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
//    _audioTips3Label.backgroundColor = [UIColor clearColor];
//    _audioTips3Label.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _audioTips3Label.lineBreakMode = UILineBreakModeWordWrap;
//    _audioTips3Label.textAlignment=UITextAlignmentCenter;
//    _audioTips3Label.numberOfLines = 0;
//    [self.view addSubview:_audioTips3Label];
    [NSThread detachNewThreadSelector:@selector(GetAudioFormart) toTarget:self withObject:nil];

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

- (void)_audioHDMIBtnClick{
    NSLog(@"_audioHDMIBtnClick");
    _audioStatus=1;
    _audioExternalBtn.backgroundColor=[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _audioHDMIBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioExternalImg.image =[UIImage imageNamed:@"button_external aduio_nor"];
    _audioHDMIImg.image =[UIImage imageNamed:@"button_hdmi aduio_pre"];
    [_audioHDMIBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [_audioExternalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NSThread detachNewThreadSelector:@selector(SetAudioFormart) toTarget:self withObject:nil];
}

- (void)_audioExternalBtnClick{
    NSLog(@"_audioExternalBtnClick");
    _audioStatus=2;
    _audioHDMIBtn.backgroundColor=[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _audioExternalBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioExternalImg.image =[UIImage imageNamed:@"button_external aduio_pre"];
    _audioHDMIImg.image =[UIImage imageNamed:@"button_hdmi aduio_nor"];
    [_audioExternalBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [_audioHDMIBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NSThread detachNewThreadSelector:@selector(SetAudioFormart) toTarget:self withObject:nil];
}

- (void)_NOaudioBtnClick{
    NSLog(@"_NOaudioBtnClick");
    _audioStatus=0;
//    _audioHDMIBtn.backgroundColor=[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _audioExternalBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioExternalImg.image =[UIImage imageNamed:@"button_external aduio_pre"];
    _audioHDMIImg.image =[UIImage imageNamed:@"button_hdmi aduio_nor"];
    [_audioExternalBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [_audioHDMIBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NSThread detachNewThreadSelector:@selector(SetAudioFormart) toTarget:self withObject:nil];
}


#pragma mark-- 设置音频输入    0:禁止  1:HDMI  2:外部音源输入
-(void)SetAudioFormart
{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_audio_source&pipe=0&value=%d",_ip,80,_audioStatus];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *value=[self parseJsonString2:http_request.ResponseString :@"\"info\":\""];
            if ([value compare:@"suc"]==NSOrderedSame) {
                
            }
            else{
                [self showAllTextDialog:NSLocalizedString(@"settings_failed", nil)];
            }
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAllTextDialog:NSLocalizedString(@"settings_failed", nil)];
        });
    }
}

#pragma mark-- 获取音频输入
-(void)GetAudioFormart
{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_audio_source",_ip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([http_request.ResponseString compare:@""]==NSOrderedSame) {
                return;
            }
            NSString *_value=[self parseJsonString:http_request.ResponseString];
            if (([_value compare:@"0"] == NSOrderedSame)) {
                _audioStatus=0;
                _audioHDMIBtn.backgroundColor=[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
                _audioExternalBtn.backgroundColor=[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
                _audioExternalImg.image =[UIImage imageNamed:@"external_nor@3x.png"];
                _audioHDMIImg.image =[UIImage imageNamed:@"HDMI_nor@3x.png"];
                [_audioHDMIBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_audioExternalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else if (([_value compare:@"1"] == NSOrderedSame)) {
                _audioStatus=1;
                _audioExternalBtn.backgroundColor=[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
                _audioHDMIBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
                _audioExternalImg.image =[UIImage imageNamed:@"external_nor@3x.png"];
                _audioHDMIImg.image =[UIImage imageNamed:@"HDMI_sel@3x.png"];
                [_audioHDMIBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
                [_audioExternalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else if (([_value compare:@"2"] == NSOrderedSame)) {
                _audioStatus=2;
                _audioHDMIBtn.backgroundColor=[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
                _audioExternalBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
                _audioExternalImg.image =[UIImage imageNamed:@"external_sel@3x.png"];
                _audioHDMIImg.image =[UIImage imageNamed:@"HDMI_nor@3x.png"];
                [_audioExternalBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
                [_audioHDMIBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
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
