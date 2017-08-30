//
//  RecombinationLabel.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "CoreUIView.h"

@interface FSRecombinationLabel : CoreDesignableXibUIView
@property (weak, nonatomic) IBOutlet UILabel     *keyMianValueLabel;
@property (weak, nonatomic) IBOutlet UILabel     *suffixStrLabel;

@property (nonatomic,assign) CGFloat             centerX;

@property (nonatomic,assign) CGFloat             keyMainValue;
@property (nonatomic,copy  ) NSString            *suffixStr;//单位
@property (nonatomic,strong,nullable) UIFont     *labelsFont;
@property (nonatomic,strong,nullable) UIColor    *labelsColor;

@property (nonatomic,assign) BOOL                needCarry;//是否需要进位
@property (nonatomic,assign) NSUInteger          carryValue;//例1024KB=1MB,1024就是进制数
@property (nonatomic,copy  ) NSString            *_Nonnull carryForwardString;//进位一次后的单位


- (void)setupUseDefaultConfiguration;

- (void)setupLabelsColor:(UIColor *_Nullable)labelsColor labelsFont:(UIFont *_Nullable)labelsFont suffixString:(NSString *_Nullable)suffixString carrayValue:(NSUInteger)carryValue carryForwardString:(NSString *_Nonnull)carryForwardString;

- (void)setupLabelsColor:(UIColor *_Nullable)labelsColor labelsFont:(UIFont *_Nullable)labelsFont suffixString:(NSString *_Nullable)suffixString;

@end
