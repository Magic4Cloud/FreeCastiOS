//
//  FSMediaManager.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/18.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSMediaManager.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

static FSMediaManager * _sharedSingleton = nil;
static BOOL isFirstAccess = YES;

@implementation FSMediaManager

+ (instancetype)sharedMediaManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedMediaManager];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedMediaManager];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedMediaManager];
}

- (id)copy
{
    return [[[self class] alloc] init];
}

- (id)mutableCopy
{
    return [[[self class] alloc] init];
}

- (id)init
{
    if(_sharedSingleton){
        return _sharedSingleton;
    }
    if (isFirstAccess) {
        NSAssert(NO, @"Cannot create instance of Singleton");
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    return self;
}
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
+ (void)saveImage:(UIImage *)image
{
    //(1) 获取当前的授权状态
    PHAuthorizationStatus lastStatus = [PHPhotoLibrary authorizationStatus];
    
    //(2) 请求授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(status == PHAuthorizationStatusDenied) //用户拒绝（可能是之前拒绝的，有可能是刚才在系统弹框中选择的拒绝）
            {
                if (lastStatus == PHAuthorizationStatusNotDetermined) {
                    //说明，用户之前没有做决定，在弹出授权框中，选择了拒绝
                    
//                    [MBProgressHUD showError:@"保存失败"];
                    return;
                }
                // 说明，之前用户选择拒绝过，现在又点击保存按钮，说明想要使用该功能，需要提示用户打开授权
                
//                [MBProgressHUD showMessage:@"失败！请在系统设置中开启访问相册权限"];
                
            }
            else if(status == PHAuthorizationStatusAuthorized) //用户允许
            {
                //保存图片---调用上面封装的方法
                [self saveImageToCustomAblumWithImage:image];
            }
            else if (status == PHAuthorizationStatusRestricted)
            {
//                [MBProgressHUD showError:@"系统原因，无法访问相册"];
            }
        });
    }];
}

//- (void)saveImageToAlbum:(UIImage *)image {
//    
//    //首先获取相册的集合
//    PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]];
//    //对获取到集合进行遍历
//    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        PHAssetCollection *assetCollection = obj;
//        //Camera Roll是我们写入照片的相册
//        if ([assetCollection.localizedTitle isEqualToString:@"FREESTREAM"])  {
//            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                //请求创建一个Asset
//                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
//                //请求编辑相册
//                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
//                //为Asset创建一个占位符，放到相册编辑请求中
//                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset ];
//                //相册中添加照片
//                [collectonRequest addAssets:@[placeHolder]];
//            } completionHandler:^(BOOL success, NSError *error) {
//                NSLog(@"Error:%@", error);
//            }];
//        }
//    }];
//}

+ (void)saveImageToCustomAblumWithImage:(UIImage *)image
{
    //1 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [self syncSaveImageWithPhotos:image];
    if (assets == nil)
    {
//        [MBProgressHUD showError:@"保存失败"];
        return;
    }
    
    //2 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateIfNo];
    if (assetCollection == nil) {
//        [MBProgressHUD showError:@"相册创建失败"];
        return;
    }
    
    //3 将刚才保存到相机胶卷的图片添加到自定义相册中 --- 保存带自定义相册--属于增的操作，需要在PHPhotoLibrary的block中进行
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    
    if (error) {
//        [MBProgressHUD showError:@"保存失败"];
        return;
    }
//    [MBProgressHUD showSuccess:@"保存成功"];
}

+ (PHFetchResult<PHAsset *> *)syncSaveImageWithPhotos:(UIImage *)image
{
    //--1 创建 ID 这个参数可以获取到图片保存后的 asset对象
    __block NSString *createdAssetID = nil;
    
    //--2 保存图片
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //----block 执行的时候还没有保存成功--获取占位图片的 id，通过 id 获取图片---同步
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    //--3 如果失败，则返回空
    if (error) {
        return nil;
    }
    
    //--4 成功后，返回对象
    //获取保存到系统相册成功后的 asset 对象集合，并返回
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
}

+ (PHAssetCollection *)getAssetCollectionWithAppNameAndCreateIfNo
{
    //1 获取以 APP 的名称
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *title = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    //2 获取与 APP 同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册--返回
            return collection;
        }
    }
    //说明没有找到，需要创建
    NSError *error = nil;
    __block NSString *createID = nil; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到ID，当前并没有创建成功，待创建成功后，通过 ID 来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
//        [MBProgressHUD showError:@"创建失败"];
        return nil;
    }else{
//        [MBProgressHUD showSuccess:@"创建成功"];
        //通过 ID 获取创建完成的相册 -- 是一个数组
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
}



@end
