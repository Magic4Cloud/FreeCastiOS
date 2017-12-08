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
#import "FSPlatformFacebookViewController.h"
#import "FSLiveViewViewController.h"

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
@property (weak, nonatomic) IBOutlet UIView *fakeNavigationAndStatusBarView;
@property (weak, nonatomic) IBOutlet UIView *BGView;

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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isPressented) {
//        [self.navigationController setNavigationBarHidden:YES];
        
        
    } else {
        [self.navigationController setNavigationBarHidden:NO];
        self.fakeNavigationAndStatusBarView.hidden = YES;
        
        [self.fakeNavigationAndStatusBarView removeFromSuperview];
        
        NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.BGView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:64];
        [self.view addConstraint:constraint];
    }
    
    [self requestDataSource];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveModelsToLocal];
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    if ([Device currentDeviceSysVerLess:@"11"]) {
//        self.fakeNavigationViewTopConstraint.constant = -20.f;
//        [self.view layoutIfNeeded];
//        [self.view layoutSubviews];
    }
}

#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

- (void)requestDataSource {
    
    self.platformModelsArray = [CoreStore sharedStore].streamPlatformModels.mutableCopy;
    
    for (FSStreamPlatformModel *model in self.platformModelsArray) {
        NSLog(@"--------------model.streamPlatform = --%ld",(long)model.streamPlatform);
    }
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
        [weakself saveModelsToLocal];
        FSPlatformFacebookViewController *facebookVC = [[FSPlatformFacebookViewController alloc] init];
        [weakself.navigationController pushViewController:facebookVC animated:YES];
    };
    self.youtubeButtonView.goConfigureStreamAdressBlock = ^(FSStreamPlatform streamPlatform) {
        [weakself saveModelsToLocal];
    };
    self.twitchButtonView.goConfigureStreamAdressBlock = ^(FSStreamPlatform streamPlatform) {
        [weakself saveModelsToLocal];
    };
    self.customButtonView.goConfigureStreamAdressBlock = ^(FSStreamPlatform streamPlatform) {
        
        [weakself saveModelsToLocal];
        FSPlatformCustomViewController *customVC = [[FSPlatformCustomViewController alloc] init];
        [weakself.navigationController pushViewController:customVC animated:YES];
    };
//
    self.facebookButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.facebookButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
//        [weakself.youtubeButtonView setButtonDisselected];
//        [weakself.twitchButtonView setButtonDisselected];
//        [weakself.customButtonView setButtonDisselected];
    };
    self.youtubeButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.youtubeButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
//        [weakself.facebookButtonView setButtonDisselected];
//        [weakself.twitchButtonView setButtonDisselected];
//        [weakself.customButtonView setButtonDisselected];
    };
    self.twitchButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.twitchButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
//        [weakself.facebookButtonView setButtonDisselected];
//        [weakself.youtubeButtonView setButtonDisselected];
//        [weakself.customButtonView setButtonDisselected];
    };
    self.customButtonView.selectStreamPlatformBlock = ^(FSStreamPlatform streamPlatform) {
        weakself.customButtonView.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
//        [weakself.facebookButtonView setButtonDisselected];
//        [weakself.youtubeButtonView setButtonDisselected];
//        [weakself.twitchButtonView setButtonDisselected];
    };
    
}

- (void)updatePlatformUI {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.facebookButtonView updateUIWhileDataSoureceChange];
        [self.youtubeButtonView  updateUIWhileDataSoureceChange];
        [self.twitchButtonView   updateUIWhileDataSoureceChange];
        [self.customButtonView   updateUIWhileDataSoureceChange];
    });
}

#pragma mark – Target action methods

- (IBAction)backButtonClicked:(UIButton *)sender {
    if (self.isPressented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)gotoLiveViewVC:(UIButton *)sender {
    
    if (self.isPressented) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        [self.navigationController popViewControllerAnimated:NO];

        FSLiveViewViewController *liveViewController = [[FSLiveViewViewController alloc] init];
        
        MMDrawerController *sideMenuController = (MMDrawerController *)  self.view.window.rootViewController;
        
        [sideMenuController.centerViewController presentViewController:liveViewController animated:YES completion:^{}];
    }
}

- (void)saveModelsToLocal {
    [CoreStore sharedStore].streamPlatformModels = @[self.facebookButtonView.model,self.youtubeButtonView.model,self.twitchButtonView.model,self.customButtonView.model].copy;
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
