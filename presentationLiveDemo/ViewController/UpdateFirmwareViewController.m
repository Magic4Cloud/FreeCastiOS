//
//  UpdateFirmwareViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/24.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "UpdateFirmwareViewController.h"
#import "CommanParameter.h"
#import "HttpRequest.h"
#import "ProgressView.h"
#import "Rak_Lx52x_Device_Control.h"
#import "MBProgressHUD.h"
#import "Brett.h"

NSTimer* RunProgress = nil;
ProgressView *progress = nil;
CGFloat progressTime=100.0;
NSString *postHost=@"POST /actup.php HTTP/1.1\r\nHost: ";
NSString *postReferer=@"\r\nReferer: http://";
NSString *postLength=@"/up.php\r\nContent-Type: multipart/form-data; boundary=----WebKitFormBoundary9jF0QWJdi6csfpFy\r\nConnection: keep-alive\r\nContent-Length: ";
NSString *postName=@"------WebKitFormBoundary9jF0QWJdi6csfpFy\r\nContent-Disposition: form-data; name=\"upfile\"; filename=\"";
NSString *postHeadEnd=@"\"\r\nContent-Type: application/octet-stream\r\n\r\n";
NSString *postPath=@"\r\n------WebKitFormBoundary9jF0QWJdi6csfpFy\r\nContent-Disposition: form-data; name=\"path\"\r\n\r\n";
NSString *postAllEnd=@"\r\n------WebKitFormBoundary9jF0QWJdi6csfpFy--\r\n";

NSString *postVerHost=@"POST /actbk.php HTTP/1.1\r\nHost: ";
NSString *postVerReferer=@"\r\nContent-Type: application/x-www-form-urlencoded; charset=UTF-8\r\nReferer: http://";
NSString *postVerLength=@"/init.php\r\nConnection: keep-alive\r\nContent-Length: ";
NSString *postVerVersion=@"cmdtype=5&param=WXXXXXX0000000000%2C";

@interface UpdateFirmwareViewController ()
{
    bool _Exit;
    bool _isFound;
    bool _isUpdte;
    NSString* url;
    NSString *homeDir;
    NSArray *paths;
    NSString *docDir;
    NSMutableArray *fileName;
    NSMutableArray *filePath;
    RAKAsyncSocket* GCDSocket;//用于建立TCP socket
    int updatePort;
    NSString* updateIP;
    CGFloat viewH;
    CGFloat viewW;
    CGFloat totalHeight;
    CGFloat totalWeight;
}
@end

@implementation UpdateFirmwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isFound=NO;
    _isUpdte=NO;
    _Exit=NO;
    filePath=[[NSMutableArray alloc]init];
    fileName=[[NSMutableArray alloc]init];
    url=@"https://pan.baidu.com/s/1o80cPIi";
    //测试连接
