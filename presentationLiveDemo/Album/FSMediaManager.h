//
//  FSMediaManager.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/18.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSMediaManager : NSObject

+ (instancetype)sharedMediaManager;

- (void)saveImageToAlbum:(UIImage *)image;


@end
