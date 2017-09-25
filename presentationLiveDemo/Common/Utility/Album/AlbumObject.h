//
//  AlbumObject.h
//  camSight
//
//  Created by rakwireless on 16/8/4.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol AlbumDelegate <NSObject>
- (void)readFileFromAlbum:(ALAssetsGroup *)group;
- (void)saveImageToAlbum:(BOOL)success;
- (void)pressentAlertViewControllerWithError:(NSError *)error;
@end


@interface AlbumObject : NSObject
- (void)delegate:(id<AlbumDelegate>)d;
- (ALAssetsLibraryAccessFailureBlock) failureBlock;
- (void)createAlbumInPhoneAlbum:(NSString*)albumName;
- (void)saveImageToAlbum:(UIImage*)image  albumName:(NSString*)albumName;
- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                      customAlbumName:(NSString *)customAlbumName
                      completionBlock:(void (^)(void))completionBlock
                      failureBlock:(void (^)(NSError *error))failureBlock;
- (void)saveVideoToAlbum:(NSString*)path  albumName:(NSString*)albumName;
- (void)_addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName;
- (void)readFileFromAlbum:(NSString*)albumName;
- (void)removeFileFromAlbum:(NSString*)fileUrl isSuccessBlock:(void (^)(BOOL isSuccess))completionHandle;

- (void)removeFilesFromAlbum:(NSArray *)fileUrls isSuccessBlock:(void (^)(BOOL isSuccess))completionHandler;//移除多个

- (NSString *)getPathForRecord:(NSString*)albumName;
@end