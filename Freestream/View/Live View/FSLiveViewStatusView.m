//
//  FSLiveViewStatusView.m
//  Freestream
//
//  Created by Frank Li on 2017/12/7.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSLiveViewStatusView.h"

@interface FSLiveViewStatusView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation FSLiveViewStatusView

- (void)setup {
    [super setup];
}

- (void)setStreamStatus:(FSLiveViewStreamStatus)streamStatus {
    _streamStatus = streamStatus;
    
    self.imageView.image = [UIImage imageNamed:[self pointImageName]];
    self.statusLabel.text = [self getLabelText];
}

- (NSString *)pointImageName {
   return [FSLiveViewModel getStreamStatusViewPointImageNameWithStreamStatus:self.streamStatus];
}

- (NSString *)getLabelText {
    return [FSLiveViewModel getStreamStatusViewTextWithStreamStatus:self.streamStatus];
}

@end