//    url = @"https://pan.baidu.com/s/1pLjZfqb";
    updatePort=80;
    updateIP=@"192.168.100.100";
    homeDir = NSHomeDirectory();
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    docDir = [paths objectAtIndex:0];
    
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
    viewH=self.view.frame.size.height;
    viewW=self.view.frame.size.width;
    totalHeight=64+71+149+149+149+80+5;//各部分比例
    totalWeight=375;//各部分比例
    
    //顶部
    _topBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    _topBg.frame = CGRectMake(0, 0, viewW, viewH*67/totalHeight);
    _topBg.backgroundColor = [UIColor whiteColor];
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(viewW*10.5/totalHeight, viewH*32.5/totalHeight, viewH*24.5/totalHeight, viewH*24.5/totalHeight);
    [_backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
//    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backBtn.frame.origin.x+_backBtn.frame.size.width, diff_top, viewW-_backBtn.frame.origin.x-_backBtn.frame.size.width-2*diff_x, viewH*44/totalHeight)];
    _titleLabel.center=CGPointMake(self.view.center.x, _backBtn.center.y);
//    _titleLabel.text = NSLocalizedString(@"upgrade_firmware", nil);
    _titleLabel.text = @"Firmware Update";
    _titleLabel.font = [UIFont systemFontOfSize: viewH*22.5/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = [UIColor colorWithRed:0/255.0 green:178/255.0 blue:225/255.0 alpha:1.0];
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    _refreshBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _refreshBtn.frame = CGRectMake(viewW-viewH*44/totalHeight, diff_top, viewH*47/totalHeight, viewH*47/totalHeight);
    [_refreshBtn setImage:[UIImage imageNamed:@"icon_update"] forState:UIControlStateNormal];
    [_refreshBtn addTarget:nil action:@selector(_refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    //[self.view  addSubview:_refreshBtn];
    
    _versionView=[[UIView alloc]init];
    _versionView.backgroundColor=[UIColor clearColor];
    _versionView.frame=CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height+viewH*24/totalHeight,viewW,viewH*89/totalHeight);
    [self.view addSubview:_versionView];
    
    _currentVersionLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, viewH*69/totalHeight, viewW, viewH*20/totalHeight)];
    _currentVersionLabel.text = NSLocalizedString(@"upgrade_firmware_current_version", nil);
    _currentVersionLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _currentVersionLabel.backgroundColor = [UIColor clearColor];
    _currentVersionLabel.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _currentVersionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _currentVersionLabel.textAlignment=UITextAlignmentCenter;
    _currentVersionLabel.numberOfLines = 0;
    [_versionView addSubview:_currentVersionLabel];
    
    _versionImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Firmware update_update_icon@3x.png"]];
    _versionImg.frame = CGRectMake(0, viewH*30/totalHeight, viewH*29/totalHeight, viewH*29/totalHeight);
    _versionImg.center=CGPointMake(viewW*0.5, _versionImg.center.y);
    _versionImg.contentMode=UIViewContentModeScaleToFill;
    [_versionView addSubview:_versionImg];
    
    _newVersionLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH*20/totalHeight)];
    _newVersionLabel.text = @"";
    _newVersionLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _newVersionLabel.backgroundColor = [UIColor clearColor];
    _newVersionLabel.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _newVersionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _newVersionLabel.textAlignment=UITextAlignmentCenter;
    _newVersionLabel.numberOfLines = 0;
    [_versionView addSubview:_newVersionLabel];
    
    //Upgrade
    _chooseFirmwareView=[[UIViewLinkmanTouch alloc]initWithFrame:CGRectMake(0,_versionView.frame.origin.y+_versionView.frame.size.height+viewH*15/totalHeight,viewW,viewH*44/totalHeight)];
    _chooseFirmwareView.backgroundColor=[UIColor whiteColor];
    _chooseFirmwareView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_chooseFirmwareViewClick)];
    [_chooseFirmwareView addGestureRecognizer:singleTap];
    [self.view addSubview:_chooseFirmwareView];
    
    _chooseFirmwareLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH*44/totalHeight)];
    _chooseFirmwareLabel.text = NSLocalizedString(@"choose_firmware_title", nil);
    _chooseFirmwareLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _chooseFirmwareLabel.backgroundColor = [UIColor clearColor];
    _chooseFirmwareLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _chooseFirmwareLabel.lineBreakMode = UILineBreakModeWordWrap;
    _chooseFirmwareLabel.textAlignment=UITextAlignmentCenter;
    _chooseFirmwareLabel.numberOfLines = 0;
    [_chooseFirmwareView addSubview:_chooseFirmwareLabel];
    
    _chooseFirmwareImg=[[UIImageView alloc]init];
    _chooseFirmwareImg.frame = CGRectMake(viewW-viewW*44/totalWeight, 0, viewH*44/totalHeight, viewH*44/totalHeight);
    [_chooseFirmwareImg setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"]];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI);
    [_chooseFirmwareImg setTransform:rotate];
    //[_chooseFirmwareView  addSubview:_chooseFirmwareImg];
    
    _chooseFirmwareNameLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, _chooseFirmwareView.frame.origin.y+_chooseFirmwareView.frame.size.height, viewW, viewH*44/totalHeight)];
    _chooseFirmwareNameLabel.text = NSLocalizedString(@"upgrade_firmware_name", nil);
    _chooseFirmwareNameLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _chooseFirmwareNameLabel.backgroundColor = [UIColor whiteColor];
    _chooseFirmwareNameLabel.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _chooseFirmwareNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    _chooseFirmwareNameLabel.textAlignment=UITextAlignmentCenter;
    _chooseFirmwareNameLabel.numberOfLines = 0;
    [self.view addSubview:_chooseFirmwareNameLabel];
    
    //Update
    _updateFirmwareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _updateFirmwareBtn.frame = CGRectMake(viewW*30/totalWeight, viewH-viewH*85/totalHeight, viewW*316/totalWeight, viewH*44/totalHeight);
    [_updateFirmwareBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_nor@3x.png"] forState:UIControlStateNormal];
    [_updateFirmwareBtn setBackgroundImage:[UIImage imageNamed:@"button_rectangle_dis@3x.png"] forState:UIControlStateHighlighted];
    [_updateFirmwareBtn setTitle: NSLocalizedString(@"upgrade_firmware_btn", nil) forState: UIControlStateNormal];
    [_updateFirmwareBtn setTitleColor:[UIColor colorWithRed:236/255.0 green:79/255.0 blue:38/255.0 alpha:1.0] forState:UIControlStateNormal];
    _updateFirmwareBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*18/totalHeight*0.8];
    _updateFirmwareBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_updateFirmwareBtn addTarget:nil action:@selector(_updateFirmwareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_updateFirmwareBtn];
    
    _firmwareListBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    _firmwareListBgView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    
    _firmwareListView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, viewW*0.8, viewH*0.6)];
    _firmwareListView.backgroundColor=[UIColor whiteColor];
    _firmwareListView.center=self.view.center;
    
    
    _firmwareListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewW*0.8,viewH*0.6) style:UITableViewStylePlain];
    _firmwareListTable.center=self.view.center;
    _firmwareListTable.dataSource = self;
    _firmwareListTable.delegate = self;
    _firmwareListTable.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);
    
    
    progress = [[ProgressView alloc]initWithFrame:CGRectMake(0, _chooseFirmwareNameLabel.frame.size.height+_chooseFirmwareNameLabel.frame.origin.y+viewH*10/totalHeight, viewW*140/totalWeight, viewW*140/totalWeight)];
    progress.center=CGPointMake(viewW*0.5, progress.center.y);
    progress.arcFinishColor = [UIColor  colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
    progress.arcUnfinishColor = [UIColor  colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
    progress.arcBackColor = [UIColor  colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    progress.percent = 0;
    progressPos=0;
    [self.view addSubview:progress];
    
    //RunProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(RunProgressTimer) userInfo:nil repeats:YES];
    
    _firmwareNoteLabel1= [[UILabel alloc] initWithFrame:CGRectMake(0, progress.frame.origin.y+progress.frame.size.height+viewH*34/totalHeight, viewW, viewH*20/totalHeight)];
    _firmwareNoteLabel1.text = NSLocalizedString(@"upgrade_firmware_note1", nil);
    _firmwareNoteLabel1.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _firmwareNoteLabel1.backgroundColor = [UIColor clearColor];
    _firmwareNoteLabel1.textColor = [UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0];
    _firmwareNoteLabel1.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareNoteLabel1.textAlignment=UITextAlignmentCenter;
    _firmwareNoteLabel1.numberOfLines = 0;
    [self.view addSubview:_firmwareNoteLabel1];
    
    _firmwareNoteLabel2= [[UILabel alloc] initWithFrame:CGRectMake(0, _firmwareNoteLabel1.frame.origin.y+_firmwareNoteLabel1.frame.size.height+viewH*5/totalHeight, viewW, viewH*20/totalHeight)];
    _firmwareNoteLabel2.text = NSLocalizedString(@"upgrade_firmware_note2", nil);
    _firmwareNoteLabel2.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _firmwareNoteLabel2.backgroundColor = [UIColor clearColor];
    _firmwareNoteLabel2.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _firmwareNoteLabel2.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareNoteLabel2.textAlignment=UITextAlignmentCenter;
    _firmwareNoteLabel2.numberOfLines = 0;
    [self.view addSubview:_firmwareNoteLabel2];
    
    //success view
    _firmwareSuccessView=[[UIView alloc]initWithFrame:CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height,viewW,viewH-viewH*64/totalHeight)];
    _firmwareSuccessView.userInteractionEnabled=YES;
    _firmwareSuccessView.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    [self.view addSubview:_firmwareSuccessView];
    
    _firmwareSuccessImg=[[UIImageView alloc]init];
    _firmwareSuccessImg.frame = CGRectMake(67*viewW/totalWeight, viewH*132/totalHeight, viewH*44/totalHeight, viewH*44/totalHeight);
    [_firmwareSuccessImg setImage:[UIImage imageNamed:@"function menu_update_complete_icon@3x.png"]];
    [_firmwareSuccessView  addSubview:_firmwareSuccessImg];
    
    _firmwareSuccessNote=[[UILabel alloc]initWithFrame:CGRectMake(_firmwareSuccessImg.frame.origin.x+_firmwareSuccessImg.frame.size.width+6*viewW/totalWeight,viewH*132/totalHeight,viewW-(_firmwareSuccessImg.frame.origin.x+_firmwareSuccessImg.frame.size.width+6*viewW/totalWeight),viewH*44/totalHeight)];
    _firmwareSuccessNote.text = NSLocalizedString(@"upgrade_firmware_success_text", nil);
    _firmwareSuccessNote.font = [UIFont systemFontOfSize: viewH*28/totalHeight*0.8];
    _firmwareSuccessNote.backgroundColor = [UIColor clearColor];
    _firmwareSuccessNote.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _firmwareSuccessNote.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareSuccessNote.textAlignment=UITextAlignmentLeft;
    _firmwareSuccessNote.numberOfLines = 0;
    [_firmwareSuccessView addSubview:_firmwareSuccessNote];
    
    UIView *_versionOverView=[[UIView alloc]init];
    _versionOverView.frame=CGRectMake(0,viewH*220/totalHeight,viewW,viewH*94/totalHeight);
    _versionOverView.backgroundColor = [UIColor whiteColor];
    [_firmwareSuccessView addSubview:_versionOverView];
    
    _firmwareSuccessVersion=[[UILabel alloc]initWithFrame:CGRectMake(0,viewH*16/totalHeight,viewW,viewH*24/totalHeight)];
    _firmwareSuccessVersion.text = NSLocalizedString(@"upgrade_firmware_success_note", nil);
    _firmwareSuccessVersion.font = [UIFont systemFontOfSize: viewH*24/totalHeight*0.8];
    _firmwareSuccessVersion.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _firmwareSuccessVersion.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareSuccessVersion.textAlignment=UITextAlignmentCenter;
    _firmwareSuccessVersion.numberOfLines = 0;
    [_versionOverView addSubview:_firmwareSuccessVersion];
    
    _firmwareSuccessValue=[[UILabel alloc]initWithFrame:CGRectMake(0,viewH*54/totalHeight,viewW,viewH*24/totalHeight)];
    _firmwareSuccessValue.text = @"";
    _firmwareSuccessValue.font = [UIFont systemFontOfSize: viewH*24/totalHeight*0.8];
    _firmwareSuccessValue.textColor = [UIColor colorWithRed:105/255.0 green:106/255.0 blue:117/255.0 alpha:1.0];
    _firmwareSuccessValue.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareSuccessValue.textAlignment=UITextAlignmentCenter;
    _firmwareSuccessValue.numberOfLines = 0;
    [_versionOverView addSubview:_firmwareSuccessValue];
    
    //failed view
    _firmwareFailedTryAgainBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _firmwareFailedTryAgainBtn.frame=CGRectMake(0,viewH*355/totalHeight,100*viewW/totalWeight,viewH*20/totalHeight);
    _firmwareFailedTryAgainBtn.center=CGPointMake(viewW*0.5,_firmwareFailedTryAgainBtn.center.y);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"upgrade_firmware_failed_try_again", nil)];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0] range:strRange];
    [str addAttribute:NSUnderlineColorAttributeName value:[UIColor colorWithRed:233/255.0 green:82/255.0 blue:25/255.0 alpha:1.0] range:strRange];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize: viewH*20/totalHeight*0.8]
                range:strRange];
    [_firmwareFailedTryAgainBtn setAttributedTitle:str forState:UIControlStateNormal];
    _firmwareFailedTryAgainBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_firmwareFailedTryAgainBtn addTarget:nil action:@selector(_firmwareFailedTryAgainBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_firmwareSuccessView addSubview:_firmwareFailedTryAgainBtn];
    
    _firmwareFailedNote1=[[UILabel alloc]initWithFrame:CGRectMake(0,viewH*385/totalHeight,viewW,viewH*20/totalHeight)];
    _firmwareFailedNote1.text = NSLocalizedString(@"upgrade_firmware_failed_note", nil);
    _firmwareFailedNote1.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _firmwareFailedNote1.backgroundColor = [UIColor clearColor];
    _firmwareFailedNote1.textColor = [UIColor colorWithRed:142/255.0 green:143/255.0 blue:152/255.0 alpha:1.0];
    _firmwareFailedNote1.lineBreakMode = UILineBreakModeWordWrap;
    _firmwareFailedNote1.textAlignment=UITextAlignmentCenter;
    _firmwareFailedNote1.numberOfLines = 0;
    [_firmwareSuccessView addSubview:_firmwareFailedNote1];
    
    NSArray *files = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:docDir error:Nil];
    for (int i=0; i<[files count]; i++) {
        if(([files[i] hasPrefix:@"upgrade"])&&([files[i] hasSuffix:@".tgz"])){
            [fileName addObject:files[i]];
        }
    }
    [self choosefirmwareViewInit];
    
    _firmwareNoteLabel1.hidden=YES;
    _firmwareNoteLabel2.hidden=YES;
    _firmwareSuccessView.hidden=YES;
    progress.hidden=YES;
    
    updateIP=[self Get_Paths:@"DEVICEIP"];
    _currentVersionLabel.text = [self Get_Paths:@"DEVICEVERSION"];
}

