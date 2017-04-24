//
//  XMShareView.m
//  XMShare
//
//  Created by Amon on 15/8/6.
//  Copyright (c) 2015年 GodPlace. All rights reserved.
//

#import "XMShareView.h"

#import "VerticalUIButton.h"
#import "CommonMarco.h"
#import "XMShareWeiboUtil.h"
#import "XMShareWechatUtil.h"
#import "XMShareQQUtil.h"
#import "MBProgressHUD.h"

static const CGFloat totalWidth = 375.0;
static const CGFloat totalHeight = 667.0;

//  每一项的宽度
static CGFloat itemWidth = 60.0;

//  每一项的高度
static CGFloat itemHeight = 60.0;


//  每行显示数量
static const NSInteger numbersOfItemInLine = 4;

@implementation XMShareView


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configureData];
        [self initUI];
        
    }
    return self;
    
}

/**
 *  加载视图
 */
- (void)initUI
{
    
    //  背景色黑色半透明
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    //  点击关闭
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(clickClose)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
    
    CGFloat startY = 0;
    CGFloat bgViewWidth = SIZE_OF_SCREEN.width-20 ;
    CGFloat bgViewHeight = SIZE_OF_SCREEN.height*232/totalHeight;
    CGFloat bgViewX = (SIZE_OF_SCREEN.width - bgViewWidth) / 2;
    CGFloat bgViewY = (SIZE_OF_SCREEN.height - bgViewHeight)-75*SIZE_OF_SCREEN.height/totalHeight;
    
    itemWidth=((SIZE_OF_SCREEN.width-20)-(numbersOfItemInLine+1)*(23*SIZE_OF_SCREEN.width/totalWidth))/numbersOfItemInLine;
    
    itemHeight=itemWidth;
    
    //  居中白色视图
    UIView *shareActionView = [[UIView alloc] initWithFrame:CGRectMake(bgViewX,
                                                                       bgViewY,
                                                                       bgViewWidth,
                                                                       bgViewHeight)];
    ViewRadius(shareActionView, 8);
    shareActionView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];

    [self addSubview:shareActionView];
    
    for ( int i = 0; i < iconList.count; i ++ ) {
        
        VerticalUIButton *tempButton;
        UIImage *img = [UIImage imageNamed: iconList[i] ];
        
        int row = (i+1) / numbersOfItemInLine;
        int col = (i+1) % numbersOfItemInLine;
        if (col==0) {
            col=numbersOfItemInLine;
        }
        
        CGFloat x =  (23*SIZE_OF_SCREEN.width/totalWidth) * col+itemWidth* (col-1);
        
        CGFloat y = startY+(20*SIZE_OF_SCREEN.height/totalHeight);
        
        tempButton = [[VerticalUIButton alloc] initWithFrame:CGRectMake(x, y, itemWidth, itemHeight)];
        tempButton.titleLabel.font = [UIFont systemFontOfSize:13*SIZE_OF_SCREEN.height/totalHeight];
        [tempButton setImage:img forState:UIControlStateNormal];
        [tempButton setTitle:textList[i] forState:UIControlStateNormal];
        [tempButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tempButton addTarget:self action:@selector(clickActionButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if([textList[i] isEqualToString:NSLocalizedString(@"wechat", nil)]){
            
            tempButton.tag = SHARE_ITEM_WEIXIN_SESSION;
            
        }else if([textList[i] isEqualToString:NSLocalizedString(@"moments", nil)]){
            
            tempButton.tag = SHARE_ITEM_WEIXIN_TIMELINE;
            
        }else if([textList[i] isEqualToString:NSLocalizedString(@"qq", nil)]){
            
            tempButton.tag = SHARE_ITEM_QQ;
            
        }else if([textList[i] isEqualToString:NSLocalizedString(@"QQ空间", nil)]){
            
            tempButton.tag = SHARE_ITEM_QZONE;
            
        }else if([textList[i] isEqualToString:NSLocalizedString(@"weibo", nil)]){
            
            tempButton.tag = SHARE_ITEM_WEIBO;
            
        }
        else if([textList[i] isEqualToString:NSLocalizedString(@"youtube", nil)]){
            
            tempButton.tag = SHARE_ITEM_YOUTUBE;
            
        }
        else if([textList[i] isEqualToString:NSLocalizedString(@"facebook", nil)]){
            
            tempButton.tag = SHARE_ITEM_FACEBOOK;
            
        }
        else if([textList[i] isEqualToString:NSLocalizedString(@"twitter", nil)]){
            
            tempButton.tag = SHARE_ITEM_TWITTER;
            
        }
        else if([textList[i] isEqualToString:NSLocalizedString(@"instagram", nil)]){
            
            tempButton.tag = SHARE_ITEM_INS;
            
        }
        
        [shareActionView addSubview:tempButton];
    
        if(col==numbersOfItemInLine){
            UIView *line=[[UIView alloc]init];
            line.frame=CGRectMake(0, 116*SIZE_OF_SCREEN.height/totalHeight, bgViewWidth, 1);
            line.backgroundColor=[UIColor colorWithRed:67/255.0 green:68/255.0 blue:80/255.0 alpha:1.0];
            [shareActionView addSubview:line];
            startY=116*SIZE_OF_SCREEN.height/totalHeight+1;
        }
    }
    
    
    UIButton *_cancelBtn= [[UIButton alloc] initWithFrame:CGRectMake(bgViewX, SIZE_OF_SCREEN.height-67*SIZE_OF_SCREEN.height/totalHeight, bgViewWidth, 57*SIZE_OF_SCREEN.height/totalHeight)];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:23*SIZE_OF_SCREEN.height/totalHeight*0.8];
    ViewRadius(_cancelBtn, 8);
    [_cancelBtn setTitle:NSLocalizedString(@"share_cancel", nil) forState:UIControlStateNormal];
    _cancelBtn.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(_cancelBtnTouched:) forControlEvents:UIControlEventTouchDown];
    [_cancelBtn addTarget:self action:@selector(_cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
}


/**
 *  初始化数据
 */
- (void)configureData
{
    
    /**
     *  判断应用是否安装，可用于是否显示
     *  QQ和Weibo分别有网页版登录与分享，微信目前不支持
     */
    BOOL hadInstalledWeixin = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
    //    BOOL hadInstalledQQ = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
    //    BOOL hadInstalledWeibo = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weibo://"]];
    
    iconList = [[NSMutableArray alloc] init];
    textList = [[NSMutableArray alloc] init];
    
    [iconList addObject:@"Youtube@3x"];
    [textList addObject:NSLocalizedString(@"youtube", nil)];
    
    [iconList addObject:@"facebook@3x"];
    [textList addObject:NSLocalizedString(@"facebook", nil)];
    
    [iconList addObject:@"twitter@3x"];
    [textList addObject:NSLocalizedString(@"twitter", nil)];
    
    [iconList addObject:@"ins@3x"];
    [textList addObject:NSLocalizedString(@"instagram", nil)];
    
    [iconList addObject:@"QQ@3x"];
    [textList addObject:NSLocalizedString(@"qq", nil)];
    
    [iconList addObject:@"wechat@3x"];
    [textList addObject:NSLocalizedString(@"wechat", nil)];
    
    [iconList addObject:@"weibo@3x"];
    [textList addObject:NSLocalizedString(@"weibo", nil)];
    
    [iconList addObject:@"moments@3x"];
    [textList addObject:NSLocalizedString(@"moments", nil)];
    
    
    //if(hadInstalledWeixin){
        
//        [iconList addObject:@"icon_share_wechat@2x"];
//        [iconList addObject:@"icon_share_moment@2x"];
//        [textList addObject:NSLocalizedString(@"微信好友", nil)];
//        [textList addObject:NSLocalizedString(@"朋友圈", nil)];
    
    //}
    
    //    if(hadInstalledQQ){
    
//    [iconList addObject:@"icon_share_qq@2x"];
//    [iconList addObject:@"icon_share_qzone@2x"];
//    [textList addObject:NSLocalizedString(@"QQ", nil)];
//    [textList addObject:NSLocalizedString(@"QQ空间", nil)];
    
    //    }
    
    //    if(hadInstalledWeibo){
    
//    [iconList addObject:@"icon_share_webo@2x"];
//    [textList addObject:NSLocalizedString(@"微博", nil)];
    
    //    }
    
}

- (void)clickActionButton:(VerticalUIButton *)sender
{
    
    if ( sender.tag == SHARE_ITEM_WEIXIN_SESSION ) {
        
        [self shareToWeixinSession];
        [self clickClose];
        
    }else if ( sender.tag == SHARE_ITEM_WEIXIN_TIMELINE ) {
        
        [self shareToWeixinTimeline];
        [self clickClose];
        
    }else if ( sender.tag == SHARE_ITEM_QQ ) {
        
        [self shareToQQ];
        [self clickClose];
        
    }else if ( sender.tag == SHARE_ITEM_QZONE ) {
        
        [self shareToQzone];
        [self clickClose];
        
    }else if ( sender.tag == SHARE_ITEM_WEIBO ) {
    
        [self shareToWeibo];
        [self clickClose];
    }
    else if ( sender.tag == SHARE_ITEM_YOUTUBE ) {
        
        [self showAllTextDialog:NSLocalizedString(@"develop", nil)];
    }
    else if ( sender.tag == SHARE_ITEM_FACEBOOK ) {
        
        [self showAllTextDialog:NSLocalizedString(@"develop", nil)];
    }
    else if ( sender.tag == SHARE_ITEM_TWITTER ) {
        
        [self showAllTextDialog:NSLocalizedString(@"develop", nil)];
    }
    else if ( sender.tag == SHARE_ITEM_INS ) {
        
        [self showAllTextDialog:NSLocalizedString(@"develop", nil)];
    }
    
}

- (void)_cancelBtnClick:(UIButton *)button{
    button.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    [button setTitleColor:[UIColor colorWithRed:67/255.0 green:68/255.0 blue:80/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self clickClose];
}

- (void)_cancelBtnTouched:(UIButton *)button{
    button.backgroundColor=[UIColor whiteColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)shareToWeixinSession
{
    
    XMShareWechatUtil *util = [XMShareWechatUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    util.shareImg = self.shareImg;
    
    [util shareToWeixinSession];
    
}

- (void)shareToWeixinTimeline
{
    
    XMShareWechatUtil *util = [XMShareWechatUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    util.shareImg = self.shareImg;
    
    [util shareToWeixinTimeline];
    
}

- (void)shareToQQ
{
    XMShareQQUtil *util = [XMShareQQUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    util.shareImg = self.shareImg;
    
    [util shareToQQ];
}

- (void)shareToQzone
{
    XMShareQQUtil *util = [XMShareQQUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    util.shareImg = self.shareImg;
    
    [util shareToQzone];
}

- (void)shareToWeibo
{
 
    XMShareWeiboUtil *util = [XMShareWeiboUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    util.shareImg = self.shareImg;
    
    [util shareToWeibo];
    
}

- (void)clickClose
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    }];
}

#pragma mark-- Toast显示示例
-(void)showAllTextDialog:(NSString *)str{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:HUD];
    HUD.labelText = str;
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        //[HUD release];
        //HUD = nil;
    }];
}


@end
