//
//  PlatformModel+CoreDataProperties.h
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "PlatformModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PlatformModel (CoreDataProperties)

+ (NSFetchRequest<PlatformModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *customString;
@property (nonatomic) BOOL isEnable;
@property (nonatomic) BOOL isSelected;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *rtmp;
@property (nullable, nonatomic, copy) NSString *streamKey;

@end

NS_ASSUME_NONNULL_END
