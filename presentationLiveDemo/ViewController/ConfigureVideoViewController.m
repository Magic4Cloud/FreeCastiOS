//
//  ConfigureVideoViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/18.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "ConfigureVideoViewController.h"
#import "CommanParameter.h"

@interface ConfigureVideoViewController ()
{
    CGFloat viewH;
    CGFloat viewW;
    CGFloat totalHeight;//各部分比例
    CGFloat totalWeight;//各部分比例
}
@end

@implementation ConfigureVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
    viewH=self.view.frame.size.height;
    viewW=self.view.frame.size.width;
    totalHeight=64+71+149+149+149+80+5;//各部分比例
    totalWeight=375;//各部分比例
    
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
    _titleLabel.text = NSLocalizedString(@"video_title", nil);
    _titleLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    _videoResolutionView=[[UIView alloc]init];
    _videoResolutionView.frame=CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height, viewW, viewH*104/totalHeight);
    _videoResolutionView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_videoResolutionView];
    
    _videoResolutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*18/totalHeight, viewW, viewH*20/totalHeight)];
    _videoResolutionLabel.text = NSLocalizedString(@"video_resolution", nil);
    _videoResolutionLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _videoResolutionLabel.backgroundColor = [UIColor clearColor];
    _videoResolutionLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _videoResolutionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoResolutionLabel.textAlignment=UITextAlignmentCenter;
    _videoResolutionLabel.numberOfLines = 0;
    [_videoResolutionView addSubview:_videoResolutionLabel];

    _videoResolution480p=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoResolution480p.frame = CGRectMake(viewW*46/totalWeight, viewH*58/totalHeight, viewW*72/totalWeight, viewH*28/totalHeight);
    [[_videoResolution480p layer] setBorderWidth:1.0];//画线的宽度
    [[_videoResolution480p layer] setBorderColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0].CGColor];//颜色
    [[_videoResolution480p layer]setCornerRadius:viewW*10/totalWeight];//圆角
    _videoResolution480p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution480p.layer setMasksToBounds:YES];
    [_videoResolution480p setTitle: NSLocalizedString(@"video_480p", nil) forState: UIControlStateNormal];
    [_videoResolution480p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution480p.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _videoResolution480p.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_videoResolution480p addTarget:nil action:@selector(_videoResolution480pClick) forControlEvents:UIControlEventTouchUpInside];
    [_videoResolutionView  addSubview:_videoResolution480p];
    
    _videoResolution720p=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoResolution720p.frame = CGRectMake(viewW*152/totalWeight, viewH*58/totalHeight, viewW*72/totalWeight, viewH*28/totalHeight);
    [[_videoResolution720p layer] setBorderWidth:1.0];//画线的宽度
    [[_videoResolution720p layer] setBorderColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0].CGColor];//颜色
    [[_videoResolution720p layer]setCornerRadius:viewW*10/totalWeight];//圆角
    _videoResolution720p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution720p.layer setMasksToBounds:YES];
    [_videoResolution720p setTitle: NSLocalizedString(@"video_720p", nil) forState: UIControlStateNormal];
    [_videoResolution720p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution720p.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _videoResolution720p.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_videoResolution720p addTarget:nil action:@selector(_videoResolution720pClick) forControlEvents:UIControlEventTouchUpInside];
    [_videoResolutionView  addSubview:_videoResolution720p];
    
    _videoResolution1080p=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoResolution1080p.frame = CGRectMake(viewW*258/totalWeight, viewH*58/totalHeight, viewW*72/totalWeight, viewH*28/totalHeight);
    [[_videoResolution1080p layer] setBorderWidth:1.0];//画线的宽度
    [[_videoResolution1080p layer] setBorderColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0].CGColor];//颜色
    [[_videoResolution1080p layer]setCornerRadius:viewW*10/totalWeight];//圆角
    _videoResolution1080p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution1080p.layer setMasksToBounds:YES];
    [_videoResolution1080p setTitle: NSLocalizedString(@"video_1080p", nil) forState: UIControlStateNormal];
    [_videoResolution1080p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution1080p.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _videoResolution1080p.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_videoResolution1080p addTarget:nil action:@selector(_videoResolution1080pClick) forControlEvents:UIControlEventTouchUpInside];
    [_videoResolutionView  addSubview:_videoResolution1080p];

    _videoRateView=[[UIView alloc]init];
    _videoRateView.frame=CGRectMake(0,_videoResolutionView.frame.origin.y+_videoResolutionView.frame.size.height+viewH*1/totalHeight, viewW, viewH*119/totalHeight);
    _videoRateView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_videoRateView];
    
    _videoRateLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*18/totalHeight, viewW, viewH*20/totalHeight)];
    _videoRateLabel.text = NSLocalizedString(@"video_rate", nil);
    _videoRateLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _videoRateLabel.backgroundColor = [UIColor clearColor];
    _videoRateLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _videoRateLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoRateLabel.textAlignment=UITextAlignmentCenter;
    _videoRateLabel.numberOfLines = 0;
    [_videoRateView addSubview:_videoRateLabel];
    
    _videoRateSlider = [[UISlider alloc] initWithFrame:CGRectMake(viewW*26/totalWeight, viewH*66/totalHeight, viewW*284/totalWeight, viewH*10/totalHeight)];
    _videoRateSlider.minimumValue = 0;
    _videoRateSlider.maximumValue = 8;
    _videoRateSlider.value = 6;
    _videoRateSlider.thumbTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _videoRateSlider.minimumTrackTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_videoRateSlider addTarget:self action:@selector(_videoRateSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_videoRateView addSubview:_videoRateSlider];
    
    _videoRateMaxLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*321/totalWeight, viewH*59/totalHeight, viewW*22/totalWeight, viewH*18/totalHeight)];
    _videoRateMaxLabel.text = NSLocalizedString(@"video_rate_max", nil);
    _videoRateMaxLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _videoRateMaxLabel.backgroundColor = [UIColor clearColor];
    _videoRateMaxLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _videoRateMaxLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoRateMaxLabel.textAlignment=UITextAlignmentLeft;
    _videoRateMaxLabel.numberOfLines = 0;
    [_videoRateView addSubview:_videoRateMaxLabel];
    
    _videoRateValueLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*215/totalWeight, viewH*88/totalHeight, viewW*25/totalWeight, viewH*18/totalHeight)];
    _videoRateValueLabel.center=CGPointMake(6/8.0*_videoRateSlider.frame.size.width+_videoRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoRateValueLabel.center.y);
    _videoRateValueLabel.text = @"6";
    _videoRateValueLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _videoRateValueLabel.backgroundColor = [UIColor clearColor];
    _videoRateValueLabel.textColor = [UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0];
    _videoRateValueLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoRateValueLabel.textAlignment=UITextAlignmentCenter;
    _videoRateValueLabel.numberOfLines = 0;
    [_videoRateView addSubview:_videoRateValueLabel];
    
    _videoFrameRateView=[[UIView alloc]init];
    _videoFrameRateView.frame=CGRectMake(0,_videoRateView.frame.origin.y+_videoRateView.frame.size.height+viewH*1/totalHeight, viewW, viewH*119/totalHeight);
    _videoFrameRateView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_videoFrameRateView];
    
    _videoFrameRateLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*18/totalHeight, viewW, viewH*20/totalHeight)];
    _videoFrameRateLabel.text = NSLocalizedString(@"video_framerate", nil);
    _videoFrameRateLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _videoFrameRateLabel.backgroundColor = [UIColor clearColor];
    _videoFrameRateLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _videoFrameRateLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoFrameRateLabel.textAlignment=UITextAlignmentCenter;
    _videoFrameRateLabel.numberOfLines = 0;
    [_videoFrameRateView addSubview:_videoFrameRateLabel];
    
    _videoFrameRateSlider = [[UISlider alloc] initWithFrame:CGRectMake(viewW*26/totalWeight, viewH*66/totalHeight, viewW*284/totalWeight, viewH*10/totalHeight)];
    _videoFrameRateSlider.minimumValue = 0;
    _videoFrameRateSlider.maximumValue = 30;
    _videoFrameRateSlider.value = 25;
    _videoFrameRateSlider.thumbTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _videoFrameRateSlider.minimumTrackTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_videoFrameRateSlider addTarget:self action:@selector(_videoFrameRateSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_videoFrameRateView addSubview:_videoFrameRateSlider];
    
    _videoFrameRateMaxLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*321/totalWeight, viewH*59/totalHeight, viewW*43/totalWeight, viewH*18/totalHeight)];
    _videoFrameRateMaxLabel.text = NSLocalizedString(@"video_framerate_max", nil);
    _videoFrameRateMaxLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _videoFrameRateMaxLabel.backgroundColor = [UIColor clearColor];
    _videoFrameRateMaxLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _videoFrameRateMaxLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoFrameRateMaxLabel.textAlignment=UITextAlignmentLeft;
    _videoFrameRateMaxLabel.numberOfLines = 0;
    [_videoFrameRateView addSubview:_videoFrameRateMaxLabel];
    
    _videoFrameRateValueLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*228/totalWeight, viewH*88/totalHeight, viewW*25/totalWeight, viewH*18/totalHeight)];
    _videoFrameRateValueLabel.center=CGPointMake(25/30.0*_videoFrameRateSlider.frame.size.width+_videoFrameRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoFrameRateValueLabel.center.y);
    _videoFrameRateValueLabel.text = @"25";
    _videoFrameRateValueLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _videoFrameRateValueLabel.backgroundColor = [UIColor clearColor];
    _videoFrameRateValueLabel.textColor = [UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0];
    _videoFrameRateValueLabel.lineBreakMode = UILineBreakModeWordWrap;
    _videoFrameRateValueLabel.textAlignment=UITextAlignmentCenter;
    _videoFrameRateValueLabel.numberOfLines = 0;
    [_videoFrameRateView addSubview:_videoFrameRateValueLabel];
    
    //Confirm
    _videoConfirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoConfirmBtn.frame = CGRectMake(viewW*30/totalWeight, viewH-viewH*117/totalHeight, viewW*316/totalWeight, viewH*44/totalHeight);
    [_videoConfirmBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_nor@3x.png"] forState:UIControlStateNormal];
    [_videoConfirmBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_dis@3x.png"] forState:UIControlStateHighlighted];
    [_videoConfirmBtn setTitle: NSLocalizedString(@"video_confirm_btn", nil) forState: UIControlStateNormal];
    [_videoConfirmBtn setTitleColor:[UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoConfirmBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _videoConfirmBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_videoConfirmBtn addTarget:nil action:@selector(_videoConfirmBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_videoConfirmBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_videoResolution480pClick{
    _videoResolution1080p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution1080p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution720p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution720p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution480p.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_videoResolution480p setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
}

- (void)_videoResolution720pClick{
    _videoResolution480p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution480p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution1080p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution1080p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution720p.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_videoResolution720p setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
}

- (void)_videoResolution1080pClick{
    _videoResolution480p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution480p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution720p.backgroundColor=[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0];
    [_videoResolution720p setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0] forState:UIControlStateNormal];
    _videoResolution1080p.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_videoResolution1080p setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
}

- (void)_videoConfirmBtnBtnClick{
    NSLog(@"_videoConfirmBtnBtnClick");
}

-(IBAction)_videoRateSliderValue:(id)sender{
    float value = _videoRateSlider.value; //读取滑块的值
    _videoRateValueLabel.text = [NSString stringWithFormat:@"%d",(int)value];
    _videoRateValueLabel.center=CGPointMake(_videoRateSlider.value/8.0*_videoRateSlider.frame.size.width+_videoRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoRateValueLabel.center.y);
}

-(IBAction)_videoFrameRateSliderValue:(id)sender{
    float value = _videoFrameRateSlider.value; //读取滑块的值
    _videoFrameRateValueLabel.text = [NSString stringWithFormat:@"%d",(int)value];
    _videoFrameRateValueLabel.center=CGPointMake(_videoFrameRateSlider.value/30.0*_videoFrameRateSlider.frame.size.width+_videoFrameRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _videoFrameRateValueLabel.center.y);
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
