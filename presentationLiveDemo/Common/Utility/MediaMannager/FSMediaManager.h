//
//  FSMediaManager.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/18.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface FSMediaManager : NSObject

+ (void)saveImage:(UIImage *)image;

//+ (void)accessToImageAccordingToTheAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void(^)(UIImage *image,NSDictionary *info))completion;

+ (NSArray<UIImage *>*)getAllPhotoWithsize:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)imageResizeMode;
@end
