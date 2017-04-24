//
//  SubtitleViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/30.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "SubtitleViewController.h"
#import "CommanParameter.h"
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "RAKAsyncSocket.h"
#import "ImageHelper.h"
#import "decode.h"
#import "AlbumObject.h"
#import "CommanParameters.h"

NSString *subtitleHost=@"POST /acttit.php HTTP/1.1\r\nHost: ";
NSString *subtitleReferer=@"\r\nReferer: http://";
NSString *subtitleLength=@"/test.php\r\nContent-Type: multipart/form-data; boundary=----WebKitFormBoundary9jF0QWJdi6csfpFy\r\nConnection: keep-alive\r\nContent-Length: ";
NSString *subtitleName=@"------WebKitFormBoundary9jF0QWJdi6csfpFy\r\nContent-Disposition: form-data; name=\"titfile\"; filename=\"";
NSString *subtitleHeadEnd=@"\"\r\nContent-Type: image/jpeg\r\n\r\n";
NSString *subtitleAllEnd=@"\r\n------WebKitFormBoundary9jF0QWJdi6csfpFy--\r\n";

@interface SubtitleViewController () <UITextFieldDelegate>
{
    int _enableSubtitle;
    int _x;
    int _y;
    int _opcity;
    int _roll;
    NSString *_base64Word;
    NSString *_bmpPath;
    int _bmpSize;
    RAKAsyncSocket* GCDSocket;//用于建立TCP socket
    NSString *album_name;
    AlbumObject *_albumObject;
}
@end

@implementation SubtitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    self.view.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesForView)];
    [self.view addGestureRecognizer:singleTap0];
    CGFloat minSize=10;
    CGFloat maxSize=72;
    CGFloat curSize=20;
    int colorNum=10;
