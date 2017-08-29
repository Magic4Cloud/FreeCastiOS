//
//  CollectionViewCell.m
//  collectionView
//
//  Created by shikee_app05 on 14-12-10.
//  Copyright (c) 2014年 shikee_app05. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        self.text = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 40)];
        self.text.backgroundColor = [UIColor clearColor];
        self.text.textColor=[UIColor colorWithRed:48/255.0 green:60/255.0 blue:82/255.0 alpha:1.0];
        self.text.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.text];
        
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [self.selectImageView setContentMode:UIViewContentModeScaleAspectFill];
        self.selectImageView.clipsToBounds = YES;
        self.imgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imgView];
        
        self.selectImageView= [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-CGRectGetWidth(self.frame)*44/119, 0, CGRectGetWidth(self.frame)*44/119, CGRectGetHeight(self.frame)*44/119)];
        self.selectImageView.backgroundColor = [UIColor clearColor];
        [self.selectImageView setContentMode:UIViewContentModeScaleAspectFill];
        self.selectImageView.clipsToBounds = YES;
        //self.selectImageView.image=self.selectImageView.image = [UIImage imageNamed:@"Browse_edit_def_icon@3x"];
        [self.imgView addSubview:self.selectImageView];
        
        self.videoInfoView=[[UIView alloc]init];
        self.videoInfoView.frame=CGRectMake(0, CGRectGetHeight(self.frame)-CGRectGetHeight(self.frame)*27/119, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*27/119);
        self.videoInfoView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self.imgView addSubview:self.videoInfoView];
        
        self.videoImageView= [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)*8/119, 0, CGRectGetWidth(self.frame)*17/119, CGRectGetHeight(self.frame)*10/119)];
        self.videoImageView.center=CGPointMake(self.videoImageView.center.x, self.videoInfoView.center.y);
        self.videoImageView.backgroundColor = [UIColor clearColor];
        [self.videoImageView setContentMode:UIViewContentModeScaleAspectFill];
        self.videoImageView.clipsToBounds = YES;
        self.videoImageView.image=self.selectImageView.image = [UIImage imageNamed:@"Browse_videos_camera_icon@3x"];
        [self.imgView addSubview:self.videoImageView];

        self.videoTimeLabel= [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-CGRectGetWidth(self.frame)*54/119, 0, CGRectGetWidth(self.frame)*48/119, CGRectGetHeight(self.frame)*15/119)];
        self.videoTimeLabel.center=CGPointMake(self.videoTimeLabel.center.x, self.videoInfoView.center.y);
        self.videoTimeLabel.backgroundColor = [UIColor clearColor];
        self.videoTimeLabel.textColor=[UIColor whiteColor];
        self.videoTimeLabel.textAlignment = NSTextAlignmentRight;
        self.videoTimeLabel.font=[UIFont fontWithName:nil size:CGRectGetHeight(self.frame)*15/119];
        self.videoTimeLabel.text=@"00:50";
        [self.imgView addSubview:self.videoTimeLabel];
        
        self.videoInfoView.hidden=YES;
        self.videoImageView.hidden=YES;
        self.videoTimeLabel.hidden=YES;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)sendValue:(id)dic
{
    self.videoInfoView.hidden=YES;
    self.videoImageView.hidden=YES;
    self.videoTimeLabel.hidden=YES;
    self.imgView.image = [dic objectForKey:@"img"];
    if ([[dic objectForKey:@"flag"] compare: @""]==NSOrderedSame) {
        self.selectImageView.hidden=YES;
        return;
    }
    
    selectFlag = [[dic objectForKey:@"flag"] boolValue];
    if (selectFlag)
    {
        self.selectImageView.hidden=NO;
        self.selectImageView.image = [UIImage imageNamed:@"edit_sel@3x"];
    } else {
        self.selectImageView.hidden=NO;
        self.selectImageView.image = [UIImage imageNamed:@"edit_nor@3x"];
    }
}

- (void)sendVideoValue:(NSString*)time
{
    self.videoInfoView.hidden=NO;
    self.videoImageView.hidden=NO;
    self.videoTimeLabel.hidden=NO;
    self.videoTimeLabel.text=time;
}

- (void)setSelectFlag:(BOOL)flag
{
    selectFlag = flag;
    
    if (selectFlag)
    {
        self.selectImageView.image = [UIImage imageNamed:@"edit_sel@3x"];
    } else {
        self.selectImageView.image = [UIImage imageNamed:@"edit_nor@3x"];
    }
}

- (void)removeText
{
    [self.text removeFromSuperview];
}

@end
