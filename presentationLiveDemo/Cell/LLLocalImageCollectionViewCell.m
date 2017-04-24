//
//  LLLocalImageCollectionViewCell.m
//  GetLocalPhoto01
//
//  Created by lyc on 15/3/31.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "LLLocalImageCollectionViewCell.h"

@implementation LLLocalImageCollectionViewCell

- (void)sendValue:(id)dic
{
    self.imageView.image = [dic objectForKey:@"img"];
    selectFlag = [[dic objectForKey:@"flag"] boolValue];
    if (selectFlag)
    {
        self.selectImageView.image = [UIImage imageNamed:@"image_select"];
        self.selectImageView.frame=CGRectMake(0, 0, 100, 100);
    } else {
        self.selectImageView.image = [UIImage imageNamed:@"image_unselect"];
        self.selectImageView.frame=CGRectMake(0, 0, 100, 100);
    }
}

- (void)setSelectFlag:(BOOL)flag
{
    selectFlag = flag;
    
    if (selectFlag)
    {
        self.selectImageView.image = [UIImage imageNamed:@"image_select"];
        self.selectImageView.frame=CGRectMake(0, 0, 100, 100);
    } else {
        self.selectImageView.image = [UIImage imageNamed:@"image_unselect"];
        self.selectImageView.frame=CGRectMake(0, 0, 100, 100);
    }
}

@end
