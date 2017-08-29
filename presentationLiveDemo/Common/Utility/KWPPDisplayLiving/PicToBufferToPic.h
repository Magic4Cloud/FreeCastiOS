//
//  PicToBufferToPic.h
//  presentationLiveDemo
//
//  Created by zyh_scut on 16/8/23.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#ifndef PicToBufferToPic_h
#define PicToBufferToPic_h
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "LFGPUImageBeautyFilter.h"

typedef NS_ENUM(NSInteger,ScaleSizeLevel){
    ScaleSizeSS =1,  //缩放比例，1最小：25%
    ScaleSizeS =2,   //2小： 50%
    ScaleSizeM =3,   //3中：75%
    ScaleSizeL =4,   //4大：100%
};

@interface PicBufferUtil :NSObject

+(CVPixelBufferRef) firstWayConvertToCVPixelBufferRefFromImage: (UIImage* )image;
+(CVPixelBufferRef) convertToCVPixelBufferFromImage:(UIImage *) image;
+(UIImage *) scaleImage:(UIImage *)image toScale:(ScaleSizeLevel)scaleSize;
+(UIImage *) scaleImage:(UIImage *)image toSize:(CGSize)size;
+(UIImage *)putImage:(UIImage *)imageUL :(UIImage *)imageUR :(UIImage *)imageLL :(UIImage *)imageLR :(UIImage *)imageText onTheTopOfImage:(UIImage *)imageMain:(NSString *)showType;
+(UIImage *) convertToImageFromCVImageBufferRef:( CVImageBufferRef)pixelBuffer;
+ (UIImage *)changeAlphaOfImageWith:(CGFloat)alpha withImage:(UIImage*)image;

@end
#endif /* PicToBufferToPic_h */
