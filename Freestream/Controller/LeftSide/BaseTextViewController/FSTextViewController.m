//
//  FSTextViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/10.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSTextViewController.h"
#import "CommonAppHeader.h"
@interface FSTextViewController ()
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (nonatomic,strong) NSArray <NSString *>*dataSource;
@end

@implementation FSTextViewController

#pragma mark - Setters/Getters
- (NSArray<NSString *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [FSLeftSideModel getLeftSideViewControllersContents].copy;
    }
    return _dataSource;
}
#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextView];
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

#pragma mark – Private methods
- (void)setupTextView {
    self.contentTextView.text = self.dataSource[self.leftSideTitleTag];
}
#pragma mark – Target action methods

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate


@end
