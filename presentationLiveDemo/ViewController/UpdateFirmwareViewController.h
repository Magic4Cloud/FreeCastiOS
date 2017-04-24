//
//  UpdateFirmwareViewController.h
//  presentationLiveDemo
//
//  Created by rakwireless on 2016/10/24.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewLinkmanTouch.h"
#import "RAKAsyncSocket.h"

@interface UpdateFirmwareViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIImageView *_topBg;
    UIButton *_backBtn;
    UILabel *_titleLabel;
    UIButton *_refreshBtn;
    
    UIView *_versionView;
    UILabel *_currentVersionLabel;
    UIImageView *_versionImg;
    UILabel *_newVersionLabel;
    
    UIViewLinkmanTouch *_chooseFirmwareView;
    UILabel *_chooseFirmwareLabel;
    UIImageView *_chooseFirmwareImg;
    UILabel *_chooseFirmwareNameLabel;
    
    UIButton *_updateFirmwareBtn;
    
    UIView *_firmwareListBgView;
    UIView *_firmwareListView;
    UILabel *_firmwareListTitle;
    UITableView *_firmwareListTable;
    UILabel *_firmwareNoteLabel1;
    UILabel *_firmwareNoteLabel2;
    
    UIView *_firmwareSuccessView;
    UILabel *_firmwareSuccessVersion;
    UILabel *_firmwareSuccessValue;
    UIImageView *_firmwareSuccessImg;
    UILabel *_firmwareSuccessNote;
    
    UIButton *_firmwareFailedTryAgainBtn;
    UILabel *_firmwareFailedNote1;
    
    UIView *firmwareView;
}
@end
