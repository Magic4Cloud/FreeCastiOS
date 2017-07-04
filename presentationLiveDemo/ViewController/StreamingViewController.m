//
//  StreamingViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/17.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "StreamingViewController.h"
#import "CommanParameter.h"
#import "ModuleLivingViewController.h"
#import "Rak_Lx52x_Device_Control.h"
#import "LX520View.h"
#import "MBProgressHUD.h"
#include "LFLiveStreamInfo.h"
#import "LFLiveKit.h"
#import "LFLiveSessionWithPicSource.h"
#import "PicToBufferToPic.h"
#import "SubtitleViewController.h"
#import "BannerViewController.h"
#import "PauseScreenViewController.h"
#import "AudioViewController.h"
#import "NetworkViewController.h"
#import <QuartzCore/QuartzCore.h>

Rak_Lx52x_Device_Control *_LiveScan;
@interface StreamingViewController ()
{
    BOOL _Exit;
    NSString* _userid;
    NSString* _userip;
    NSString* _username;
    NSString* _userpassword;
    NSString* video_type;
    LX520View *_videoView;
    bool _isPlaying;
    int _isLiving;//0:停止 1:直播中 2:暂停
    NSString* url;
    CGFloat l_control_pos;
    CGFloat c_control_pos;
    CGFloat r_control_pos;
    CGFloat viewH;
    CGFloat viewW;
    CGFloat totalHeight;
    CGFloat totalWeight;
    NSMutableArray *_recordUrl;
}
@property(strong, nonatomic) LFLiveSessionWithPicSource *session;
@end

@implementation StreamingViewController