-(void)RunProgressTimer{
    if (_isUpdte) {
        if (progress.percent>=1) {
            if (RunProgress != nil) {
                [RunProgress invalidate];
                RunProgress = nil;
            }
        }
        else{
            progress.percent += 1/progressTime;
        }
    }
}

-(void)ShowFirmwareList{
    [self.view addSubview:_firmwareListBgView];
    [_firmwareListBgView addSubview:_firmwareListView];
    [_firmwareListBgView  addSubview:_firmwareListTable];
}

-(void)HideFirmwareList{
    [_firmwareListBgView removeFromSuperview];
    [_firmwareListBgView  removeFromSuperview];
    [_firmwareListBgView removeFromSuperview];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fileName count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.frame=CGRectMake(0, 0, self.view.frame.size.width*0.8, title_size);
    cell.textLabel.text=fileName[indexPath.row];
    cell.font = [UIFont fontWithName:@"Arial" size:add_title_size];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _chooseFirmwareNameLabel.text=fileName[indexPath.row];
    [self HideFirmwareList];
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _Exit=YES;
    _isUpdte=NO;
    _isFound=NO;
    if (RunProgress!=nil) {
        [RunProgress invalidate];
        RunProgress=nil;
    }
    if (GCDSocket != nil) {
        [GCDSocket disconnect];//关闭建立的SOCKET
        GCDSocket = nil;
    }
}

