//
//  MenuViewController.m
//  FreeCast
//
//  Created by rakwireless on 2016/10/18.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "MenuViewController.h"
#import "CommanParameter.h"
#import "UpdateFirmwareViewController.h"
#import "EditionViewController.h"
#import "CopyrightViewController.h"
#import "PrivacyPolicyViewController.h"
#import "DisclaimerViewController.h"
#import "ThemeViewController.h"
#import "FeedbackViewController.h"
#import "SupportViewController.h"
#import "UserGuardViewController.h"
#import "CommanParameters.h"

@interface MenuViewController ()
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.colors = @[(__bridge id)MENU_BG1_COLOR.CGColor, (__bridge id)MENU_BG0_COLOR.CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 1);
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
    
//    UIImageView *_Bg=[[UIImageView alloc]init];
//    _Bg.frame = CGRectMake(0, 0, viewW, viewH*20/totalHeight);
//    _Bg.contentMode=UIViewContentModeScaleToFill;
//    _Bg.backgroundColor=[UIColor blackColor];
//    _Bg.alpha=0.1;
//    [self.view addSubview:_Bg];
    
    [self init_View];
    
//    //顶部
//    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav bar_bg@3x.png"]];
//    _topBg.frame = CGRectMake(0, 0, viewW, viewH*64/totalHeight);
//    _topBg.contentMode=UIViewContentModeScaleToFill;
//    [self.view addSubview:_topBg];
//    
//    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _backBtn.frame = CGRectMake(0, diff_top, viewH*44/totalHeight, viewH*44/totalHeight);
//    [_backBtn setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"] forState:UIControlStateNormal];
//    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
//    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
//    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
//    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view  addSubview:_backBtn];
//    
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtn.frame.origin.x+_backBtn.frame.size.width, diff_top, viewW-_backBtn.frame.origin.x-_backBtn.frame.size.width-2*diff_x, viewH*44/totalHeight)];
//    _titleLabel.center=CGPointMake(self.view.center.x, _backBtn.center.y);
//    _titleLabel.text = NSLocalizedString(@"founction_menu", nil);
//    _titleLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
//    _titleLabel.backgroundColor = [UIColor clearColor];
//    _titleLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _titleLabel.textColor = [UIColor colorWithRed:232/255.0 green:59/255.0 blue:14/255.0 alpha:1.0];
//    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _titleLabel.textAlignment=UITextAlignmentCenter;
//    _titleLabel.numberOfLines = 0;
//    [self.view addSubview:_titleLabel];
//    
//    _supportLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*8/totalWeight, _topBg.frame.origin.y+_topBg.frame.size.height+viewH*2/totalHeight, viewW*80/totalWeight, viewH*16/totalHeight)];
//    _supportLabel.text = NSLocalizedString(@"support_title", nil);
//    _supportLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
//    _supportLabel.backgroundColor = [UIColor clearColor];
//    _supportLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
//    _supportLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _supportLabel.textAlignment=UITextAlignmentLeft;
//    _supportLabel.numberOfLines = 0;
//    [self.view addSubview:_supportLabel];
    
