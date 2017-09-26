//
//  BannerViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "BannerViewController.h"
#import "CommanParameters.h"
#import "PicToBufferToPic.h"
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "RAKAsyncSocket.h"
#import "ImageHelper.h"
#import "CommanParameters.h"
#import "decode.h"

NSString *bannerHost=@"POST /actosd.php HTTP/1.1\r\nHost: ";
NSString *bannerReferer=@"\r\nReferer: http://";
NSString *bannerLength=@"/test.php\r\nContent-Type: multipart/form-data; boundary=----WebKitFormBoundary9jF0QWJdi6csfpFy\r\nConnection: keep-alive\r\nContent-Length: ";
NSString *bannerName=@"------WebKitFormBoundary9jF0QWJdi6csfpFy\r\nContent-Disposition: form-data; name=\"upfile\"; filename=\"";
NSString *bannerHeadEnd=@"\"\r\nContent-Type: image/jpeg\r\n\r\n";
NSString *bannerAllEnd=@"\r\n------WebKitFormBoundary9jF0QWJdi6csfpFy--\r\n";

@interface BannerViewController ()
{
    int orairation;//正在选择的角标位置 0:上左 1:上右 2:下左 3:下右
    int _enableBanner;
    int _x;
    int _y;
    int _opcity;
    NSString *_base64Word;
    RAKAsyncSocket* GCDSocket;//用于建立TCP socket
    NSString *_leftUpBmpPath;
    NSString *_rightUpPath;
    NSString *_leftDownPath;
    NSString *_rightDownPath;
    int _bmpSize;
    NSString *_bmpPath;
}
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    //    _imagePickerController.mediaTypes= [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    _imagePickerController.allowsEditing = NO;
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _opcity=128;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *tmpPath = [path stringByAppendingPathComponent:@"temp"];
    NSLog(@"tmpPath=%@",tmpPath);
    if (![self isFileExistAtPath:tmpPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    _leftUpBmpPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"_leftUpBmpPath.bmp"]];
    NSLog(@"_leftUpBmpPath=%@",_leftUpBmpPath);
    _rightUpPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"_rightUpPath.bmp"]];
    NSLog(@"_rightUpPath=%@",_rightUpPath);
    _leftDownPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"_leftDownPath.bmp"]];
    NSLog(@"_leftDownPath=%@",_leftDownPath);
    _rightDownPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"_rightDownPath.bmp"]];
    NSLog(@"_rightDownPath=%@",_rightDownPath);
    
    //顶部
    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
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
    _titleLabel.text = @"Logo";
//    _titleLabel.text = NSLocalizedString(@"banner_title", nil);
    _titleLabel.font = [UIFont boldSystemFontOfSize: viewH*22.5/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    //Display btn
//    _bannerDisplayView=[[UIView alloc]initWithFrame:CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height,viewW,viewH*44/totalHeight)];
//    _bannerDisplayView.backgroundColor=[UIColor whiteColor];
//    [self.view addSubview:_bannerDisplayView];
    
    _bannerDisplayLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*16.5/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height + viewH*26/totalHeight, viewW*150/totalWeight, viewH*15/totalHeight)];
//    _bannerDisplayLabel.text = NSLocalizedString(@"banner_display", nil);
    _bannerDisplayLabel.text = @"Logo Display";
    _bannerDisplayLabel.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
    _bannerDisplayLabel.backgroundColor = [UIColor clearColor];
    _bannerDisplayLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _bannerDisplayLabel.lineBreakMode = UILineBreakModeWordWrap;
    _bannerDisplayLabel.textAlignment=UITextAlignmentLeft;
    _bannerDisplayLabel.numberOfLines = 0;
    [self.view addSubview:_bannerDisplayLabel];
    
    _bannerDisplayBtn= [[UISwitch alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height,viewW*51/totalWeight, viewH*31/totalHeight)];
    _bannerDisplayBtn.center=CGPointMake(viewW*288.5/totalWeight, _bannerDisplayLabel.center.y);
    _bannerDisplayBtn.on = NO;
    _bannerDisplayBtn.onTintColor =MAIN_COLOR;
    [_bannerDisplayBtn addTarget:self action:@selector(_bannerDisplayBtnAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_bannerDisplayBtn];
    
    //bannerLayout
    _bannerLayoutView=[[UIView alloc]initWithFrame:CGRectMake(0,_bannerDisplayLabel.frame.origin.y+_bannerDisplayLabel.frame.size.height+viewH*28.5/totalHeight,viewW,viewH*375/totalHeight)];
    _bannerLayoutView.backgroundColor=[UIColor whiteColor];
    _bannerLayoutView.layer.borderWidth = 1.5;
    _bannerLayoutView.layer.borderColor = [UIColor colorWithRed:199/255.0 green:200/255.0 blue:202/255.0 alpha:1.0].CGColor;
    [self.view addSubview:_bannerLayoutView];
    
    UIView *line=[[UIView alloc]init];
    line.frame=CGRectMake(viewW*187.2/totalWeight, 0, 1.5,viewH*375/totalHeight);
    line.backgroundColor=[UIColor colorWithRed:199/255.0 green:200/255.0 blue:202/255.0 alpha:1.0];
    [_bannerLayoutView addSubview:line];
    
    _bannerLayoutUpperLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,viewH*20/totalHeight, viewW*187/totalWeight, viewH*12.5/totalHeight)];
    _bannerLayoutUpperLeftLabel.text = NSLocalizedString(@"banner_u_left", nil);
    _bannerLayoutUpperLeftLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