- (void)viewDidLoad {
    [self _switchPortrait];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _recordUrl=[[NSMutableArray alloc]init];
    _recordUrl=[self Get_Urls:@"STREAMURL"];
    _isPlaying=NO;
    _isLiving=0;
    url=@"rtmp://rak.uplive.ks-cdn.com/live/LIVEQU15612334A4A?vdoid=1474526229";
    _Exit=NO;
    video_type=@"h264";
    _username=@"admin";
    _userpassword=@"admin";
    self.session=[LFLiveSessionWithPicSource sharedInstance];
    
    viewH=self.view.frame.size.height;
    viewW=self.view.frame.size.width;
    if (viewH>viewW) {
        
    }
    else{
        viewW=self.view.frame.size.height;
        viewH=self.view.frame.size.width;
    }
    totalHeight=64+71+149+149+149+80+5;//各部分比例
    totalWeight=375;//各部分比例
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _LiveScan = [[Rak_Lx52x_Device_Control alloc] init];
    _videoView = [[LX520View alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    _videoView.center=self.view.center;
    _videoView.backgroundColor = [UIColor blackColor];
    [_videoView startGetYUVData:YES];
    [_videoView set_log_level:4];
    [_videoView delegate:self];

    
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
    _titleLabel.center=CGPointMake(viewW*0.5, _backBtn.center.y);
    _titleLabel.text = NSLocalizedString(@"streaminig_title", nil);
    _titleLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    
    _streamingImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live stream_banner@3x.png"]];
    _streamingImg.userInteractionEnabled=YES;
    _streamingImg.frame = CGRectMake(0, _topBg.frame.origin.y+_topBg.frame.size.height, viewW, viewH*145/totalHeight);
    _streamingImg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_streamingImg];
    
    _streamStatusImg=[[UIImageView alloc]init];
    _streamStatusImg.frame = CGRectMake(viewW-viewH*32/totalHeight, viewH*13/totalHeight, viewH*19/totalHeight, viewH*19/totalHeight);
    _streamStatusImg.image=[UIImage imageNamed:@"live view_pilot lamp_off@3x.png"];
    [_streamingImg  addSubview:_streamStatusImg];
    
    _streamingTitleImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live streaming_banner_text image@3x.png"]];
    _streamingTitleImg.userInteractionEnabled=YES;
    _streamingTitleImg.frame = CGRectMake(viewW*55/totalWeight, viewH*29/totalHeight, viewW*264/totalWeight, viewW*264*48/totalWeight/804);
    _streamingTitleImg.contentMode=UIViewContentModeScaleToFill;
    [_streamingImg addSubview:_streamingTitleImg];
    
    //Control
    _streamingControlBgImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream_Slide bar_bg@3x.png"]];
    _streamingControlBgImg.userInteractionEnabled=YES;
    _streamingControlBgImg.frame = CGRectMake(0, viewH*78/totalHeight, viewH*40*87/totalHeight/12, viewH*40/totalHeight);
    _streamingControlBgImg.center=CGPointMake(viewW*0.5, _streamingControlBgImg.center.y);
    _streamingControlBgImg.contentMode=UIViewContentModeScaleToFill;
    [_streamingImg addSubview:_streamingControlBgImg];

    _streamingControlImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream_Slide bar_stop button@3x.png"]];
    _streamingControlImg.userInteractionEnabled=YES;
    UIPanGestureRecognizer *panGestureRecognizer= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_streamingControlImg addGestureRecognizer:panGestureRecognizer];
    _streamingControlImg.frame = CGRectMake(0, 0, viewH*32/totalHeight, viewH*32/totalHeight);
    _streamingControlImg.center=CGPointMake(_streamingControlBgImg.frame.size.width-viewH*20/totalHeight, viewH*20/totalHeight);
    r_control_pos=_streamingControlImg.center.x;
    _streamingControlImg.center=CGPointMake(_streamingControlBgImg.frame.size.width*0.5, viewH*20/totalHeight);
    c_control_pos=_streamingControlImg.center.x;
    _streamingControlImg.center=CGPointMake(viewH*20/totalHeight, viewH*20/totalHeight);
    l_control_pos=_streamingControlImg.center.x;
    _streamingControlImg.contentMode=UIViewContentModeScaleToFill;
    [_streamingControlBgImg addSubview:_streamingControlImg];
    
    //Config view2
    _streamingConfigView=[[UIView alloc]initWithFrame:CGRectMake(0,_streamingImg.frame.origin.y+_streamingImg.frame.size.height+16,viewW*5/4,viewH*77/totalHeight)];
    _streamingConfigView.userInteractionEnabled=YES;
    UIPanGestureRecognizer *panGestureRecognizer2= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView2:)];
    [_streamingConfigView addGestureRecognizer:panGestureRecognizer2];
    _streamingConfigView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_streamingConfigView];
    
    _linkmanBtn0=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn0.frame = CGRectMake(0, viewH*12/totalHeight, viewH*40*132/123/totalHeight, viewH*40/totalHeight);
    _linkmanBtn0.center=CGPointMake(viewW*0.125, _linkmanBtn0.center.y);
    [_linkmanBtn0 setImage:[UIImage imageNamed:@"live stream_subtitle_icon@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn0 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn0 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn0.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn0 addTarget:nil action:@selector(_linkmanBtn0Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn0];
    
    _linkmanLabel0 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn0.frame.origin.y+_linkmanBtn0.frame.size.height+viewH*4/totalHeight, viewW*50/totalWeight, viewH*15/totalHeight)];
    _linkmanLabel0.center=CGPointMake(viewW*0.125, _linkmanLabel0.center.y);
    _linkmanLabel0.text = NSLocalizedString(@"parameter_subtitle", nil);
    _linkmanLabel0.font = [UIFont systemFontOfSize: viewH*14/totalHeight*0.8];
    _linkmanLabel0.backgroundColor = [UIColor clearColor];
    _linkmanLabel0.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel0.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel0.textAlignment=UITextAlignmentCenter;
    _linkmanLabel0.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel0];
    
    UIView *_linkmanline0=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn0.frame.origin.x+_linkmanBtn0.frame.size.width+viewW*24/totalWeight,viewH*18/totalHeight,viewW*1/totalWeight,viewH*40/totalHeight)];
    _linkmanline0.center=CGPointMake(viewW*1/4, _linkmanline0.center.y);
    _linkmanline0.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_streamingConfigView addSubview:_linkmanline0];
    
    _linkmanBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn1.frame = CGRectMake(0, viewH*12/totalHeight, viewH*40*132/123/totalHeight, viewH*40/totalHeight);
    _linkmanBtn1.center=CGPointMake(viewW*0.375, _linkmanBtn0.center.y);
    [_linkmanBtn1 setImage:[UIImage imageNamed:@"live stream_banner_icon@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn1 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn1 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn1.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn1 addTarget:nil action:@selector(_linkmanBtn1Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn1];
    
    _linkmanLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn1.frame.origin.y+_linkmanBtn1.frame.size.height+viewH*4/totalHeight, viewW*50/totalWeight, viewH*15/totalHeight)];
    _linkmanLabel1.center=CGPointMake(viewW*0.375, _linkmanLabel0.center.y);
    _linkmanLabel1.text = NSLocalizedString(@"parameter_banner", nil);
    _linkmanLabel1.font = [UIFont systemFontOfSize: viewH*14/totalHeight*0.8];
    _linkmanLabel1.backgroundColor = [UIColor clearColor];
    _linkmanLabel1.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel1.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel1.textAlignment=UITextAlignmentCenter;
    _linkmanLabel1.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel1];
    
    UIView *_linkmanline1=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn1.frame.origin.x+_linkmanBtn1.frame.size.width+viewW*24/totalWeight,viewH*18/totalHeight,viewW*1/totalWeight,viewH*40/totalHeight)];
    _linkmanline1.center=CGPointMake(viewW*2/4, _linkmanline1.center.y);
    _linkmanline1.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_streamingConfigView addSubview:_linkmanline1];
    
    _linkmanBtn2=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn2.frame = CGRectMake(0, viewH*12/totalHeight, viewH*40*132/123/totalHeight, viewH*40/totalHeight);
    _linkmanBtn2.center=CGPointMake(viewW*0.625, _linkmanBtn2.center.y);
    [_linkmanBtn2 setImage:[UIImage imageNamed:@"live stream_screen_icon@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn2 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn2 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn2.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn2 addTarget:nil action:@selector(_linkmanBtn2Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn2];
    
    _linkmanLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn2.frame.origin.y+_linkmanBtn2.frame.size.height+viewH*4/totalHeight, viewW*50/totalWeight, viewH*15/totalHeight)];
    _linkmanLabel2.center=CGPointMake(viewW*0.625, _linkmanLabel2.center.y);
    _linkmanLabel2.text = NSLocalizedString(@"parameter_screen", nil);
    _linkmanLabel2.font = [UIFont systemFontOfSize: viewH*14/totalHeight*0.8];
    _linkmanLabel2.backgroundColor = [UIColor clearColor];
    _linkmanLabel2.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel2.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel2.textAlignment=UITextAlignmentCenter;
    _linkmanLabel2.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel2];
    
    UIView *_linkmanline2=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn2.frame.origin.x+_linkmanBtn2.frame.size.width+viewW*24/totalWeight,viewH*18/totalHeight,viewW*1/totalWeight,viewH*40/totalHeight)];
    _linkmanline2.center=CGPointMake(viewW*3/4, _linkmanline2.center.y);
    _linkmanline2.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_streamingConfigView addSubview:_linkmanline2];
    
    _linkmanBtn3=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn3.frame = CGRectMake(0, viewH*12/totalHeight, viewH*40*132/123/totalHeight, viewH*40/totalHeight);
    _linkmanBtn3.center=CGPointMake(viewW*0.875, _linkmanBtn0.center.y);
    [_linkmanBtn3 setImage:[UIImage imageNamed:@"live stream_audio_icon@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn3 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn3 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn3.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn3 addTarget:nil action:@selector(_linkmanBtn3Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn3];
    
    _linkmanLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn3.frame.origin.y+_linkmanBtn3.frame.size.height+viewH*4/totalHeight, viewW*50/totalWeight, viewH*15/totalHeight)];
    _linkmanLabel3.center=CGPointMake(viewW*0.875, _linkmanLabel3.center.y);
    _linkmanLabel3.text = NSLocalizedString(@"parameter_audio", nil);
    _linkmanLabel3.font = [UIFont systemFontOfSize: viewH*14/totalHeight*0.8];
    _linkmanLabel3.backgroundColor = [UIColor clearColor];
    _linkmanLabel3.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel3.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel3.textAlignment=UITextAlignmentCenter;
    _linkmanLabel3.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel3];
    
    UIView *_linkmanline3=[[UIView alloc]initWithFrame:CGRectMake(_linkmanBtn3.frame.origin.x+_linkmanBtn3.frame.size.width+viewW*24/totalWeight,viewH*18/totalHeight,viewW*1/totalWeight,viewH*40/totalHeight)];
    _linkmanline3.center=CGPointMake(viewW-10*totalWeight/viewW, _linkmanline3.center.y);
    _linkmanline3.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_streamingConfigView addSubview:_linkmanline3];
    
    _linkmanBtn4=[UIButton buttonWithType:UIButtonTypeCustom];
    _linkmanBtn4.frame = CGRectMake(0, viewH*12/totalHeight, viewH*40*132/123/totalHeight, viewH*40/totalHeight);
    _linkmanBtn4.center=CGPointMake(viewW*1.125, _linkmanBtn0.center.y);
    [_linkmanBtn4 setImage:[UIImage imageNamed:@"live stream_network_icon@3x.png"] forState:UIControlStateNormal];
    [_linkmanBtn4 setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_linkmanBtn4 setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _linkmanBtn4.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_linkmanBtn4 addTarget:nil action:@selector(_linkmanBtn4Click) forControlEvents:UIControlEventTouchUpInside];
    [_streamingConfigView  addSubview:_linkmanBtn4];
    
    _linkmanLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(0, _linkmanBtn4.frame.origin.y+_linkmanBtn4.frame.size.height+viewH*4/totalHeight, viewW*50/totalWeight, viewH*15/totalHeight)];
    _linkmanLabel4.center=CGPointMake(viewW*1.125, _linkmanLabel4.center.y);
    _linkmanLabel4.text = NSLocalizedString(@"parameter_network", nil);
    _linkmanLabel4.font = [UIFont systemFontOfSize: viewH*14/totalHeight*0.8];
    _linkmanLabel4.backgroundColor = [UIColor clearColor];
    _linkmanLabel4.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _linkmanLabel4.lineBreakMode = UILineBreakModeWordWrap;
    _linkmanLabel4.textAlignment=UITextAlignmentCenter;
    _linkmanLabel4.numberOfLines = 0;
    [_streamingConfigView addSubview:_linkmanLabel4];

    //platform
    _streamingAddressLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, viewW, viewH*30/totalHeight)];
    _streamingAddressLabel.center=CGPointMake(viewW*0.5, _streamingConfigView.frame.origin.y+_streamingConfigView.frame.size.height+viewH*15/totalHeight);
    _streamingAddressLabel.text = NSLocalizedString(@"streaminig_address", nil);
    _streamingAddressLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _streamingAddressLabel.backgroundColor = [UIColor clearColor];
    _streamingAddressLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _streamingAddressLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingAddressLabel.textAlignment=UITextAlignmentCenter;
    _streamingAddressLabel.numberOfLines = 0;
    [self.view addSubview:_streamingAddressLabel];
    
    _streamingAddressView=[[UIView alloc]initWithFrame:CGRectMake(0,_streamingAddressLabel.frame.origin.y+_streamingAddressLabel.frame.size.height,viewW,viewH*135/totalHeight)];
    _streamingAddressView.backgroundColor=[UIColor whiteColor];
    _streamingAddressView.userInteractionEnabled = YES;
    [self.view addSubview:_streamingAddressView];
    
    _platformView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(viewW*15/totalWeight,_streamingAddressLabel.frame.origin.y+_streamingAddressLabel.frame.size.height+viewH*15/totalHeight,viewW*124/totalWeight,viewH*105/totalHeight)];
    _platformView.userInteractionEnabled = YES;
    _platformView.center=CGPointMake(viewW*1/4, _platformView.center.y);
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformViewClick)];
    [_platformView addGestureRecognizer:singleTap2];
    [self.view addSubview:_platformView];
    
    _streamingPlatformImg=[[UIImageView alloc]init];
    _streamingPlatformImg.frame = CGRectMake((_platformView.frame.size.width-viewH*64/totalHeight*180/168)*0.5, viewH*11/totalHeight, viewH*64/totalHeight*180/168, viewH*64/totalHeight);
    [_streamingPlatformImg setImage:[UIImage imageNamed:@"streaming_paltform_icon@3x.png"]];
    [_platformView  addSubview:_streamingPlatformImg];
    
    _streamingPlatform = [[UILabel alloc] initWithFrame:CGRectMake(0, _streamingPlatformImg.frame.origin.y+_streamingPlatformImg.frame.size.height+viewH*8/totalHeight, _platformView.frame.size.width, viewH*16/totalHeight)];
    _streamingPlatform.text = NSLocalizedString(@"platform_text", nil);
    _streamingPlatform.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _streamingPlatform.backgroundColor = [UIColor clearColor];
    _streamingPlatform.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _streamingPlatform.lineBreakMode = UILineBreakModeWordWrap;
    _streamingPlatform.textAlignment=UITextAlignmentCenter;
    _streamingPlatform.numberOfLines = 0;
    [_platformView addSubview:_streamingPlatform];
    
    UIView *line1=[[UIView alloc]initWithFrame:CGRectMake(viewW*187/totalWeight,_streamingAddressView.frame.origin.y+viewH*21/totalHeight,viewW*1/totalWeight,_streamingAddressView.frame.size.height-viewH*42/totalHeight)];
    line1.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [self.view addSubview:line1];
    
    //Address View
    _addressView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(viewW*219/totalWeight,_streamingAddressLabel.frame.origin.y+_streamingAddressLabel.frame.size.height+viewH*15/totalHeight,viewW*124/totalWeight,viewH*105/totalHeight)];
    _addressView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_addressViewClick)];
    [_addressView addGestureRecognizer:singleTap3];
    _addressView.center=CGPointMake(viewW*3/4, _addressView.center.y);
    [self.view addSubview:_addressView];
    
    _streamingAddressImg=[[UIImageView alloc]init];
    _streamingAddressImg.frame = CGRectMake(viewW*26/totalWeight, viewH*11/totalHeight, viewH*67/totalHeight*180/168, viewH*67/totalHeight);
    _streamingAddressImg.center=CGPointMake(_addressView.frame.size.width*0.5, _streamingAddressImg.center.y);
    [_streamingAddressImg setImage:[UIImage imageNamed:@"streaming_address_icon@3x.png"]];
    [_addressView  addSubview:_streamingAddressImg];
    
    _streamingAddress = [[MarqueeLabel alloc] initWithFrame: CGRectMake(0, _streamingAddressImg.frame.origin.y+_streamingAddressImg.frame.size.height+viewH*3/totalHeight, _addressView.frame.size.width, viewH*28/totalHeight) duration:7.0 andFadeLength:10.0f];
    _streamingAddress.text= [self Get_Paths:STREAM_URL_KEY];
    if ([_streamingAddress.text compare:@""]==NSOrderedSame) {
        _streamingAddress.text = NSLocalizedString(@"address_text", nil);
    }
    _streamingAddress.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _streamingAddress.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _streamingAddress.center=CGPointMake(_addressView.frame.size.width*0.5, _streamingAddress.center.y);
    _streamingAddress.textAlignment=UITextAlignmentCenter;
    _streamingAddress.numberOfLines = 1;
    _streamingAddress.opaque = NO;
    _streamingAddress.enabled = YES;
    _streamingAddress.shadowOffset = CGSizeMake(0.0, -1.0);
    [_addressView addSubview:_streamingAddress];
    
    //streamingAddress
    _streamingShareLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, viewW, viewH*30/totalHeight)];
    _streamingShareLabel.center=CGPointMake(viewW*0.5, _streamingAddressView.frame.origin.y+_streamingAddressView.frame.size.height+viewH*15/totalHeight);
    _streamingShareLabel.text = NSLocalizedString(@"address_dialog_title", nil);
    _streamingShareLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    _streamingShareLabel.backgroundColor = [UIColor clearColor];
    _streamingShareLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _streamingShareLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingShareLabel.textAlignment=UITextAlignmentCenter;
    _streamingShareLabel.numberOfLines = 0;
    [self.view addSubview:_streamingShareLabel];
    
    _streamingShareView=[[UIView alloc]initWithFrame:CGRectMake(0,_streamingShareLabel.frame.origin.y+_streamingShareLabel.frame.size.height,viewW,viewH*155/totalHeight)];
    _streamingShareView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_streamingShareView];
    
    _streamingObtainLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*20/totalWeight,viewH*16/totalHeight, viewW*67/totalWeight, viewH*32/totalHeight)];
    _streamingObtainLabel.text = NSLocalizedString(@"streaminig_obtain", nil);
    _streamingObtainLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _streamingObtainLabel.backgroundColor = [UIColor clearColor];
    _streamingObtainLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _streamingObtainLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingObtainLabel.textAlignment=UITextAlignmentRight;
    _streamingObtainLabel.numberOfLines = 0;
    [_streamingShareView addSubview:_streamingObtainLabel];
    
    _streamingObtainField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*91/totalWeight, viewH*16/totalHeight, viewW-viewW*123/totalWeight, viewH*32/totalHeight)];
    _streamingObtainField.placeholder = NSLocalizedString(@"address_live_tips", nil);
    _streamingObtainField.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _streamingObtainField.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _streamingObtainField.delegate = self;
    _streamingObtainField.textColor = [UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
    _streamingObtainField.textAlignment=UITextAlignmentLeft;
    [_streamingShareView addSubview:_streamingObtainField];
    
    _streamingMannualLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*20/totalWeight,viewH*69/totalHeight, viewW*67/totalWeight, viewH*32/totalHeight)];
    _streamingMannualLabel.text = NSLocalizedString(@"streaminig_manual", nil);
    _streamingMannualLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _streamingMannualLabel.backgroundColor = [UIColor clearColor];
    _streamingMannualLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _streamingMannualLabel.lineBreakMode = UILineBreakModeWordWrap;
    _streamingMannualLabel.textAlignment=UITextAlignmentRight;
    _streamingMannualLabel.numberOfLines = 0;
    [_streamingShareView addSubview:_streamingMannualLabel];
    
    _streamingMannualField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*91/totalWeight, viewH*69/totalHeight, viewW-viewW*123/totalWeight, viewH*32/totalHeight)];
    _streamingMannualField.placeholder = @"http://";
    _streamingMannualField.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _streamingMannualField.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _streamingMannualField.textColor = [UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
    _streamingMannualField.delegate = self;
    _streamingMannualField.textAlignment=UITextAlignmentLeft;
    [_streamingShareView addSubview:_streamingMannualField];
    
    _streamingShareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _streamingShareBtn.frame = CGRectMake(viewW*135/totalWeight, viewH*113/totalHeight, viewW*106/totalWeight, viewH*32/totalHeight);
    [_streamingShareBtn setBackgroundImage:[UIImage imageNamed:@"live stream_address_button_nor@3x.png"] forState:UIControlStateNormal];
    [_streamingShareBtn setBackgroundImage:[UIImage imageNamed:@"live stream_address_button_pre@3x.png"] forState:UIControlStateHighlighted];
    [_streamingShareBtn setTitle: NSLocalizedString(@"streaminig_share", nil) forState: UIControlStateNormal];
    [_streamingShareBtn setTitleColor:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
    _streamingShareBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _streamingShareBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_streamingShareBtn addTarget:nil action:@selector(_streamingShareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_streamingShareView  addSubview:_streamingShareBtn];
    
    //Choose Platform View
    [self platformViewInit];
    
    //Input Address View
    [self inputAddressViewInit];
}

/**
 * 选择平台弹窗
 */
-(void)platformViewInit{
    _choosePlatformView=[[UIView alloc]initWithFrame:CGRectMake(0,viewH,viewW,viewH)];
    _choosePlatformView.backgroundColor=[UIColor clearColor];
    _choosePlatformView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutCancelClick)];
    [_choosePlatformView addGestureRecognizer:singleTap];
    [self.view addSubview:_choosePlatformView];
    
    _PlatformViewLayout=[[UIView alloc]initWithFrame:CGRectMake(viewW*10/totalWeight,viewH*476/totalHeight,viewW*355/totalWeight,viewH*116/totalHeight)];
    [[_PlatformViewLayout layer]setCornerRadius:viewW*10/totalWeight];//圆角
    _PlatformViewLayout.backgroundColor=[UIColor whiteColor];
    _PlatformViewLayout.userInteractionEnabled = YES;
    [_choosePlatformView addSubview:_PlatformViewLayout];
    
    for (int i=0; i<4; i++) {
        UIViewLinkmanTouch *_platformLayoutView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(viewW*13*(i+1)/totalWeight+viewW*70*i/totalWeight,viewH*15/totalHeight,viewW*20/totalWeight+viewH*60/totalHeight,viewH*90/totalHeight)];
        
        _platformLayoutView.tag=i;
        _platformLayoutView.userInteractionEnabled = YES;
        [_PlatformViewLayout addSubview:_platformLayoutView];
        UIImageView *_platformLayoutImg=[[UIImageView alloc]init];
        _platformLayoutImg.frame = CGRectMake(viewW*10/totalWeight, viewH*5/totalHeight, viewH*60/totalHeight, viewH*60/totalHeight);
        [_platformLayoutImg setImage:[UIImage imageNamed:@"Youtube@3x.png"]];
        [_platformLayoutView  addSubview:_platformLayoutImg];
        
        UILabel *_platformLayoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(_platformLayoutImg.frame.origin.x, _platformLayoutImg.frame.origin.y+_platformLayoutImg.frame.size.height+viewH*7/totalHeight, viewH*60/totalHeight, viewH*13/totalHeight)];
        _platformLayoutLabel.text = NSLocalizedString(@"youtube", nil);
        _platformLayoutLabel.font = [UIFont systemFontOfSize: viewH*13/totalHeight];
        _platformLayoutLabel.backgroundColor = [UIColor clearColor];
        _platformLayoutLabel.textColor = [UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1.0];
        _platformLayoutLabel.lineBreakMode = UILineBreakModeWordWrap;
        _platformLayoutLabel.textAlignment=UITextAlignmentCenter;
        _platformLayoutLabel.numberOfLines = 0;
        [_platformLayoutView addSubview:_platformLayoutLabel];
        switch (i) {
            case 0:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"Youtube@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"youtube", nil);
                UITapGestureRecognizer *singleTap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick0)];
                [_platformLayoutView addGestureRecognizer:singleTap0];
            }
                break;
            case 1:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"facebook@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"facebook", nil);
                UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick1)];
                [_platformLayoutView addGestureRecognizer:singleTap1];
            }
                break;
            case 2:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"Yi Live@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"yi_live", nil);
                UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick2)];
                [_platformLayoutView addGestureRecognizer:singleTap2];
            }
                break;
            case 3:
            {
                [_platformLayoutImg setImage:[UIImage imageNamed:@"MuDu Live@3x.png"]];
                _platformLayoutLabel.text = NSLocalizedString(@"mudu_live", nil);
                UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_platformLayoutViewClick3)];
                [_platformLayoutView addGestureRecognizer:singleTap3];
            }
                break;
                
            default:
                break;
        }
    }
    
    UIButton *_platformLayoutCancel=[UIButton buttonWithType:UIButtonTypeCustom];
    _platformLayoutCancel.frame = CGRectMake(viewW*10/totalWeight, viewH*600/totalHeight, viewW*355/totalWeight, viewH*57/totalHeight);
    _platformLayoutCancel.backgroundColor=[UIColor whiteColor];
    [_platformLayoutCancel setTitleColor:[UIColor colorWithRed:67/255.0 green:77/255.0 blue:87/255.0 alpha:1.0]forState:UIControlStateNormal];
    [_platformLayoutCancel setTitleColor:[UIColor lightGrayColor]forState:UIControlStateHighlighted];
    [[_platformLayoutCancel layer]setCornerRadius:viewW*10/totalWeight];
    [_platformLayoutCancel setTitle:NSLocalizedString(@"share_cancel", nil) forState:UIControlStateNormal];
    _platformLayoutCancel.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_platformLayoutCancel addTarget:nil action:@selector(_platformLayoutCancelClick) forControlEvents:UIControlEventTouchUpInside];
    _platformLayoutCancel.titleLabel.font=[UIFont systemFontOfSize:viewH*23/totalHeight*0.8];
    [_choosePlatformView  addSubview:_platformLayoutCancel];
}

