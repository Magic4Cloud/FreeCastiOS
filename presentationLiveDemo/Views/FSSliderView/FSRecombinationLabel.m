//
//  RecombinationLabel.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSRecombinationLabel.h"
#import "CommonAppHeaders.h"
@implementation FSRecombinationLabel

- (void)setKeyMainValue:(CGFloat)keyMainValue {
    if (_needCarry) {
        if(_carryValue == 0){
            @throw [NSException exceptionWithName:@"Something is not right exception"
                                       reason:@"You want carry but not set carryValue or set a error carryValue when use FSRecombinationLable"
                                     userInfo:nil];
        }
    }
    if (_needCarry && keyMainValue >= _carryValue) {
        keyMainValue = keyMainValue / _carryValue;
        _suffixStrLabel.text = self.carryForwardString;
    }else {
        _suffixStrLabel.text = self.suffixStr;
    }
    _keyMainValue = keyMainValue;
    self.keyMianValueLabel.text = [self deleteLastUnuseZore:keyMainValue];
    
}

//- (CGFloat)getKeyMainValue {
//    if (self.needCarry && [self.suffixStrLabel.text isEqualToString:self.suffixStr]) {
//        return (_keyMainValue * self.carryValue);
//    }else{
//        return _keyMainValue;
//    }
//}

- (NSString *)deleteLastUnuseZore:(CGFloat)floatValue{
    NSString *stringNumber = [NSString stringWithFormat:@"%.1f",floatValue];
    NSNumber *numberObj = @(stringNumber.floatValue);
    return  [NSString stringWithFormat:@"%@",numberObj];
}

- (void)setSuffixString:(NSString *)suffixString{
    
        self.suffixStr = suffixString;
        self.suffixStrLabel.text = suffixString;
    
//    if (suffixString.length > 0) {
//        self.suffixLabel.hidden = NO;
//    } else {
//        self.suffixLabel.hidden = YES;
//    }
}

- (void)setupUseDefaultConfiguration {
    [self setupLabelsColor:nil labelsFont:nil suffixString:@"F"];
}

- (void)setupLabelsColor:(UIColor *_Nullable)labelsColor labelsFont:(UIFont *_Nullable)labelsFont suffixString:(NSString *_Nullable)suffixString {
    _labelsFont = labelsFont;
    _labelsColor = labelsColor;
    self.suffixStr = suffixString;
    _needCarry = NO;
    [self setup];
}

- (void)setupLabelsColor:(UIColor *_Nullable)labelsColor labelsFont:(UIFont *_Nullable)labelsFont suffixString:(NSString *_Nullable)suffixString carrayValue:(NSUInteger)carryValue carryForwardString:(NSString *_Nonnull)carryForwardString {
    if (carryValue <= 0) {
        @throw [NSException exceptionWithName:@"Something is not right exception"
                                       reason:@"You want carry but not set carryValue or set a error carryValue when use FSRecombinationLable"
                                     userInfo:nil];
    }
    self.labelsFont = labelsFont;
    self.labelsColor = labelsColor;
    self.suffixString = suffixString;
    self.needCarry = YES;
    self.carryValue = carryValue;
    self.carryForwardString = carryForwardString;
    
    [self setup];
}

- (void)setup{
    [super setup];
    
    [self setupLabelsColor];
    [self setupLabelsFont];
    
}

- (void)setupLabelsColor {
    [self setupLabelsColor:self.labelsColor];
}

- (void)setupLabelsColor:(nullable UIColor *)labelsColor {
    if (labelsColor) {
        self.keyMianValueLabel.tintColor = labelsColor;
        self.suffixStrLabel.tintColor = labelsColor;
    }
}

- (void)setupLabelsFont {
    [self setupLabelsFont:self.labelsFont];
}

- (void)setupLabelsFont:(nullable UIFont *)labelsFont {
    if (labelsFont) {
        self.keyMianValueLabel.font = labelsFont;
        self.suffixStrLabel.font = labelsFont;
    }
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

@end
