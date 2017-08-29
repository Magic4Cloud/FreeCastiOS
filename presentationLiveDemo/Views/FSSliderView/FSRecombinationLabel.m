//
//  RecombinationLabel.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/29.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSRecombinationLabel.h"

@implementation FSRecombinationLabel

- (void)setKeyValue:(CGFloat)keyValue {
    if (self.needCarry) {
        if(self.carryValue == 0){
            @throw [NSException exceptionWithName:@"Something is not right exception"
                                       reason:@"You want carry but not set carryValue when use FSRecombinationLable"
                                     userInfo:nil];
        }
    }
    if (self.needCarry && keyValue >= self.carryValue) {
        keyValue = keyValue / self.carryValue;
        self.suffixLabel.text = self.carryForwardString;
    }else {
        self.suffixLabel.text = self.suffixString;
    }
    self.keyValue = keyValue;
    self.valueLabel.text = [self deleteLastUnuseZore:keyValue];

}

- (CGFloat)keyValue {
    if (self.needCarry && [self.suffixLabel.text isEqualToString:self.suffixString]) {
        return (self.keyValue * self.carryValue);
    }else{
        return self.keyValue;
    }
}

- (NSString *)deleteLastUnuseZore:(CGFloat)floatValue{
    NSString *stringNumber = [NSString stringWithFormat:@"%.1f",floatValue];
    NSNumber *numberObj = @(stringNumber.floatValue);
    return  [NSString stringWithFormat:@"%@",numberObj];
}

@end