- (void)_refreshBtnClick{
    //[self scanDevice];
}

//返回
- (void)_backBtnClick{
    _Exit=YES;
    _isUpdte=NO;
    _isFound=NO;
    if (RunProgress!=nil) {
        [RunProgress invalidate];
        RunProgress=nil;
    }
    if (GCDSocket != nil) {
        [GCDSocket disconnect];//关闭建立的SOCKET
        GCDSocket = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//VER='HD_WifiV_566_V1.57.2';"
- (void)getFilePath{
    [filePath removeAllObjects];
    NSString *srcPath=[NSString stringWithFormat:@"%@/%@/files/",docDir,[_chooseFirmwareNameLabel.text stringByReplacingOccurrencesOfString:@".tgz" withString:@""]];
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *myDirectoryEnumerator;
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:srcPath];
    //列举目录内容，可以遍历子目录
    NSString *path;
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    while((path=[myDirectoryEnumerator nextObject])!=nil)
    {
        if ([path containsString:@".DS_Store"]) {
            
        }
        else{
            NSArray *Names = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@/",srcPath,path] error:Nil];
            if ([Names count]==0) {
                NSLog(@"%@",path);
                [filePath addObject:[NSString stringWithFormat:@"/%@",path]];
            }
        }
    }
}

- (void)_chooseFirmwareViewClick{
    NSLog(@"_chooseFirmwareViewClick");
    //fileName = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:docDir error:Nil];
    //[self ShowFirmwareList];
    
    [self setInfoViewFrame:firmwareView :NO];
}

- (void)_updateFirmwareBtnClick{
    NSLog(@"_updateFirmwareBtnClick");
    _isSetVer=NO;
    [self getFilePath];
    if ([filePath count]==0) {
        [self showAllTextDialog:NSLocalizedString(@"upgrade_firmware_failed_no_firmware", nil)];
    }
    else{
        if ([_newVersionLabel.text compare:@""] ==NSOrderedSame) {
            [self showAllTextDialog:NSLocalizedString(@"upgrade_firmware_failed_get_version", nil)];
            return;
        }
        _firmwareSuccessValue.text=_currentVersionLabel.text;
        _firmwareNoteLabel1.hidden=YES;
        _firmwareNoteLabel2.hidden=YES;
        _firmwareSuccessView.hidden=YES;
        progress.hidden=YES;
        
        GCDSocket = [[RAKAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];//建立与设备 TCP 80端口连接，用于串口透传数据发送与接收
        NSError *err;
        [GCDSocket connectToHost:updateIP onPort:updatePort error:&err];
        if (err != nil)
        {
            NSLog(@"error = %@",err);
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:NSLocalizedString(@"upgrade_firmware_failed_connect", nil)];
            });
        }
        else{
            _isUpdte=YES;
            dispatch_async(dispatch_get_main_queue(),^ {
                _updateFirmwareBtn.enabled=NO;
                _firmwareNoteLabel1.hidden=NO;
                _firmwareNoteLabel2.hidden=NO;
                progress.hidden=NO;
            });
            fileNum=0;
            [NSThread detachNewThreadSelector:@selector(sendPacket) toTarget:self withObject:nil];//升级
            [GCDSocket readDataWithTimeout:-1 tag:0];
        }
    }
}

