//
//  FSPlatformButtonView.m
//  Freestream
//
//  Created by Frank Li on 2017/12/1.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSPlatformButtonView.h"

@implementation FSPlatformButtonView

- (void)setup {
    [super setup];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
}

- (void)setSelected {
    
}

- (IBAction)editPlatformRtmpAdress:(id)sender {
    
}

- (void)tapAction {
    
}

- (void)setImageWithPlatformType {
    
}

@end
