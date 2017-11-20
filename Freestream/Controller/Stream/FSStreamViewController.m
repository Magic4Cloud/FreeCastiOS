//
//  FSStreamViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/17.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSStreamViewController.h"

@interface FSStreamViewController ()

@end

@implementation FSStreamViewController

#pragma mark - Setters/Getters


#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestDataSource];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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

- (IBAction)dismiss:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)push:(UIButton *)sender {
    [self.navigationController pushViewController:[[UIViewController alloc] init] animated:YES];
}

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate

@end