//    _albumObject=[[AlbumObject alloc]init];
//    [_albumObject delegate:self];
//    album_name=@"FREECAST";
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [_albumObject createAlbumInPhoneAlbum:album_name];
//        _bmpPath=[_albumObject getPathForRecord:album_name];
//        _bmpPath=[NSString stringWithFormat:@"%@/title.bmp",_bmpPath];
//        NSLog(@"_bmpPath=%@",_bmpPath);
//        UIImage *image=[UIImage imageNamed:@"title.bmp"];
//        [_albumObject saveImageToAlbum:image albumName:album_name];
//    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                             name:UIKeyboardWillHideNotification object:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *tmpPath = [path stringByAppendingPathComponent:@"temp"];
    NSLog(@"tmpPath=%@",tmpPath);
    if (![self isFileExistAtPath:tmpPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    _bmpPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"title.bmp"]];
    NSLog(@"_bmpPath=%@",_bmpPath);
    
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
    _titleLabel.text = NSLocalizedString(@"subtitle_title", nil);
    _titleLabel.font = [UIFont boldSystemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    ;

    //Display btn
    _subtitleDisplayView=[[UIView alloc]initWithFrame:CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height,viewW,viewH*44/totalHeight)];
    _subtitleDisplayView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_subtitleDisplayView];
    
    _subtitleDisplayLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height, viewW*150/totalWeight, viewH*44/totalHeight)];
    _subtitleDisplayLabel.text = NSLocalizedString(@"subtitle_display", nil);
    _subtitleDisplayLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _subtitleDisplayLabel.backgroundColor = [UIColor clearColor];
    _subtitleDisplayLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _subtitleDisplayLabel.lineBreakMode = UILineBreakModeWordWrap;
    _subtitleDisplayLabel.textAlignment=UITextAlignmentLeft;
    _subtitleDisplayLabel.numberOfLines = 0;
    [self.view addSubview:_subtitleDisplayLabel];
    
    _subtitleDisplayBtn= [[UISwitch alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height,viewW*51/totalWeight, viewH*31/totalHeight)];
    _subtitleDisplayBtn.center=CGPointMake(viewW*342/totalWeight, _subtitleDisplayLabel.center.y);
    _subtitleDisplayBtn.on = NO;
    _subtitleDisplayBtn.onTintColor =MAIN_COLOR;
    [_subtitleDisplayBtn addTarget:self action:@selector(_subtitleDisplayBtnAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_subtitleDisplayBtn];
    

    //Display Type
    _subtitleTypeView=[[UIView alloc]initWithFrame:CGRectMake(0,_subtitleDisplayView.frame.origin.y+_subtitleDisplayView.frame.size.height+viewH*20/totalHeight,viewW,viewH*44/totalHeight)];
    _subtitleTypeView.userInteractionEnabled=YES;
    CAGradientLayer *_gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
    _gradientLayer.bounds = _subtitleTypeView.bounds;
    _gradientLayer.borderWidth = 0;
    _gradientLayer.frame = _subtitleTypeView.bounds;
    _gradientLayer.colors = [NSArray arrayWithObjects:
                             (id)[[UIColor colorWithRed:237/255.0 green:238/255.0 blue:240/255.0 alpha:1.0] CGColor],
                             (id)[[UIColor whiteColor] CGColor], nil,nil];
    _gradientLayer.startPoint = CGPointMake(0.5, 1.0);
    _gradientLayer.endPoint = CGPointMake(0.5, 0.5);
    [_subtitleTypeView.layer insertSublayer:_gradientLayer atIndex:0];
    [self.view addSubview:_subtitleTypeView];

    _subtitleTypeSizeImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream banner_Fonts size_icon@3x.png"]];
    _subtitleTypeSizeImg.frame = CGRectMake(viewW*17/totalWeight, viewH*10/totalHeight, viewH*87*24/totalHeight/75, viewH*24/totalHeight);
    _subtitleTypeSizeImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTapTypeSize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_subtitleTypeSizeBtnClick)];
    [_subtitleTypeSizeImg addGestureRecognizer:singleTapTypeSize];
    _subtitleTypeSizeImg.contentMode=UIViewContentModeScaleToFill;
    [_subtitleTypeView addSubview:_subtitleTypeSizeImg];
    
    _subtitleTypeSizeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _subtitleTypeSizeBtn.frame = CGRectMake(viewW*52/totalWeight, viewH*10/totalHeight, viewW*50/totalWeight, viewH*24/totalHeight);
    [_subtitleTypeSizeBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _subtitleTypeSizeBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleTypeSizeBtn.backgroundColor=[UIColor whiteColor];
    _subtitleTypeSizeBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_subtitleTypeSizeBtn setTitle:@"20pt" forState:UIControlStateNormal];
    [_subtitleTypeSizeBtn addTarget:nil action:@selector(_subtitleTypeSizeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_subtitleTypeView  addSubview:_subtitleTypeSizeBtn];
    
    UIView *line1=[[UIView alloc]init];
    line1.frame=CGRectMake(viewW*118/totalWeight, 0, 1, viewH*44/totalHeight);
    line1.backgroundColor= [UIColor colorWithRed:219/255.0 green:220/255.0 blue:233/255.0 alpha:1.0];
    [_subtitleTypeView  addSubview:line1];
    
    _subtitleTypeColorImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream banner_Fonts color_icon@3x.png"]];
    _subtitleTypeColorImg.frame = CGRectMake(viewW*133/totalWeight, viewH*10/totalHeight, viewH*84*23/totalHeight/72, viewH*23/totalHeight);
    _subtitleTypeColorImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTapTypeColor = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_subtitleTypeColorBtnClick)];
    [_subtitleTypeColorImg addGestureRecognizer:singleTapTypeColor];
    _subtitleTypeColorImg.contentMode=UIViewContentModeScaleToFill;
    [_subtitleTypeView addSubview:_subtitleTypeColorImg];
    
    _subtitleTypeColorBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _subtitleTypeColorBtn.frame = CGRectMake(viewW*175/totalWeight, viewH*13/totalHeight, viewW*32/totalWeight, viewH*18/totalHeight);
    _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _subtitleTypeColorBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_subtitleTypeColorBtn addTarget:nil action:@selector(_subtitleTypeColorBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_subtitleTypeView  addSubview:_subtitleTypeColorBtn];
    
    UIView *line2=[[UIView alloc]init];
    line2.frame=CGRectMake(viewW*228/totalWeight, 0, 1, viewH*44/totalHeight);
    line2.backgroundColor= [UIColor colorWithRed:219/255.0 green:220/255.0 blue:233/255.0 alpha:1.0];
    [_subtitleTypeView  addSubview:line2];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_subtitleTypeFixedClick)];
    
    subtitleTypeFixedLabel=[UIButton buttonWithType:UIButtonTypeCustom];
    subtitleTypeFixedLabel.frame = CGRectMake(viewW*236/totalWeight,viewH*13/totalHeight, viewW*34/totalWeight, viewH*17/totalHeight);
    subtitleTypeFixedLabel.backgroundColor=[UIColor clearColor];
    subtitleTypeFixedLabel.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [subtitleTypeFixedLabel addTarget:nil action:@selector(_subtitleTypeFixedClick) forControlEvents:UIControlEventTouchUpInside];
    [subtitleTypeFixedLabel setTitle:NSLocalizedString(@"subtitle_fixed", nil) forState:UIControlStateNormal];
    [subtitleTypeFixedLabel setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:0.4] forState:UIControlStateNormal];
    subtitleTypeFixedLabel.titleLabel.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    [_subtitleTypeView  addSubview:subtitleTypeFixedLabel];
    
    subtitleTypeFixedImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_nora@3x.png"]];
    subtitleTypeFixedImg.userInteractionEnabled=YES;
    subtitleTypeFixedImg.frame = CGRectMake(viewW*272/totalWeight, viewH*10/totalHeight, viewH*23/totalHeight, viewH*23/totalHeight);
    subtitleTypeFixedImg.contentMode=UIViewContentModeScaleToFill;
    [subtitleTypeFixedImg addGestureRecognizer:singleTap];
    [_subtitleTypeView addSubview:subtitleTypeFixedImg];
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_subtitleTypeRollClick)];
    subtitleTypeRollLabel=[UIButton buttonWithType:UIButtonTypeCustom];
    subtitleTypeRollLabel.frame = CGRectMake(viewW*309/totalWeight,viewH*13/totalHeight, viewW*34/totalWeight, viewH*17/totalHeight);
    subtitleTypeRollLabel.backgroundColor=[UIColor clearColor];
    subtitleTypeRollLabel.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [subtitleTypeRollLabel addTarget:nil action:@selector(_subtitleTypeRollClick) forControlEvents:UIControlEventTouchUpInside];
    [subtitleTypeRollLabel setTitle:NSLocalizedString(@"subtitle_roll", nil) forState:UIControlStateNormal];
    [subtitleTypeRollLabel setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:0.4] forState:UIControlStateNormal];
    subtitleTypeRollLabel.titleLabel.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    [_subtitleTypeView  addSubview:subtitleTypeRollLabel];
    
    subtitleTypeRollImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_nor@3x.png"]];
    subtitleTypeRollImg.frame = CGRectMake(viewW*338/totalWeight, viewH*11/totalHeight, viewH*19*93/totalHeight/60, viewH*19/totalHeight);
    subtitleTypeRollImg.userInteractionEnabled=YES;
    [subtitleTypeRollImg addGestureRecognizer:singleTap2];
    subtitleTypeRollImg.contentMode=UIViewContentModeScaleToFill;
    [_subtitleTypeView addSubview:subtitleTypeRollImg];
    
    _subtitleTextView=[[UIView alloc]initWithFrame:CGRectMake(0,_subtitleTypeView.frame.origin.y+_subtitleTypeView.frame.size.height,viewW,viewH*144/totalHeight)];
    _subtitleTextView.userInteractionEnabled=YES;
    _subtitleTextView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_subtitleTextView];
    
    _subtitleTextField=[[UITextField alloc]init];
    _subtitleTextField.frame=CGRectMake(viewW*123/totalWeight,viewH*110/totalHeight, 100, 100);
    _subtitleTextField.center=CGPointMake(_subtitleTextView.frame.size.width*0.5, _subtitleTextView.frame.size.height*0.5);
    //[_subtitleTextField addTarget:self  action:@selector(_subtitleTextFieldChanged)  forControlEvents:UIControlEventAllEditingEvents];
    _subtitleTextField.font=[UIFont systemFontOfSize: viewH*curSize/totalHeight];
    _subtitleTextField.textColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    //_subtitleTextField.delegate=self;
    [_subtitleTextField addTarget:self action:@selector(_subtitleTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _subtitleTextField.backgroundColor = [UIColor whiteColor];
    _subtitleTextField.textAlignment=UITextAlignmentCenter;
    _subtitleTextField.text=NSLocalizedString(@"subtitle_text", nil);
    [_subtitleTextView addSubview:_subtitleTextField];

    subtitleTypeTipsLabel= [[UILabel alloc] initWithFrame:CGRectMake(0,_subtitleTextView.frame.origin.y+_subtitleTextView.frame.size.height, viewW, viewH*30/totalHeight)];
    subtitleTypeTipsLabel.text = NSLocalizedString(@"subtitle_tips", nil);
    subtitleTypeTipsLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    subtitleTypeTipsLabel.backgroundColor = [UIColor clearColor];
    subtitleTypeTipsLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:0.4];
    subtitleTypeTipsLabel.lineBreakMode = UILineBreakModeWordWrap;
    subtitleTypeTipsLabel.textAlignment=UITextAlignmentCenter;
    subtitleTypeTipsLabel.numberOfLines = 0;
    [self.view addSubview:subtitleTypeTipsLabel];
    
    //Settings
    _subtitleSettingsView=[[UIView alloc]initWithFrame:CGRectMake(0,subtitleTypeTipsLabel.frame.origin.y+subtitleTypeTipsLabel.frame.size.height,viewW,viewH*53/totalHeight)];
    //CGRectMake(0,subtitleTypeTipsLabel.frame.origin.y+subtitleTypeTipsLabel.frame.size.height,viewW,viewH*160/totalHeight)];
    _subtitleSettingsView.userInteractionEnabled=YES;
    _subtitleSettingsView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_subtitleSettingsView];
    
    _subtitleDurationLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*22/totalWeight,viewH*14/totalHeight, viewW*112/totalWeight, viewH*32/totalHeight)];
    _subtitleDurationLabel.text = NSLocalizedString(@"subtitle_duration", nil);
    _subtitleDurationLabel.font = [UIFont boldSystemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleDurationLabel.backgroundColor = [UIColor clearColor];
    _subtitleDurationLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _subtitleDurationLabel.lineBreakMode = UILineBreakModeWordWrap;
    _subtitleDurationLabel.textAlignment=UITextAlignmentLeft;
    _subtitleDurationLabel.numberOfLines = 0;
    //[_subtitleSettingsView addSubview:_subtitleDurationLabel];
    
    _subtitleDurationField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*180/totalWeight, viewH*14/totalHeight, viewW*119/totalWeight, viewH*32/totalHeight)];
    _subtitleDurationField.text = @"5";
    [_subtitleDurationField addTarget:self action:@selector(_subtitleDurationFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _subtitleDurationField.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleDurationField.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    _subtitleDurationField.textColor = MAIN_COLOR;
    _subtitleDurationField.delegate=self;
    _subtitleDurationField.textAlignment=UITextAlignmentCenter;
    //[_subtitleSettingsView addSubview:_subtitleDurationField];
    
    _subtitleDurationKit=[[UILabel alloc] initWithFrame:CGRectMake(viewW*307/totalWeight,viewH*14/totalHeight, viewW*58/totalWeight, viewH*32/totalHeight)];
    _subtitleDurationKit.text = NSLocalizedString(@"subtitle_seconds", nil);
    _subtitleDurationKit.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleDurationKit.backgroundColor = [UIColor clearColor];
    _subtitleDurationKit.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _subtitleDurationKit.lineBreakMode = UILineBreakModeWordWrap;
    _subtitleDurationKit.textAlignment=UITextAlignmentCenter;
    _subtitleDurationKit.numberOfLines = 0;
    //[_subtitleSettingsView addSubview:_subtitleDurationKit];

    _subtitleIntervalLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*22/totalWeight,viewH*66/totalHeight, viewW*112/totalWeight, viewH*32/totalHeight)];
    _subtitleIntervalLabel.text = NSLocalizedString(@"subtitle_interval", nil);
    _subtitleIntervalLabel.font = [UIFont boldSystemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleIntervalLabel.backgroundColor = [UIColor clearColor];
    _subtitleIntervalLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _subtitleIntervalLabel.lineBreakMode = UILineBreakModeWordWrap;
    _subtitleIntervalLabel.textAlignment=UITextAlignmentLeft;
    _subtitleIntervalLabel.numberOfLines = 0;
    //[_subtitleSettingsView addSubview:_subtitleIntervalLabel];
    
    _subtitleIntervalField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*180/totalWeight, viewH*66/totalHeight, viewW*119/totalWeight, viewH*32/totalHeight)];
    _subtitleIntervalField.text = @"10";
    [_subtitleIntervalField addTarget:self action:@selector(_subtitleIntervalFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _subtitleIntervalField.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleIntervalField.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
    _subtitleIntervalField.textColor = MAIN_COLOR;
    _subtitleIntervalField.delegate=self;
    _subtitleIntervalField.textAlignment=UITextAlignmentCenter;
    //[_subtitleSettingsView addSubview:_subtitleIntervalField];
    
    _subtitleIntervalKit=[[UILabel alloc] initWithFrame:CGRectMake(viewW*307/totalWeight,viewH*66/totalHeight, viewW*58/totalWeight, viewH*32/totalHeight)];
    _subtitleIntervalKit.text = NSLocalizedString(@"subtitle_seconds", nil);
    _subtitleIntervalKit.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleIntervalKit.backgroundColor = [UIColor clearColor];
    _subtitleIntervalKit.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _subtitleIntervalKit.lineBreakMode = UILineBreakModeWordWrap;
    _subtitleIntervalKit.textAlignment=UITextAlignmentCenter;
    _subtitleIntervalKit.numberOfLines = 0;
    //[_subtitleSettingsView addSubview:_subtitleIntervalKit];
    
    
    _subtitleOpacityLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewW*22/totalWeight,viewH*14/totalHeight, viewW*53/totalWeight, viewH*25/totalHeight)];
    //CGRectMake(viewW*22/totalWeight,viewH*119/totalHeight, viewW*53/totalWeight, viewH*25/totalHeight)];
    _subtitleOpacityLabel.text = NSLocalizedString(@"subtitle_opacity", nil);
    _subtitleOpacityLabel.font = [UIFont boldSystemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleOpacityLabel.backgroundColor = [UIColor clearColor];
    _subtitleOpacityLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _subtitleOpacityLabel.lineBreakMode = UILineBreakModeWordWrap;
    _subtitleOpacityLabel.textAlignment=UITextAlignmentLeft;
    _subtitleOpacityLabel.numberOfLines = 0;
    [_subtitleSettingsView addSubview:_subtitleOpacityLabel];
    
    _subtitleOpacitySlider= [[UISlider alloc] initWithFrame:CGRectMake(viewW*103/totalWeight, viewH*14/totalHeight, viewW*200/totalWeight, viewH*25/totalHeight)];
    _subtitleOpacitySlider.minimumValue = 0;
    _subtitleOpacitySlider.maximumValue = 128;
    _subtitleOpacitySlider.value = 128;
    _subtitleOpacitySlider.thumbTintColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _subtitleOpacitySlider.minimumTrackTintColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _subtitleOpacitySlider.continuous=YES;
    [_subtitleOpacitySlider addTarget:self action:@selector(_subtitleOpacitySliderValue:) forControlEvents:UIControlEventValueChanged];
    [_subtitleOpacitySlider addTarget:self action:@selector(_subtitleOpacitySliderClick)  forControlEvents:UIControlEventTouchUpInside];
    [_subtitleSettingsView addSubview:_subtitleOpacitySlider];
    
    _subtitleOpacityValue = [[UITextField alloc] initWithFrame:CGRectMake(viewW*311/totalWeight, viewH*14/totalHeight, viewW*44/totalWeight, viewH*25/totalHeight)];
    _subtitleOpacityValue.text = @"100%";
    [_subtitleOpacityValue addTarget:self action:@selector(_subtitleOpacityValueDidChange:) forControlEvents:UIControlEventEditingChanged];
    _subtitleOpacityValue.font = [UIFont systemFontOfSize: viewH*17/totalHeight*0.8];
    _subtitleOpacityValue.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    _subtitleOpacityValue.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _subtitleOpacityValue.delegate=self;
    _subtitleOpacityValue.textAlignment=UITextAlignmentCenter;
    [_subtitleSettingsView addSubview:_subtitleOpacityValue];
    
    //SizePicker
    _subtitleSizePickerView=[[UIView alloc]init];
    _subtitleSizePickerView.frame=CGRectMake(0, viewH*172/totalHeight, ((maxSize-minSize)*40-20)*viewW/totalWeight/2, viewH*37/totalHeight);
    UIPanGestureRecognizer *panGestureRecognizer= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSizePicker:)];
    [_subtitleSizePickerView addGestureRecognizer:panGestureRecognizer];
    _subtitleSizePickerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_subtitleSizePickerView];
    
    UIView *lineSizePicker=[[UIView alloc]init];
    lineSizePicker.frame=CGRectMake(0, viewH*36/totalHeight, _subtitleSizePickerView.frame.size.width, viewH*1/totalHeight);
    lineSizePicker.backgroundColor= [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    [_subtitleSizePickerView addSubview:lineSizePicker];
    
    for(int i=0;i<=(maxSize-minSize)/2;i++){
        UIButton *_sizePickerBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _sizePickerBtn.frame = CGRectMake(viewW*40*i/totalWeight, viewH*9/totalHeight, viewW*20/totalWeight, viewH*20/totalHeight);
        _sizePickerBtn.tag=(int)(minSize+2*i);
        [_sizePickerBtn setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0]forState:UIControlStateNormal];
        [_sizePickerBtn setTitleColor:MAIN_COLOR forState:UIControlStateHighlighted];
        _sizePickerBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
        _sizePickerBtn.backgroundColor=[UIColor whiteColor];
        _sizePickerBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        [_sizePickerBtn setTitle:[NSString stringWithFormat:@"%d",(int)(minSize+2*i)] forState:UIControlStateNormal];
        [_sizePickerBtn addTarget:nil action:@selector(_sizePickerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_subtitleSizePickerView  addSubview:_sizePickerBtn];
    }
    _subtitleSizePickerView.hidden=YES;
    
    //Color
    _subtitleColorPickerView=[[UIView alloc]init];
    _subtitleColorPickerView.frame=CGRectMake(0, viewH*172/totalHeight, (colorNum*52)*viewW/totalWeight, viewH*37/totalHeight);
    UIPanGestureRecognizer *panGestureRecognizer2= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panColorPicker:)];
    [_subtitleColorPickerView addGestureRecognizer:panGestureRecognizer2];
    _subtitleColorPickerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_subtitleColorPickerView];
    
    UIView *lineColorPicker=[[UIView alloc]init];
    lineColorPicker.frame=CGRectMake(0, viewH*36/totalHeight, _subtitleSizePickerView.frame.size.width, viewH*1/totalHeight);
    lineColorPicker.backgroundColor= [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    [_subtitleColorPickerView addSubview:lineColorPicker];
    
    for(int i=0;i<=colorNum;i++){
        UIButton *_colorPickerBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _colorPickerBtn.frame = CGRectMake(viewW*52*i/totalWeight, viewH*10/totalHeight, viewW*32/totalWeight, viewH*18/totalHeight);
        _colorPickerBtn.tag=i;
        switch (i) {
            case 0:
                _colorPickerBtn.backgroundColor=[UIColor blackColor];
                break;
            case 1:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:252/255.0 green:49/255.0 blue:88/255.0 alpha:1.0];
                break;
            case 2:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:253/255.0 green:149/255.0 blue:39/255.0 alpha:1.0];
                break;
            case 3:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:254/255.0 green:203/255.0 blue:47/255.0 alpha:1.0];
                break;
            case 4:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:81/255.0 green:215/255.0 blue:106/255.0 alpha:1.0];
                break;
            case 5:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:96/255.0 green:201/255.0 blue:269/255.0 alpha:1.0];
                break;
            case 6:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:6/255.0 green:163/255.0 blue:191/255.0 alpha:1.0];
                break;
            case 7:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:22/255.0 green:168/255.0 blue:150/255.0 alpha:1.0];
                break;
            case 8:
                _colorPickerBtn.backgroundColor=[UIColor colorWithRed:88/255.0 green:91/255.0 blue:211/255.0 alpha:1.0];
                break;
            case 9:
                _colorPickerBtn.backgroundColor=MAIN_COLOR;
                break;
            default:
                break;
        }
        _colorPickerBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        [_colorPickerBtn addTarget:nil action:@selector(_colorPickerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_subtitleColorPickerView  addSubview:_colorPickerBtn];
    }
    _subtitleColorPickerView.hidden=YES;
    
    //Enable
    [NSThread detachNewThreadSelector:@selector(GetSubtitleStatus) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(GetSubtitleFormart) toTarget:self withObject:nil];
    
    if([self Get_Paths:SUBTITLE_SIZE_KEY]!=nil){
        [_subtitleTypeSizeBtn setTitle:[NSString stringWithFormat:@"%@%@",[self Get_Paths:SUBTITLE_SIZE_KEY],@"pt"] forState:UIControlStateNormal];
        _subtitleTextField.font=[UIFont systemFontOfSize: viewH*[[self Get_Paths:SUBTITLE_SIZE_KEY] intValue]/totalHeight];
    }
    else{
        [self Save_Paths:@"20" :SUBTITLE_SIZE_KEY];
    }
    
    if([self Get_Colors:SUBTITLE_COLOR_KEY]!=nil){
        _subtitleTypeColorBtn.backgroundColor=[self Get_Colors:SUBTITLE_COLOR_KEY];
        _subtitleTextField.textColor=[self Get_Colors:SUBTITLE_COLOR_KEY];
    }
    else{
        [self Save_Colors:_subtitleTextField.textColor :SUBTITLE_COLOR_KEY];
    }
    
    if ([self Get_Paths:SUBTITLE_TEXT_KEY]!=nil) {
        _subtitleTextField.text=[self Get_Paths:SUBTITLE_TEXT_KEY];
    }
    else{
        [self Save_Paths:_subtitleTextField.text :SUBTITLE_TEXT_KEY];
    }
    
    if([self Get_Paths:SUBTITLE_DURATION_KEY]!=nil){
        _subtitleDurationField.text=[self Get_Paths:SUBTITLE_DURATION_KEY];
    }
    else{
        [self Save_Paths:_subtitleDurationField.text :SUBTITLE_DURATION_KEY];
    }
    
    if([self Get_Paths:SUBTITLE_INTERVAL_KEY]!=nil){
        _subtitleIntervalField.text=[self Get_Paths:SUBTITLE_INTERVAL_KEY];
    }
    else{
        [self Save_Paths:_subtitleIntervalField.text :SUBTITLE_INTERVAL_KEY];
    }
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

