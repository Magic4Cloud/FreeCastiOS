//
//  MainImageViewBtn.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2017/3/27.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainImageViewBtn : UIButton
@property(nonatomic ,strong)UILabel *text;
@property(nonatomic ,strong)UIImageView *imgView;
@property(nonatomic ,strong)UIColor *color;

- (id)initWithFrame:(CGRect)frame;
- (void)draw:(UIColor*)color;
@end
