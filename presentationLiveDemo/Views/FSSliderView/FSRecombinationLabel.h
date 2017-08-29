//
//  RecombinationLabel.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "CoreUIView.h"

@interface FSRecombinationLabel : CoreDesignableXibUIView
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *suffixLabel;

@property (nonatomic,assign) CGFloat    keyValue;
@property (nonatomic,copy  ) NSString   *suffixString;//单位
@property (nonatomic,strong) UIFont     *labelsFont;
@property (nonatomic,strong) UIColor    *labelsColor;

@property (nonatomic,assign) BOOL       needCarry;//是否需要进位
@property (nonatomic,assign) NSUInteger  carryValue;//例1024KB=1MB,1024就是进制数
@property (nonatomic,copy  ) NSString   *carryForwardString;//进位一次后的单位

@end