//    _bannerLayoutUpperLeftLabel.backgroundColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _bannerLayoutUpperLeftLabel.textColor = [UIColor colorWithRed:184.548/255.0 green:184.548/255.0 blue:184.548/255.0 alpha:1.0];
    _bannerLayoutUpperLeftLabel.lineBreakMode = UILineBreakModeWordWrap;
    _bannerLayoutUpperLeftLabel.textAlignment=UITextAlignmentCenter;
    _bannerLayoutUpperLeftLabel.numberOfLines = 0;
    [_bannerLayoutView addSubview:_bannerLayoutUpperLeftLabel];
    
    _bannerLayoutUpperRightLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*188/totalWeight,viewH*20/totalHeight, viewW*187/totalWeight, viewH*12.5/totalHeight)];
    _bannerLayoutUpperRightLabel.text = NSLocalizedString(@"banner_u_right", nil);
    _bannerLayoutUpperRightLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
//    _bannerLayoutUpperRightLabel.backgroundColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _bannerLayoutUpperRightLabel.textColor = [UIColor colorWithRed:184.548/255.0 green:184.548/255.0 blue:184.548/255.0 alpha:1.0];
    _bannerLayoutUpperRightLabel.lineBreakMode = UILineBreakModeWordWrap;
    _bannerLayoutUpperRightLabel.textAlignment=UITextAlignmentCenter;
    _bannerLayoutUpperRightLabel.numberOfLines = 0;
    [_bannerLayoutView addSubview:_bannerLayoutUpperRightLabel];
    
    _bannerLayoutUpperLeftImg=[UIButton buttonWithType:UIButtonTypeCustom];
    _bannerLayoutUpperLeftImg.frame = CGRectMake(viewW*41/totalWeight,viewH*53/totalHeight, viewW*105/totalWeight, viewH*105/totalHeight);
    [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
     _bannerLayoutUpperLeftImg.contentMode=UIViewContentModeScaleToFill;
    _bannerLayoutUpperLeftImg.backgroundColor=[UIColor whiteColor];
    _bannerLayoutUpperLeftImg.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_bannerLayoutUpperLeftImg addTarget:nil action:@selector(_bannerLayoutUpperLeftImgClick) forControlEvents:UIControlEventTouchUpInside];
    [_bannerLayoutView addSubview:_bannerLayoutUpperLeftImg];
    
    _bannerLayoutUpperRightImg=[UIButton buttonWithType:UIButtonTypeCustom];
    _bannerLayoutUpperRightImg.frame = CGRectMake(viewW*229.5/totalWeight,viewH*53/totalHeight, viewW*105/totalWeight, viewH*105/totalHeight);
    [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    _bannerLayoutUpperRightImg.contentMode=UIViewContentModeScaleToFill;
    _bannerLayoutUpperRightImg.backgroundColor=[UIColor whiteColor];
    _bannerLayoutUpperRightImg.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_bannerLayoutUpperRightImg addTarget:nil action:@selector(_bannerLayoutUpperRightImgClick) forControlEvents:UIControlEventTouchUpInside];
    [_bannerLayoutView addSubview:_bannerLayoutUpperRightImg];
    
    _bannerLayoutLowerLeftImg=[UIButton buttonWithType:UIButtonTypeCustom];
    _bannerLayoutLowerLeftImg.frame = CGRectMake(viewW*41/totalWeight,viewH*241.5/totalHeight, viewW*105/totalWeight, viewH*105/totalHeight);
    [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    _bannerLayoutLowerLeftImg.contentMode=UIViewContentModeScaleToFill;
    _bannerLayoutLowerLeftImg.backgroundColor=[UIColor whiteColor];
    _bannerLayoutLowerLeftImg.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_bannerLayoutLowerLeftImg addTarget:nil action:@selector(_bannerLayoutLowerLeftImgClick) forControlEvents:UIControlEventTouchUpInside];
    [_bannerLayoutView addSubview:_bannerLayoutLowerLeftImg];
    
    _bannerLayoutLowerRightImg=[UIButton buttonWithType:UIButtonTypeCustom];
    _bannerLayoutLowerRightImg.frame = CGRectMake(viewW*229.5/totalWeight,viewH*241.5/totalHeight, viewW*105/totalWeight, viewH*105/totalHeight);
    [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    _bannerLayoutLowerRightImg.contentMode=UIViewContentModeScaleToFill;
    _bannerLayoutLowerRightImg.backgroundColor=[UIColor whiteColor];
    _bannerLayoutLowerRightImg.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_bannerLayoutLowerRightImg addTarget:nil action:@selector(_bannerLayoutLowerRightImgClick) forControlEvents:UIControlEventTouchUpInside];
    [_bannerLayoutView addSubview:_bannerLayoutLowerRightImg];
    
    _bannerLayoutLowerLeftLabel= [[UILabel alloc] initWithFrame:CGRectMake(0,viewH*210/totalHeight, viewW*187/totalWeight, viewH*12.5/totalHeight)];
//    _bannerLayoutLowerLeftLabel.text = NSLocalizedString(@"banner_l_left", nil);
    _bannerLayoutLowerLeftLabel.text = @"Bottom Left";
    _bannerLayoutLowerLeftLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
