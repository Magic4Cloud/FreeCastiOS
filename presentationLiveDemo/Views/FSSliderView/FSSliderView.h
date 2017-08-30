//
//  FSSliderView.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "CoreUIView.h"
#import "FSRecombinationLabel.h"
@interface FSSliderView : CoreDesignableXibUIView

@property (weak, nonatomic) IBOutlet FSRecombinationLabel *keyRecombinationLabel;

@property (weak, nonatomic) IBOutlet FSRecombinationLabel *leftRecombinationLabel;

@property (weak, nonatomic) IBOutlet FSRecombinationLabel *rightRecombinationLabel;

@property (weak, nonatomic) IBOutlet UISlider             *slider;

@property (nonatomic,assign) BOOL            rightValueHiden;//default is NO
@property (nonatomic,assign) BOOL            leftValueHiden;//default is NO
@property (nonatomic,assign) BOOL            keyValueHiden;//key Value Label is over the sliderThumb,keyValueLabel.centerX always equal to sliderThumb.centerX ; defult is NO
@property (nonatomic,assign) NSDecimalNumber *sliderMaxValue;
@property (nonatomic,assign) NSDecimalNumber *sliderMinValue;

@property (nonatomic,strong) UIFont          *labelsFont;
@property (nonatomic,strong) UIColor         *rightValueColor;
@property (nonatomic,strong) UIColor         *leftValueColor;
@property (nonatomic,strong) UIColor         *keyValueColor;

- (void)setUpHidenLeftValueLabel:(BOOL)hidenLeftValueLabel hidenRightValueLabel:(BOOL)hidenRightValueLabel hidenKeyValueLabel:(BOOL)hidenKeyValueLabel labelFont:(UIFont *_Nullable)labelsfont leftValueColor:(UIColor *_Nullable)leftValueColor rightValueColor:(UIColor *_Nullable)rightValueColor keyValueColor:(UIColor *_Nullable)keyValueColor maxValue:(NSDecimalNumber *_Nullable)maxValue minValue:(NSDecimalNumber *_Nullable)minValue;
@end
