//
//  JXScrollLabel.h
//  Test
//
//  Created by Jokinryou Xu on 11/25/14.
//  Copyright (c) 2014 Jokinryou Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXScrollLabel : UIScrollView

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text fontSize:(CGFloat)fontSize ;

- (void)startScroll;

- (void)setTextValue:(NSString *)value;

/* 文字从左滚动到右的时间 */
@property (nonatomic) NSTimeInterval leftToRightDuration;

/* 两次滚动之间的时间间隔 */
@property (nonatomic) NSTimeInterval scrollInterval;

/* label之后的空白长度 */
@property (nonatomic) CGFloat fadeLength;

/* 文字颜色 */
@property (nonatomic, strong) UIColor *textColor;

@end
