//
//  MRRNSUserDefaultsManager.h
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import <Foundation/Foundation.h>

//Class to manage NSUserDefaults, I'm not sure if this is optimal or not, first time I've handled user defaults this way... just experimenting

@interface MRRNSUserDefaultsManager : NSObject

- (void)updateAllFolders:(NSMutableArray *)allFolders;
- (void)addFolder:(NSMutableDictionary *)folder;
- (void)deleteFolder:(NSMutableDictionary *)folderToDelete;
- (void)updateFolder:(NSMutableDictionary *)folder;
- (NSMutableArray *)folders;


@end