/**
 * 选择平台：youtube
 */
-(void)_platformLayoutViewClick0{
    NSLog(@"Youtube");
    _streamingPlatform.text=NSLocalizedString(@"youtube", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
}

/**
 * 选择平台：facebook
 */
-(void)_platformLayoutViewClick1{
    NSLog(@"Facebook");
    _streamingPlatform.text=NSLocalizedString(@"facebook", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
}

/**
 * 选择平台：yi live
 */
-(void)_platformLayoutViewClick2{
    NSLog(@"Yi Live");
    _streamingPlatform.text=NSLocalizedString(@"yi_live", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
}

/**
 * 选择平台：mudu
 */
-(void)_platformLayoutViewClick3{
    NSLog(@"MuDu Live");
    _streamingPlatform.text=NSLocalizedString(@"mudu_live", nil);
    [self setInfoViewFrame:_choosePlatformView :YES];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mudu.tv/login"]];
}

/**
 * 取消选择平台
 */
-(void)_platformLayoutCancelClick{
    NSLog(@"_platformLayoutCancelClick");
    _streamingPlatform.text=NSLocalizedString(@"platform_text", nil); 
    [self setInfoViewFrame:_choosePlatformView :YES];
}

/**
 * 输入直播地址弹窗
 */
-(void)inputAddressViewInit{
    _inputAddressView=[[UIView alloc]initWithFrame:CGRectMake(0,viewH,viewW,viewH)];
    _inputAddressView.backgroundColor=[UIColor clearColor];
    _inputAddressView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_inputAddressViewCancelClick)];
//    [_inputAddressView addGestureRecognizer:singleTap];
    [self.view addSubview:_inputAddressView];
    
    _inputAddressViewLayout=[[UIView alloc]initWithFrame:CGRectMake(0,0,viewW*283/totalWeight,viewH*281/totalHeight)];
    [[_inputAddressViewLayout layer]setCornerRadius:viewW*10/totalWeight];//圆角
    _inputAddressViewLayout.backgroundColor=[UIColor whiteColor];
    _inputAddressViewLayout.center=CGPointMake(viewW*0.5, viewH*0.5);
    _inputAddressViewLayout.userInteractionEnabled = YES;
    [_inputAddressView addSubview:_inputAddressViewLayout];
    
    myTextField=[[CAAutoFillTextField alloc]initWithFrame:CGRectMake(viewW*19/totalWeight, viewH*30/totalHeight, viewW*246/totalWeight, viewH*40/totalHeight)];
    myTextField.userInteractionEnabled=YES;
    [_inputAddressViewLayout addSubview:myTextField];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
     _recordUrl=[self Get_Urls:@"STREAMURL"];
    for (int i = 0; i<[_recordUrl count]; i++) {
        CAAutoCompleteObject *object = [[CAAutoCompleteObject alloc] initWithObjectName:[NSString stringWithFormat:@"%@",[_recordUrl objectAtIndex:i]] AndID:i];
        [tempArray addObject:object];
    }
    [myTextField setDataSourceArray:tempArray];
    [myTextField setDelegate:self];
    
    UIView *line=[[UIView alloc]init];
    line.frame=CGRectMake(viewW*19/totalWeight,viewH*247/totalHeight,viewW*246/totalWeight,1);
    line.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    [_inputAddressViewLayout addSubview:line];
    
    UIButton *_clearBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _clearBtn.backgroundColor=[UIColor whiteColor];
    _clearBtn.frame = CGRectMake(0, 0, viewW*106/totalWeight, viewH*18/totalHeight);
    _clearBtn.center=CGPointMake(_inputAddressViewLayout.frame.size.width*0.5, line.center.y);
    [_clearBtn setTitleColor:[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0]forState:UIControlStateNormal];
    [_clearBtn setTitleColor:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0]forState:UIControlStateHighlighted];
    [_clearBtn setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
    _clearBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_clearBtn addTarget:nil action:@selector(_clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_inputAddressViewLayout  addSubview:_clearBtn];
}

/**
 * 文字滚动相关回调
 */
- (void) CAAutoTextFillBeginEditing:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillBeginEditing");
}

