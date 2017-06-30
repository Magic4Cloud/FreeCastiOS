//
//  TTYoutubuViewController.m
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTYoutubuViewController.h"

#import "WebViewController.h"

static const NSString * client_id = @"945244505483-5ehvap33vg7mksb8b5981fmrknq82eiq.apps.googleusercontent.com";
static const NSString * client_secret = @"eGP1p47CilC4AAy3G8Gk6Mk4";

@interface TTYoutubuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;

@property (weak, nonatomic) IBOutlet UIButton *codeButton;

@property (nonatomic, strong)NSDictionary * dict;

@property (nonatomic, strong)NSDictionary * accessTokenDic;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity2;

@end

@implementation TTYoutubuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self deviceSigin];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_dict) {
        [self getaccesstoken];
    }
}
- (void)getaccesstoken {
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v4/token"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    
    NSString * device_code = _dict[@"device_code"];
    //5.设置请求体
    
    NSString * body = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@&grant_type=http://oauth.net/grant_type/device/1.0",client_id,client_secret,device_code];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    
    [_activity2 startAnimating];
    NSLog(@"request:%@",[request description]);
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        _accessTokenDic = dict;
        [self getstream];
        dispatch_async(dispatch_get_main_queue(), ^{
//            _accessTokenTextView.text = [dict description];
        });
        
    }];
    
    //7.执行任务
    [dataTask resume];
    
    
}
- (void)getstream {
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/youtube/v3/liveBroadcasts.list?part=id,snippet,cdn,status&mine=true"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"GET";
    
    //5.设置请求体
    NSString * accessToken =  [NSString stringWithFormat:@"Bearer %@",_accessTokenDic[@"access_token"]];
    
    //    NSString * body = [NSString stringWithFormat:@"part=id,snippet,cdn,status"];
    //    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:accessToken forHTTPHeaderField:@"Authorization"];
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    
    NSLog(@"request:%@",[request description]);
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_activity2 stopAnimating];
//            [self showAlert:@"结果" message:[dict description]];
        });
        
    }];
    
    //7.执行任务
    [dataTask resume];
    
}



- (void)deviceSigin
{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/device/code"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    NSString * body = [NSString stringWithFormat:@"client_id=%@&scope=https://www.googleapis.com/auth/youtube",client_id];
    //5.设置请求体
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    
    [_activityView startAnimating];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        _dict = dict;
        /*{
         "device_code" = "AH-1Ng20hn4D2lrWqNGroXvMl_5UjHEWi5BS8bb8s4yJijMfDqjGZLl5ZWM3j3Mg1MUJKQHBuSfj7ufWjHplcM2nVlQrZrMARQ";
         "expires_in" = 1800;
         interval = 5;
         "user_code" = "CXVH-FJZC";
         "verification_url" = "https://www.google.com/device";
         }*/
        dispatch_async(dispatch_get_main_queue(), ^{
            [_codeButton setTitle:dict[@"user_code"] forState:UIControlStateNormal];
//            _textFiled.text = dict[@"user_code"];
//            _accessTokenTextView.text = [dict description];
//            UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
//            [pasteboard setString:_textFiled.text];
            [_activityView stopAnimating];
        });
        
    }];
    
    //7.执行任务
    [dataTask resume];
}

- (void)initUI
{
    [self configNavigationWithTitle:@"Authentication" rightButtonTitle:@"Done"];

    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"Go to http://www.google.com/device and paste the code displayed above"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor TTLightBlueColor] range:NSMakeRange(5, 29)];
    
    _linkLabel.attributedText = string;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkLabelClick)];
    [_linkLabel addGestureRecognizer:tap];
    _linkLabel.userInteractionEnabled = YES;
    
    
}

#pragma mark - actions  
//done
- (void)TTRightButtonClick
{
    
}


- (void)linkLabelClick
{
    WebViewController * vc = [[WebViewController alloc] init];
    vc.url = _dict[@"verification_url"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)copyCodeButtonClick:(id)sender {
    UIButton * button = (UIButton *)sender;
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = button.currentTitle;
    
    [self showHudMessage:@"Has been copied!"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
