//
//  FSStreamViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSStreamViewController.h"
#import "CommonAppHeader.h"
//Controllers
#import "FSPlatformCustomViewController.h"
//Cells
//Views
#import "FSPlatformButtonView.h"
//API

//Models
#import "FSStreamPlatformModel.h"
@interface FSStreamViewController ()
@property (nonatomic,strong) NSMutableArray  <FSStreamPlatformModel *>*platformModelsArray;
@property (weak, nonatomic) IBOutlet FSPlatformButtonView *facebookButtonView;
@property (weak, nonatomic) IBOutlet FSPlatformButtonView *youtubeButtonView;
@property (weak, nonatomic) IBOutlet FSPlatformButtonView *twitchButtonView;
@property (weak, nonatomic) IBOutlet FSPlatformButtonView *customButtonView;
@property (weak, nonatomic) IBOutlet UIView *fakeNavigationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fakeNavigationViewTopConstraint;

@end

@implementation FSStreamViewController

#pragma mark - Setters/Getters
- (NSMutableArray<FSStreamPlatformModel *> *)platformModelsArray {
    if (!_platformModelsArray) {
        _platformModelsArray = @[].mutableCopy;
    }
    return _platformModelsArray;
}

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    [self requestDataSource];
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

- (void)viewDidLayoutSubviews {
    if ([Device currentDeviceSysVerLess:@"11"]) {
        self.fakeNavigationViewTopConstraint.constant = -20.f;
        [self.view layoutIfNeeded];
        [self.view layoutSubviews];
    }
}

#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

- (void)requestDataSource {
    self.platformModelsArray = [CoreStore sharedStore].streamPlatformModels.mutableCopy;
}

#pragma mark – Private methods

- (FSStreamPlatformModel *)getModelWithPlatform:(FSStreamPlatform)platform {
    for (FSStreamPlatformModel * model in self.platformModelsArray) {
        if (model.streamPlatform == platform) {
            return model;
        }
    }
    return [[FSStreamPlatformModel alloc] initWithStreamPlatform:platform];
}

- (void)setupUI {
    
    self.facebookButtonView.model = [self getModelWithPlatform:FSStreamPlatformFaceBook];
    self.youtubeButtonView.model  = [self getModelWithPlatform:FSStreamPlatformYouTube];
    self.twitchButtonView.model   = [self getModelWithPlatform:FSStreamPlatformTwitch];
    self.customButtonView.model   = [self getModelWithPlatform:FSStreamPlatformCustom];
    WEAK(self);
    
    self.facebookButtonView.goConfigureStreamAdressBlock = ^(FSStreamPlatform streamPlatform) {
        
    };
    self.youtubeButtonView.goConfigureStreamAdressBlock = ^(FSStreamPlatform streamPlatform) {
        
    };
    self.twitchButtonView.goConfigureStreamAdressBlock = ^(FSStreamPlatform streamPlatform) {
        
    };
    self.customButtonView.goConfigureStreamAdressBlock = ^(FSStreamPlatform streamPlatform) {
        FSPlatformCustomViewController *customVC = [[FSPlatformCustomViewController alloc] init];
        [weakself.navigationController pushViewController:customVC animated:YES];
    };
//
    self.facebookButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.facebookButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
        [weakself.youtubeButtonView setButtonDisselected];
        [weakself.twitchButtonView setButtonDisselected];
        [weakself.customButtonView setButtonDisselected];
    };
    self.youtubeButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.youtubeButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
        [weakself.facebookButtonView setButtonDisselected];
        [weakself.twitchButtonView setButtonDisselected];
        [weakself.customButtonView setButtonDisselected];
    };
    self.twitchButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.twitchButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
        [weakself.facebookButtonView setButtonDisselected];
        [weakself.youtubeButtonView setButtonDisselected];
        [weakself.customButtonView setButtonDisselected];
    };
    self.customButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.customButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
        [weakself.facebookButtonView setButtonDisselected];
        [weakself.youtubeButtonView setButtonDisselected];
        [weakself.twitchButtonView setButtonDisselected];
    };
    
}

#pragma mark – Target action methods

- (IBAction)backButtonClicked:(UIButton *)sender {
    
    if (self.isPressented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods
- (void)dealloc {
    NSLog(@"----------------dealloc streamVC------------");
}
#pragma mark – Delegate

@end