- (void) CAAutoTextFillEndEditing:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillEndEditing");
    if ([textField.txtField.text compare:@""]!=NSOrderedSame) {
        _streamingAddress.text=textField.txtField.text;
        [self Save_Paths:_streamingAddress.text :STREAM_URL_KEY];
        [self addUrls];
    }
    else{
        if ([[self Get_Paths:STREAM_URL_KEY] compare:@""]==NSOrderedSame) {
            _streamingAddress.text = NSLocalizedString(@"address_text", nil);
        }
    }
    [self setInfoViewFrame:_inputAddressView :YES];
}

- (BOOL) CAAutoTextFillWantsToEdit:(CAAutoFillTextField *) textField {
    NSLog(@"CAAutoTextFillWantsToEdit");
    return YES;
}

/**
 * 取消输入直播地址
 */
-(void)_inputAddressViewCancelClick{
    NSLog(@"_inputAddressViewCancelClick");
    [self setInfoViewFrame:_inputAddressView :YES];
}

/**
 * 保存直播地址
 */
-(void)addUrls{
    BOOL isSame=NO;
    for (int i=0; i<[_recordUrl count]; i++) {
        if([[_recordUrl objectAtIndex:i] compare:_streamingAddress.text]==NSOrderedSame)
            isSame=YES;
    }
    if (!isSame) {
        NSMutableArray *mutaArray = [[NSMutableArray alloc] init];
        [mutaArray addObjectsFromArray:_recordUrl];
        [mutaArray addObject:_streamingAddress.text];
        [self Save_Urls:mutaArray :@"STREAMURL"];
    }
    
}

