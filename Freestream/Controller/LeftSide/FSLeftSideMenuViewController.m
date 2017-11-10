//
//  FSLeftSideMenuViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSLeftSideMenuViewController.h"
#import "FSLeftSideTableViewCell.h"
#import "CommonAppHeader.h"

static NSInteger const KCellCount = 4;

@interface FSLeftSideMenuViewController ()<UITableViewDelegate,UITableViewDataSource,FSLeftSideTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong,nonnull) NSMutableArray <NSString *>*dataSource;
@end

@implementation FSLeftSideMenuViewController
#pragma mark - Setters/Getters

- (NSMutableArray<NSString *> *)dataSource {
    if (!_dataSource) {
        _dataSource = @[NSLocalizedString(@"Version", nil),
                        NSLocalizedString(@"Disclaimer", nil),
                        NSLocalizedString(@"Privacy Policy", nil),
                        NSLocalizedString(@"Copyright", nil),].mutableCopy;
    }
    return _dataSource;
}

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
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

#pragma mark – Private methods
- (void)setupUI {
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.colors = @[(__bridge id)[UIColor whiteColor].CGColor, (__bridge id)[UIColor FSMainTextNormalColor].CGColor];
    layer.locations = @[@0.382, @1.0];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 1);
    layer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer addSublayer:layer];
    [self.view bringSubviewToFront:self.tableView];
    [self.view bringSubviewToFront:self.logoImageView];
    
}
#pragma mark – Target action methods

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSLeftSideTableViewCell * cell = [FSLeftSideTableViewCell reusableCellDequeueTableView:tableView];
    [cell setupTitleButton:self.dataSource[indexPath.row]];
    cell.tag = indexPath.row;
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return KCellCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FSLeftSideTableViewCell heightForLeftSideMenu];
}
#pragma mark - FSLeftSideTableViewCellDelegate

- (void)didSelectedCell:(FSLeftSideTitle)cellTitle {
    switch (cellTitle) {
        case FSLeftSideTitleVersion:
            
            break;
        case FSLeftSideTitleDisclaimer:
            
            break;
        case FSLeftSideTitlePrivacyPolicy:
            
            break;
        case FSLeftSideTitleCopyRight:
            
            break;
    }
}

@end
