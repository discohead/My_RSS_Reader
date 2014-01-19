//
//  MRRFolderTableViewController.h
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRRNSUserDefaultsManager.h"

@interface MRRFolderTableViewController : UITableViewController

@property (strong,nonatomic) NSMutableDictionary *folder;
@property (strong,nonatomic) MRRNSUserDefaultsManager *userDefaultsManager;

@end
