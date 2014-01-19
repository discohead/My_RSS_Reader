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


- (void)addFolder:(NSMutableDictionary *)folder
{
    NSMutableDictionary *folders = [self folders];
    
    //Lazy instantiation of user defaults main dictionary of folders
    if (!folders)
    {
        folders = [[NSMutableDictionary alloc] init];
        [folders setObject:folder forKey:folder[@"name"]];
        [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else
    {
        [folders setObject:folder forKey:folder[@"name"]];
        [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)deleteFolder:(NSMutableDictionary *)folderToDelete
{
    NSMutableDictionary *folders = [self folders];
    [folders removeObjectForKey:folderToDelete[@"name"]];
    [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateFolder:(NSMutableDictionary *)folder
{
    NSMutableDictionary *folders = [self folders];
    [folders setObject:folder forKey:folder[@"name"]];
    [[NSUserDefaults standardUserDefaults] setObject:folders forKey:@"folders"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)folders
{
    NSMutableDictionary *folders = [[[NSUserDefaults standardUserDefaults] objectForKey:@"folders"] mutableCopy];
    return folders;
}

@end
