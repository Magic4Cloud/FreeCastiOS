//
//  TTPlatFormCell.m
//  presentationLiveDemo
//
//  Created by tc on 6/28/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTPlatFormCell.h"

@implementation TTPlatFormCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _contentBgView.layer.borderColor = [UIColor TTBackLightGrayColor].CGColor;
    _contentBgView.layer.borderWidth = 0.5;
    _contentBgView.backgroundColor = [UIColor whiteColor];
    // Initialization code
    _cellEditButton.hidden = YES;
}

- (void)setModel:(PlatformModel *)model
{
    if (model)
    {
        _cellImageView.highlighted = model.isEnable;
        _contentBgView.backgroundColor = model.isSelected ? [UIColor blueColor] : [UIColor whiteColor];
        _cellEditButton.hidden = !model.isSelected;
    }
    else
    {
        _cellImageView.highlighted = NO;
        _contentBgView.backgroundColor = [UIColor whiteColor];
        _cellEditButton.hidden = YES;
    }
}
@end
