//
//  FSSubtitleViewController.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSSubtitleViewController.h"

@interface FSSubtitleViewController ()

@end

@implementation FSSubtitleViewController

#pragma mark - Setters/Getters


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestDataSource];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (void)requestDataSource {
    
    
}

#pragma mark – Private methods

#pragma mark – Target action methods

#pragma mark - IBActions
- (IBAction)fontSizeButtonClickedAction:(UIButton *)sender {
}
- (IBAction)selectColorButtonClickedAction:(UIButton *)sender {
}
- (IBAction)showTypeButtonClickedAction:(UIButton *)sender {
}
- (IBAction)DisplaySwitchTurnOffOrTurnOn:(UISwitch *)sender {
}
- (IBAction)backButtonClickedAction:(UIButton *)sender {
}

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate


@end