//保活
int fileNum=0;
CGFloat progressPos;
- (void)sendPacket
{
    if(_isUpdte)
    {
        NSArray  *array= [filePath[fileNum] componentsSeparatedByString:@"/"];
        NSString *topStream=[NSString stringWithFormat:@"%@%@%@",postName, array[[array count]-1],postHeadEnd];
        //NSLog(@"topStream==%@",topStream);
        NSString *bottomStream=[NSString stringWithFormat:@"%@%@%@",postPath,filePath[fileNum],postAllEnd];
        //NSLog(@"bottomStream==%@",bottomStream);
        NSString *destPath=[NSString stringWithFormat:@"%@/%@/files%@",docDir,[_chooseFirmwareNameLabel.text stringByReplacingOccurrencesOfString:@".tgz" withString:@""],filePath[fileNum]];
        NSData *data = [NSData dataWithContentsOfFile:destPath];
        int send_len=(int)data.length+(int)topStream.length+(int)bottomStream.length;
        int bin_len=(int)data.length;
        int init_len=bin_len;
        dispatch_async(dispatch_get_main_queue(),^ {
            _firmwareNoteLabel1.text=[NSString stringWithFormat:@"%@(%d/%d)",NSLocalizedString(@"upgrade_firmware_note1", nil),(fileNum+1),(int)[filePath count]];
        });
        //NSLog(@"data.length=%d",send_len);
        NSString *HeadStream=[NSString stringWithFormat:@"%@%@%@%@%@%d\r\nAccept: */*\r\n\r\n%@",postHost,updateIP,postReferer,updateIP,postLength,send_len,topStream];
        //NSLog(@"HeadStream=%@",HeadStream);
        //发送头
        [GCDSocket writeData:[HeadStream dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:100];
        //发送TopStream
        //[GCDSocket writeData:[topStream dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:100];
        //发送文件
        while (bin_len>0) {
            if (bin_len>1024) {
                [GCDSocket writeData:[data subdataWithRange:NSMakeRange((progressTime-bin_len), 1024)] withTimeout:1.0 tag:100];
                bin_len=bin_len-1024;
                dispatch_async(dispatch_get_main_queue(),^ {
                    progress.percent = progressPos+(init_len-bin_len)*progressTime/(init_len*progressTime*[filePath count]);
                });
            }
            else{
                [GCDSocket writeData:[data subdataWithRange:NSMakeRange((progressTime-bin_len), bin_len)] withTimeout:1.0 tag:100];
                bin_len=0;
            }
            [NSThread sleepForTimeInterval:0.01f];
        }
        //发送BottomStream
        [GCDSocket writeData:[bottomStream dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:100];
        //NSLog(@"bin_len=%d",bin_len);
        dispatch_async(dispatch_get_main_queue(),^ {
            progress.percent = progressTime*(fileNum+1)/(progressTime*[filePath count]);
        });
        progressPos=progressTime*(fileNum+1)/(progressTime*[filePath count]);
    }
}

bool _isSetVer=NO;
-(void)setVersion{
    //set version
    _isSetVer=YES;
    NSString *newVersion=_newVersionLabel.text;
    NSLog(@"newVersion=%@",newVersion);
    postVerVersion=@"cmdtype=5&param=WXXXXXX0000000000%2C";
    postVerVersion=[NSString stringWithFormat:@"%@%@",postVerVersion,newVersion];
    NSString *HeadStream=[NSString stringWithFormat:@"%@%@%@%@%@%d\r\nAccept: */*\r\n\r\n%@",postVerHost,updateIP,postVerReferer,updateIP,postVerLength,(int)postVerVersion.length,postVerVersion];
    NSLog(@"HeadStream=%@",HeadStream);

    //发送头
    [GCDSocket writeData:[HeadStream dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:100];
}

-(void)socket:(RAKAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if([sock isEqual:GCDSocket]){
        if(data.length > 0)
        {
            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"result=%@",result);
            if ([result hasPrefix: @"HTTP/1.1 200 OK"]) {
                [GCDSocket disconnect];
                if (_isSetVer) {
                    if (GCDSocket!=nil) {
                        [GCDSocket disconnect];
                        GCDSocket=nil;
                    }
                    dispatch_async(dispatch_get_main_queue(),^ {
                        _firmwareSuccessVersion.text = NSLocalizedString(@"upgrade_firmware_success_note", nil);
                        [_firmwareSuccessImg setImage:[UIImage imageNamed:@"function menu_update_complete_icon@3x.png"]];
                        _firmwareSuccessNote.text = NSLocalizedString(@"upgrade_firmware_success_text", nil);
                        _firmwareSuccessView.hidden=NO;
                        _firmwareFailedTryAgainBtn.hidden=YES;
                        _firmwareFailedNote1.hidden=YES;
                        if ([result containsString:@"更新成功"]) {
                            _firmwareSuccessValue.text=_newVersionLabel.text;
                        }
                        else{
                            [self showAllTextDialog:NSLocalizedString(@"upgrade_firmware_failed_change_version", nil)];
                        }
                    });
                    _isSetVer=NO;
                    return;
                }
                _isSetVer=NO;
                NSError *err;
                [GCDSocket connectToHost:updateIP onPort:updatePort error:&err];
                if (err != nil)
                {
                    NSLog(@"error = %@",err);
                    dispatch_async(dispatch_get_main_queue(),^ {
                        [self showAllTextDialog:NSLocalizedString(@"upgrade_firmware_failed_connect", nil)];
                    });
                }
                if ([result containsString:@"文件上传成功"])
                {
                    fileNum++;
                    if (fileNum<[filePath count]) {
                        [NSThread detachNewThreadSelector:@selector(sendPacket) toTarget:self withObject:nil];
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(),^ {
                            progress.percent=1.0;
                        });
                        [NSThread detachNewThreadSelector:@selector(setVersion) toTarget:self withObject:nil];
                    }
                }
                else
                {
                    NSLog(@"error1111111111");
//                    [self showAllTextDialog:@"此文件不存在，请检查！"];
//                    if (fileNum<[filePath count]) {
//                        [NSThread detachNewThreadSelector:@selector(sendPacket) toTarget:self withObject:nil];
//                    }
                    if (GCDSocket!=nil) {
                        [GCDSocket disconnect];
                        GCDSocket=nil;
                    }
                    _firmwareSuccessValue.text=_currentVersionLabel.text;
                    _firmwareSuccessVersion.text = NSLocalizedString(@"upgrade_firmware_success_note", nil);
                    [_firmwareSuccessImg setImage:[UIImage imageNamed:@"function menu_update_failed_icon@3x.png"]];
                    _firmwareSuccessNote.text = NSLocalizedString(@"upgrade_firmware_failed_text", nil);
                    
                    _firmwareSuccessView.hidden=NO;
                    _firmwareFailedTryAgainBtn.hidden=NO;
                    _firmwareFailedNote1.hidden=NO;
                }
            }
            else{
                if (GCDSocket!=nil) {
                    [GCDSocket disconnect];
                    GCDSocket=nil;
                }
                _firmwareSuccessValue.text=_currentVersionLabel.text;
                _firmwareSuccessVersion.text = NSLocalizedString(@"upgrade_firmware_success_note", nil);
                [_firmwareSuccessImg setImage:[UIImage imageNamed:@"function menu_update_failed_icon@3x.png"]];
                _firmwareSuccessNote.text = NSLocalizedString(@"upgrade_firmware_failed_text", nil);
                
                _firmwareSuccessView.hidden=NO;
                _firmwareFailedTryAgainBtn.hidden=NO;
                _firmwareFailedNote1.hidden=NO;
            }
        }
        [GCDSocket readDataWithTimeout:-1 tag:0];
    }
}


- (void)_firmwareFailedTryAgainBtnClick{
    NSLog(@"_firmwareFailedTryAgainBtnClick");
    _firmwareNoteLabel1.hidden=YES;
    _firmwareNoteLabel2.hidden=YES;
    _firmwareSuccessView.hidden=YES;
    progress.hidden=YES;
    _updateFirmwareBtn.enabled=YES;
}

-(void)choosefirmwareViewInit{
    firmwareView=[[UIView alloc]initWithFrame:CGRectMake(0,viewH,viewW,viewH)];
    firmwareView.backgroundColor=[UIColor clearColor];
    firmwareView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_firmwareViewCancelClick)];
    [firmwareView addGestureRecognizer:singleTap];
    [self.view addSubview:firmwareView];
    
    UIView *_firmwareViewLayout=[[UIView alloc]initWithFrame:CGRectMake(viewW*10/totalWeight,viewH*592/totalHeight-viewH*57*[fileName count]/totalHeight,viewW*355/totalWeight,viewH*57*[fileName count]/totalHeight)];
    [[_firmwareViewLayout layer]setCornerRadius:viewW*10/totalWeight];//圆角
    _firmwareViewLayout.backgroundColor=[UIColor whiteColor];
    _firmwareViewLayout.userInteractionEnabled = YES;
    [firmwareView addSubview:_firmwareViewLayout];
    
    for (int i=0; i<[fileName count]; i++) {
        UIButton *_chooseLayoutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _chooseLayoutBtn.tag=i;
        _chooseLayoutBtn.frame = CGRectMake(0, viewH*57*i/totalHeight, viewW*355/totalWeight, viewH*57/totalHeight);
        _chooseLayoutBtn.backgroundColor=[UIColor clearColor];
        [_chooseLayoutBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateHighlighted];
        _chooseLayoutBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        [_chooseLayoutBtn addTarget:nil action:@selector(_chooseLayoutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _chooseLayoutBtn.titleLabel.font=[UIFont systemFontOfSize:viewH*23/totalHeight*0.8];
        [_firmwareViewLayout  addSubview:_chooseLayoutBtn];
        
        [_chooseLayoutBtn setTitle:fileName[i] forState:UIControlStateNormal];
        [_chooseLayoutBtn setTitleColor:[UIColor colorWithRed:67/255.0 green:77/255.0 blue:87/255.0 alpha:1.0]forState:UIControlStateNormal];

        if (i<([fileName count]-1)) {
            UIView *Line=[[UIView alloc]init];
            Line.frame = CGRectMake(0, viewH*57*(i+1)/totalHeight, viewW*355/totalWeight, 1);
            Line.backgroundColor=[UIColor colorWithRed:180/255.0 green:181/255.0 blue:182/255.0 alpha:1.0];
            [_firmwareViewLayout  addSubview:Line];
        }
    }
    
    UIButton *_firmwareViewCancel=[UIButton buttonWithType:UIButtonTypeCustom];
    _firmwareViewCancel.frame = CGRectMake(viewW*10/totalWeight, viewH*600/totalHeight, viewW*355/totalWeight, viewH*57/totalHeight);
    _firmwareViewCancel.backgroundColor=[UIColor whiteColor];
    [_firmwareViewCancel setTitleColor:[UIColor colorWithRed:67/255.0 green:77/255.0 blue:87/255.0 alpha:1.0]forState:UIControlStateNormal];
    [_firmwareViewCancel setTitleColor:[UIColor lightGrayColor]forState:UIControlStateHighlighted];
    [[_firmwareViewCancel layer]setCornerRadius:viewW*10/totalWeight];
    [_firmwareViewCancel setTitle:NSLocalizedString(@"share_cancel", nil) forState:UIControlStateNormal];
    _firmwareViewCancel.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_firmwareViewCancel addTarget:nil action:@selector(_firmwareViewCancelClick) forControlEvents:UIControlEventTouchUpInside];
    _firmwareViewCancel.titleLabel.font=[UIFont systemFontOfSize:viewH*23/totalHeight*0.8];
    [firmwareView  addSubview:_firmwareViewCancel];
}

