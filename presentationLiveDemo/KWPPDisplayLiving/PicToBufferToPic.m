//
//  PicToBufferToPic.m
//  presentationLiveDemo
//
//  Created by zyh_scut on 16/8/23.
//  Copyright © 2016年 ZYH. All rights reserved.
//

#import "PicToBufferToPic.h"



@implementation PicBufferUtil


+(CVPixelBufferRef) firstWayConvertToCVPixelBufferRefFromImage: (UIImage* )image {
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    
    CVPixelBufferRef pxbuffer =NULL;
    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,image.size.width,image.size.height,kCVPixelFormatType_32BGRA,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata !=NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context =CGBitmapContextCreate(pxdata,image.size.width,image.size.height,8,4*image.size.width,rgbColorSpace,kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little);
    NSParameterAssert(context);
    
    CGContextDrawImage(context,CGRectMake(0,0,image.size.width,image.size.height),image.CGImage);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}

//将一张图片转为CVPixelBufferRef   注：使用完pxbuffer后，需要释放内存
+(CVPixelBufferRef)convertToCVPixelBufferFromImage:(UIImage *)image {
    CVPixelBufferRef pxbuffer = NULL;
    
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    
    size_t width =image.size.width;
    size_t height =image.size.height;
    size_t bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
    
    CFDataRef dataFromImage = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    GLbyte *imgData = (GLbyte *)CFDataGetBytePtr(dataFromImage);
    
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, imgData,bytesPerRow,NULL,NULL, (__bridge CFDictionaryRef)options, &pxbuffer);
    CFRelease(dataFromImage);
    
    return pxbuffer;
}

//将一张图片以scaleSize的比例缩放，返回缩放后的图片
+(UIImage *)scaleImage:(UIImage *)image toScale:(ScaleSizeLevel)scaleSize{
    float scaleLever = 1.0/(5-(int)scaleSize);
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleLever, image.size.height * scaleLever));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleLever, image.size.height * scaleLever)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, size) == NO)
    {
        CGFloat widthFactor = width/targetWidth;
        CGFloat heightFactor = height/targetHeight;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width/ scaleFactor;
        scaledHeight = height/scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");

    UIGraphicsEndImageContext();
    
    return newImage;
}

//将图片1贴到图片2 的右下角上，返回组合后的图片
CGFloat pos_diff=3.0;
int pos_count=0;

+(UIImage *)putImage:(UIImage *)imageUL :(UIImage *)imageUR :(UIImage *)imageLL :(UIImage *)imageLR :(UIImage *)imageText onTheTopOfImage:(UIImage *)imageMain:(NSString *)showType{
    if ((imageUL==nil)&&(imageUR==nil)&&(imageLL==nil)&&(imageLR==nil)&&(imageText==nil)) {
        return imageMain;
    }
    
    CGFloat w1 = CGImageGetWidth(imageMain.CGImage);
    CGFloat h1= CGImageGetHeight(imageMain.CGImage);

    CGFloat imageUL_w;
    CGFloat imageUL_h;
    CGFloat imageUR_w;
    CGFloat imageUR_h;
    CGFloat imageLL_w;
    CGFloat imageLL_h;
    CGFloat imageLR_w;
    CGFloat imageLR_h;
    CGFloat imageT_w;
    CGFloat imageT_h;
    
    UIGraphicsBeginImageContext(CGSizeMake(w1, h1));
    [imageMain drawInRect:CGRectMake(0, 0, w1, h1)];
    if (imageText!=nil) {
        imageT_w = CGImageGetWidth(imageText.CGImage);
        imageT_h = CGImageGetHeight(imageText.CGImage);
        if ([showType isEqualToString:@"roll"]) {
            [imageText drawInRect:CGRectMake(w1-pos_count*pos_diff,h1-imageT_h+10, imageT_w,imageT_h)];
            if (w1-pos_count*pos_diff<=-imageT_w) {
                pos_count=0;
            }
            else{
                pos_count++;
            }
        }
        else{
            [imageText drawInRect:CGRectMake((w1-imageT_w)*0.5,h1-imageT_h+10, imageT_w,imageT_h)];
        }
    }
    
    if (imageUL!=nil) {
        imageUL_w = CGImageGetWidth(imageUL.CGImage);
        imageUL_h = CGImageGetHeight(imageUL.CGImage);
        [imageUL drawInRect:CGRectMake(0, 0, imageUL_w*h1/6/imageUL_h,h1/6)];
    }
    if (imageUR!=nil) {
        imageUR_w = CGImageGetWidth(imageUR.CGImage);
        imageUR_h = CGImageGetHeight(imageUR.CGImage);
        [imageUR drawInRect:CGRectMake(w1-imageUR_w*h1/6/imageUR_h, 0, imageUR_w*h1/6/imageUR_h,h1/6)];
    }
    if (imageLL!=nil) {
        imageLL_w = CGImageGetWidth(imageLL.CGImage);
        imageLL_h = CGImageGetHeight(imageLL.CGImage);
        [imageLL drawInRect:CGRectMake(0, h1-h1/6, imageLL_w*h1/6/imageLL_h,h1/6)];
    }
    if (imageLR!=nil) {
        imageLR_w = CGImageGetWidth(imageLR.CGImage);
        imageLR_h = CGImageGetHeight(imageLR.CGImage);
        [imageLR drawInRect:CGRectMake(w1-imageLR_w*h1/6/imageLR_h,h1-h1/6,imageLR_w*h1/6/imageLR_h,h1/6)];
    }
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

//将一个CVImageBufferRef对象 转为图片@ 
+(UIImage *) convertToImageFromCVImageBufferRef:(CVImageBufferRef)pixelBuffer{
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);  //上锁
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer); //获取地址
    size_t width = CVPixelBufferGetWidth(pixelBuffer);  //获取宽，高，大小，以及每一行的位数
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    size_t buffersize = CVPixelBufferGetDataSize(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();  //构造色彩空间
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,baseAddress,buffersize,NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace,kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,provider, NULL, true, kCGRenderingIntentDefault);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];  //定义图片
    CGImageRelease(cgImage);  //释放内存
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0); //解锁
    return image;
}

/**
 *  改变图片的透明度
 *
 *  @param alpha 透明度
 *  @param image 图片源
 *
 *  @return 返回透明度变化后的图片
 */
+ (UIImage *)changeAlphaOfImageWith:(CGFloat)alpha withImage:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