//    _bannerLayoutLowerLeftLabel.backgroundColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _bannerLayoutLowerLeftLabel.textColor = [UIColor colorWithRed:184.548/255.0 green:184.548/255.0 blue:184.548/255.0 alpha:1.0];
    _bannerLayoutLowerLeftLabel.lineBreakMode = UILineBreakModeWordWrap;
    _bannerLayoutLowerLeftLabel.textAlignment=UITextAlignmentCenter;
    _bannerLayoutLowerLeftLabel.numberOfLines = 0;
    [_bannerLayoutView addSubview:_bannerLayoutLowerLeftLabel];
    
    _bannerLayoutLowerRightLabel= [[UILabel alloc] initWithFrame:CGRectMake(viewW*188/totalWeight,viewH*210/totalHeight, viewW*187/totalWeight, viewH*12.5/totalHeight)];
//    _bannerLayoutLowerRightLabel.text = NSLocalizedString(@"banner_u_right", nil);
    _bannerLayoutLowerRightLabel.text = @"Bottom Right";
    _bannerLayoutLowerRightLabel.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
//    _bannerLayoutLowerRightLabel.backgroundColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _bannerLayoutLowerRightLabel.textColor = [UIColor colorWithRed:184.548/255.0 green:184.548/255.0 blue:184.548/255.0 alpha:1.0];
    _bannerLayoutLowerRightLabel.lineBreakMode = UILineBreakModeWordWrap;
    _bannerLayoutLowerRightLabel.textAlignment=UITextAlignmentCenter;
    _bannerLayoutLowerRightLabel.numberOfLines = 0;
    [_bannerLayoutView addSubview:_bannerLayoutLowerRightLabel];
    
    
    UIView *line2=[[UIView alloc]init];
    line2.frame=CGRectMake(0, 0, viewW*375/totalWeight,1.5);
    line2.center = CGPointMake(_bannerLayoutView.center.x,viewH*186.5/totalHeight);
    line2.backgroundColor=[UIColor colorWithRed:199/255.0 green:200/255.0 blue:202/255.0 alpha:1.0];
    [_bannerLayoutView addSubview:line2];
    
    //Settings
    _bannerSettingsView=[[UIView alloc]initWithFrame:CGRectMake(0,_bannerLayoutView.frame.origin.y+_bannerLayoutView.frame.size.height,viewW,viewH*89/totalHeight)];
    _bannerSettingsView.userInteractionEnabled=YES;
    _bannerSettingsView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_bannerSettingsView];
    
//    _bannerDurationLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*37/totalWeight,viewH*30/totalHeight, viewW*112/totalWeight, viewH*32/totalHeight)];
//    _bannerDurationLabel.text = NSLocalizedString(@"subtitle_duration", nil);
//    _bannerDurationLabel.font = [UIFont systemFontOfSize: viewH*15/totalHeight*0.8];
//    _bannerDurationLabel.backgroundColor = [UIColor clearColor];
//    _bannerDurationLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
//    _bannerDurationLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _bannerDurationLabel.textAlignment=UITextAlignmentLeft;
//    _bannerDurationLabel.numberOfLines = 0;
    //[_bannerSettingsView addSubview:_bannerDurationLabel];
    
//    _bannerDurationField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*180/totalWeight, viewH*14/totalHeight, viewW*119/totalWeight, viewH*32/totalHeight)];
//    _bannerDurationField.text = @"5";
//    [_bannerDurationField addTarget:self action:@selector(_bannerDurationFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//    _bannerDurationField.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
//    _bannerDurationField.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
//    _bannerDurationField.textColor = [UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
//    _bannerDurationField.delegate=self;
//    _bannerDurationField.textAlignment=UITextAlignmentCenter;
    //[_bannerSettingsView addSubview:_bannerDurationField];
    
//    _bannerDurationKit=[[UILabel alloc] initWithFrame:CGRectMake(viewW*307/totalWeight,viewH*14/totalHeight, viewW*58/totalWeight, viewH*32/totalHeight)];
//    _bannerDurationKit.text = NSLocalizedString(@"subtitle_seconds", nil);
//    _bannerDurationKit.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
//    _bannerDurationKit.backgroundColor = [UIColor clearColor];
//    _bannerDurationKit.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
//    _bannerDurationKit.lineBreakMode = UILineBreakModeWordWrap;
//    _bannerDurationKit.textAlignment=UITextAlignmentCenter;
//    _bannerDurationKit.numberOfLines = 0;
    //[_bannerSettingsView addSubview:_bannerDurationKit];
    
//    _bannerIntervalLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*22/totalWeight,viewH*66/totalHeight, viewW*112/totalWeight, viewH*32/totalHeight)];
//    _bannerIntervalLabel.text = NSLocalizedString(@"subtitle_interval", nil);
//    _bannerIntervalLabel.font = [UIFont boldSystemFontOfSize: viewH*17/totalHeight*0.8];
//    _bannerIntervalLabel.backgroundColor = [UIColor clearColor];
//    _bannerIntervalLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
//    _bannerIntervalLabel.lineBreakMode = UILineBreakModeWordWrap;
//    _bannerIntervalLabel.textAlignment=UITextAlignmentLeft;
//    _bannerIntervalLabel.numberOfLines = 0;
    //[_bannerSettingsView addSubview:_bannerIntervalLabel];
    
//    _bannerIntervalField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*180/totalWeight, viewH*66/totalHeight, viewW*119/totalWeight, viewH*32/totalHeight)];
//    _bannerIntervalField.text = @"10";
//    _bannerIntervalField.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
//    _bannerIntervalField.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
//    _bannerIntervalField.textColor = [UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
//    [_bannerIntervalField addTarget:self action:@selector(_bannerIntervalFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//    _bannerIntervalField.delegate=self;
//    _bannerIntervalField.textAlignment=UITextAlignmentCenter;
    //[_bannerSettingsView addSubview:_bannerIntervalField];
    
