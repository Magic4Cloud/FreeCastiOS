//
//  FSSliderView.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "CoreUIView.h"

@interface FSSliderView : CoreDesignableXibUIView
@property (nonatomic,assign) BOOL            rightValueHiden;//default is NO
@property (nonatomic,assign) BOOL            leftValueHiden;//default is NO
@property (nonatomic,assign) BOOL            keyValueHiden;//key Value Label is over the sliderThumb,keyValueLabel.centerX always equal to sliderThumb.centerX ; defult is NO
@property (nonatomic,assign) NSDecimalNumber *sliderMaxValue;
@property (nonatomic,assign) NSDecimalNumber *sliderMinValue;

@property (nonatomic,strong) UIFont          *labelsFont;
@property (nonatomic,strong) UIColor         *rightValueColor;
@property (nonatomic,strong) UIColor         *leftValueColor;
@property (nonatomic,strong) UIColor         *keyValueColor;


@end
