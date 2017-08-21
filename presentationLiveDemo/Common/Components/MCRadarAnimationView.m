////
////  MCRadarAnimationView.m
////  Patrol
////
////  Created by hades on 2017/5/24.
////  Copyright © 2017年 Cloud4Magic. All rights reserved.
////
//
//#import "MCRadarAnimationView.h"
//#import "CommonAppHeaders.h"
//
//@implementation MCRadarAnimationView
//#pragma mark - override
//- (void)drawRect:(CGRect)rect
//{
//    self.backgroundColor = [UIColor clearColor];
////    self.layer.backgroundColor = [UIColor clearColor].CGColor;
////    self.layer.opacity = 0;
//    //半径
//    CGFloat redbius = (rect.size.width * 1.58)/2.0;
////    self.layer.cornerRadius = redbius/2.0;
////    self.layer.masksToBounds = YES;
////    self.clipsToBounds = YES;
//    CGPoint point = CGPointMake(rect.origin.x + rect.size.width/2.0, rect.origin.y + rect.size.width/2.0);
//    CGFloat startAngle = 0;
//    CGFloat endAngle = 2*M_PI;
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:redbius startAngle:startAngle endAngle:endAngle clockwise:YES];
//    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//    layer.path = path.CGPath;   //添加路径
//    layer.strokeColor = [UIColor MCRadarViewColor].CGColor;
//    layer.fillColor = [UIColor MCRadarViewColor].CGColor;
//    [self.layer addSublayer:layer];
//}
//@end
