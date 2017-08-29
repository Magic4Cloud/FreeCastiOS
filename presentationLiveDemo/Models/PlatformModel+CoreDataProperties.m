//
//  PlatformModel+CoreDataProperties.m
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "PlatformModel+CoreDataProperties.h"

@implementation PlatformModel (CoreDataProperties)

+ (NSFetchRequest<PlatformModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PlatformModel"];
}

@dynamic customString;
@dynamic isEnable;
@dynamic isSelected;
@dynamic name;
@dynamic rtmp;
@dynamic streamKey;

@end
