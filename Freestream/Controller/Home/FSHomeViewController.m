//
//  FSHomeViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSHomeViewController.h"
#import "FSHomePageButtonView.h"
#import "CommonAppHeader.h"

@interface FSHomeViewController ()<FSHomePageButtonViewDelegate,LGSideMenuDelegate>
@property (weak, nonatomic) IBOutlet UIView               *effectView;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *liveViewButton;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *streamButton;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *configureButton;
@property (weak, nonatomic) IBOutlet FSHomePageButtonView *browseButton;

@end

@implementation FSHomeViewController

#pragma mark - Setters/Getters


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtonViews];
    [self addEffectViewForBgImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
- (void)setupButtonViews{

    [self.liveViewButton  setupButtonViewWithTag:FSHomePageButtonLiveView];
    [self.streamButton    setupButtonViewWithTag:FSHomePageButtonStream];
    [self.configureButton setupButtonViewWithTag:FSHomePageButtonConfigure];
    [self.browseButton    setupButtonViewWithTag:FSHomePageButtonBrowse];
    
    self.liveViewButton.delegate  = self;
    self.streamButton.delegate    = self;
    self.configureButton.delegate = self;
    self.browseButton.delegate    = self;
}

- (void)addEffectViewForBgImage {
    //实现模糊效果
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //毛玻璃视图
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    visualEffectView.alpha = 0.4;
    [self.effectView addSubview:visualEffectView];
    visualEffectView.frame = [UIScreen mainScreen].bounds;

}
#pragma mark – Target action methods

- (IBAction)showLeftMenu:(UIButton *)sender {
    [self showLeftViewAnimated:nil];
}

- (IBAction)selectedLiveViewButton:(UIButton *)sender {
}

- (IBAction)selectedStreamButton:(UIButton *)sender {
}

- (IBAction)selectedConfigureButton:(UIButton *)sender {
}

- (IBAction)selectedBrowseButton:(UIButton *)sender {
}

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate
- (void)buttonViewDidSelected:(FSHomePageButtonTag)tag {
    switch (tag) {
        case FSHomePageButtonLiveView:
            [self performSelector:@selector(selectedLiveViewButton:) withObject:nil];
            break;
        case FSHomePageButtonStream:
            [self performSelector:@selector(selectedStreamButton:) withObject:nil];
            break;
        case FSHomePageButtonConfigure:
            [self performSelector:@selector(selectedConfigureButton:) withObject:nil];
            break;
        case FSHomePageButtonBrowse:
            [self performSelector:@selector(selectedBrowseButton:) withObject:nil];
            break;
        default:
            break;
    }
}


@end
