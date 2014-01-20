//
//  MRRNSUserDefaultsManager.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRNSUserDefaultsManager.h"

@interface MRRNSUserDefaultsManager ()

@end

@implementation MRRNSUserDefaultsManager

- (void)updateAllFolders:(NSMutableArray *)allFolders
{
    [[NSUserDefaults standardUserDefaults] setObject:allFolders forKey:@"folders"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)addFolder:(NSMutableDictionary *)folder
{
    NSMutableArray *folders = [self folders];
    
    //Lazy instantiation of user defaults main dictionary of folders
    if (!folders)
    {
        folders = [[NSMutableArray alloc] init];
        [folders addObject:folder];
        [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else
    {
        [folders addObject:folder];
        [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)deleteFolder:(NSMutableDictionary *)folderToDelete
{
    NSMutableArray *folders = [self folders];
    [folders removeObject:folderToDelete];
    [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateFolder:(NSMutableDictionary *)folder
{
    NSMutableArray *folders = [self folders];
    NSUInteger idx = [folders indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *folderDictionary = (NSDictionary *)obj;
        return [folderDictionary[@"name"] isEqualToString:folder[@"name"]];
    }];
    if (idx != NSNotFound)
    {
        [folders replaceObjectAtIndex:idx withObject:folder];
        [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSMutableArray *)folders
{
    NSMutableArray *folders = [[[NSUserDefaults standardUserDefaults] objectForKey:@"folders"] mutableCopy];
    return folders;
}

@end
