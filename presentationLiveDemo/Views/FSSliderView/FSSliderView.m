//
//  FSSliderView.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSSliderView.h"

@interface FSSliderView()
@property (weak, nonatomic) IBOutlet UILabel                      *keyValueLabel;
@property (weak, nonatomic) IBOutlet UILabel                      *rightValueLabel;
@property (weak, nonatomic) IBOutlet UILabel                      *leftValueLabel;
@property (weak, nonatomic) IBOutlet UISlider                     *slider;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsCollection;

@end
@implementation FSSliderView

- (void)setup {
    [super setup];
    
    [self setupLabelsText];
    [self setupLabelsFont];
    [self setupLabelsColor];
    [self setupHidenViews];
    [self setupSliderMaxValueAndMinValue];
}

- (void)setUpHidenLeftValueLabel:(BOOL)hidenLeftValueLabel hidenRightValueLabel:(BOOL)hidenRightValueLabel hidenKeyValueLabel:(BOOL)hidenKeyValueLabel labelFont:(nullable UIFont*)labelsfont leftValueColor:(nullable UIColor*)leftValueColor rightValueColor:(nullable UIColor*)rightValueColor keyValueColor:(nullable UIColor*)keyValueColor maxValue:(nullable NSDecimalNumber *)maxValue minValue:(nullable NSDecimalNumber *)minValue{
    self.leftValueHiden = hidenLeftValueLabel;
    self.rightValueHiden = hidenRightValueLabel;
    self.keyValueHiden = hidenKeyValueLabel;
    self.labelsFont = labelsfont;
    self.leftValueColor = leftValueColor;
    self.rightValueColor = rightValueColor;
    self.keyValueColor = keyValueColor;
    self.sliderMaxValue = maxValue;
    self.sliderMinValue = minValue;
    [self setup];
}

- (void)setupLabelsText {
    self.leftValueLabel.text = @"";
}

- (void)setupLabelsFont {
    if (!self.labelsFont) {
        return;
    }
    for (UILabel *label in _labelsCollection) {
        label.font = self.labelsFont;
    }
}
- (void)setupLabelsColor {
    [self setupLabelsColorWithleftValueColor:self.leftValueColor rightValueColor:self.rightValueColor keyValueColor:self.keyValueColor];
}

- (void)setupLabelsColorWithleftValueColor:(UIColor *)leftValueColor
                           rightValueColor:(UIColor *)rightValueColor
                             keyValueColor:(UIColor *)keyValueColor {
    if (leftValueColor) {
        self.leftValueLabel.tintColor = leftValueColor;
    }
    if (rightValueColor) {
        self.rightValueLabel.tintColor = rightValueColor;
    }
    if (keyValueColor) {
        self.keyValueLabel.tintColor = keyValueColor;
    }
}

- (void)setupHidenViews {
    [self setupHidenLeftValue:self.leftValueHiden hidenRightValue:self.rightValueHiden hidenKeyValue:self.keyValueLabel];
}

- (void)setupHidenLeftValue:(BOOL)hidenLeftValue
            hidenRightValue:(BOOL)hidenRightValue
              hidenKeyValue:(BOOL)hidenKeyValue {
    self.leftValueLabel.hidden = hidenLeftValue;
    self.rightValueLabel.hidden = hidenRightValue;
    self.keyValueLabel.hidden = hidenKeyValue;
}

- (void)setupSliderMaxValueAndMinValue {
    if (self.sliderMaxValue) {
        self.slider.maximumValue = self.sliderMaxValue.floatValue;
        
    }
    if (self.sliderMinValue) {
        self.slider.minimumValue = self.sliderMinValue.floatValue;
    }
}

- (IBAction)sliderDidChangeAction:(UISlider *)sender {
    NSLog(@"-------_____---------%lf,xposition = %lf",sender.value,[self xPositionFromSliderValue:sender]);
}


- (float)xPositionFromSliderValue:(UISlider *)aSlider {
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value - aSlider.minimumValue)/(aSlider.maximumValue - aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    
    return sliderValueToPixels;
}
@end