-(BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;  
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_subtitleDisplayBtnAction:(UISwitch*)sender{
    if (sender.on) {
        NSLog(@"on");
        _enableSubtitle=1;
    }
    else{
        NSLog(@"off");
        _enableSubtitle=0;
    }
    [NSThread detachNewThreadSelector:@selector(SetSubtitleStatus) toTarget:self withObject:nil];
}

- (void)_subtitleTypeSizeBtnClick{
    NSLog(@"_subtitleTypeSizeBtnClick");
    if (_subtitleSizePickerView.hidden) {
        _subtitleColorPickerView.hidden=YES;
        [self moveInAnimation];
    }
    else{
       [self revealAnimation];
    }
}

- (void)_subtitleTypeColorBtnClick{
    NSLog(@"_subtitleTypeColorBtnClick");
    if (_subtitleColorPickerView.hidden) {
        _subtitleSizePickerView.hidden=YES;
        [self moveInAnimation2];
    }
    else{
        [self revealAnimation2];
    }
}

- (void)touchesForView{
    NSLog(@"touchesForView");
    if (!_subtitleSizePickerView.hidden) {
        [self revealAnimation];
    }
    if (!_subtitleColorPickerView.hidden) {
        [self revealAnimation2];
    }
}

/**
 *  移入效果
 */
-(void)moveInAnimation{
    _subtitleSizePickerView.hidden=NO;
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionMoveIn;//设置动画的类型
    anima.subtype = kCATransitionFromBottom; //设置动画的方向
    anima.duration = 0.3f;
    [_subtitleSizePickerView.layer addAnimation:anima forKey:@"moveInAnimation"];
}

/**
 *  移出效果
 */
-(void)revealAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        CATransition *anima = [CATransition animation];
        anima.type = kCATransitionReveal;//设置动画的类型
        anima.subtype = kCATransitionFromTop; //设置动画的方向
        anima.duration = 0.3f;
        [_subtitleSizePickerView.layer addAnimation:anima forKey:@"revealAnimation"];
    } completion:^(BOOL finished) {
        _subtitleSizePickerView.hidden=YES;
    }];
}

