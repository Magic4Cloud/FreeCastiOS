//
//  FSBrowseViewController.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/21.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSBrowseViewController.h"
//Utility
#import "FSMediaManager.h"
//Cells
#import "FSPhotoCollectionViewCell.h"
#import "FSVideoCollectionViewCell.h"


typedef NS_ENUM(NSInteger, FSSegmentedControlSelected) {
    FSSegmentedControlSelectedPhoto = 0,
    FSSegmentedControlSelectedVideo,
};

@interface FSBrowseViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIButton           *selectButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UICollectionView   *collectionView;

@property (nonatomic,strong) NSMutableArray             *dataSourceArray;

@end

@implementation FSBrowseViewController

#pragma mark - Setters/Getters
-(NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        _dataSourceArray =@[].mutableCopy;
        
    }
    return _dataSourceArray;
}

- (UICollectionViewFlowLayout *) buildingCollectionFlowLayout {
    CGFloat margin = 15;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = [FSPhotoCollectionViewCell photoCollectionViewCellSize];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(margin,margin,margin,margin);
    return flowLayout;
}

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDataSource];
    [self collectionViewSettings];
    
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

- (void)getDataSource {
    self.dataSourceArray = [FSMediaManager getAllPhotoWithsize:CGSizeMake(100, 100) resizeMode:PHImageRequestOptionsResizeModeFast].mutableCopy;
    [self.collectionView reloadData];
}

#pragma mark – Private methods
- (void)collectionViewSettings {
    self.collectionView.collectionViewLayout = [self buildingCollectionFlowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor redColor];
}
#pragma mark – Target action methods

#pragma mark - IBActions
- (IBAction)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.segmentControl.selectedSegmentIndex == FSSegmentedControlSelectedPhoto) {
        FSPhotoCollectionViewCell *cell = [FSPhotoCollectionViewCell reusableCellDequeueCollectionView:collectionView forIndexPath:indexPath];
        cell.photoImageView.image = self.dataSourceArray[indexPath.row];
        return cell;
    }else {
        FSVideoCollectionViewCell *cell = [FSVideoCollectionViewCell reusableCellDequeueCollectionView:collectionView forIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}



@end
