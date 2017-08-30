//
//  FSSliderView.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSSliderView.h"

@interface FSSliderView()
@property (strong, nonatomic) IBOutletCollection(FSRecombinationLabel) NSArray *recombinationLabelsCollection;


@end
@implementation FSSliderView

- (void)setup {
    [super setup];
    
    [self setupLabelsDefault];
    [self setupSliderMaxValueAndMinValue];
    [self setupLabelsText];
    [self setupLabelsFont];
    [self setupLabelsColor];
    [self setupHidenViews];
    
}

- (void)setupLabelsDefault {
    for (FSRecombinationLabel * recombinationLabel in self.recombinationLabelsCollection) {
        [recombinationLabel setupUseDefaultConfiguration];
        recombinationLabel.suffixStr = @"%";
    }
}

- (void)setUpHidenLeftValueLabel:(BOOL)hidenLeftValueLabel hidenRightValueLabel:(BOOL)hidenRightValueLabel hidenKeyValueLabel:(BOOL)hidenKeyValueLabel labelFont:(UIFont *_Nullable)labelsfont leftValueColor:(UIColor *_Nullable)leftValueColor rightValueColor:(UIColor *_Nullable)rightValueColor keyValueColor:(UIColor *_Nullable)keyValueColor maxValue:(NSDecimalNumber *_Nullable)maxValue minValue:(NSDecimalNumber *_Nullable)minValue {
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
    self.leftRecombinationLabel.keyMainValue = self.sliderMinValue.floatValue;
    self.rightRecombinationLabel.keyMainValue = self.sliderMaxValue.floatValue;
    self.keyRecombinationLabel.keyMainValue = self.slider.value;
}

- (void)setupLabelsFont {
    if (!self.labelsFont) {
        return;
    }
    for (FSRecombinationLabel * recombinationLabel in self.recombinationLabelsCollection) {
        recombinationLabel.labelsFont = self.labelsFont;
    }
}
- (void)setupLabelsColor {
    [self setupLabelsColorWithleftValueColor:self.leftValueColor rightValueColor:self.rightValueColor keyValueColor:self.keyValueColor];
}

- (void)setupLabelsColorWithleftValueColor:(UIColor *)leftValueColor
                           rightValueColor:(UIColor *)rightValueColor
                             keyValueColor:(UIColor *)keyValueColor {
    if (leftValueColor) {
        self.leftRecombinationLabel.labelsColor = leftValueColor;
    }
    if (rightValueColor) {
        self.rightRecombinationLabel.labelsColor = rightValueColor;
    }
    if (keyValueColor) {
        self.keyRecombinationLabel.labelsColor = keyValueColor;
    }
}

- (void)setupHidenViews {
    [self setupHidenLeftValue:self.leftValueHiden hidenRightValue:self.rightValueHiden hidenKeyValue:self.keyValueHiden];
}

- (void)setupHidenLeftValue:(BOOL)hidenLeftValue
            hidenRightValue:(BOOL)hidenRightValue
              hidenKeyValue:(BOOL)hidenKeyValue {
    self.leftRecombinationLabel.hidden = hidenLeftValue;
    self.rightRecombinationLabel.hidden = hidenRightValue;
    self.keyRecombinationLabel.hidden = hidenKeyValue;
}

- (void)setupSliderMaxValueAndMinValue {
    if (self.sliderMaxValue) {
        self.slider.maximumValue = self.sliderMaxValue.floatValue;
    }else {
        self.slider.maximumValue = 1;
    }
    if (self.sliderMinValue) {
        self.slider.minimumValue = self.sliderMinValue.floatValue;
        
    }else {
        self.slider.minimumValue = 0;
    }
}

- (IBAction)sliderDidChangeAction:(UISlider *)sender {
    NSLog(@"-------_____---------%lf,xposition = %lf",sender.value,[self xPositionFromSliderValue:sender]);
    [self.keyRecombinationLabel setKeyMainValue:sender.value];
}


- (float)xPositionFromSliderValue:(UISlider *)aSlider {
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value - aSlider.minimumValue)/(aSlider.maximumValue - aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    
    return sliderValueToPixels;
}
@end
