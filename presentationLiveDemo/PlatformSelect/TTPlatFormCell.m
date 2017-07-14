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

- (void)setImageviewImageWithImageName:(NSString *)imageName
{
    self.cellImageView.image = [UIImage imageNamed:imageName];
    _cellImageView.highlighted = NO;
    _contentBgView.backgroundColor = [UIColor whiteColor];
    _cellEditButton.hidden = YES;

}

- (void)setModel:(PlatformModel *)model andPlatformName:(NSString *)name
{
    NSString * suffixString;
    _model = model;
    
    if (model)
    {
        if (model.isEnable)
        {
            if (model.isSelected)
            {
                suffixString = @"_pre";
            }
            else
            {
                suffixString = @"_activation";
            }
            
        }
        else
        {
            suffixString = @"_nor";
        }
        
        _cellImageView.highlighted = model.isEnable;
        _contentBgView.backgroundColor = model.isSelected ? [UIColor TTLightBlueColor] : [UIColor whiteColor];
        _cellEditButton.hidden = !model.isSelected;
    }
    else
    {
        suffixString = @"_nor";
        _cellImageView.highlighted = NO;
        _contentBgView.backgroundColor = [UIColor whiteColor];
        _cellEditButton.hidden = YES;
    }
    UIImage * iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"button_%@%@",name,suffixString]];
    
    _cellImageView.image = iconImage;
    
}

@end