//    _bannerIntervalKit=[[UILabel alloc] initWithFrame:CGRectMake(viewW*307/totalWeight,viewH*66/totalHeight, viewW*58/totalWeight, viewH*32/totalHeight)];
//    _bannerIntervalKit.text = NSLocalizedString(@"subtitle_seconds", nil);
//    _bannerIntervalKit.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
//    _bannerIntervalKit.backgroundColor = [UIColor clearColor];
//    _bannerIntervalKit.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
//    _bannerIntervalKit.lineBreakMode = UILineBreakModeWordWrap;
//    _bannerIntervalKit.textAlignment=UITextAlignmentCenter;
//    _bannerIntervalKit.numberOfLines = 0;
    //[_bannerSettingsView addSubview:_bannerIntervalKit];
    
    _bannerOpacityLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*30/totalWeight,viewH*37/totalHeight, viewW*53/totalWeight, viewH*25/totalHeight)];
    _bannerOpacityLabel.text = NSLocalizedString(@"subtitle_opacity", nil);
    _bannerOpacityLabel.font = [UIFont boldSystemFontOfSize: viewH*15/totalHeight*0.8];
    _bannerOpacityLabel.backgroundColor = [UIColor clearColor];
    _bannerOpacityLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _bannerOpacityLabel.lineBreakMode = UILineBreakModeWordWrap;
    _bannerOpacityLabel.textAlignment=UITextAlignmentLeft;
    _bannerOpacityLabel.numberOfLines = 0;
    [_bannerSettingsView addSubview:_bannerOpacityLabel];
    
    
    _bannerOpacitySlider= [[UISlider alloc] initWithFrame:CGRectMake(viewW*114.5/totalWeight, viewH*14/totalHeight, viewW*219/totalWeight, viewH*25/totalHeight)];
    _bannerOpacitySlider.center = CGPointMake(viewW*223.5/totalWeight, _bannerOpacityLabel.center.y);
    _bannerOpacitySlider.minimumValue = 0;
    _bannerOpacitySlider.maximumValue = 128;
    _bannerOpacitySlider.value = 128;
    _bannerOpacitySlider.thumbTintColor = MAIN_COLOR;
    _bannerOpacitySlider.minimumTrackTintColor = MAIN_COLOR;
    _bannerOpacitySlider.continuous=YES;
    [_bannerOpacitySlider addTarget:self action:@selector(_bannerOpacitySliderValue:) forControlEvents:UIControlEventValueChanged];
    [_bannerOpacitySlider addTarget:self action:@selector(_bannerOpacitySliderClick) forControlEvents:UIControlEventTouchUpInside];
    [_bannerSettingsView addSubview:_bannerOpacitySlider];
    
    UIImage *imagea=[self OriginImage:[UIImage imageNamed:@"circle"] scaleToSize:CGSizeMake(11, 11)];
    [_bannerOpacitySlider  setThumbImage:imagea forState:UIControlStateNormal];
    
    
    _bannerOpacityValue = [[UITextField alloc] initWithFrame:CGRectMake(viewW*308/totalWeight, viewH*60/totalHeight, viewW*44/totalWeight, viewH*12.5/totalHeight)];
    _bannerOpacityValue.text = @"100%";
    _bannerOpacityValue.font = [UIFont systemFontOfSize: viewH*12.5/totalHeight*0.8];