//    CGFloat init_X=viewW*57/totalWeight;
//    
//    //Help
//    _useHelpView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*74/totalHeight,viewW,viewH*36/totalHeight)];
//    _useHelpView.userInteractionEnabled = YES;
//    [_useHelpView setToucheColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0]];
//    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_useHelpViewClick)];
//    [_useHelpView addGestureRecognizer:singleTap1];
//    [self.view addSubview:_useHelpView];
//    
//    _useHelpLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _useHelpLabel.text = NSLocalizedString(@"using_help", nil);
//    _useHelpLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _useHelpLabel.backgroundColor = [UIColor clearColor];
//    _useHelpLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _useHelpLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _useHelpLabel.textAlignment=UITextAlignmentLeft;
//    _useHelpLabel.numberOfLines = 0;
//    [_useHelpView addSubview:_useHelpLabel];
//    
////    _useHelpImg=[[UIImageView alloc]init];
////    _useHelpImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [_useHelpImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI);
////    [_useHelpImg setTransform:rotate];
////    [_useHelpView  addSubview:_useHelpImg];
////    
////    UIView *line1=[[UIView alloc]init];
////    line1.frame=CGRectMake(viewW*16/totalWeight, _useHelpView.frame.origin.y+_useHelpView.frame.size.height, viewW-viewW*16/totalWeight, 1);
////    line1.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
////    [self.view  addSubview:line1];
//    
//    //Technical Support
//    _technicalSupportView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*114/totalHeight,viewW,viewH*36/totalHeight)];
//    _technicalSupportView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_technicalSupportViewClick)];
//    [_technicalSupportView addGestureRecognizer:singleTap2];
//    [self.view addSubview:_technicalSupportView];
//    
//    _technicalSupportLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _technicalSupportLabel.text = NSLocalizedString(@"technical_support", nil);
//    _technicalSupportLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _technicalSupportLabel.backgroundColor = [UIColor clearColor];
//    _technicalSupportLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _technicalSupportLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _technicalSupportLabel.textAlignment=UITextAlignmentLeft;
//    _technicalSupportLabel.numberOfLines = 0;
//    [_technicalSupportView addSubview:_technicalSupportLabel];
//    
////    _technicalSupportImg=[[UIImageView alloc]init];
////    _technicalSupportImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [_technicalSupportImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    [_technicalSupportImg setTransform:rotate];
////    [_technicalSupportView  addSubview:_technicalSupportImg];
////    
////    UIView *line2=[[UIView alloc]init];
////    line2.frame=CGRectMake(viewW*16/totalWeight, _technicalSupportView.frame.origin.y+_technicalSupportView.frame.size.height, viewW-viewW*16/totalWeight, 1);
////    line2.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
////    [self.view  addSubview:line2];
//    
//    //Feedback
//    _feedbackView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*154/totalHeight,viewW,viewH*36/totalHeight)];
//    _feedbackView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_feedbackViewClick)];
//    [_feedbackView addGestureRecognizer:singleTap3];
//    [self.view addSubview:_feedbackView];
//    
//    _feedbackLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _feedbackLabel.text = NSLocalizedString(@"feedback", nil);
//    _feedbackLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _feedbackLabel.backgroundColor = [UIColor clearColor];
//    _feedbackLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _feedbackLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _feedbackLabel.textAlignment=UITextAlignmentLeft;
//    _feedbackLabel.numberOfLines = 0;
//    [_feedbackView addSubview:_feedbackLabel];
//    
////    _feedbackImg=[[UIImageView alloc]init];
////    _feedbackImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [_feedbackImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    [_feedbackImg setTransform:rotate];
////    [_feedbackView  addSubview:_feedbackImg];
////    
////    UIView *line3=[[UIView alloc]init];
////    line3.frame=CGRectMake(viewW*16/totalWeight, _feedbackView.frame.origin.y+_feedbackView.frame.size.height, viewW-viewW*16/totalWeight, 1);
////    line3.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
////    [self.view  addSubview:line3];
//    UIView *line3=[[UIView alloc]init];
//    line3.frame=CGRectMake(0, viewH*190/totalHeight, viewW, viewH*34/totalHeight);
//    line3.backgroundColor=[UIColor colorWithRed:49/255.0 green:49/255.0 blue:56/255.0 alpha:1.0];
//    [self.view  addSubview:line3];
//    
//    //Theme
//    _themeView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*224/totalHeight,viewW,viewH*36/totalHeight)];
//    _themeView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_themeViewClick)];
//    [_themeView addGestureRecognizer:singleTap9];
//    [self.view addSubview:_themeView];
//    
//    _themeLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _themeLabel.text = NSLocalizedString(@"theme", nil);
//    _themeLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _themeLabel.backgroundColor = [UIColor clearColor];
//    _themeLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _themeLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _themeLabel.textAlignment=UITextAlignmentLeft;
//    _themeLabel.numberOfLines = 0;
//    [_themeView addSubview:_themeLabel];
//    
//    UIView *line4=[[UIView alloc]init];
//    line4.frame=CGRectMake(0, viewH*260/totalHeight, viewW, viewH*34/totalHeight);
//    line4.backgroundColor=[UIColor colorWithRed:49/255.0 green:49/255.0 blue:56/255.0 alpha:1.0];
//    [self.view  addSubview:line4];
//    
//    //Upgrade
//    _upgradeView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*294/totalHeight,viewW,viewH*36/totalHeight)];
//    _upgradeView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_upgradeViewClick)];
//    [_upgradeView addGestureRecognizer:singleTap4];
//    [self.view addSubview:_upgradeView];
//    
//    _upgradeLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _upgradeLabel.text = NSLocalizedString(@"upgrade_firmware", nil);
//    _upgradeLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _upgradeLabel.backgroundColor = [UIColor clearColor];
//    _upgradeLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _upgradeLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _upgradeLabel.textAlignment=UITextAlignmentLeft;
//    _upgradeLabel.numberOfLines = 0;
//    [_upgradeView addSubview:_upgradeLabel];
//    
////    _upgradeImg=[[UIImageView alloc]init];
////    _upgradeImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [_upgradeImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    [_upgradeImg setTransform:rotate];
////    [_upgradeView  addSubview:_upgradeImg];
////    
////    _aboutLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*8/totalWeight, _upgradeView.frame.origin.y+_upgradeView.frame.size.height+viewH*2/totalHeight, viewW*80/totalWeight, viewH*16/totalHeight)];
////    _aboutLabel.text = NSLocalizedString(@"about", nil);
////    _aboutLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
////    _aboutLabel.backgroundColor = [UIColor clearColor];
////    _aboutLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
////    _aboutLabel.lineBreakMode = UILineBreakModeWordWrap;
////    _aboutLabel.textAlignment=UITextAlignmentLeft;
////    _aboutLabel.numberOfLines = 0;
////    [self.view addSubview:_aboutLabel];
//    
//    UIView *line5=[[UIView alloc]init];
//    line5.frame=CGRectMake(0, viewH*330/totalHeight, viewW, viewH*34/totalHeight);
//    line5.backgroundColor=[UIColor colorWithRed:49/255.0 green:49/255.0 blue:56/255.0 alpha:1.0];
//    [self.view  addSubview:line5];
//    
//    //Disclaimer
//    _disclaimerView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*364/totalHeight,viewW,viewH*36/totalHeight)];
//    _disclaimerView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_disclaimerViewClick)];
//    [_disclaimerView addGestureRecognizer:singleTap5];
//    [self.view addSubview:_disclaimerView];
//    
//    _disclaimerLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _disclaimerLabel.text = NSLocalizedString(@"disclaimer", nil);
//    _disclaimerLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _disclaimerLabel.backgroundColor = [UIColor clearColor];
//    _disclaimerLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _disclaimerLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _disclaimerLabel.textAlignment=UITextAlignmentLeft;
//    _disclaimerLabel.numberOfLines = 0;
//    [_disclaimerView addSubview:_disclaimerLabel];
//    
////    _disclaimerImg=[[UIImageView alloc]init];
////    _disclaimerImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [_disclaimerImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    [_disclaimerImg setTransform:rotate];
////    [_disclaimerView  addSubview:_disclaimerImg];
////    
////    UIView *line4=[[UIView alloc]init];
////    line4.frame=CGRectMake(viewW*16/totalWeight, _disclaimerView.frame.origin.y+_disclaimerView.frame.size.height, viewW-viewW*16/totalWeight, 1);
////    line4.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
////    [self.view  addSubview:line4];
//
//    //Privacy policy
//    _privacyView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*404/totalHeight,viewW,viewH*36/totalHeight)];
//    _privacyView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_privacyViewClick)];
//    [_privacyView addGestureRecognizer:singleTap6];
//    [self.view addSubview:_privacyView];
//    
//    _privacyLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _privacyLabel.text = NSLocalizedString(@"privacy_policy", nil);
//    _privacyLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _privacyLabel.backgroundColor = [UIColor clearColor];
//    _privacyLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _privacyLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _privacyLabel.textAlignment=UITextAlignmentLeft;
//    _privacyLabel.numberOfLines = 0;
//    [_privacyView addSubview:_privacyLabel];
//    
////    _privacyImg=[[UIImageView alloc]init];
////    _privacyImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [_privacyImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    [_privacyImg setTransform:rotate];
////    [_privacyView  addSubview:_privacyImg];
////    
////    UIView *line5=[[UIView alloc]init];
////    line5.frame=CGRectMake(viewW*16/totalWeight, _privacyView.frame.origin.y+_privacyView.frame.size.height, viewW-viewW*16/totalWeight, 1);
////    line5.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
////    [self.view  addSubview:line5];
//    
//    //Copyright
//    _copyrightView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*444/totalHeight,viewW,viewH*36/totalHeight)];
//    _copyrightView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_copyrightViewClick)];
//    [_copyrightView addGestureRecognizer:singleTap7];
//    [self.view addSubview:_copyrightView];
//    
//    copyrightLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    copyrightLabel.text = NSLocalizedString(@"copyright_info", nil);
//    copyrightLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    copyrightLabel.backgroundColor = [UIColor clearColor];
//    copyrightLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    copyrightLabel.lineBreakMode = UILineBreakModeWordWrap;
//    copyrightLabel.textAlignment=UITextAlignmentLeft;
//    copyrightLabel.numberOfLines = 0;
//    [_copyrightView addSubview:copyrightLabel];
//    
////    copyrightImg=[[UIImageView alloc]init];
////    copyrightImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [copyrightImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    [copyrightImg setTransform:rotate];
////    [_copyrightView  addSubview:copyrightImg];
////    
////    UIView *line6=[[UIView alloc]init];
////    line6.frame=CGRectMake(viewW*16/totalWeight, _copyrightView.frame.origin.y+_copyrightView.frame.size.height, viewW-viewW*16/totalWeight, 1);
////    line6.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
////    [self.view  addSubview:line6];
//    
//    //Edition
//    _editionView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,viewH*484/totalHeight,viewW,viewH*36/totalHeight)];
//    _editionView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTap8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_editionViewClick)];
//    [_editionView addGestureRecognizer:singleTap8];
//    [self.view addSubview:_editionView];
//    
//    _editionLabel= [[UILabel alloc] initWithFrame:CGRectMake(init_X, 0, self.view.frame.size.width*180, viewH*36/totalHeight)];
//    _editionLabel.text = NSLocalizedString(@"edition", nil);
//    _editionLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
//    _editionLabel.backgroundColor = [UIColor clearColor];
//    _editionLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
//    _editionLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _editionLabel.textAlignment=UITextAlignmentLeft;
//    _editionLabel.numberOfLines = 0;
//    [_editionView addSubview:_editionLabel];
////    
////    _editionImg=[[UIImageView alloc]init];
////    _editionImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
////    [_editionImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
////    [_editionImg setTransform:rotate];
////    [_editionView  addSubview:_editionImg];
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


