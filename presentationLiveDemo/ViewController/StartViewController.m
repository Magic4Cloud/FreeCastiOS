//
//  StartViewController.m
//  presentationLiveDemo
//
//  Created by 周恒 on 2017/7/24.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "StartViewController.h"
#import "CommanParameters.h"

@interface StartViewController ()
{
    NSInteger count;
}

@property (nonatomic, strong)NSTimer * timer;
@property (nonatomic, strong) UIImageView *logoImage;
@property (nonatomic, strong) UIView * progressBarView;
@property (nonatomic, strong) UIView *moveProgressView;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:42/255.0 alpha:1.0];
    [self.view addSubview:self.logoImage];
    [self.view addSubview:self.progressBarView];
    [self.view addSubview:self.moveProgressView];
    count = 1;
    [self timerBegin];
    
    // Do any additional setup after loading the view.
}

- (void)dismissSelf
{
    if (self.dismissSelfBlock) {
        self.dismissSelfBlock();
    }
}


- (void)timerCount:(NSTimer *)tim
{
    if (count == 0)
    {
        [self dismissSelf];
        [tim invalidate];
        tim = nil;
    }
    count -- ;
}

- (void)timerBegin
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerCount:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    [UIView animateWithDuration:2 animations:^{
        self.moveProgressView.frame = CGRectMake(viewW*77/totalWeight, viewH*357.5/totalHeight, viewH*221/totalHeight, viewH*2/totalHeight);
    } completion:^(BOOL finished) {
        self.moveProgressView.frame = CGRectMake(viewW*77/totalWeight, viewH*357.5/totalHeight, viewH*1/totalHeight, viewH*2/totalHeight);
    }];
}


- (UIImageView * )logoImage
{
    if (!_logoImage) {
        _logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(viewW*158.5/totalWeight, viewH*259.5/totalHeight, viewH*58.5/totalHeight, viewH*58.5/totalHeight)];
        _logoImage.image = [UIImage imageNamed:@"logo_118"];
        
    }
    return _logoImage;
}


- (UIView *)progressBarView {
    if (!_progressBarView) {
        _progressBarView = [[UIView alloc] initWithFrame:CGRectMake(viewW*77/totalWeight, viewH*357.5/totalHeight, viewH*221/totalHeight, viewH*2/totalHeight)];
        _progressBarView.backgroundColor = [UIColor colorWithRed:80/255.0 green:100/255.0 blue:108/255.0 alpha:1.0];
    }
    return _progressBarView;
}

- (UIView *)moveProgressView {
    if (!_moveProgressView) {
        _moveProgressView = [[UIView alloc] initWithFrame:CGRectMake(viewW*77/totalWeight, viewH*357.5/totalHeight, viewH*1/totalHeight, viewH*2/totalHeight)];
        _moveProgressView.backgroundColor = MAIN_COLOR;
    }
    return _moveProgressView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
