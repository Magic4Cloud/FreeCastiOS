//
//  FSLeftSideTableViewCell.h
//  Freestream
//
//  Created by Frank Li on 2017/11/9.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>
#import "FSLeftSideModel.h"

@protocol FSLeftSideTableViewCellDelegate <NSObject>
@required
- (void)didSelectedCell:(FSLeftSideTitle)cellTitle;
@end

@interface FSLeftSideTableViewCell : CoreXibTableViewCell

@property (nonatomic, weak) id <FSLeftSideTableViewCellDelegate>delegate;

- (void)setupTitleButton:(NSString *)title;

+ (CGFloat) heightForLeftSideMenu;
@end