//    _bannerOpacityValue.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    [_bannerOpacityValue addTarget:self action:@selector(_bannerOpacityValueDidChange:) forControlEvents:UIControlEventEditingChanged];
    _bannerOpacityValue.delegate=self;
    _bannerOpacityValue.textColor = [UIColor colorWithRed:176.359/255.0 green:176.359/255.0 blue:176.359/255.0 alpha:1.0];
    _bannerOpacityValue.textAlignment=UITextAlignmentCenter;
    [_bannerSettingsView addSubview:_bannerOpacityValue];

    [self chooseImgViewInit];
    //Enable
    [NSThread detachNewThreadSelector:@selector(GetBannerStatus) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(GetBannerFormart) toTarget:self withObject:nil];
    
    if([self Get_Images:BANNER_UPPER_LEFT_KEY]==nil){
        [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
        [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    }
    else{
        [_bannerLayoutUpperLeftImg setImage:[self Get_Images:BANNER_UPPER_LEFT_KEY] forState:UIControlStateNormal];
        [_bannerLayoutUpperLeftImg setImage:[self Get_Images:BANNER_UPPER_LEFT_KEY] forState:UIControlStateHighlighted];
    }
    
    if([self Get_Images:BANNER_UPPER_RIGHT_KEY]==nil){
        [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
        [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    }
    else{
        [_bannerLayoutUpperRightImg setImage:[self Get_Images:BANNER_UPPER_RIGHT_KEY] forState:UIControlStateNormal];
        [_bannerLayoutUpperRightImg setImage:[self Get_Images:BANNER_UPPER_RIGHT_KEY] forState:UIControlStateHighlighted];
    }
    
    if([self Get_Images:BANNER_LOWER_LEFT_KEY]==nil){
        [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
        [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    }
    else{
        [_bannerLayoutLowerLeftImg setImage:[self Get_Images:BANNER_LOWER_LEFT_KEY] forState:UIControlStateNormal];
        [_bannerLayoutLowerLeftImg setImage:[self Get_Images:BANNER_LOWER_LEFT_KEY] forState:UIControlStateHighlighted];
    }
    
    if([self Get_Images:BANNER_LOWER_RIGHT_KEY]==nil){
        [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
        [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    }
    else{
        [_bannerLayoutLowerRightImg setImage:[self Get_Images:BANNER_LOWER_RIGHT_KEY] forState:UIControlStateNormal];
        [_bannerLayoutLowerRightImg setImage:[self Get_Images:BANNER_LOWER_RIGHT_KEY] forState:UIControlStateHighlighted];
    }
    if([self Get_Paths:BANNER_DURATION_KEY]!=nil){
        _bannerDurationField.text=[self Get_Paths:BANNER_DURATION_KEY];
    }
    else{
        [self Save_Paths:_bannerDurationField.text :BANNER_DURATION_KEY];
    }
    if([self Get_Paths:BANNER_INTERVAL_KEY]!=nil){
        _bannerIntervalField.text=[self Get_Paths:BANNER_INTERVAL_KEY];
    }
    else{
        [self Save_Paths:_bannerIntervalField.text :BANNER_INTERVAL_KEY];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//屏幕常亮
}

-(void)chooseImgViewInit{
    _chooseImgView=[[UIView alloc]initWithFrame:CGRectMake(0,viewH,viewW,viewH)];
    _chooseImgView.backgroundColor=[UIColor clearColor];
    _chooseImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_chooseImgViewCancelClick)];
    [_chooseImgView addGestureRecognizer:singleTap];
    [self.view addSubview:_chooseImgView];
    
    UIView *_chooseImgViewLayout=[[UIView alloc]initWithFrame:CGRectMake(viewW*10/totalWeight,viewH*421/totalHeight,viewW*355/totalWeight,viewH*171/totalHeight)];
    [[_chooseImgViewLayout layer]setCornerRadius:viewW*10/totalWeight];//圆角
    _chooseImgViewLayout.backgroundColor=[UIColor whiteColor];
    _chooseImgViewLayout.userInteractionEnabled = YES;
    [_chooseImgView addSubview:_chooseImgViewLayout];
    
    for (int i=0; i<3; i++) {
        UIButton *_chooseLayoutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _chooseLayoutBtn.tag=i;
        _chooseLayoutBtn.frame = CGRectMake(0, viewH*57*i/totalHeight, viewW*355/totalWeight, viewH*57/totalHeight);
        _chooseLayoutBtn.backgroundColor=[UIColor clearColor];
        [_chooseLayoutBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateHighlighted];
        _chooseLayoutBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        [_chooseLayoutBtn addTarget:nil action:@selector(_chooseLayoutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _chooseLayoutBtn.titleLabel.font=[UIFont systemFontOfSize:viewH*23/totalHeight*0.8];
        [_chooseImgViewLayout  addSubview:_chooseLayoutBtn];
        
        switch (i) {
            case 0:
            {
                [_chooseLayoutBtn setTitle:NSLocalizedString(@"share_camera", nil) forState:UIControlStateNormal];
                [_chooseLayoutBtn setTitleColor:[UIColor colorWithRed:67/255.0 green:77/255.0 blue:87/255.0 alpha:1.0]forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
               [_chooseLayoutBtn setTitle:NSLocalizedString(@"share_album", nil) forState:UIControlStateNormal];
               [_chooseLayoutBtn setTitleColor:[UIColor colorWithRed:67/255.0 green:77/255.0 blue:87/255.0 alpha:1.0]forState:UIControlStateNormal];
            }
                break;
            case 2:
            {
                [_chooseLayoutBtn setTitle:NSLocalizedString(@"share_delete", nil) forState:UIControlStateNormal];
                [_chooseLayoutBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
        
        if (i<2) {
            UIView *Line=[[UIView alloc]init];
            Line.frame = CGRectMake(0, viewH*57*(i+1)/totalHeight, viewW*355/totalWeight, 1);
            Line.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:182/255.0 alpha:1.0];
            [_chooseImgViewLayout  addSubview:Line];
        }
    }
    
    UIButton *_chooseImgViewCancel=[UIButton buttonWithType:UIButtonTypeCustom];
    _chooseImgViewCancel.frame = CGRectMake(viewW*10/totalWeight, viewH*600/totalHeight, viewW*355/totalWeight, viewH*57/totalHeight);
    _chooseImgViewCancel.backgroundColor=[UIColor whiteColor];
    [_chooseImgViewCancel setTitleColor:[UIColor colorWithRed:67/255.0 green:77/255.0 blue:87/255.0 alpha:1.0]forState:UIControlStateNormal];
    [_chooseImgViewCancel setTitleColor:[UIColor lightGrayColor]forState:UIControlStateHighlighted];
    [[_chooseImgViewCancel layer]setCornerRadius:viewW*10/totalWeight];
    [_chooseImgViewCancel setTitle:NSLocalizedString(@"share_cancel", nil) forState:UIControlStateNormal];
    _chooseImgViewCancel.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_chooseImgViewCancel addTarget:nil action:@selector(_chooseImgViewCancelClick) forControlEvents:UIControlEventTouchUpInside];
    _chooseImgViewCancel.titleLabel.font=[UIFont systemFontOfSize:viewH*23/totalHeight*0.8];
    [_chooseImgView  addSubview:_chooseImgViewCancel];
}


-(void)_chooseImgViewCancelClick{
    NSLog(@"_chooseImgViewCancelClick");
    [self setInfoViewFrame:_chooseImgView :YES];
}

-(void)_chooseLayoutBtnClick:(UIButton*)button{
    NSLog(@"_chooseLayoutBtnClick");
    [self setInfoViewFrame:_chooseImgView :YES];
    switch (button.tag) {
        case 0:
        {
            NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                _imagePickerController.mediaTypes = @[mediaTypes[0]];
                _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                _imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }else {
                NSLog(@"当前设备不支持拍照");
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Note"
                                                                                          message:@"The photo  not support take photo"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      
                                                                  }]];
                [self presentViewController:alertController
                                   animated:YES
                                 completion:nil];
            }
        }
            break;
        case 1:
        {
            _imagePickerController.mediaTypes= [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }
            break;
        case 2:
        {
            switch (orairation) {
                case 0:
                {
                    [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
                    [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
                    [self Save_Images:nil :BANNER_UPPER_LEFT_KEY];
                    [self Save_Images:nil :BANNER_UPPER_LEFT_PUSH_KEY];
                }
                    break;
                case 1:
                {
                    [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
                    [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
                    [self Save_Images:nil :BANNER_UPPER_RIGHT_KEY];
                    [self Save_Images:nil :BANNER_UPPER_RIGHT_PUSH_KEY];
                }
                    break;
                case 2:
                {
                    [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
                    [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
                    [self Save_Images:nil :BANNER_LOWER_LEFT_KEY];
                    [self Save_Images:nil :BANNER_LOWER_LEFT_PUSH_KEY];
                }
                    break;
                case 3:
                {
                    [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
                    [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
                    [self Save_Images:nil :BANNER_LOWER_RIGHT_KEY];
                    [self Save_Images:nil :BANNER_LOWER_RIGHT_PUSH_KEY];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void) clearImage{
    [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutUpperLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutUpperRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutLowerLeftImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_nor@3x.png"] forState:UIControlStateNormal];
    [_bannerLayoutLowerRightImg setImage:[UIImage imageNamed:@"stream_banner_addbutoon_pre@3x.png"] forState:UIControlStateHighlighted];
    
    [self Save_Images:nil :BANNER_UPPER_LEFT_KEY];
    [self Save_Images:nil :BANNER_UPPER_LEFT_PUSH_KEY];
    [self Save_Images:nil :BANNER_UPPER_RIGHT_KEY];
    [self Save_Images:nil :BANNER_UPPER_RIGHT_PUSH_KEY];
    [self Save_Images:nil :BANNER_LOWER_LEFT_KEY];
    [self Save_Images:nil :BANNER_LOWER_LEFT_PUSH_KEY];
    [self Save_Images:nil :BANNER_LOWER_RIGHT_KEY];
    [self Save_Images:nil :BANNER_LOWER_RIGHT_PUSH_KEY];
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        //UIImage *image = [PicBufferUtil scaleImage:info[UIImagePickerControllerOriginalImage] toSize:_bannerLayoutUpperLeftImg.frame.size];
        UIImage *image =info[UIImagePickerControllerOriginalImage];
        float scale=(int)image.size.height;
        if ((int)image.size.width>(int)image.size.height) {
            scale=(int)image.size.width;
        }
        image = [self scaleImage:image toScale:_bannerLayoutUpperLeftImg.frame.size.height/scale];
        unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
        [self clearImage];
        int diff=80;
        switch (orairation) {
            case 0:
            {
                _x=diff;
                _y=diff;
                _bmpPath=_leftUpBmpPath;
                [_bannerLayoutUpperLeftImg setImage:image forState:UIControlStateNormal];
                [_bannerLayoutUpperLeftImg setImage:image forState:UIControlStateHighlighted];
                _bannerLayoutUpperLeftImg.alpha=_bannerOpacitySlider.value/128.0;
                [self Save_Images:image :BANNER_UPPER_LEFT_KEY];
                [self Save_Images:[self getImageFromView:_bannerLayoutUpperLeftImg] :BANNER_UPPER_LEFT_PUSH_KEY];
            }
                break;
            case 1:
            {
                _x=1920-diff-_bannerLayoutUpperLeftImg.frame.size.width;
                _y=0+diff;
                _bmpPath=_rightUpPath;
                [_bannerLayoutUpperRightImg setImage:image forState:UIControlStateNormal];
                [_bannerLayoutUpperRightImg setImage:image forState:UIControlStateHighlighted];
                _bannerLayoutUpperRightImg.alpha=_bannerOpacitySlider.value/128.0;
                [self Save_Images:image :BANNER_UPPER_RIGHT_KEY];
                [self Save_Images:[self getImageFromView:_bannerLayoutUpperRightImg] :BANNER_UPPER_RIGHT_PUSH_KEY];
            }
                break;
            case 2:
            {
                _x=diff;
                _y=1080-diff-_bannerLayoutUpperLeftImg.frame.size.height;
                _bmpPath=_leftDownPath;
                [_bannerLayoutLowerLeftImg setImage:image forState:UIControlStateNormal];
                [_bannerLayoutLowerLeftImg setImage:image forState:UIControlStateHighlighted];
                _bannerLayoutLowerLeftImg.alpha=_bannerOpacitySlider.value/128.0;
                [self Save_Images:image :BANNER_LOWER_LEFT_KEY];
                [self Save_Images:[self getImageFromView:_bannerLayoutLowerLeftImg] :BANNER_LOWER_LEFT_PUSH_KEY];
            }
                break;
            case 3:
            {
                _x=1920-diff-_bannerLayoutUpperLeftImg.frame.size.width;
                _y=1080-diff-_bannerLayoutUpperLeftImg.frame.size.height;
                _bmpPath=_rightDownPath;
                [_bannerLayoutLowerRightImg setImage:image forState:UIControlStateNormal];
                [_bannerLayoutLowerRightImg setImage:image forState:UIControlStateHighlighted];
                _bannerLayoutLowerRightImg.alpha=_bannerOpacitySlider.value/128.0;
                [self Save_Images:image :BANNER_LOWER_RIGHT_KEY];
                [self Save_Images:[self getImageFromView:_bannerLayoutLowerRightImg] :BANNER_LOWER_RIGHT_PUSH_KEY];
            }
                break;
                
            default:
                break;
        }
        [NSThread detachNewThreadSelector:@selector(SetBannerFormart) toTarget:self withObject:nil];
        _bmpSize=bmp_write(bitmap, image.size.width, image.size.height, (char *)[_bmpPath UTF8String]);
        free(bitmap);
        [NSThread detachNewThreadSelector:@selector(SetBannerImg) toTarget:self withObject:nil];
    }else{
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    
}

#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}

#pragma mark-- 获取字幕使能状态
-(void)GetBannerStatus{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_picture_enable",_ip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *_value=[self parseJsonString:http_request.ResponseString];
            if (([_value compare:@"1"] == NSOrderedSame)) {
                _bannerDisplayBtn.on=YES;
            }
            else{
                _bannerDisplayBtn.on=NO;
            }
        });
    }
}

#pragma mark-- 设置角标使能状态 0:不使能  1:使能
-(void)SetBannerStatus{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_picture_enable&pipe=0&value=%d",_ip,80,_enableBanner];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *value=[self parseJsonString2:http_request.ResponseString :@"\"info\":\""];
            if ([value compare:@"suc"]==NSOrderedSame) {
                
            }
            else{
                if (_enableBanner==1) {
                    _bannerDisplayBtn.on=NO;
                }
                else{
                    _bannerDisplayBtn.on=YES;
                }
                [self showAllTextDialog:NSLocalizedString(@"settings_failed", nil)];
            }
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_enableBanner==1) {
                _bannerDisplayBtn.on=NO;
            }
            else{
                _bannerDisplayBtn.on=YES;
            }
            [self showAllTextDialog:NSLocalizedString(@"settings_failed", nil)];
        });
    }
}

#pragma mark-- 获取角标显示位置／透明度／滚动状态
-(void)GetBannerFormart
{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_picture_pos",_ip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        //{"x":"1920","y":"-0","opcity":"-128","roll":"1"}
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([http_request.ResponseString compare:@""]==NSOrderedSame) {
                return;
            }
            _x=[[self parseJsonString2:http_request.ResponseString :@"\"x\":\""] intValue];
            _y=[[self parseJsonString2:http_request.ResponseString :@"\"y\":\""] intValue];
            _opcity=abs([[self parseJsonString2:http_request.ResponseString :@"\"opcity\":\""] intValue]);
            NSLog(@"_opcity0=%d",_opcity);
            _bannerOpacityValue.text=[NSString stringWithFormat:@"%d%@",_opcity*100/128,@"%"];
            _bannerOpacitySlider.value=_opcity;
            float alpha=_bannerOpacitySlider.value/128.0;
            _bannerLayoutUpperLeftImg.alpha=alpha;
            _bannerLayoutUpperRightImg.alpha=alpha;
            _bannerLayoutLowerLeftImg.alpha=alpha;
            _bannerLayoutLowerRightImg.alpha=alpha;
        });
    }
}

#pragma mark-- 设置角标显示位置／透明度
-(void)SetBannerFormart
{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_picture_pos&pipe=0&x=%d&y=%d&opcity=%d",_ip,80,_x,_y,_opcity];
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

#pragma mark-- 设置角标内容
-(void)SetBannerImg
{
    GCDSocket = [[RAKAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];//建立与设备 TCP 80端口连接，用于串口透传数据发送与接收
    NSError *err;
    [GCDSocket connectToHost:_ip onPort:80 error:&err];
    if (err != nil)
    {
        NSLog(@"error = %@",err);
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"upgrade_firmware_failed_connect", nil)];
        });
    }
    else{
        [GCDSocket readDataWithTimeout:-1 tag:0];
        int bin_len=_bmpSize;
        int count=0;
        NSString *topStream=[NSString stringWithFormat:@"%@%@%@",bannerName, @"test.jpeg",bannerHeadEnd];
        //NSLog(@"topStream==%@",topStream);
        NSString *bottomStream=bannerAllEnd;
        int send_len=bin_len+(int)topStream.length+(int)bottomStream.length;
        NSString *HeadStream=[NSString stringWithFormat:@"%@%@%@%@%@%d\r\nAccept: */*\r\n\r\n%@",bannerHost,_ip,bannerReferer,_ip,bannerLength,send_len,topStream];
        NSLog(@"HeadStream=%@",HeadStream);
        
        //发送头
        [GCDSocket writeData:[HeadStream dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:100];
        NSData *data;
        FILE * pFile = fopen([_bmpPath UTF8String], "rb");
        if(NULL != pFile)
        {
            void*pBuffer = malloc(_bmpSize);
            if (NULL != pBuffer)
            {
                fseek(pFile , 0, SEEK_SET);
                fread(pBuffer, 1, _bmpSize, pFile);
                fclose(pFile);
                data = [ [NSData alloc] initWithBytes:pBuffer length: _bmpSize];
                free(pBuffer);
            }  
        }

        //发送文件
        while (bin_len>0) {
            if (bin_len>1024) {
                [GCDSocket writeData:[data subdataWithRange:NSMakeRange(count, 1024)] withTimeout:1.0 tag:100];
                bin_len=bin_len-1024;
                count+=1024;
            }
            else{
                [GCDSocket writeData:[data subdataWithRange:NSMakeRange(count, bin_len)] withTimeout:1.0 tag:100];
                bin_len=0;
                count=0;
            }
            [NSThread sleepForTimeInterval:0.01f];
        }
        //发送BottomStream
        [GCDSocket writeData:[bottomStream dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:100];
    }

}

-(void)socket:(RAKAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if([sock isEqual:GCDSocket]){
        if(data.length > 0)
        {
            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"result=%@",result);
            if ([result hasPrefix: @"HTTP/1.1 200 OK"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   if ([result containsString:@"文件上传成功"]) {
                        [self showAllTextDialog:NSLocalizedString(@"settings_success", nil)];
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
            if (GCDSocket!=nil) {
                [GCDSocket disconnect];
                GCDSocket=nil;
            }
        }
        [GCDSocket readDataWithTimeout:-1 tag:0];
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


//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_bannerDisplayBtnAction:(UISwitch*)sender{
    if (sender.on) {
        NSLog(@"_bannerDisplayBtn is on");
        _enableBanner=1;
    }
    else{
        NSLog(@"_bannerDisplayBtn is off");
        _enableBanner=0;
    }
    [NSThread detachNewThreadSelector:@selector(SetBannerStatus) toTarget:self withObject:nil];
}

- (void)_bannerLayoutUpperLeftImgClick{
    NSLog(@"_bannerLayoutUpperLeftImgClick");
    orairation=0;
    [self setInfoViewFrame:_chooseImgView :NO];
}
- (void)_bannerLayoutUpperRightImgClick{
    NSLog(@"_bannerLayoutUpperRightImgClick");
    orairation=1;
    [self setInfoViewFrame:_chooseImgView :NO];
}
- (void)_bannerLayoutLowerLeftImgClick{
    NSLog(@"_bannerLayoutLowerLeftImgClick");
    orairation=2;
    [self setInfoViewFrame:_chooseImgView :NO];
}
- (void)_bannerLayoutLowerRightImgClick{
    NSLog(@"_bannerLayoutLowerRightImgClick");
    orairation=3;
    [self setInfoViewFrame:_chooseImgView :NO];
}

- (void)_bannerOpacitySliderValue:(UISlider*)slider{
    _bannerOpacityValue.text= [NSString stringWithFormat:@"%d%@",(int)slider.value*100/128,@"%"];
    _opcity=_bannerOpacitySlider.value;
    NSLog(@"_opcity1=%d",_opcity);
    _bannerLayoutUpperLeftImg.alpha=(int)slider.value/128.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutUpperLeftImg] :BANNER_UPPER_LEFT_PUSH_KEY];
    _bannerLayoutUpperRightImg.alpha=(int)slider.value/128.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutUpperRightImg] :BANNER_UPPER_RIGHT_PUSH_KEY];
    _bannerLayoutLowerLeftImg.alpha=(int)slider.value/128.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutLowerLeftImg] :BANNER_LOWER_LEFT_PUSH_KEY];
    _bannerLayoutLowerRightImg.alpha=(int)slider.value/128.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutLowerRightImg] :BANNER_LOWER_RIGHT_PUSH_KEY];
}

- (void)_bannerOpacitySliderClick{
    NSLog(@"_subtitleOpacitySliderClick");
    [NSThread detachNewThreadSelector:@selector(SetBannerFormart) toTarget:self withObject:nil];
}


- (void)_bannerDurationFieldDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        [self showAllTextDialog:NSLocalizedString(@"duration_value_empty", nil)];
        return;
    }
    [self Save_Paths:TextField.text :BANNER_DURATION_KEY];
}

- (void)_bannerIntervalFieldDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        [self showAllTextDialog:NSLocalizedString(@"interval_value_empty", nil)];
        return;
    }
    [self Save_Paths:TextField.text :BANNER_INTERVAL_KEY];
}

