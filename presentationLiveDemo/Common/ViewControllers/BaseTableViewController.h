//
//  BaseTableViewController.h
//  Patrol
//
//  Created by Benjamin on 4/7/17.
//  Copyright © 2017 Cloud4Magic. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak)         IBOutlet        UITableView     *tableView;

@end
