//
//  FSLiveViewViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/16.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSLiveViewViewController.h"
#import "CommonAppHeader.h"
#import "FSStreamViewController.h"
//获取wifi名
#import <SystemConfiguration/CaptiveNetwork.h>

#define FSLiveViewVideoType @"h264"

@interface FSLiveViewViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;

//topBar
@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (weak, nonatomic) IBOutlet UIImageView *wifiImageView;
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIImageView *audioModelImageView;
@property (weak, nonatomic) IBOutlet UIImageView *powerStatusImageView;

//center

//bottomBar
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *streamButton;
@property (weak, nonatomic) IBOutlet UIButton *browserButton;
@property (weak, nonatomic) IBOutlet UIButton *configureButton;
@property (weak, nonatomic) IBOutlet UIButton *platformButton;

@property (nonatomic,assign) BOOL             hidenTopBarAndBottomBar;
@property (nonatomic,  copy) NSString         *userIP;
@property (nonatomic,  copy) NSString         *userID;

@end

@implementation FSLiveViewViewController

#pragma mark - Setters/Getters


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self beginSearchDevice];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self updateWifiName];
    [self showTopAndBottomBgView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self stopSearchDevice];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

#pragma mark – Private methods

- (void)updateWifiName {
    NSString *wifiName = [self getWifiName];
    if (wifiName.length < 1) {
        wifiName = NSLocalizedString(@"No wireless LAN connection", nil);
    }
    self.wifiNameLabel.text = wifiName;
}

- (NSString *)getWifiName {
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (void)showTopAndBottomBgView {
    self.hidenTopBarAndBottomBar = YES;
    [self performSelector:@selector(tapContentView:) withObject:nil];
}

- (void)beginSearchDevice {
    [self disableButtons];
    WEAK(self);
    [[FSSearchDeviceManager shareInstance] beginSearchDeviceDuration:5.f completionHandle:^(Scanner *resultInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself scanDeviceOver:resultInfo];
        });
    }];
}

- (void)scanDeviceOver:(Scanner *)result {
    
    if (result.Device_ID_Arr.count < 1) {
        [self showActionSheet];
        return;
    }
    //使用扫描到的第一个设备
    self.userIP = [result.Device_IP_Arr objectAtIndex:0];
    self.userID = [result.Device_ID_Arr objectAtIndex:0];
    
    NSString *liveViewUrlString = [NSString stringWithFormat:@"rtsp://admin:admin@%@/cam1/%@", self.userIP,FSLiveViewVideoType];
    
    [self getDeviceConfigure];
    
}

- (void)showActionSheet {
    
}

- (void)getDeviceConfigure {
#warning needRefactor....coding here
//    NSString * configIP = _userip;
//    NSString *URL=[[NSString alloc]initWithFormat:@"http://%@:%ld/server.command?command=get_resol&type=h264&pipe=0",configIP,(long)configPort];
//    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
//
//    if(http_request.StatusCode==200)
//    {
//        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
//        _resolution=[self parseJsonString:http_request.ResponseString];
//        dispatch_async(dispatch_get_main_queue(),^ {
//            if ([_resolution compare:@"3"]==NSOrderedSame) {
//                //                [self set1080P];
//            }
//            else if ([_resolution compare:@"2"]==NSOrderedSame) {
//                //                                [self set720P];
//            }
//            else{
//                //                [self set480P];
//            }
//        });
//        NSLog(@"============resolution=%@",_resolution);
//    }
//
//    //get quality
//    URL=[[NSString alloc]initWithFormat:@"http://%@:%ld/server.command?command=get_enc_quality&type=h264&pipe=0",configIP,(long)configPort];
//    http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
//    if(http_request.StatusCode==200)
//    {
//        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
//        _quality=[self parseJsonString:http_request.ResponseString];
//        dispatch_async(dispatch_get_main_queue(),^ {
//            float value=[_quality intValue]*3000/52.0;
//            if (((int)value%100)!=0) {
//                value=value+100;
//            }
//            //            [self setVideoRate:value];
//        });
//        NSLog(@"******************quality=%@",_quality);
//    }
//    else{
//        dispatch_async(dispatch_get_main_queue(),^ {
//            [self showAllTextDialog:NSLocalizedString(@"get_quality_failed", nil)];
//        });
//    }
//
//    //get fps
//    URL=[[NSString alloc]initWithFormat:@"http://%@:%ld/server.command?command=get_max_fps&type=h264&pipe=0",configIP,(long)configPort];
//    http_request = [HttpRequest HTTPRequestWithUrl:URL andData:nil andMethod:@"GET" andUserName:@"admin" andPassword:@"admin"];
//    if(http_request.StatusCode==200)
//    {
//        http_request.ResponseString=[http_request.ResponseString stringByReplacingOccurrencesOfString:@" " withString:@""];
//        _fps=[self parseJsonString:http_request.ResponseString];
//        dispatch_async(dispatch_get_main_queue(),^ {
//            //                        [self setVideoFrameRate:[fps intValue]];
//            _session = [self getSessionWithRakisrak:YES];
//        });
//
//        //        NSLog(@"???????????????????????fps=%@",_fps);
//    }
}

- (void)disableButtons {
    [self buttonsEnable:NO];
}

- (void)enableButtons {
    [self buttonsEnable:YES];
}

- (void)buttonsEnable:(BOOL)enable {
    self.backButton.userInteractionEnabled      = enable;
    
    self.cameraButton.userInteractionEnabled    = enable;
    self.recordButton.userInteractionEnabled    = enable;
    self.streamButton.userInteractionEnabled    = enable;
    self.browserButton.userInteractionEnabled   = enable;
    self.configureButton.userInteractionEnabled = enable;
    self.platformButton.userInteractionEnabled  = enable;
}

#pragma mark – Target action methods

#pragma mark - IBActions

- (IBAction)tapContentView:(UITapGestureRecognizer *)sender {
    
    CGFloat topBgViewHeight = CGRectGetHeight(self.topBgView.frame);
    CGFloat bottomBgViewHeight = CGRectGetHeight(self.bottomBgView.frame);
    
    if(self.hidenTopBarAndBottomBar == YES) {
        topBgViewHeight    = -topBgViewHeight;
        bottomBgViewHeight = -bottomBgViewHeight;
    }
    WEAK(self);
    [UIView animateWithDuration:0.3 animations:^{
        weakself.topBgView.originY = weakself.topBgView.originY - topBgViewHeight;
        weakself.bottomBgView.originY = weakself.bottomBgView.originY + bottomBgViewHeight;
    } completion:^(BOOL finished) {}];
    
    self.hidenTopBarAndBottomBar = !self.hidenTopBarAndBottomBar;
}

- (IBAction)backButtonDidClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cameraButtonDidClicked:(UIButton *)sender {
    
}

- (IBAction)recordButtonDidClicked:(UIButton *)sender {
}

- (IBAction)streamButtonDidClicked:(UIButton *)sender {
}

- (IBAction)browserButtonDidClicked:(UIButton *)sender {
}

- (IBAction)configureButtonDidClicked:(UIButton *)sender {
}

- (IBAction)platformButtonDidClicked:(UIButton *)sender {
}

- (IBAction)pushVC:(UIButton *)sender {
    [self presentViewController:[[FSStreamViewController alloc
                                  ] init] animated:YES completion:nil];
}

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods
//重写父类的
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(BOOL)prefersStatusBarHidden{
    
    return NO;
}

#pragma mark – Delegate


@end
