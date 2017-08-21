//
//  BaseCollectionViewController.h
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseCollectionViewController : BaseViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak)         IBOutlet        UICollectionView     *collectionView;

@end
