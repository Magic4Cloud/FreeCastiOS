//
//  TTPlatformSelectViewController.m
//  presentationLiveDemo
//
//  Created by tc on 6/28/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTPlatformSelectViewController.h"
#import "TTPlatFormCell.h"
#import "CollectionHeaderView.h"
#import "CollectionReusableFooterView.h"


#import "TTCoreDataClass.h"

#import "TTYoutubuViewController.h"

@interface TTPlatformSelectViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray<PlatformModel *> * platformsArray;
@end

@implementation TTPlatformSelectViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)initData
{
    NSArray * array = [[TTCoreDataClass shareInstance] localAllPlatforms];
    _platformsArray = [NSMutableArray arrayWithArray:array];
    
}

- (void)initUI
{
    self.title = @"Stream";
    
    self.view.backgroundColor = [UIColor TTBackLightGrayColor];
    //顶部
    UIImageView *  _topBg=[[UIImageView alloc] initWithImage:nil];
    _topBg.backgroundColor = [UIColor whiteColor];
    _topBg.frame = CGRectMake(0, 0, ScreenWidth, 64);
    _topBg.contentMode=UIViewContentModeScaleToFill;
    [self.view addSubview:_topBg];
    
     UIButton * _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(0, 20, 44, 44);
    [_backBtn setImage:[UIImage imageNamed:@"nav_icon_back_pre@3x.png"] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _backBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_backBtn addTarget:nil action:@selector(_backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_backBtn];
    
     UILabel * _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, ScreenWidth - 80*2, 44)];

    _titleLabel.text = @"Stream";
    _titleLabel.font = [UIFont systemFontOfSize: 20];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor TTLightBlueColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TTPlatFormCell" bundle:nil] forCellWithReuseIdentifier:@"TTPlatFormCell"];

    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionReusableFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionReusableFooterView"];
    
}

#pragma mark - actions
- (void)_backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goliVeNowButtonClick
{
    
}

#pragma mark - praivate methods
- (PlatformModel *)getPlatformByName:(NSString *)name
{
    __block PlatformModel * model = nil;
    [_platformsArray enumerateObjectsUsingBlock:^(PlatformModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:name]) {
            model = obj;
            *stop = YES;
        }
    }];
    
    return model;
}

#pragma mark - collectionView  delegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    return 3;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        CollectionHeaderView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView" forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            view.headerLabel.text = @"Live Platform";
        }
        else
        {
            view.headerLabel.text = @"Personalize your Live Stream";
        }
        reusableview = view;
    }
    else if (kind == UICollectionElementKindSectionFooter)
    {
        CollectionReusableFooterView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionReusableFooterView" forIndexPath:indexPath];
        
        [footerView.button addTarget:self action:@selector(goliVeNowButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.section == 1) {
            reusableview = footerView;

        }
        
    }

    return reusableview;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeZero;
    }
    return CGSizeMake(ScreenWidth, 100);
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTPlatFormCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTPlatFormCell" forIndexPath:indexPath];
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0://facebook
            {
                cell.model = [self getPlatformByName:faceBook];
            }
                break;
            case 1://youtubu
            {
                cell.model = [self getPlatformByName:youtubu];
            }
                break;
            case 2://uStream
            {
                cell.model = [self getPlatformByName:uStream];
            }
                break;
            case 3://Twitch
            {
                cell.model = [self getPlatformByName:twitch];
            }
                break;
            case 4://LiveStream
            {
                cell.model = [self getPlatformByName:liveStream];
            }
                break;
            case 5://Custom
            {
                cell.model = [self getPlatformByName:custom];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        TTPlatFormCell * cell = (TTPlatFormCell *)[collectionView cellForItemAtIndexPath:indexPath];
        PlatformModel * model = cell.model;
        if(cell.cellEditButton.hidden)
        {
            
        }
        switch (indexPath.row) {
            case 0://facebook
            {
                
            }
                break;
            case 1://youtubu
            {
                TTYoutubuViewController * vc = [[TTYoutubuViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2://uStream
            {
                
            }
                break;
            case 3://Twitch
            {
                
            }
                break;
            case 4://LiveStream
            {
                
            }
                break;
            case 5://Custom
            {
                
            }
                break;
                
            default:
                break;
        }

    }
    else
    {
        
    }
    
    
}


#pragma mark - setter
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat sizeWidth = ScreenWidth/3;
        layout.itemSize = CGSizeMake(sizeWidth, sizeWidth);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.headerReferenceSize = CGSizeMake(ScreenWidth, 45);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64,ScreenWidth , ScreenHeight-64) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor TTBackLightGrayColor];
        }
    return _collectionView;
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
