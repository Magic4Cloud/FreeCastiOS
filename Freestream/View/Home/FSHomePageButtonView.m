//
//  FSHomePageButtonView.m
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSHomePageButtonView.h"
#import "CommonAppHeader.h"

@interface FSHomePageButtonView()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSString *normalImageName;
@property (nonatomic, copy) NSString *highlightedImageName;
@end

@implementation FSHomePageButtonView

- (void)setup {
    [super setup];

    self.layer.borderColor  = [UIColor FSMainTextNormalColor].CGColor;
    self.layer.borderWidth  = 2.f;
    self.layer.cornerRadius = 10 * FSRATIO;
    self.layer.masksToBounds = YES;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.imageView.size = CGSizeMake(80 * FSRATIO, 80 * FSRATIO);
    self.imageView.center = self.button.center;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutIfNeeded];
}
- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    self.imageView.size = CGSizeMake(80 * FSRATIO, 80 * FSRATIO);
    self.imageView.center = self.button.center;
    
}

- (void)setupButtonViewWithTag:(FSHomePageButtonTag)tag {
    self.tag = tag;
    switch (tag) {
        case FSHomePageButtonLiveView:
            self.normalImageName = @"liveView";
            break;
        case FSHomePageButtonStream:
            self.normalImageName = @"stream";
            break;
        case FSHomePageButtonConfigure:
            self.normalImageName = @"browse";
            break;
        case FSHomePageButtonBrowse:
            self.normalImageName = @"configure";
            break;
    }
    self.highlightedImageName = [NSString stringWithFormat:@"%@_pre",self.normalImageName];
    [self.imageView setImage:[UIImage imageNamed:self.normalImageName]];
}

- (IBAction)buttonTouchDown:(UIButton *)sender {
    
    [self.imageView setImage:[UIImage imageNamed:self.highlightedImageName]];
}

- (IBAction)buttonTouchDragOutside:(UIButton *)sender {
    
    [self.imageView setImage:[UIImage imageNamed:self.normalImageName]];
}

- (IBAction)buttonTouchCancel:(UIButton *)sender {
    
    [self.imageView setImage:[UIImage imageNamed:self.normalImageName]];
}
- (IBAction)buttonTouchUpOutside:(UIButton *)sender {
    
    [self.imageView setImage:[UIImage imageNamed:self.normalImageName]];
}

- (IBAction)buttonTouchUpInside:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonViewDidSelected:)]) {
        [self.delegate buttonViewDidSelected:self.tag];
    }
    [self.imageView setImage:[UIImage imageNamed:self.normalImageName]];
}
@end
