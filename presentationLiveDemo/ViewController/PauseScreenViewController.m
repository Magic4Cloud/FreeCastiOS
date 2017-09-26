//
//  PauseScreenViewController.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/31.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "PauseScreenViewController.h"
#import "PicToBufferToPic.h"
#import "CommanParameters.h"

@interface PauseScreenViewController ()
{
    int pushType;//0:照片  1:视频
}
@end

@implementation PauseScreenViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
//    _imagePickerController.mediaTypes= [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    _imagePickerController.allowsEditing = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
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
    _titleLabel.text = NSLocalizedString(@"pause_screen_title", nil);
    _titleLabel.font = [UIFont boldSystemFontOfSize: viewH*20/totalHeight*0.8];
    _titleLabel.backgroundColor = [UIColor clearColor];
    //_topLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];

    //Picture Push
    _pauseScreenPushView=[[UIView alloc]initWithFrame:CGRectMake(0,_topBg.frame.origin.y+_topBg.frame.size.height,viewW,viewH*44/totalHeight)];
    _pauseScreenPushView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_pauseScreenPushView];
    
    _pauseScreenPushLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height, viewW*150/totalWeight, viewH*44/totalHeight)];
    _pauseScreenPushLabel.text = NSLocalizedString(@"pause_screen_picture_push", nil);
    _pauseScreenPushLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _pauseScreenPushLabel.backgroundColor = [UIColor clearColor];
    _pauseScreenPushLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _pauseScreenPushLabel.lineBreakMode = UILineBreakModeWordWrap;
    _pauseScreenPushLabel.textAlignment=UITextAlignmentLeft;
    _pauseScreenPushLabel.numberOfLines = 0;
    [self.view addSubview:_pauseScreenPushLabel];
    
    _pauseScreenPushBtn= [[UISwitch alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,_topBg.frame.origin.y+_topBg.frame.size.height,viewW*51/totalWeight, viewH*31/totalHeight)];
    _pauseScreenPushBtn.center=CGPointMake(viewW*342/totalWeight, _pauseScreenPushLabel.center.y);
    _pauseScreenPushBtn.on = NO;
    _pauseScreenPushBtn.onTintColor =MAIN_COLOR;
    [_pauseScreenPushBtn addTarget:self action:@selector(_pauseScreenPushBtnAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pauseScreenPushBtn];
    
    //pauseScreenPicturePush
    _pauseScreenPicturePushView=[[UIView alloc]initWithFrame:CGRectMake(0,viewH*118/totalHeight,viewW,viewH*220/totalHeight)];
    _pauseScreenPicturePushView.userInteractionEnabled=YES;
    _pauseScreenPicturePushView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_pauseScreenPicturePushView];

    _pauseScreenPicturePushImg=[[UIImageView alloc]init];
    _pauseScreenPicturePushImg.frame = CGRectMake(viewW*54/totalWeight, viewH*12/totalHeight, viewH*150*804/totalHeight/453, viewH*150/totalHeight);
    _pauseScreenPicturePushImg.center=CGPointMake(viewW*0.5, _pauseScreenPicturePushImg.center.y);
    _pauseScreenPicturePushImg.image=[UIImage imageNamed:@"stream_pause pic_add_bg@3x.png"];
    _pauseScreenPicturePushImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_pauseScreenPicturePushImgClick)];
    [_pauseScreenPicturePushImg addGestureRecognizer:singleTap0];
    [_pauseScreenPicturePushView addSubview:_pauseScreenPicturePushImg];

    _pauseScreenPicturePushBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_pauseScreenPicturePushBtn.layer setMasksToBounds:YES];
    [_pauseScreenPicturePushBtn.layer setCornerRadius:2.0];
    _pauseScreenPicturePushBtn.frame = CGRectMake(viewW*135/totalWeight,viewH*178/totalHeight, viewW*106/totalWeight, viewH*32/totalHeight);
    [_pauseScreenPicturePushBtn setTitle: NSLocalizedString(@"upload", nil) forState: UIControlStateNormal];
    _pauseScreenPicturePushBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _pauseScreenPicturePushBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    [_pauseScreenPicturePushBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _pauseScreenPicturePushBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_pauseScreenPicturePushBtn addTarget:nil action:@selector(_pauseScreenPicturePushBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_pauseScreenPicturePushView  addSubview:_pauseScreenPicturePushBtn];
  
    //Video Push
    _pauseScreenVideoPushView=[[UIView alloc]initWithFrame:CGRectMake(0,viewH*368/totalHeight,viewW,viewH*44/totalHeight)];
    _pauseScreenVideoPushView.backgroundColor=[UIColor whiteColor];
    //[self.view addSubview:_pauseScreenVideoPushView];
    
    _pauseScreenVideoPushLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*16/totalWeight,viewH*368/totalHeight, viewW*150/totalWeight, viewH*44/totalHeight)];
    _pauseScreenVideoPushLabel.text = NSLocalizedString(@"pause_screen_video_push", nil);
    _pauseScreenVideoPushLabel.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.8];
    _pauseScreenVideoPushLabel.backgroundColor = [UIColor clearColor];
    _pauseScreenVideoPushLabel.textColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _pauseScreenVideoPushLabel.lineBreakMode = UILineBreakModeWordWrap;
    _pauseScreenVideoPushLabel.textAlignment=UITextAlignmentLeft;
    _pauseScreenVideoPushLabel.numberOfLines = 0;
    //[self.view addSubview:_pauseScreenVideoPushLabel];
    
    _pauseScreenVideoPushBtn= [[UISwitch alloc] initWithFrame:CGRectMake(viewW*308/totalWeight,viewH*368/totalHeight,viewW*51/totalWeight, viewH*31/totalHeight)];
    _pauseScreenVideoPushBtn.center=CGPointMake(viewW*342/totalWeight, _pauseScreenVideoPushLabel.center.y);
    _pauseScreenVideoPushBtn.on = NO;
    _pauseScreenVideoPushBtn.onTintColor =MAIN_COLOR;
    [_pauseScreenVideoPushBtn addTarget:self action:@selector(_pauseScreenVideoPushBtnAction:) forControlEvents:UIControlEventValueChanged];
    //[self.view addSubview:_pauseScreenVideoPushBtn];
    
    //pauseScreenVideoView
    _pauseScreenVideoView=[[UIView alloc]initWithFrame:CGRectMake(0,viewH*422/totalHeight,viewW,viewH*220/totalHeight)];
    _pauseScreenVideoView.userInteractionEnabled=YES;
    _pauseScreenVideoView.backgroundColor=[UIColor whiteColor];
    //[self.view addSubview:_pauseScreenVideoView];
    
    _pauseScreenVideoImg=[[UIImageView alloc]init];
    _pauseScreenVideoImg.frame = CGRectMake(viewW*113/totalWeight, viewH*12/totalHeight, viewH*150/totalHeight, viewH*150/totalHeight);
    _pauseScreenVideoImg.center=CGPointMake(viewW*0.5, _pauseScreenVideoImg.center.y);
    _pauseScreenVideoImg.image=[UIImage imageNamed:@"stream_pause video_add_bg@3x.png"];
    _pauseScreenVideoImg.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_pauseScreenVideoImgClick)];
    [_pauseScreenVideoImg addGestureRecognizer:singleTap1];
    [_pauseScreenVideoView addSubview:_pauseScreenVideoImg];
    
    _pauseScreenVideoBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_pauseScreenVideoBtn.layer setMasksToBounds:YES];
    [_pauseScreenVideoBtn.layer setCornerRadius:2.0];
    _pauseScreenVideoBtn.frame = CGRectMake(viewW*135/totalWeight,viewH*178/totalHeight, viewW*106/totalWeight, viewH*32/totalHeight);
    [_pauseScreenVideoBtn setTitle: NSLocalizedString(@"upload", nil) forState: UIControlStateNormal];
    _pauseScreenVideoBtn.backgroundColor=[UIColor colorWithRed:67/255.0 green:69/255.0 blue:83/255.0 alpha:1.0];
    _pauseScreenVideoBtn.titleLabel.font = [UIFont systemFontOfSize: viewH*16/totalHeight*0.8];
    [_pauseScreenVideoBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _pauseScreenVideoBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_pauseScreenVideoBtn addTarget:nil action:@selector(_pauseScreenVideoBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_pauseScreenVideoView  addSubview:_pauseScreenVideoBtn];
    [self chooseImgViewInit];
    
    if([[self Get_Paths:PAUSE_SCREEN_PHOTO_ENABLE_KEY] compare:@"off"]==NSOrderedSame){
        _pauseScreenPushBtn.on=NO;
    }
    else{
        _pauseScreenPushBtn.on=YES;
    }
    if([self Get_Images:PAUSE_SCREEN_PHOTO_SRC_KEY]==nil){
        _pauseScreenPicturePushImg.image=[UIImage imageNamed:@"stream_pause pic_add_bg@3x.png"];
    }
    else{
        _pauseScreenPicturePushImg.image=[self Get_Images:PAUSE_SCREEN_PHOTO_SRC_KEY];
    }
    if([[self Get_Paths:PAUSE_SCREEN_VIDEO_ENABLE_KEY] compare:@"off"]==NSOrderedSame){
        _pauseScreenVideoPushBtn.on=NO;
    }
    else{
        _pauseScreenVideoPushBtn.on=YES;
    }
    [self Get_Paths:PAUSE_SCREEN_VIDEO_SRC_KEY];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)_chooseLayoutBtnClick:(UIButton*)button{
    NSLog(@"_chooseLayoutBtnClick");
    [self setInfoViewFrame:_chooseImgView :YES];
    switch (button.tag) {
        case 0:
        {
            if(pushType==0){//拍照
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
            else if(pushType==1){//录像
                NSArray * mediaTypes =[UIImagePickerController  availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    _imagePickerController.mediaTypes = @[mediaTypes[1]];
                    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                    [self presentViewController:_imagePickerController animated:YES completion:nil];
                }else {
                    NSLog(@"当前设备不支持录像");
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Note"
                                         message:@"The photo  not support record video"
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
        }
            break;
        case 1:
        {
            if(pushType==0){//照片
                _imagePickerController.mediaTypes= [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
            else if(pushType==1){//视频
                _imagePickerController.mediaTypes= [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:_imagePickerController animated:YES completion:nil];
            }
        }
            break;
        case 2:
        {
            if(pushType==0){//照片
                _pauseScreenPicturePushImg.image =[UIImage imageNamed:@"stream_pause pic_add_bg@3x.png"];
                [self Save_Images:nil :PAUSE_SCREEN_PHOTO_SRC_KEY];
            }
            else if(pushType==1){//视频
                
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)_chooseImgViewCancelClick{
    NSLog(@"_chooseImgViewCancelClick");
    [self setInfoViewFrame:_chooseImgView :YES];
}

//返回
- (void)_backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_pauseScreenPushBtnAction:(UISwitch*)sender{
    if (sender.on) {
        NSLog(@"_pauseScreenPushBtn is on");
        [self Save_Paths:@"on" :PAUSE_SCREEN_PHOTO_ENABLE_KEY];
    }
    else{
        NSLog(@"_pauseScreenPushBtn is off");
        [self Save_Paths:@"off" :PAUSE_SCREEN_PHOTO_ENABLE_KEY];
    }
}

- (void)_pauseScreenPicturePushImgClick{
    NSLog(@"_pauseScreenPicturePushImgClick");
    pushType=0;
    [self setInfoViewFrame:_chooseImgView :NO];
}

- (void)_pauseScreenPicturePushBtnClick{
    NSLog(@"_pauseScreenPicturePushBtnClick");
}

- (void)_pauseScreenVideoPushBtnAction:(UISwitch*)sender{
    if (sender.on) {
        NSLog(@"_pauseScreenVideoPushBtn is on");
        [self Save_Paths:@"on" :PAUSE_SCREEN_VIDEO_ENABLE_KEY];
    }
    else{
        NSLog(@"_pauseScreenVideoPushBtn is off");
        [self Save_Paths:@"off" :PAUSE_SCREEN_VIDEO_ENABLE_KEY];
    }
}

- (void)_pauseScreenVideoImgClick{
    NSLog(@"_pauseScreenVideoImgClick");
    pushType=1;
    [self setInfoViewFrame:_chooseImgView :NO];
}

- (void)_pauseScreenVideoBtnBtnClick{
    NSLog(@"_pauseScreenVideoBtnBtnClick");
}

//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        //如果是图片
        _pauseScreenPicturePushImg.image = [PicBufferUtil scaleImage:info[UIImagePickerControllerOriginalImage] toSize:_pauseScreenPicturePushImg.frame.size];
        [self Save_Images:_pauseScreenPicturePushImg.image :PAUSE_SCREEN_PHOTO_SRC_KEY];
        
//        //压缩图片
//        NSData *fileData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
//        //保存图片至相册
//        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//        //上传图片
//        [self uploadImageWithData:fileData];
        
    }else{
        //如果是视频
        NSURL *url = info[UIImagePickerControllerMediaURL];
        //播放视频
//        _moviePlayer.contentURL = url;
//        [_moviePlayer play];
//        //保存视频至相册（异步线程）
//        NSString *urlStr = [url path];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
//                
//                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//            }
//        });
//        NSData *videoData = [NSData dataWithContentsOfURL:url];
//        //视频上传
//        [self uploadVideoWithData:videoData];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//屏幕常亮
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


@end