/**
 *  移入效果
 */
-(void)moveInAnimation2{
    _subtitleColorPickerView.hidden=NO;
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionMoveIn;//设置动画的类型
    anima.subtype = kCATransitionFromBottom; //设置动画的方向
    anima.duration = 0.3f;
    [_subtitleColorPickerView.layer addAnimation:anima forKey:@"moveInAnimation"];
}

/**
 *  移出效果
 */
-(void)revealAnimation2{
    [UIView animateWithDuration:0.3 animations:^{
        CATransition *anima = [CATransition animation];
        anima.type = kCATransitionReveal;//设置动画的类型
        anima.subtype = kCATransitionFromTop; //设置动画的方向
        anima.duration = 0.3f;
        [_subtitleColorPickerView.layer addAnimation:anima forKey:@"revealAnimation"];
    } completion:^(BOOL finished) {
        _subtitleColorPickerView.hidden=YES;
    }];
}

- (void)_subtitleTypeFixedClick{
    NSLog(@"_subtitleTypeFixedClick");
    [subtitleTypeRollLabel setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:0.4] forState:UIControlStateNormal];
    subtitleTypeFixedImg.image=[UIImage imageNamed:@"subtitle_Fonts fixed_icon_sel@3x.png"];
    [subtitleTypeFixedLabel setTitleColor:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
    subtitleTypeRollImg.image=[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_nor@3x.png"];
    _roll=0;
    [NSThread detachNewThreadSelector:@selector(SetSubtitleFormart) toTarget:self withObject:nil];
}

- (void)_subtitleTypeRollClick{
    NSLog(@"_subtitleTypeRollClick");
    [subtitleTypeFixedLabel setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:0.4] forState:UIControlStateNormal];
    subtitleTypeFixedImg.image=[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_nora@3x.png"];
    [subtitleTypeRollLabel setTitleColor:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
    subtitleTypeRollImg.image=[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_sel@3x.png"];
    _roll=1;
    [NSThread detachNewThreadSelector:@selector(SetSubtitleFormart) toTarget:self withObject:nil];
}

- (void)_subtitleTextFieldDidChange:(UITextField *) TextField{
    _subtitleTextField.text=TextField.text;
    [self Save_Paths:TextField.text :SUBTITLE_TEXT_KEY];
    //[self getImageFromView:_subtitleTextField];
    //[self Save_Images:[self getImageFromView:_subtitleTextField] :SUBTITLE_PHOTO_PUSH_KEY];
}

- (void)_subtitleOpacitySliderValue:(UISlider*)slider{
    _subtitleOpacityValue.text= [NSString stringWithFormat:@"%d%@",(int)slider.value*100/128,@"%"];
    _subtitleTextField.alpha=(int)_subtitleOpacitySlider.value/128.0;
    _opcity=_subtitleOpacitySlider.value;
}

- (void)_subtitleOpacitySliderClick{
    NSLog(@"_subtitleOpacitySliderClick");
    [NSThread detachNewThreadSelector:@selector(SetSubtitleFormart) toTarget:self withObject:nil];
}

- (void)_subtitleDurationFieldDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        [self showAllTextDialog:NSLocalizedString(@"duration_value_empty", nil)];
        return;
    }
    [self Save_Paths:TextField.text :SUBTITLE_DURATION_KEY];
}

- (void)_subtitleIntervalFieldDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        [self showAllTextDialog:NSLocalizedString(@"interval_value_empty", nil)];
        return;
    }
    [self Save_Paths:TextField.text :SUBTITLE_INTERVAL_KEY];
}

