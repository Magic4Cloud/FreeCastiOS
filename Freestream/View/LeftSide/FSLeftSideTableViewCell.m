//
//  FSLeftSideTableViewCell.m
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSLeftSideTableViewCell.h"
#import "CommonAppHeader.h"

@interface FSLeftSideTableViewCell()
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;

@end

@implementation FSLeftSideTableViewCell

- (void)setup {

}

- (void)setupTitleButton:(NSString *)title {
    
    self.titleLabel.text = title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat) heightForLeftSideMenu {
    return 50 * FSRATIO;
}

- (IBAction)buttonTouchUpInside:(UIButton *)sender {
    NSLog(@"----------------%s",__func__);
    self.titleLabel.textColor = [UIColor FSMainTextNormalColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedCell:)]) {
        [self.delegate didSelectedCell:self.tag];
    }
    
}

- (IBAction)buttonTouchDown:(UIButton *)sender {
    NSLog(@"----------------%s",__func__);
    self.titleLabel.textColor = [UIColor FSMainTextHighlightedColor];
    
}

- (IBAction)buttonTouchDragOutside:(UIButton *)sender {
    NSLog(@"----------------%s",__func__);
    self.titleLabel.textColor = [UIColor FSMainTextNormalColor];
}

- (IBAction)buttonTouchUpOutside:(UIButton *)sender {
    NSLog(@"----------------%s",__func__);
    self.titleLabel.textColor = [UIColor FSMainTextNormalColor];
}

@end
