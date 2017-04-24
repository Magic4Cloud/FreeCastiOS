//
//  BrowseViewController.h
//  FreeCast
//
//  Created by rakwireless on 2016/10/11.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UIButton *_editBtn;
    UISegmentedControl *segmentedControl;
    
    UIView *_bottomBg;
    UIButton *_deleteBtn;
    UILabel *_deleteLabel;
    UIButton *_shareBtn;
    UILabel *_shareLabel;
}
@property (nonatomic,strong)UICollectionView *collectionView;
@end