- (void)_subtitleOpacityValueDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        [self showAllTextDialog:NSLocalizedString(@"opacity_value_empty", nil)];
        return;
    }
    NSString *value=[TextField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    _subtitleOpacitySlider.value=[value intValue];
    [self Save_Paths:value :SUBTITLE_OPACITY_KEY];
    _subtitleTextField.alpha=(int)_subtitleOpacitySlider.value/100.0;
    [self getImageFromView:_subtitleTextField];
    //[self Save_Images:[self getImageFromView:_subtitleTextField] :SUBTITLE_PHOTO_PUSH_KEY];
}

- (void)_sizePickerBtnClick:(UIButton*)button{
    _subtitleTextField.font=[UIFont systemFontOfSize: viewH*button.tag/totalHeight];
    [_subtitleTypeSizeBtn setTitle:[NSString stringWithFormat:@"%dpt",(int)button.tag] forState:UIControlStateNormal];
    [self Save_Paths:[NSString stringWithFormat:@"%d",(int)button.tag] :SUBTITLE_SIZE_KEY];
    [self getImageFromView:_subtitleTextField];
    //[self Save_Images:[self getImageFromView:_subtitleTextField] :SUBTITLE_PHOTO_PUSH_KEY];
}

- (void) panSizePicker:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        if (((view.center.x + translation.x)>=(viewW-view.frame.size.width*0.5))&&((view.center.x + translation.x)<=view.frame.size.width*0.5)){
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
        //        NSLog(@"translation.x==>%f",translation.x);
        //        NSLog(@"translation.y==>%f",translation.y);
    }
}

