//
//  JXScrollLabel.m
//  Test
//
//  Created by Jokinryou Xu on 11/25/14.
//  Copyright (c) 2014 Jokinryou Xu. All rights reserved.
//

#import "JXScrollLabel.h"

#define iOS7orLATER [[UIDevice currentDevice].systemVersion doubleValue] >= 7.0f

@implementation JXScrollLabel
{
    UILabel *_textLabel;
    UILabel *_fadeLabel;
    CGSize textLabelSize;
    CGFloat width;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Override" reason:@"Use initWithFrame:text:fontSize instead!" userInfo:nil];
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    @throw [NSException exceptionWithName:@"Override" reason:@"Use initWithFrame:text:fontSize instead!" userInfo:nil];
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text fontSize:(CGFloat)fontSize {

    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

    width=frame.size.width;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
    self.userInteractionEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;

    _leftToRightDuration = 5;
    _scrollInterval = 0;
    _fadeLength = 10;

    _textLabel = [[UILabel alloc] init];
    _textLabel.text = text;
    _textLabel.font = [UIFont systemFontOfSize:fontSize];
    textLabelSize = [self calTextSize:text withFont:[UIFont systemFontOfSize:fontSize]];
    _textLabel.frame = CGRectMake(0, 0, textLabelSize.width, frame.size.height);
    [self addSubview:_textLabel];

    if (self.needScroll) {
        _fadeLabel = [[UILabel alloc] init];
        _fadeLabel.text = _textLabel.text;
        _fadeLabel.font = [UIFont systemFontOfSize:fontSize];
        _fadeLabel.frame = CGRectMake(_textLabel.frame.size.width + _fadeLength, _textLabel.frame.origin.y, _textLabel.frame.size.width, _textLabel.frame.size.height);

        [self addSubview:_fadeLabel];

        self.contentSize = CGSizeMake(CGRectGetMaxX(_fadeLabel.frame), _textLabel.frame.size.height);
    }

    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_textLabel) {
        _textLabel.frame = CGRectMake(_textLabel.frame.origin.x, (frame.size.height - _textLabel.frame.size.height) / 2, _textLabel.frame.size.width, _textLabel.frame.size.height);
        if (self.needScroll) {
            _fadeLabel.frame = CGRectMake(_textLabel.frame.size.width + _fadeLength, _textLabel.frame.origin.y, _textLabel.frame.size.width, _textLabel.frame.size.height);
            self.contentSize = CGSizeMake(CGRectGetMaxX(_fadeLabel.frame), _textLabel.frame.size.height);
        }
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textLabel) {
        _textLabel.textColor = textColor;
    }
    if (_fadeLabel) {
        _fadeLabel.textColor = textColor;
    }
}

- (void)setTextValue:(NSString *)value {
    if (_textLabel) {
        _textLabel.text = value;
    }
    if (_fadeLabel) {
        _fadeLabel.text = value;
    }
}

- (void)startScroll {

    if (!self.needScroll) {
        return;
    }

    __block JXScrollLabel *blockSelf = self;
    [UIView animateWithDuration:_leftToRightDuration animations:^(void) {
        self.contentOffset = CGPointMake(_textLabel.frame.size.width + _fadeLength, self.contentOffset.y);
    } completion:^(BOOL finished) {
        if (finished) {
            self.contentOffset = CGPointMake(0, self.contentOffset.y);
            [blockSelf performSelector:@selector(startScroll) withObject:nil afterDelay:_scrollInterval];
        }
    }];
}

- (void)setFadeLength:(CGFloat)fadeLength {
    _fadeLength = fadeLength;
    if (self.needScroll) {
        _fadeLabel.frame = CGRectMake(_textLabel.frame.size.width + fadeLength, _textLabel.frame.origin.y, _textLabel.frame.size.width, _textLabel.frame.size.height);
        self.contentSize = CGSizeMake(CGRectGetMaxX(_fadeLabel.frame), _textLabel.frame.size.height);
    }
}

- (BOOL)needScroll {
    return _textLabel.frame.size.width > self.frame.size.width;
}

- (CGSize)calTextSize:(NSString *)text withFont:(UIFont *)textFont {
    CGSize textSize = iOS7orLATER ? [text sizeWithAttributes:@{NSFontAttributeName : textFont}] : [text sizeWithFont:textFont];
    CGSize labelSize = CGSizeMake((CGFloat) ceil(textSize.width), (CGFloat) ceil(textSize.height));
    return labelSize;
}


@end
