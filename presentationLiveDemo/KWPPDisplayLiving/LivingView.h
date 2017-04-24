//
//  LivingView.h
//  presentationLiveDemo
//
//  Created by zyh_scut on 16/8/28.
//  Copyright © 2016年 ZYH. All rights reserved.
//


/**
 * 直播控制视图
 * 仅仅展示几个按钮
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,LivingOperationType){
    PPTLiving =1,
    MixPPTandCameraLiving,
    SwitchLivingCamera,
    StopLiving,
    PausingLiving
};


@interface LivingView : UIView

@property (nonatomic, assign)BOOL isLivingStarted;

-(instancetype) init;
-(instancetype) initLivingViewWithLivingServerAddress:(NSString *)rtmpServerAddress;

-(void)refreshPPTSlideImage:(UIImage *)newSlideImage withNewImageIndex:(int)newIndex;
-(void)refreshTimeLableWithNewContent:(NSString *)newContent;

-(void)stopLiving;
@end