- (void)_colorPickerBtnClick:(UIButton*)button{
    switch (button.tag) {
        case 0:
            _subtitleTypeColorBtn.backgroundColor=[UIColor blackColor];
            _subtitleTextField.textColor=[UIColor blackColor];
            break;
        case 1:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:252/255.0 green:49/255.0 blue:88/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:252/255.0 green:49/255.0 blue:88/255.0 alpha:1.0];
            break;
        case 2:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:253/255.0 green:149/255.0 blue:39/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:253/255.0 green:149/255.0 blue:39/255.0 alpha:1.0];
            break;
        case 3:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:254/255.0 green:203/255.0 blue:47/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:254/255.0 green:203/255.0 blue:47/255.0 alpha:1.0];
            break;
        case 4:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:81/255.0 green:215/255.0 blue:106/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:81/255.0 green:215/255.0 blue:106/255.0 alpha:1.0];
            break;
        case 5:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:96/255.0 green:201/255.0 blue:269/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:96/255.0 green:201/255.0 blue:269/255.0 alpha:1.0];
            break;
        case 6:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:6/255.0 green:163/255.0 blue:191/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:6/255.0 green:163/255.0 blue:191/255.0 alpha:1.0];
            break;
        case 7:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:22/255.0 green:168/255.0 blue:150/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:22/255.0 green:168/255.0 blue:150/255.0 alpha:1.0];
            break;
        case 8:
            _subtitleTypeColorBtn.backgroundColor=[UIColor colorWithRed:88/255.0 green:91/255.0 blue:211/255.0 alpha:1.0];
            _subtitleTextField.textColor=[UIColor colorWithRed:88/255.0 green:91/255.0 blue:211/255.0 alpha:1.0];
            break;
        case 9:
            _subtitleTypeColorBtn.backgroundColor=MAIN_COLOR;
            _subtitleTextField.textColor=MAIN_COLOR;
            break;
        default:
            break;
    }
    [self Save_Colors:_subtitleTextField.textColor :SUBTITLE_COLOR_KEY];
    [self getImageFromView:_subtitleTextField];
    //[self Save_Images:[self getImageFromView:_subtitleTextField] :SUBTITLE_PHOTO_PUSH_KEY];
}

