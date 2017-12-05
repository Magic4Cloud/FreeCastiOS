//
//  FSPlatformButtonView.m
//  Freestream
//
//  Created by Frank Li on 2017/12/1.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSPlatformButtonView.h"

@interface FSPlatformButtonView()

@property (weak, nonatomic) IBOutlet UIView   *contentBgView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation FSPlatformButtonView

- (void)setup {
    [super setup];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
}

- (void)setModel:(FSStreamPlatformModel *)model {
    _model = model;
    [self updateUIWithModel];
}

- (void)setButtonDisselected {
    switch (self.model.buttonStatus) {
        case FSStreamPlatformButtonStatusNormal: {
            self.model.buttonStatus = FSStreamPlatformButtonStatusNormal;
        }
            break;
        case FSStreamPlatformButtonStatusSelected: {
            self.model.buttonStatus = FSStreamPlatformButtonStatusActivation;
        }
            break;
        case FSStreamPlatformButtonStatusActivation: {
            self.model.buttonStatus = FSStreamPlatformButtonStatusActivation;
        }
            break;
        default:
            break;
    }
    [self updateUIWithModel];
}

- (void)updateUIWithModel {
    switch (self.model.buttonStatus) {
        case FSStreamPlatformButtonStatusNormal: {
            self.imageView.image = [UIImage imageNamed:self.model.normalImageName];
            self.contentBgView.backgroundColor = [UIColor whiteColor];
            self.editButton.hidden = YES;
        }break;
        case FSStreamPlatformButtonStatusSelected: {
            self.imageView.image = [UIImage imageNamed:self.model.highlightedImageName];
            self.contentBgView.backgroundColor = [UIColor blueColor];
            self.editButton.hidden = NO;
        }break;
        case FSStreamPlatformButtonStatusActivation: {
            self.imageView.image = [UIImage imageNamed:self.model.activationImageName];
            self.contentBgView.backgroundColor = [UIColor whiteColor];
            self.editButton.hidden = YES;
        }break;
        default:
            break;
    }
}

- (IBAction)editPlatformRtmpAdress:(UIButton *)sender {
    if (self.goConfigureStreamAdressBlock) {
        self.goConfigureStreamAdressBlock(self.model.streamPlatform);
    }
}


- (void)tapAction {
    switch (self.model.buttonStatus) {
        case FSStreamPlatformButtonStatusNormal: {
            if (self.goConfigureStreamAdressBlock) {
                self.goConfigureStreamAdressBlock(self.model.streamPlatform);
            }
        }
            break;
        case FSStreamPlatformButtonStatusSelected: {
            
        }
            break;
        case FSStreamPlatformButtonStatusActivation: {
            if (self.selectStreamPlatformBlock) {
                self.selectStreamPlatformBlock(self.model.streamPlatform);
            }
        }
            break;
        default:
            break;
    }
}



@end
