//
//  StreamViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/14.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "StreamViewController.h"
//#import "StreamingViewController.h"
#import "CommanParameter.h"

@interface StreamViewController ()

@end

@implementation StreamViewController

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
    _titleLabel.text = NSLocalizedString(@"live_stream_title", nil);
    _titleLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    //设置分段控件点击相应事件
    NSArray *segmentedData = [[NSArray alloc]initWithObjects:NSLocalizedString(@"parameter", nil),NSLocalizedString(@"network", nil),NSLocalizedString(@"address", nil),nil];
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedData];
    segmentedControl.frame = CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*8/totalHeight,viewW*343/totalWeight,viewH*29/totalHeight);
    segmentedControl.tintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:82/255.0 alpha:1.0];
    segmentedControl.selectedSegmentIndex = 0;//默认选中的按钮索引
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor],UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,[UIColor blackColor],UITextAttributeTextShadowColor ,nil];
    [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    
    NSDictionary *highlightedAttributes2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,  [UIFont fontWithName:normal size:viewH*16*0.8/totalHeight],UITextAttributeFont ,[UIColor blackColor],UITextAttributeTextShadowColor ,nil];
    
    [segmentedControl setTitleTextAttributes:highlightedAttributes2 forState:UIControlStateNormal];
    [segmentedControl addTarget:self action:@selector(doSomethingInSegment:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0,segmentedControl.frame.origin.y+segmentedControl.frame.size.height+viewH*8/totalHeight,viewW,viewH*1/totalHeight)];
    line.backgroundColor=[UIColor blackColor];
    [self.view addSubview:line];
    
    //parameter
    _parameterView=[[UIView alloc]initWithFrame:CGRectMake(0,line.frame.origin.y+line.frame.size.height,viewW,viewH*327/totalHeight)];
    _parameterView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_parameterView];
    
    UIView *_parameterLine1=[[UIView alloc]initWithFrame:CGRectMake(0,0,viewW*323/totalWeight,viewH*1/totalHeight)];
    _parameterLine1.center= CGPointMake(_parameterView.center.x, _parameterView.center.y-line.frame.origin.y-line.frame.size.height);
    _parameterLine1.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    [_parameterView addSubview:_parameterLine1];
    
    UIView *_parameterLine2=[[UIView alloc]initWithFrame:CGRectMake(0,0,viewH*1/totalHeight,viewH*267/totalHeight)];
    _parameterLine2.center=CGPointMake(_parameterView.center.x, _parameterView.center.y-line.frame.origin.y-line.frame.size.height);
    _parameterLine2.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    [_parameterView addSubview:_parameterLine2];
    
    
    _streamView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(viewW*26/totalWeight,viewH*42/totalHeight,viewW*135/totalWeight,viewH*101/totalHeight)];
    _streamView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_streamViewClick)];
    [_streamView addGestureRecognizer:singleTap1];
    [_parameterView addSubview:_streamView];
    
    _streamBtn=[[UIImageView alloc]init];
    _streamBtn.frame = CGRectMake(viewW*39/totalWeight, viewH*11/totalHeight, viewH*55/totalHeight*180/168, viewH*55/totalHeight);
    _streamBtn.image=[UIImage imageNamed:@"live_parameter_streming_icon@3x.png"];
    [_streamView  addSubview:_streamBtn];
    
    _streamLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _streamBtn.frame.origin.y+_streamBtn.frame.size.height+viewH*12/totalHeight, _streamView.frame.size.width, viewH*16/totalHeight)];
    _streamLabel.text = NSLocalizedString(@"parameter_stream", nil);
    _streamLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _streamLabel.backgroundColor = [UIColor clearColor];
    _streamLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _streamLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamLabel.textAlignment=UITextAlignmentCenter;
    _streamLabel.numberOfLines = 0;
    [_streamView addSubview:_streamLabel];
    
    
    _subscriptView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(viewW*214/totalWeight,viewH*42/totalHeight,viewW*135/totalWeight,viewH*101/totalHeight)];
    _subscriptView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_subscriptViewClick)];
    [_subscriptView addGestureRecognizer:singleTap2];
    [_parameterView addSubview:_subscriptView];
    
    _subscriptBtn=[[UIImageView alloc]init];
    _subscriptBtn.frame = CGRectMake(viewW*39/totalWeight, viewH*11/totalHeight, viewH*55/totalHeight*180/168, viewH*55/totalHeight);
    [_subscriptBtn setImage:[UIImage imageNamed:@"live_parameter_subscript_icon@3x.png"]];
    [_subscriptView  addSubview:_subscriptBtn];
    
    _subscriptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _subscriptBtn.frame.origin.y+_subscriptBtn.frame.size.height+viewH*12/totalHeight, _subscriptView.frame.size.width, viewH*16/totalHeight)];
    _subscriptLabel.text = NSLocalizedString(@"parameter_subscript", nil);
    _subscriptLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _subscriptLabel.backgroundColor = [UIColor clearColor];
    _subscriptLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _subscriptLabel.lineBreakMode = UILineBreakModeWordWrap;
    _subscriptLabel.textAlignment=UITextAlignmentCenter;
    _subscriptLabel.numberOfLines = 0;
    [_subscriptView addSubview:_subscriptLabel];

    
    _subtitleView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(viewW*26/totalWeight,viewH*185/totalHeight,viewW*135/totalWeight,viewH*101/totalHeight)];
    _subtitleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_subtitleViewClick)];
    [_subtitleView addGestureRecognizer:singleTap3];
    [_parameterView addSubview:_subtitleView];
    
    _subtitleBtn=[[UIImageView alloc]init];
    _subtitleBtn.frame = CGRectMake(viewW*39/totalWeight, viewH*11/totalHeight, viewH*55/totalHeight*180/168, viewH*55/totalHeight);
    [_subtitleBtn setImage:[UIImage imageNamed:@"live_parameter_subtitle_icon@3x.png"]];
    [_subtitleView  addSubview:_subtitleBtn];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _subtitleBtn.frame.origin.y+_subtitleBtn.frame.size.height+viewH*12/totalHeight, _subtitleView.frame.size.width, viewH*16/totalHeight)];
    _subtitleLabel.text = NSLocalizedString(@"parameter_subtitle", nil);
    _subtitleLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _subtitleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _subtitleLabel.textAlignment=UITextAlignmentCenter;
    _subtitleLabel.numberOfLines = 0;
    [_subtitleView addSubview:_subtitleLabel];
    
    
    _audioInputView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(viewW*214/totalWeight,viewH*185/totalHeight,viewW*135/totalWeight,viewH*101/totalHeight)];
    _audioInputView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_audioInputViewClick)];
    [_audioInputView addGestureRecognizer:singleTap4];
    [_parameterView addSubview:_audioInputView];
    
    _audioInputBtn=[[UIImageView alloc]init];
    _audioInputBtn.frame = CGRectMake(viewW*39/totalWeight, viewH*11/totalHeight, viewH*55/totalHeight*180/168, viewH*55/totalHeight);
    [_audioInputBtn setImage:[UIImage imageNamed:@"live_parameter_audio input_icon@3x.png"]];
    [_audioInputView  addSubview:_audioInputBtn];
    
    _audioInputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _audioInputBtn.frame.origin.y+_audioInputBtn.frame.size.height+viewH*12/totalHeight, _audioInputView.frame.size.width, viewH*16/totalHeight)];
    _audioInputLabel.text = NSLocalizedString(@"parameter_audio", nil);
    _audioInputLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _audioInputLabel.backgroundColor = [UIColor clearColor];
    _audioInputLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _audioInputLabel.lineBreakMode = UILineBreakModeWordWrap;
    _audioInputLabel.textAlignment=UITextAlignmentCenter;
    _audioInputLabel.numberOfLines = 0;
    [_audioInputView addSubview:_audioInputLabel];
    
    //network
    _networkView=[[UIView alloc]initWithFrame:CGRectMake(0,line.frame.origin.y+line.frame.size.height,viewW,viewH*152/totalHeight)];
    [self.view addSubview:_networkView];
    
    _networkStatusView=[[UIView alloc]initWithFrame:CGRectMake(0,0,viewW,viewH*44/totalHeight)];
    _networkStatusView.backgroundColor=[UIColor whiteColor];
    [_networkView addSubview:_networkStatusView];
    
    _networkStatusText= [[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,0, viewW*160/totalWeight, viewH*44/totalHeight)];
    _networkStatusText.text = NSLocalizedString(@"network_state_label", nil);
    _networkStatusText.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _networkStatusText.backgroundColor = [UIColor clearColor];
    _networkStatusText.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _networkStatusText.lineBreakMode = UILineBreakModeWordWrap;
    _networkStatusText.textAlignment=UITextAlignmentLeft;
    _networkStatusText.numberOfLines = 0;
    [_networkStatusView addSubview:_networkStatusText];
    
    _networkStatusValue= [[UILabel alloc] initWithFrame:CGRectMake(viewW-viewW*176/totalWeight,0, viewW*160/totalWeight, viewH*44/totalHeight)];
    _networkStatusValue.text = NSLocalizedString(@"network_not_connected", nil);
    _networkStatusValue.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _networkStatusValue.backgroundColor = [UIColor clearColor];
    _networkStatusValue.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _networkStatusValue.lineBreakMode = UILineBreakModeWordWrap;
    _networkStatusValue.textAlignment=UITextAlignmentRight;
    _networkStatusValue.numberOfLines = 0;
    [_networkStatusView addSubview:_networkStatusValue];
    
    _networkWayView=[[UIView alloc]initWithFrame:CGRectMake(0,_networkStatusView.frame.origin.y+_networkStatusView.frame.size.height+viewH*20/totalHeight,viewW,viewH*89/totalHeight)];
    _networkWayView.backgroundColor=[UIColor whiteColor];
    [_networkView addSubview:_networkWayView];
    
    _networkDHCPText=[[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,0, viewW*160/totalWeight, viewH*44/totalHeight)];
    _networkDHCPText.text = NSLocalizedString(@"network_dhcp", nil);
    _networkDHCPText.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _networkDHCPText.backgroundColor = [UIColor clearColor];
    _networkDHCPText.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _networkDHCPText.lineBreakMode = UILineBreakModeWordWrap;
    _networkDHCPText.textAlignment=UITextAlignmentLeft;
    _networkDHCPText.numberOfLines = 0;
    [_networkWayView addSubview:_networkDHCPText];
    
    _networkDHCPSwitch= [[UISwitch alloc] initWithFrame:CGRectMake(0,0,viewW*51/totalWeight, viewH*31/totalHeight)];
    _networkDHCPSwitch.center=CGPointMake(viewW*334/totalWeight, _networkDHCPText.center.y);
    _networkDHCPSwitch.on = NO;
    _networkDHCPSwitch.onTintColor =[UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    [_networkDHCPSwitch addTarget:self action:@selector(_networkDHCPSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [_networkWayView addSubview:_networkDHCPSwitch];
    
    UIView *_networkLine=[[UIView alloc]initWithFrame:CGRectMake(viewW*16/totalWeight,_networkDHCPText.frame.origin.y+_networkDHCPText.frame.size.height,viewW-viewW*16/totalWeight,viewH*1/totalHeight)];
    _networkLine.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    [_networkWayView addSubview:_networkLine];
    
    _networkManualText=[[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_networkLine.frame.origin.y+_networkLine.frame.size.height, viewW*160/totalWeight, viewH*44/totalHeight)];
    _networkManualText.text = NSLocalizedString(@"network_manual", nil);
    _networkManualText.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _networkManualText.backgroundColor = [UIColor clearColor];
    _networkManualText.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _networkManualText.lineBreakMode = UILineBreakModeWordWrap;
    _networkManualText.textAlignment=UITextAlignmentLeft;
    _networkManualText.numberOfLines = 0;
    [_networkWayView addSubview:_networkManualText];
    
    _networkManualSwitch= [[UISwitch alloc] initWithFrame:CGRectMake(0,0,viewW*51/totalWeight, viewH*31/totalHeight)];
    _networkManualSwitch.center=CGPointMake(viewW*334/totalWeight, _networkManualText.center.y);
    _networkManualSwitch.on = NO;
    _networkManualSwitch.onTintColor =[UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    [_networkManualSwitch addTarget:self action:@selector(_networkManualSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [_networkWayView addSubview:_networkManualSwitch];
    _networkView.hidden=YES;
    
    //Address
    _addressView=[[UIView alloc]initWithFrame:CGRectMake(0,line.frame.origin.y+line.frame.size.height,viewW,viewH*558/totalHeight)];
    [self.view addSubview:_addressView];
    
    _addressLiveLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*12/totalWeight,viewH*110/totalHeight, viewW*110/totalWeight, viewH*40/totalHeight)];
    _addressLiveLabel.backgroundColor=[UIColor whiteColor];
    _addressLiveLabel.text = NSLocalizedString(@"address_live_label", nil);
    _addressLiveLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _addressLiveLabel.backgroundColor = [UIColor clearColor];
    _addressLiveLabel.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _addressLiveLabel.lineBreakMode = UILineBreakModeWordWrap;
    _addressLiveLabel.textAlignment=UITextAlignmentLeft;
    _addressLiveLabel.numberOfLines = 0;
    [_addressView addSubview:_addressLiveLabel];
    
    _addressLiveText=[[UITextField alloc]init];
    _addressLiveText.frame=CGRectMake(viewW*123/totalWeight,viewH*110/totalHeight, viewW*240/totalWeight, viewH*40/totalHeight);
    [_addressLiveText addTarget:self  action:@selector(_addressLiveTextChanged)  forControlEvents:UIControlEventAllEditingEvents];
    _addressLiveText.backgroundColor = [UIColor whiteColor];
    _addressLiveText.placeholder=NSLocalizedString(@"address_live_url", nil);
    [_addressView addSubview:_addressLiveText];
    
    _addressLiveImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"adress_prompt_image@3x.png"]];
    _addressLiveImg.frame=CGRectMake(viewW*138/totalWeight,_addressLiveText.frame.size.height+_addressLiveText.frame.origin.y+viewH*60/totalHeight, viewW*117/totalWeight, viewH*124/totalHeight);
    [_addressView addSubview:_addressLiveImg];
    
    _addressLiveTips=[[UILabel alloc] initWithFrame:CGRectMake(0,_addressLiveImg.frame.size.height+_addressLiveImg.frame.origin.y+viewH*25/totalHeight, viewW, viewH*20/totalHeight)];
    _addressLiveTips.text = NSLocalizedString(@"address_live_tips", nil);
    _addressLiveTips.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _addressLiveTips.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _addressLiveTips.lineBreakMode = UILineBreakModeWordWrap;
    _addressLiveTips.textAlignment=UITextAlignmentCenter;
    _addressLiveTips.numberOfLines = 0;
    [_addressView addSubview:_addressLiveTips];
    
    _addressLiveBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _addressLiveBtn.frame = CGRectMake(viewW*136/totalWeight, _addressLiveTips.frame.size.height+_addressLiveTips.frame.origin.y+viewH*6/totalHeight, viewW*100/totalWeight, viewH*18/totalHeight);
    [_addressLiveBtn setTitleColor:[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0] forState:UIControlStateNormal];
    _addressLiveBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    [_addressLiveBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _addressLiveBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"address_live_btn", nil)];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_addressLiveBtn setAttributedTitle:str forState:UIControlStateNormal];
    [_addressLiveBtn addTarget:nil action:@selector(_addressLiveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_addressView  addSubview:_addressLiveBtn];
    
    _addressShareBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_addressShareBtn.layer setMasksToBounds:YES];
    [_addressShareBtn.layer setCornerRadius:2.0];
    _addressShareBtn.frame= CGRectMake(viewW*30/totalWeight, _addressLiveText.frame.size.height+_addressLiveText.frame.origin.y+viewH*102/totalHeight, viewW*316/totalWeight, viewH*44/totalHeight);
    [_addressShareBtn setTitle: NSLocalizedString(@"address_share_btn", nil) forState: UIControlStateNormal];
    [_addressShareBtn setTitleColor:[UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0] forState:UIControlStateNormal];
    _addressShareBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _addressShareBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_addressShareBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateHighlighted];
    _addressShareBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_addressShareBtn addTarget:nil action:@selector(_addressShareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_addressView  addSubview:_addressShareBtn];
    
    if([_addressLiveText.text compare:@""]==NSOrderedSame){
        _addressShareBtn.hidden=YES;
        _addressLiveImg.hidden=NO;
        _addressLiveTips.hidden=NO;
        _addressLiveBtn.hidden=NO;
    }
    else{
        _addressShareBtn.hidden=NO;
        _addressLiveImg.hidden=YES;
        _addressLiveTips.hidden=YES;
        _addressLiveBtn.hidden=YES;
    }
    _addressView.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doSomethingInSegment:(UISegmentedControl *)Seg
{
    
    NSInteger Index = Seg.selectedSegmentIndex;
    
    switch (Index)
    {
        case 0:
            _parameterView.hidden=NO;
            _networkView.hidden=YES;
            _addressView.hidden=YES;
            break;
        case 1:
            _parameterView.hidden=YES;
            _networkView.hidden=NO;
            _addressView.hidden=YES;
            break;
        case 2:
            _parameterView.hidden=YES;
            _networkView.hidden=YES;
            _addressView.hidden=NO;
            break;
        default:
            break;
    }
}