- (void)init_View{
    for(int i=0;i<7;i++){
        CGFloat init_X=viewW*57/totalWeight;
        CGFloat init_Y=viewH*80/totalHeight;
        UIButton *_menuBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _menuBtn.tag=i;
        switch (i) {
            case 0:
                init_X=0;
                _menuBtn.frame= CGRectMake(init_X, init_Y+viewH*40*i/totalHeight, viewW, viewH*34/totalHeight);
                [_menuBtn setTitle: @"" forState: UIControlStateNormal];
                _menuBtn.backgroundColor=[UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1.0];
//                [_menuBtn setTitle: NSLocalizedString(@"using_help", nil) forState: UIControlStateNormal];
//                _menuBtn.backgroundColor=[UIColor clearColor];
                break;
            case 1:
//                [_menuBtn setTitle: NSLocalizedString(@"theme", nil) forState: UIControlStateNormal];
//                _menuBtn.backgroundColor=[UIColor clearColor];
                _menuBtn.frame= CGRectMake(init_X, init_Y+viewH*40*i/totalHeight+viewH*14/totalHeight, viewW, viewH*20/totalHeight);
                [_menuBtn setTitle: NSLocalizedString(@"disclaimer", nil) forState: UIControlStateNormal];
                _menuBtn.backgroundColor=[UIColor clearColor];
                break;
            case 2:
                _menuBtn.frame= CGRectMake(init_X, init_Y+viewH*40*i/totalHeight+viewH*14/totalHeight, viewW, viewH*20/totalHeight);
                [_menuBtn setTitle: NSLocalizedString(@"privacy_policy", nil) forState: UIControlStateNormal];
                _menuBtn.backgroundColor=[UIColor clearColor];
//                [_menuBtn setTitle: @"" forState: UIControlStateNormal];
//                _menuBtn.backgroundColor=[UIColor colorWithRed:49/255.0 green:49/255.0 blue:56/255.0 alpha:1.0];
//                init_X=0;
                break;
            case 3:
                _menuBtn.frame= CGRectMake(init_X, init_Y+viewH*40*i/totalHeight+viewH*14/totalHeight, viewW, viewH*20/totalHeight);
                [_menuBtn setTitle: NSLocalizedString(@"copyright_info", nil) forState: UIControlStateNormal];
                _menuBtn.backgroundColor=[UIColor clearColor];
                break;
            case 4:
                init_X=0;
                _menuBtn.frame= CGRectMake(init_X, init_Y+viewH*40*i/totalHeight+viewH*14/totalHeight, viewW, viewH*34/totalHeight);
                [_menuBtn setTitle: @"" forState: UIControlStateNormal];
                _menuBtn.backgroundColor=[UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1.0];
                break;
            case 5:
                _menuBtn.frame= CGRectMake(init_X, init_Y+viewH*40*i/totalHeight+viewH*28/totalHeight, viewW, viewH*20/totalHeight);
                [_menuBtn setTitle: NSLocalizedString(@"edition", nil) forState: UIControlStateNormal];
                _menuBtn.backgroundColor=[UIColor clearColor];
                break;
            case 6:
                
                break;
                
            default:
                break;
        }
        [_menuBtn setTitleColor:[UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
        _menuBtn.titleLabel.font = [UIFont boldSystemFontOfSize:viewH*20/totalHeight];
        [_menuBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateHighlighted];
        _menuBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        [_menuBtn addTarget:nil action:@selector(_menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view  addSubview:_menuBtn];
    }
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_menuBtnClick:(UIButton*)button{
    NSLog(@"_menuBtnClick=%d",(int)button.tag);
    switch ((int)button.tag) {
        case 0:
        {
            NSLog(@"_useHelpViewClick");
            UserGuardViewController *v = [[UserGuardViewController alloc] init];
            [self.navigationController pushViewController: v animated:true];
            break;
        }
        case 1:
        {
//            NSLog(@"_themeViewClick");
//            ThemeViewController *v = [[ThemeViewController alloc] init];
//            [self.navigationController pushViewController: v animated:true];
            NSLog(@"_disclaimerViewClick");
            DisclaimerViewController *v = [[DisclaimerViewController alloc] init];
            [self.navigationController pushViewController: v animated:true];
            break;
        }
        case 2:
        {
            NSLog(@"_privacyViewClick");
            PrivacyPolicyViewController *v = [[PrivacyPolicyViewController alloc] init];
            [self.navigationController pushViewController: v animated:true];
            break;
        }
        case 3:
        {
            NSLog(@"_copyrightViewClick");
            CopyrightViewController *v = [[CopyrightViewController alloc] init];
            [self.navigationController pushViewController: v animated:true];
            break;
        }
        case 4:
        {
            break;
        }
        case 5:
        {
            NSLog(@"_editionViewClick");
            EditionViewController *v = [[EditionViewController alloc] init];
            [self.navigationController pushViewController: v animated:true];
            break;
        }
        case 6:
        {
            
            break;
        }
        default:
            break;
    }
}

- (void)_useHelpViewClick{
    NSLog(@"_useHelpViewClick");
}

- (void)_technicalSupportViewClick{
    NSLog(@"_technicalSupportViewClick");
}

- (void)_feedbackViewClick{
    NSLog(@"_feedbackViewClick");
}

- (void)_themeViewClick{
    NSLog(@"_themeViewClick");
}

- (void)_upgradeViewClick{
    NSLog(@"_upgradeViewClick");
    UpdateFirmwareViewController *v = [[UpdateFirmwareViewController alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

- (void)_disclaimerViewClick{
    NSLog(@"_disclaimerViewClick");
}

- (void)_privacyViewClick{
    NSLog(@"_privacyViewClick");
}

- (void)_copyrightViewClick{
    NSLog(@"_copyrightViewClick");
}

- (void)_editionViewClick{
    NSLog(@"_editionViewClick");
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
