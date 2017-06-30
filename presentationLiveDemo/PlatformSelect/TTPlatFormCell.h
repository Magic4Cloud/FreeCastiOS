//
//  TTPlatFormCell.h
//  presentationLiveDemo
//
//  Created by tc on 6/28/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlatformModel+CoreDataProperties.h"
/**
 选择平台cell
 */
@interface TTPlatFormCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

@property (weak, nonatomic) IBOutlet UIButton *cellEditButton;

@property (weak, nonatomic) IBOutlet UIView *contentBgView;

@property (nonatomic, strong) PlatformModel * model;

@end