//点击事件
-(void)_streamViewClick
{
    NSLog(@"_streamViewClick");
//    StreamingViewController *v = [[StreamingViewController alloc] init];
//    [self.navigationController pushViewController: v animated:true];
}

-(void)_subscriptViewClick
{
    NSLog(@"_subscriptViewClick");
}

-(void)_subtitleViewClick
{
    NSLog(@"_subtitleViewClick");
}

-(void)_audioInputViewClick
{
    NSLog(@"_audioInputViewClick");
}

- (void)_networkDHCPSwitchAction:sender
{
    if(_networkDHCPSwitch.on){
        NSLog(@"_networkDHCPSwitchAction==>yes");
    }
    else{
        NSLog(@"_networkDHCPSwitchAction==>no");
    }
}

- (void)_networkManualSwitchAction:sender
{
    if(_networkManualSwitch.on){
        NSLog(@"_networkManualSwitchAction==>yes");
    }
    else{
        NSLog(@"_networkManualSwitchAction==>no");
    }
}

- (void)_addressLiveTextChanged{
    if([_addressLiveText.text compare:@""]==NSOrderedSame){
        _addressShareBtn.hidden=YES;
        _addressLiveImg.hidden=NO;
        _addressLiveTips.hidden=NO;
        _addressLiveBtn.hidden=NO;
    }
    else{
        _addressShareBtn.hidden=NO;
        _addressLiveImg.hidden=YES;
        _addressLiveTips.hidden=YES;
        _addressLiveBtn.hidden=YES;
    }
}

-(void)_addressLiveBtnClick
{
    NSLog(@"_addressLiveBtnClick");
}

-(void)_addressShareBtnClick
{
    NSLog(@"_addressShareBtnClick");
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
    [_addressLiveText resignFirstResponder];
}

@end