/**
 * 清空保存的直播地址
 */
-(void)_clearBtnClick{
    NSLog(@"_clearBtnClick");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STREAMURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:STREAM_URL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [myTextField clear];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 弹出或取消弹窗
 */
- (void)setInfoViewFrame:(UIView*)infoView :(BOOL)isDown{
    if(isDown == NO)
    {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             [infoView setFrame:CGRectMake(0, viewH+infoView.frame.size.height, infoView.frame.size.width, infoView.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  [infoView setFrame:CGRectMake(0, viewH-infoView.frame.size.height, infoView.frame.size.width, infoView.frame.size.height)];
                                              }
                                              completion:^(BOOL finished) {
                                                  infoView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
                                              }];
                         }];
        
    }else
    {
        infoView.backgroundColor=[UIColor clearColor];
        [UIView animateWithDuration:0.1
              delay:0.0
            options:0
         animations:^{
             [infoView setFrame:CGRectMake(0, 0, infoView.frame.size.width, infoView.frame.size.height)];
         }
         completion:^(BOOL finished) {
             [UIView animateWithDuration:0.1
                                   delay:0.0
                                 options:UIViewAnimationCurveEaseIn
                              animations:^{
                                  [infoView setFrame:CGRectMake(0, infoView.frame.size.height, infoView.frame.size.width, infoView.frame.size.height)];
                              }
                              completion:^(BOOL finished) {
                              }];
         }];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//屏幕常亮
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (([_streamingAddress.text compare:@""]!=NSOrderedSame)&&
        ([_streamingAddress.text compare:NSLocalizedString(@"address_text", nil)]!=NSOrderedSame)) {
        [self Save_Paths:_streamingAddress.text :STREAM_URL_KEY];
        [self addUrls];
    }

    [super viewDidDisappear:animated];
}