-(void)_chooseLayoutBtnClick:(UIButton*)button{
    NSLog(@"_chooseLayoutBtnClick");
    [self setInfoViewFrame:firmwareView :YES];
    _chooseFirmwareNameLabel.text=fileName[button.tag];

    //解压
    NSString *verTgzPath=[NSString stringWithFormat:@"%@/%@",docDir,_chooseFirmwareNameLabel.text];
    NSURL *URL = [NSURL URLWithString:verTgzPath];
    NSString *__autoreleasing verStr = [[NSString alloc] initWithFormat:@"%@", verTgzPath];
    [Brett untarFileAtURL:URL withError:nil destinationPath:&verStr];
    
    NSString *verPath=[NSString stringWithFormat:@"%@/%@/upgrade.sh",docDir,[_chooseFirmwareNameLabel.text stringByReplacingOccurrencesOfString:@".tgz" withString:@""]];
    NSData *verData = [NSData dataWithContentsOfFile:verPath];
    NSString *verString = [[NSString alloc] initWithData:verData encoding:NSUTF8StringEncoding];
    NSString *Str=@"";
    NSString *keyStr=@"VER='";
    NSString *endStr=@"';";
    NSRange range=[verString rangeOfString:keyStr];
    if (range.location != NSNotFound) {
        int i=(int)range.location;
        verString=[verString substringFromIndex:i+keyStr.length];
        NSRange range1=[verString rangeOfString:endStr];
        if (range1.location != NSNotFound) {
            int j=(int)range1.location;
            NSRange diffRange=NSMakeRange(0, j);
            Str=[verString substringWithRange:diffRange];
            _newVersionLabel.text=Str;
        }
    }
};

-(void)_firmwareViewCancelClick{
    NSLog(@"_chooseImgViewCancelClick");
    [self setInfoViewFrame:firmwareView :YES];
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
