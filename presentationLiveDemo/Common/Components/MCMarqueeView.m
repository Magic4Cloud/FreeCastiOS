//
//  MCMarqueeView.m
//  Patrol
//
//  Created by hades on 2017/5/31.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "MCMarqueeView.h"

typedef void(^MCWonderfulAction)();

typedef NS_ENUM(NSInteger, MCMarqueeTapMode) {
    MCMarqueeTapForMove = 1,
    MCMarqueeTapForAction = 2
};

@interface MCMarqueeView () <CAAnimationDelegate>

@property (nonatomic,strong) UIButton             *bgBtn;
@property (nonatomic,strong) UILabel              *marqueeLbl;
@property (nonatomic,strong) UIColor              *bgColor;
@property (nonatomic,strong) UIColor              *txtColor;
@property (nonatomic,copy  ) NSString             *msg;
@property (nonatomic,strong) NSTimer              *timer;
@property (nonatomic,copy  ) MCWonderfulAction     tapAction;
@property (nonatomic,assign) MCMarqueeTapMode      tapMode;
@property (nonatomic,assign) MCMarqueeSpeedLevel   speedLevel;
@property (nonatomic,strong) UIView               *middleView;
@property (nonatomic,strong) UIFont               *marqueeLabelFont;
@end

@implementation MCMarqueeView
- (instancetype)initWithFrame:(CGRect)frame speed:(MCMarqueeSpeedLevel)speed Msg:(NSString *)msg bgColor:(UIColor *)bgColor txtColor:(UIColor *)txtColor{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 2;
        if(bgColor){
            self.bgColor = bgColor;
        }else{
            self.bgColor = [UIColor whiteColor];
        }
        
        if (txtColor) {
            self.txtColor = txtColor;
        }else{
            self.txtColor = [UIColor darkGrayColor];
        }
        
        if (speed) {
            self.speedLevel = speed;
        }else{
            self.speedLevel = 3;
        }
        
        self.msg = msg;
        [self doSometingBeginning];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame speed:(MCMarqueeSpeedLevel)speed Msg:(NSString *)msg {
    if (self = [super initWithFrame:frame]) {
        self.msg = msg;
        if (speed) {
            self.speedLevel = speed;
        }else{
            self.speedLevel = 3;
        }
        self.bgColor = [UIColor whiteColor];
        self.txtColor = [UIColor darkGrayColor];
        [self doSometingBeginning];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)doSometingBeginning{
    self.layer.masksToBounds = YES;
    self.backgroundColor = self.bgColor;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backAndRestart) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.middleView = middleView;
    [_middleView addSubview:self.marqueeLbl];
    [self addSubview:_middleView];
}

- (void)changeTapMarqueeAction:(void(^)())action{
    [self addSubview:self.bgBtn];
    self.tapAction = action;
    self.tapMode = MCMarqueeTapForAction;
}

- (void)changeMarqueeLabelFont:(UIFont *)font{
    self.marqueeLbl.font = font;
    self.marqueeLabelFont = font;
    CGSize msgSize = [_marqueeLbl.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    CGRect fr = self.marqueeLbl.frame;
    fr.size.width = msgSize.width;
    self.marqueeLbl.frame = fr;
}

- (UIButton *)bgBtn{
    if (!_bgBtn) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _bgBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, w, h)];
        [_bgBtn addTarget:self action:@selector(bgButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgBtn;
}

- (UILabel *)marqueeLbl{
    if (!_marqueeLbl) {
        self.tapMode = MCMarqueeTapForMove;
        CGFloat h = self.frame.size.height;
        _marqueeLbl = [[UILabel alloc]init];
        _marqueeLbl.text = self.msg;
        UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        _marqueeLbl.font = fnt;
        CGSize msgSize = [_marqueeLbl.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil]];
        _marqueeLbl.frame = CGRectMake(0, 0, msgSize.width, h);
        if (self.marqueeLabelFont != nil) {
            _marqueeLbl.font = self.marqueeLabelFont;
        }
        _marqueeLbl.textColor = self.txtColor;
    }
    return _marqueeLbl;
}

- (void)bgButtonClick {
    if (self.tapAction) {
        self.tapAction();
    }
}

#pragma mark - 操作
- (void)start{
    [self moveAction];
}

- (void)backAndRestart{
    [self.marqueeLbl.layer removeAllAnimations];
    [self.marqueeLbl removeFromSuperview];
    self.marqueeLbl = nil;
    [self.middleView addSubview:self.marqueeLbl];
    [self moveAction];
}

- (void)stop{
    [self pauseLayer:self.marqueeLbl.layer];
}

- (void)restart{
    [self resumeLayer:self.marqueeLbl.layer];
}

- (void)moveAction
{
    CGRect fr = self.marqueeLbl.frame;
    fr.origin.x = self.frame.size.width;
    self.marqueeLbl.frame = fr;
    
    CGPoint fromPoint = CGPointMake(self.frame.size.width + self.marqueeLbl.frame.size.width/2, self.frame.size.height/2);
    
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:fromPoint];
    [movePath addLineToPoint:CGPointMake(-self.marqueeLbl.frame.size.width/2, self.frame.size.height/2)];
    
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.removedOnCompletion = YES;
    
    moveAnim.duration = self.marqueeLbl.frame.size.width * self.speedLevel * 0.01;
    [moveAnim setDelegate:self];
    
    [self.marqueeLbl.layer addAnimation:moveAnim forKey:nil];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = layer.timeOffset;
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        [self moveAction];
    }
}
@end
