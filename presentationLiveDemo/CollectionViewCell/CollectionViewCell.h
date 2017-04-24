//
//  CollectionViewCell.h
//  collectionView
//
//  Created by shikee_app05 on 14-12-10.
//  Copyright (c) 2014年 shikee_app05. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
{
    int selectFlag;
}
@property(nonatomic ,strong)UILabel *text;
@property(nonatomic ,strong)UIImageView *imgView;
@property(nonatomic ,strong)UIImageView *selectImageView;
@property(nonatomic ,strong)UIView *videoInfoView;
@property(nonatomic ,strong)UIImageView *videoImageView;
@property(nonatomic ,strong)UILabel *videoTimeLabel;
- (void)sendValue:(id)dic;
- (void)setSelectFlag:(int)flag;
- (void)removeText;
- (void)sendVideoValue:(NSString*)time;

@end
