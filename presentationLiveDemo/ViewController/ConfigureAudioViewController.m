//
//  ConfigureAudioViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/18.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "ConfigureAudioViewController.h"
#import "CommanParameters.h"

@interface ConfigureAudioViewController ()
@end

@implementation ConfigureAudioViewController

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
    [_backBtn setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtn.frame.origin.x+_backBtn.frame.size.width, diff_top, viewW-_backBtn.frame.origin.x-_backBtn.frame.size.width-2*diff_x, viewH*44/totalHeight)];
    _titleLabel.center=CGPointMake(self.view.center.x, _backBtn.center.y);
    _titleLabel.text = NSLocalizedString(@"audio_title", nil);
    _titleLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    _audioSampleRateView=[[UIView alloc]init];
    _audioSampleRateView.frame=CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height, viewW, viewH*119/totalHeight);
    _audioSampleRateView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_audioSampleRateView];
    
    _audioSampleRateLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*18/totalHeight, viewW, viewH*20/totalHeight)];
    _audioSampleRateLabel.text = NSLocalizedString(@"audio_samplerate", nil);
    _audioSampleRateLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _audioSampleRateLabel.backgroundColor = [UIColor clearColor];
    _audioSampleRateLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioSampleRateLabel.lineBreakMode = UILineBreakModeWordWrap;
    _audioSampleRateLabel.textAlignment=UITextAlignmentCenter;
    _audioSampleRateLabel.numberOfLines = 0;
    [_audioSampleRateView addSubview:_audioSampleRateLabel];
    
    _audioSampleRateSlider = [[UISlider alloc] initWithFrame:CGRectMake(viewW*26/totalWeight, viewH*66/totalHeight, viewW*284/totalWeight, viewH*10/totalHeight)];
    _audioSampleRateSlider.minimumValue = 0;
    _audioSampleRateSlider.maximumValue = 60;
    _audioSampleRateSlider.value = 48;
    _audioSampleRateSlider.thumbTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioSampleRateSlider.minimumTrackTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_audioSampleRateSlider addTarget:self action:@selector(_audioSampleRateSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_audioSampleRateView addSubview:_audioSampleRateSlider];
    
    _audioSampleRateMaxLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*321/totalWeight, viewH*59/totalHeight, viewW*43/totalWeight, viewH*18/totalHeight)];
    _audioSampleRateMaxLabel.text = NSLocalizedString(@"audio_samplerate_max", nil);
    _audioSampleRateMaxLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _audioSampleRateMaxLabel.backgroundColor = [UIColor clearColor];
    _audioSampleRateMaxLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioSampleRateMaxLabel.lineBreakMode = UILineBreakModeWordWrap;
    _audioSampleRateMaxLabel.textAlignment=UITextAlignmentLeft;
    _audioSampleRateMaxLabel.numberOfLines = 0;
    [_audioSampleRateView addSubview:_audioSampleRateMaxLabel];
    
    _audioSampleRateValueLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*228/totalWeight, viewH*88/totalHeight, viewW*25/totalWeight, viewH*18/totalHeight)];
    _audioSampleRateValueLabel.center=CGPointMake(48/60.0*_audioSampleRateSlider.frame.size.width+_audioSampleRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _audioSampleRateValueLabel.center.y);
    _audioSampleRateValueLabel.text = @"48";
    _audioSampleRateValueLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _audioSampleRateValueLabel.backgroundColor = [UIColor clearColor];
    _audioSampleRateValueLabel.textColor = [UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0];
    _audioSampleRateValueLabel.lineBreakMode = UILineBreakModeWordWrap;
    _audioSampleRateValueLabel.textAlignment=UITextAlignmentCenter;
    _audioSampleRateValueLabel.numberOfLines = 0;
    [_audioSampleRateView addSubview:_audioSampleRateValueLabel];
    
    _audioRateView=[[UIView alloc]init];
    _audioRateView.frame=CGRectMake(0,_audioSampleRateView.frame.origin.y+_audioSampleRateView.frame.size.height+viewH*1/totalHeight, viewW, viewH*119/totalHeight);
    _audioRateView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_audioRateView];
    
    _audioRateLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*18/totalHeight, viewW, viewH*20/totalHeight)];
    _audioRateLabel.text = NSLocalizedString(@"audio_rate", nil);
    _audioRateLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _audioRateLabel.backgroundColor = [UIColor clearColor];
    _audioRateLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioRateLabel.lineBreakMode = UILineBreakModeWordWrap;
    _audioRateLabel.textAlignment=UITextAlignmentCenter;
    _audioRateLabel.numberOfLines = 0;
    [_audioRateView addSubview:_audioRateLabel];
    
    _audioRateSlider = [[UISlider alloc] initWithFrame:CGRectMake(viewW*26/totalWeight, viewH*66/totalHeight, viewW*284/totalWeight, viewH*10/totalHeight)];
    _audioRateSlider.minimumValue = 0;
    _audioRateSlider.maximumValue = 8;
    _audioRateSlider.value = 6;
    _audioRateSlider.thumbTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioRateSlider.minimumTrackTintColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    [_audioRateSlider addTarget:self action:@selector(_audioRateSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_audioRateView addSubview:_audioRateSlider];
    
    _audioRateMaxLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*321/totalWeight, viewH*59/totalHeight, viewW*43/totalWeight, viewH*18/totalHeight)];
    _audioRateMaxLabel.text = NSLocalizedString(@"audio_rate_max", nil);
    _audioRateMaxLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _audioRateMaxLabel.backgroundColor = [UIColor clearColor];
    _audioRateMaxLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _audioRateMaxLabel.lineBreakMode = UILineBreakModeWordWrap;
    _audioRateMaxLabel.textAlignment=UITextAlignmentLeft;
    _audioRateMaxLabel.numberOfLines = 0;
    [_audioRateView addSubview:_audioRateMaxLabel];
    
    _audioRateValueLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*228/totalWeight, viewH*88/totalHeight, viewW*25/totalWeight, viewH*18/totalHeight)];
    _audioRateValueLabel.center=CGPointMake(6/8.0*_audioRateSlider.frame.size.width+_audioRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _audioRateValueLabel.center.y);
    _audioRateValueLabel.text = @"6";
    _audioRateValueLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _audioRateValueLabel.backgroundColor = [UIColor clearColor];
    _audioRateValueLabel.textColor = [UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0];
    _audioRateValueLabel.lineBreakMode = UILineBreakModeWordWrap;
    _audioRateValueLabel.textAlignment=UITextAlignmentCenter;
    _audioRateValueLabel.numberOfLines = 0;
    [_audioRateView addSubview:_audioRateValueLabel];
    
    //Confirm
    _audioConfirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _audioConfirmBtn.frame = CGRectMake(viewW*30/totalWeight, viewH-viewH*117/totalHeight, viewW*316/totalWeight, viewH*44/totalHeight);
    [_audioConfirmBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_nor@3x.png"] forState:UIControlStateNormal];
    [_audioConfirmBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_dis@3x.png"] forState:UIControlStateHighlighted];
    [_audioConfirmBtn setTitle: NSLocalizedString(@"audio_confirm_btn", nil) forState: UIControlStateNormal];
    [_audioConfirmBtn setTitleColor:[UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0] forState:UIControlStateNormal];
    _audioConfirmBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _audioConfirmBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_audioConfirmBtn addTarget:nil action:@selector(_audioConfirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_audioConfirmBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_audioConfirmBtnClick{
    NSLog(@"_audioConfirmBtnClick");
}

-(IBAction)_audioSampleRateSliderValue:(id)sender{
    float value = _audioSampleRateSlider.value; //读取滑块的值
    _audioSampleRateValueLabel.text = [NSString stringWithFormat:@"%d",(int)value];
    _audioSampleRateValueLabel.center=CGPointMake(_audioSampleRateSlider.value/60.0*_audioSampleRateSlider.frame.size.width+_audioSampleRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _audioSampleRateValueLabel.center.y);
}

-(IBAction)_audioRateSliderValue:(id)sender{
    float value = _audioRateSlider.value; //读取滑块的值
    _audioRateValueLabel.text = [NSString stringWithFormat:@"%d",(int)value];
    _audioRateValueLabel.center=CGPointMake(_audioRateSlider.value/8.0*_audioRateSlider.frame.size.width+_audioRateSlider.frame.origin.x+viewW*5/totalWeight*0.5, _audioRateValueLabel.center.y);
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
