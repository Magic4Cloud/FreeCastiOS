//
//  MainImageViewBtn.m
//  presentationLiveDemo
//
//  Created by rakwireless on 2017/3/27.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "MainImageViewBtn.h"
#import "CommanParameters.h"

@implementation MainImageViewBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _color=MAIN_COLOR_T;
        self.backgroundColor = [UIColor clearColor];
        
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, viewH*32/totalHeight, viewH*50/totalHeight, viewH*50/totalHeight)];
        self.imgView.center=CGPointMake(CGRectGetWidth(self.frame)*0.5, self.imgView.center.y);
        [self.imgView setContentMode:UIViewContentModeScaleAspectFill];
        self.imgView.clipsToBounds = YES;
        self.imgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imgView];
        
        self.text = [[UILabel alloc]initWithFrame:CGRectMake(0, viewH*94/totalHeight, CGRectGetWidth(self.frame), viewH*20/totalHeight)];
        self.text.backgroundColor = [UIColor clearColor];
        self.text.center=CGPointMake(CGRectGetWidth(self.frame)*0.5, self.text.center.y);
        self.text.font = [UIFont systemFontOfSize: viewH*20/totalHeight*0.9];
        self.text.textColor=[UIColor whiteColor];
        self.text.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.text];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = (width + height) * 0.02;
    
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, _color.CGColor);
    // 移动到初始点
    CGContextMoveToPoint(context, radius, 0);
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius, 0);
    CGContextAddArc(context, width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
    // 绘制第2条线和第2个1/4圆弧
    CGContextAddLineToPoint(context, width, height - radius);
    CGContextAddArc(context, width - radius, height - radius, radius, 0.0, 0.5 * M_PI, 0);
    // 绘制第3条线和第3个1/4圆弧
    CGContextAddLineToPoint(context, radius, height);
    CGContextAddArc(context, radius, height - radius, radius, 0.5 * M_PI, M_PI, 0);
    // 绘制第4条线和第4个1/4圆弧
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
    // 闭合路径
    CGContextClosePath(context);
    // 填充半透明黑色
    //CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)draw:(UIColor*)color{
    _color=color;
    [self setNeedsDisplay];
}

@end