- (void) panColorPicker:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        if (((view.center.x + translation.x)>=(viewW-view.frame.size.width*0.5))&&((view.center.x + translation.x)<=view.frame.size.width*0.5)){
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
        //        NSLog(@"translation.x==>%f",translation.x);
        //        NSLog(@"translation.y==>%f",translation.y);
    }
}

-(UIImage *)imageFromText:(UITextField*)textField  withFont: (CGFloat)fontSize
{
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    UIGraphicsBeginImageContextWithOptions(textField.frame.size,NO,0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetCharacterSpacing(ctx, 10);
    CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
    CGContextSetRGBFillColor (ctx, 0.1, 0.2, 0.3, 1); // 6
    CGContextSetRGBStrokeColor (ctx, 0, 0, 0, 1);
    
    [textField.text drawInRect:textField.frame withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark-- 获取字幕使能状态
-(void)GetSubtitleStatus{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_subtitle_enable",_ip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *_value=[self parseJsonString:http_request.ResponseString];
            if (([_value compare:@"1"] == NSOrderedSame)) {
                _subtitleDisplayBtn.on=YES;
            }
            else{
                _subtitleDisplayBtn.on=NO;
            }
        });
    }
}

#pragma mark-- 设置字幕使能状态 0:不使能  1:使能
-(void)SetSubtitleStatus{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_subtitle_enable&pipe=0&value=%d",_ip,80,_enableSubtitle];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *value=[self parseJsonString2:http_request.ResponseString :@"\"info\":\""];
            if ([value compare:@"suc"]==NSOrderedSame) {
                
            }
            else{
                if (_enableSubtitle==1) {
                    _subtitleDisplayBtn.on=NO;
                }
                else{
                    _subtitleDisplayBtn.on=YES;
                }
                [self showAllTextDialog:NSLocalizedString(@"settings_failed", nil)];
            }
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_enableSubtitle==1) {
                _subtitleDisplayBtn.on=NO;
            }
            else{
                _subtitleDisplayBtn.on=YES;
            }
            [self showAllTextDialog:NSLocalizedString(@"settings_failed", nil)];
        });
    }
}