/**
 * 切换到竖屏
 */
-(void)_switchPortrait{
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int valOrientation = UIInterfaceOrientationPortrait;
    [invocation setArgument:&valOrientation atIndex:2];
    [invocation invoke];
}

/**
 * 返回
 */
- (void)_backBtnClick{
    _Exit=YES;
    //[self closeLivingSession];
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)_liveStreamBtnAction:sender
//{
//    if(_liveStreamBtn.on){
//        [self scanDevice];
//    }
//    else{
//        [self closeLivingSession];
//    }
//}

/**
 * 开启／停止／暂停直播
 */
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        if (((view.center.x + translation.x)>=l_control_pos)&&((view.center.x + translation.x)<=r_control_pos)){
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        if (((view.center.x)>l_control_pos)
            &&(view.center.x)<=(l_control_pos+(c_control_pos-l_control_pos)/2))//停止推流
        {
            _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_stop button@3x.png"];
            [view setCenter:(CGPoint){l_control_pos, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
            [_videoView take_imageRef:NO];
            _isLiving=0;
            [self closeLivingSession];
            _Exit=YES;
        }
        else if (((view.center.x)>(l_control_pos+(c_control_pos-l_control_pos)/2))&&(view.center.x)<=(c_control_pos+(r_control_pos-c_control_pos)/2))//开始推流
        {
            if(_isLiving==0){
                if ((([_streamingAddress.text compare:@""]==NSOrderedSame)||
                     ([_streamingAddress.text compare:NSLocalizedString(@"address_text", nil)]==NSOrderedSame))  &&([_streamingPlatform.text isEqual: NSLocalizedString(@"platform_text", nil)])){
                    [view setCenter:(CGPoint){l_control_pos, view.center.y}];
                    [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
                    [self showAllTextDialog:NSLocalizedString(@"streaminig_no_url_tips", nil)];
                    return;
                }
                
                _Exit=NO;
                [self scanDevice];
            }
            else{
                [_videoView take_imageRef:YES];
                _isLiving=1;
                _streamStatusImg.image=[UIImage imageNamed:@"live view_pilot lamp_on@3x.png"];
            }
            _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_star button@3x.png"];
            [view setCenter:(CGPoint){c_control_pos, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
        else if (((view.center.x)>(c_control_pos+(r_control_pos-c_control_pos)/2))&&(view.center.x)<=r_control_pos)//暂停推流
        {
            if (_isLiving==0) {
                [self showAllTextDialog:NSLocalizedString(@"streaminig_no_start_live_tips", nil)];
                [view setCenter:(CGPoint){l_control_pos, view.center.y}];
                [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
                _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_stop button@3x.png"];
                _streamStatusImg.image=[UIImage imageNamed:@"live view_pilot lamp_off@3x.png"];
            }
            else{
                _streamingControlImg.image=[UIImage imageNamed:@"stream_Slide bar_pause button@3x.png"];
                [view setCenter:(CGPoint){r_control_pos, view.center.y}];
                [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
                _isLiving=2;
                [_videoView take_imageRef:NO];
                _streamStatusImg.image=[UIImage imageNamed:@"Live view_icon_pause status@3x.png"];
                _Exit=YES;
            }
        }
    }
}

/**
 * 左右滑动显示出所有直播参数设置选项
 */
- (void) panView2:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        if (((view.center.x + translation.x)>=3*viewW/8)&&((view.center.x + translation.x)<=5*viewW/8)){
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }
}

/**
 * 设置字幕
 */
- (void)_linkmanBtn0Click{
    NSLog(@"_linkmanBtn0Click");
    SubtitleViewController *v = [[SubtitleViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

/**
 * 设置角标
 */
- (void)_linkmanBtn1Click{
    NSLog(@"_linkmanBtn1Click");
    BannerViewController*v = [[BannerViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

/**
 * 设置暂停界面
 */
- (void)_linkmanBtn2Click{
    NSLog(@"_linkmanBtn2Click");
    PauseScreenViewController*v = [[PauseScreenViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

/**
 * 设置声音
 */
- (void)_linkmanBtn3Click{
    NSLog(@"_linkmanBtn3Click");
    AudioViewController*v = [[AudioViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

/**
 * 设置网络
 */
- (void)_linkmanBtn4Click{
    NSLog(@"_linkmanBtn4Click");
    NetworkViewController*v = [[NetworkViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

/**
 * 分享直播链接
 */
- (void)_streamingShareBtnClick{
    NSLog(@"_streamingShareBtnClick");
}

/**
 * 选择输入直播链接
 */
- (void)_addressViewClick{
    NSLog(@"_addressViewClick");
    [self setInfoViewFrame:_inputAddressView :NO];
}

/**
 * 选择平台获取直播链接
 */
- (void)_platformViewClick{
    NSLog(@"_platformViewClick");
    [self setInfoViewFrame:_choosePlatformView :NO];
}

/**
 * 扫描设备
 */
- (void)scanDevice
{
    if (_Exit) {
        return;
    }
    [NSThread detachNewThreadSelector:@selector(scanDeviceTask) toTarget:self withObject:nil];
}

- (void)scanDeviceTask
{
    Lx52x_Device_Info *result = [_LiveScan ScanDeviceWithTime:1.0f];
    [self performSelectorOnMainThread:@selector(scanDeviceOver:) withObject:result waitUntilDone:NO];
}

- (void)scanDeviceOver:(Lx52x_Device_Info *)result;
{
    if (result.Device_ID_Arr.count > 0) {
        NSString *url = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", [result.Device_IP_Arr objectAtIndex:0],video_type];
        _userip = [result.Device_IP_Arr objectAtIndex:0];
        _userid = [result.Device_ID_Arr objectAtIndex:0];
        //[self showAllTextDialog:_userip];
        NSLog(@"user ifo:id=%@ username=%@ userpassword=%@",_userid,_username,_userpassword);
        NSLog(@"start play==%@",url);
        [_videoView sound:YES];
        [_videoView play:url useTcp:NO];
        
    }
    else
    {
        [self scanDevice];
    }
}

/**
 * 回调获取视频imageRef
 */
- (void)take_imageRef:(CGImageRef)imageRef{
    if(_isLiving==1)
        [self.session upload_imageRef:imageRef];
    else{
        CGImageRelease(imageRef);
    }
}

/**
 * 回调获取视频YUV数据
 */
- (void)GetYUVData:(int)width :(int)height
                  :(Byte*)yData :(Byte*)uData :(Byte*)vData
                  :(int)ySize :(int)uSize :(int)vSize
{
    _isPlaying=YES;
    if(_isLiving==2){
        [self.session upload_PauseImg];
    }
}

#pragma mark -------------------
#pragma mark LX520Delegate
- (void)state_changed:(int)state
{
    NSLog(@"state = %d", state);
    switch (state) {
        case 0: //STATE_IDLE
        {
            _isPlaying=NO;
            break;
        }
        case 1: //STATE_PREPARING
        {
            _isPlaying=NO;
            break;
        }
        case 2: //STATE_PLAYING
        {
            _isPlaying=YES;
            NSLog(@"视频直播");
            [self openLivingSession:1];
            break;
        }
        case 3: //STATE_STOPPED
        {
            _isPlaying=NO;
            break;
        }
            
        default:
            break;
    }
}

- (void)video_info:(NSString *)codecName codecLongName:(NSString *)codecLongName
{
    
}

- (void)audio_info:(NSString *)codecName codecLongName:(NSString *)codecLongName sampleRate:(int)sampleRate channels:(int)channels
{
    
}

/**
 * 停止获取视频
 */
- (void)stopVideo
{
    if (_isPlaying) {
        _isLiving=0;
        _isPlaying=NO;
        [_videoView stop];
        NSLog(@"stop play");
    }
}

/**
 * 重写构造器：构造直播会话，包括配置录制的音视频格式数据
 */
-(LFLiveSessionWithPicSource *)session{
    if(!_session){
        /**
         *  构造音频配置器
         *  双声道， 128Kbps的比特率，44100HZ的采样率
         */
        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
        audioConfiguration .numberOfChannels =2;
        audioConfiguration .audioBitrate = LFLiveAudioBitRate_128Kbps;
        audioConfiguration .audioSampleRate = LFLiveAudioSampleRate_44100Hz;
        
        /**
         * 构造视频配置
         * 窗体大小，比特率，最大比特率，最小比特率，帧率，最大间隔帧数，分辨率（注意视频大小一定要小于分辨率）
         */
        LFLiveVideoConfiguration  *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration .videoSize = CGSizeMake(1280, 720);  //视频大小
        videoConfiguration .videoBitRate = 800*1024;        //比特率
        videoConfiguration .videoMaxBitRate = 1000*1024;    //最大比特率
        videoConfiguration .videoMinBitRate = 500*1024;     //最小比特率
        videoConfiguration .videoFrameRate = 25;            //帧率
        videoConfiguration .videoMaxKeyframeInterval = 30; //最大关键帧间隔数
        videoConfiguration .sessionPreset =2;          //分辨率：0：360*540 1：540*960 2：720*1280
        videoConfiguration .landscape = NO;
        
        
        //默认音视频配置
        LFLiveAudioConfiguration *defaultAudioConfiguration = [LFLiveAudioConfiguration defaultConfiguration];
        LFLiveVideoConfiguration *defaultVideoConfiguration = [LFLiveVideoConfiguration defaultConfiguration];
        
        //利用两设备配置 来构造一个直播会话
        //_session = [[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        _session =[[LFLiveSessionWithPicSource alloc] initWithAudioConfiguration:defaultAudioConfiguration videoConfiguration:defaultVideoConfiguration];
        _session.delegate  = self;
        _session.isRAK=YES;
        _session.running =YES;
        //_session.preView =self.view;
    }
    return _session;
}

/**
 * 开始直播
 */
LFLiveStreamInfo *stream;
-(void)openLivingSession:(LivingDataSouceType) type{
//    if (([_streamingAddress.text compare:@""]==NSOrderedSame)||
//        ([_streamingAddress.text compare:NSLocalizedString(@"address_text", nil)]==NSOrderedSame)) {
//        return;
//    }
    stream = [LFLiveStreamInfo new];
    stream.url=_streamingAddress.text;
    //stream.url=@"rtmp://115.231.182.113:1935/livestream/daxvab6i";//哔哩哔哩
    //stream.url=@"rtmp://live-send.acg.tv/live/ive_15244440_8483360?streamname=live_15244440_8483360&key=e0431c91c2457efdeb6a02986299973e";
    [self Save_Paths:stream.url :STREAM_URL_KEY];
    [self addUrls];
    self.session.dataSoureType = type;
    [self.session startLive:stream];
    [LFLiveSessionWithPicSource setSharedInstance:self.session];
}

/**
 * 关闭直播
 */
-(void)closeLivingSession{
    _streamingAddress.enabled=YES;
    _platformView.userInteractionEnabled=YES;
    _streamStatusImg.image=[UIImage imageNamed:@"live view_pilot lamp_off@3x.png"];
    [self stopVideo];
    if(self.session.state == LFLivePending || self.session.state ==LFLiveStart){
        [self.session stopLive];
        [self.session setRunning:NO];
    }
}


#pragma mark --LFStreamingSessionDelegate
-(void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo{
    
}

-(void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString *networkStatusInfo;
    switch (state) {
        case LFLiveReady:
            networkStatusInfo = @"准备....";
            break;
        case LFLivePending:
            networkStatusInfo = @"连接中...";
            break;
        case LFLiveStart:
            networkStatusInfo = @"已连接";
            _streamStatusImg.image=[UIImage imageNamed:@"live view_pilot lamp_on@3x.png"];
            _streamingAddress.enabled=NO;
            _platformView.userInteractionEnabled=NO;
            [_videoView take_imageRef:YES];
            _isLiving=1;
            break;
        case LFLiveStop:
            networkStatusInfo  =@"已断开";
            break;
        case LFLiveError:
            networkStatusInfo =@"连接出错";
            break;
        default:
            break;
    }
    
    NSLog(@"状态信息%@",[NSString stringWithFormat:@"连接状态：%@\n",networkStatusInfo]);
}


-(void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
//    self.networkStatusLable .text =[NSString stringWithFormat: @"直播错误,代码:%d",(int)errorCode ];
    NSLog(@"%@",[NSString stringWithFormat: @"直播错误,代码:%d",(int)errorCode]);
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
    return YES;
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
    [_streamingObtainField resignFirstResponder];
    [_streamingMannualField resignFirstResponder];
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

- (void)Save_Urls:(NSMutableArray *)Timesamp :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:Timesamp forKey:key];
    [defaults synchronize];
}

- (NSMutableArray *)Get_Urls:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSMutableArray *value=[defaults objectForKey:key];
    return value;
}
@end