- (void)_bannerOpacityValueDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        [self showAllTextDialog:NSLocalizedString(@"opacity_value_empty", nil)];
        return;
    }
    NSString *value=[TextField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    [self Save_Paths:value :BANNER_OPACITY_KEY];
    _bannerOpacitySlider.value=[value intValue];
    _bannerLayoutUpperLeftImg.alpha=(int)_bannerOpacitySlider.value/100.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutUpperLeftImg] :BANNER_UPPER_LEFT_PUSH_KEY];
    _bannerLayoutUpperRightImg.alpha=(int)_bannerOpacitySlider.value/100.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutUpperRightImg] :BANNER_UPPER_RIGHT_PUSH_KEY];
    _bannerLayoutLowerLeftImg.alpha=(int)_bannerOpacitySlider.value/100.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutLowerLeftImg] :BANNER_LOWER_LEFT_PUSH_KEY];
    _bannerLayoutLowerRightImg.alpha=(int)_bannerOpacitySlider.value/100.0;
    [self Save_Images:[self getImageFromView:_bannerLayoutLowerRightImg] :BANNER_LOWER_RIGHT_PUSH_KEY];
}


-(UIImage *)getImageFromView:(UIButton *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)Save_Images:(UIImage *)image :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:UIImagePNGRepresentation(image) forKey:key];
    [defaults synchronize];
}

- (UIImage *)Get_Images:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSData* imageData = [defaults objectForKey:key];
    UIImage* image = [UIImage imageWithData:imageData];
    return image;
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
    [_bannerDurationField resignFirstResponder];
    [_bannerIntervalField resignFirstResponder];
    [_bannerOpacityValue resignFirstResponder];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789%"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
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