#pragma mark-- 获取字幕显示位置／透明度／滚动状态
-(void)GetSubtitleFormart
{
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=get_subtitle_pos",_ip,80];
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"POST" andUserName:@"admin" andPassword:@"admin"];
    NSLog(@"====>%@",http_request.ResponseString);
    if(http_request.StatusCode==200)
    {
        //{"x":"1920","y":"-0","opcity":"-128","roll":"1"}
        dispatch_async(dispatch_get_main_queue(), ^{
            _x=[[self parseJsonString2:http_request.ResponseString :@"\"x\":\""] intValue];
            _y=[[self parseJsonString2:http_request.ResponseString :@"\"y\":\""] intValue];
            _opcity=abs([[self parseJsonString2:http_request.ResponseString :@"\"opcity\":\""] intValue]);
            _roll=[[self parseJsonString2:http_request.ResponseString :@"\"roll\":\""] intValue];
            if(_roll==0){
                [subtitleTypeRollLabel setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:0.4] forState:UIControlStateNormal];
                subtitleTypeFixedImg.image=[UIImage imageNamed:@"subtitle_Fonts fixed_icon_sel@3x.png"];
                [subtitleTypeFixedLabel setTitleColor:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
                subtitleTypeRollImg.image=[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_nor@3x.png"];
            }
            else if(_roll==1){
                [subtitleTypeFixedLabel setTitleColor:[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:0.4] forState:UIControlStateNormal];
                subtitleTypeFixedImg.image=[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_nora@3x.png"];
                [subtitleTypeRollLabel setTitleColor:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
                subtitleTypeRollImg.image=[UIImage imageNamed:@"stream_banner_Fonts fixed_icon_sel@3x.png"];
            }
            _subtitleOpacityValue.text=[NSString stringWithFormat:@"%d%@",_opcity*100/128,@"%"];
            _subtitleOpacitySlider.value=_opcity;
            _subtitleTextField.alpha=_subtitleOpacitySlider.value/128.0;
        });
    }
}

#pragma mark-- 设置字幕显示位置／透明度／滚动状态
-(void)SetSubtitleFormart
{
    int x,y;
    x=_x;y=30;
//    if (x==1920) {
//        y=1080;
//    }
//    else if (x==1080) {
//        y=720;
//    }
//    else if (x==640) {
//        y=480;
//    }
//    else if (x==480) {
//        y=320;
//    }
//    else{
//        y=720;
//    }
    if (_roll==0) {
        x=_x/2;
    }
    else{
        x=_x;
    }
//    
//    y=_y-_subtitleTextField.frame.size.height-20;
    
    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%d/server.command?command=set_subtitle_pos&pipe=0&x=%d&y=%d&opcity=%d&roll=%d",_ip,80,x,y,_opcity,_roll];
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

#pragma mark-- 设置字幕文字内容
-(void)SetSubtitleText
{
    GCDSocket = [[RAKAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];//建立与设备 TCP 80端口连接，用于串口透传数据发送与接收
    NSError *err;
    [GCDSocket connectToHost:_ip onPort:80 error:&err];
    if (err != nil){
        NSLog(@"error = %@",err);
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showAllTextDialog:NSLocalizedString(@"upgrade_firmware_failed_connect", nil)];
        });
    }
    else{
        [GCDSocket readDataWithTimeout:-1 tag:0];
        //int bin_len=(int)_base64Word.length;
        int bin_len=_bmpSize;
        int count=0;
        NSString *topStream=[NSString stringWithFormat:@"%@%@%@",subtitleName, @"123.bmp",subtitleHeadEnd];
        //NSLog(@"topStream==%@",topStream);
        NSString *bottomStream=subtitleAllEnd;
        int send_len=bin_len+(int)topStream.length+(int)bottomStream.length;
        NSString *HeadStream=[NSString stringWithFormat:@"%@%@%@%@%@%d\r\nAccept: */*\r\n\r\n%@",subtitleHost,_ip,subtitleReferer,_ip,subtitleLength,send_len,topStream];
        NSLog(@"HeadStream=%@",HeadStream);
        
        //发送头
        [GCDSocket writeData:[HeadStream dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:100];
        //NSData* data = [_base64Word dataUsingEncoding:NSUTF8StringEncoding];
        NSData *data;
//        NSArray *aArray = [@"3333.bmp" componentsSeparatedByString:@"."];
//        NSString *filename = [aArray objectAtIndex:0];
//        NSString *sufix = [aArray objectAtIndex:1];
//        NSString *imagePath = [[NSBundle mainBundle] pathForResource:filename ofType:sufix];
//        const char* const g_pszFilePath = [imagePath UTF8String];
//        FILE * pFile = fopen(g_pszFilePath, "rb");

        FILE * pFile = fopen([_bmpPath UTF8String], "rb");
        
        if(NULL != pFile)
        {
            void*pBuffer = malloc(_bmpSize);
            if (NULL != pBuffer)
            {
                fseek(pFile , 0, SEEK_SET);
                fread(pBuffer, 1, _bmpSize, pFile);
                fclose(pFile);
                //memset(pBuffer + BMP_HEADER_LENGTH,0, BMP_SIZE);
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
        if(data.length > 0){
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
    int value=0;
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
    [_subtitleTextField resignFirstResponder];
    [_subtitleDurationField resignFirstResponder];
    [_subtitleIntervalField resignFirstResponder];
    [_subtitleOpacityValue resignFirstResponder];
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
    NSLog(@"textFieldShouldEndEditing");
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

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(UIImage *)getImageFromView:(UITextField *)view{
    [_subtitleTextField resignFirstResponder];
    UIGraphicsBeginImageContextWithOptions(view.frame.size,YES, view.layer.contentsScale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"width==%d",(int)image.size.width);
    NSLog(@"height==%d",(int)image.size.height);
    float scale=(int)image.size.height;
    if ((int)image.size.width>(int)image.size.height) {
        scale=(int)image.size.width;
    }
    image=[self scaleImage:image toScale:100.0/scale];
    NSLog(@"width==%d",(int)image.size.width);
    NSLog(@"height==%d",(int)image.size.height);
    //Create a bitmap
    //NSString *path = (NSString*)[[NSBundle mainBundle] pathForResource:@"22" ofType:@"jpg"];
    //UIImage *newImage = [UIImage imageWithContentsOfFile:path];
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
    _bmpSize=bmp_write(bitmap, image.size.width, image.size.height, (char *)[_bmpPath UTF8String]);
    //_base64Word = [NSString stringWithUTF8String:(const char *)bitmap];
    //Cleanup
    free(bitmap);
    //NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    //_base64Word = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //NSLog(@"_base64Word==%@",_base64Word);
    
/*
    NSArray *aArray = [@"22.jpg" componentsSeparatedByString:@"."];
    NSString *filename = [aArray objectAtIndex:0];
    NSString *sufix = [aArray objectAtIndex:1];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:filename ofType:sufix];
    char *jpgPath=(char *)[imagePath UTF8String];
    _bmpSize=jpg2bmp(jpgPath,(char *)[_bmpPath UTF8String]);
*/
    //NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"22.jpg"], 0.5f);
    //unsigned char *jpgData=(unsigned char *)[data bytes];
    //_bmpSize=bmp_write(jpgData, 100, 100, (char *)[_bmpPath UTF8String]);
    NSLog(@"_bmpSize=%d",_bmpSize);
    if (_bmpSize>0) {
        [NSThread detachNewThreadSelector:@selector(SetSubtitleFormart) toTarget:self withObject:nil];
        [NSThread detachNewThreadSelector:@selector(SetSubtitleText) toTarget:self withObject:nil];
    }
    else{
        
    }
    return image;
}

- (void)saveImageToAlbum:(BOOL)success{

}

- (void)Save_Colors:(UIColor *)color :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSData *foregndcolorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [defaults setObject:foregndcolorData forKey:key];
    [defaults synchronize];
}

- (UIColor *)Get_Colors:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSData *foregroundcolorData = [defaults objectForKey:key];
    UIColor* color =[NSKeyedUnarchiver unarchiveObjectWithData:foregroundcolorData];
    return color;
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

-(void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboardWillBeHidden");
    [self getImageFromView:_subtitleTextField];
}



@end
