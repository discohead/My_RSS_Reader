//
//  MRRMainTableViewController.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRMainTableViewController.h"
#import "MRRFolderTableViewController.h"
#import "MRRNSUserDefaultsManager.h"
#import "DDXML.h"

@interface MRRMainTableViewController () <UIAlertViewDelegate>

@property (strong,nonatomic) NSMutableArray *folders;
@property (strong, nonatomic) MRRNSUserDefaultsManager *userDefaultsManager;

@end

@implementation MRRMainTableViewController

#pragma mark - Lazy Instantiation of properties

- (MRRNSUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager)
    {
        _userDefaultsManager = [[MRRNSUserDefaultsManager alloc] init];
    }
    return _userDefaultsManager;
}

- (NSMutableArray *)folders
{
    if (!_folders)
    {
        _folders = [[NSMutableArray alloc] init];
    }
    return _folders;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.folders = [self.userDefaultsManager folders];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.folders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Folder Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Get NSMutableDictionary for folder
    NSMutableDictionary *folder = self.folders[indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = folder[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu Feeds", (unsigned long)[folder[@"feeds"] count]];
    
    
    return cell;
}

#pragma mark - TableView Editing
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Get folder to delete
        NSMutableDictionary *deletedFolder = [self.folders objectAtIndex:indexPath.row];
        //Delete from user defaults
        [self.userDefaultsManager deleteFolder:deletedFolder];
        //Delete from datasource
        [self.folders removeObject:deletedFolder];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.folders exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    [self.userDefaultsManager updateAllFolders:self.folders];
    [self.tableView reloadData];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toFolder"])
    {
        if ([sender isKindOfClass:[UITableViewCell class]])
        {
            //Get folder to pass on to folder view controller
            UITableViewCell *folderCell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:folderCell];
            NSMutableDictionary *folder = self.folders[indexPath.row];

            if ([segue.destinationViewController isKindOfClass:[MRRFolderTableViewController class]])
            {
                MRRFolderTableViewController *folderVC = (MRRFolderTableViewController *)segue.destinationViewController;
                folderVC.folder = folder;
                folderVC.userDefaultsManager = self.userDefaultsManager;
            }
            
        }
    }
}


#pragma mark - IBActions
- (IBAction)addFolderBarButtonItemPressed:(id)sender
{
    //Get new folder name via alert view
    UIAlertView *newFolder = [[UIAlertView alloc] initWithTitle:@"New Folder" message:@"Enter Folder Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    newFolder.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newFolder show];
}

- (IBAction)importOPMLBarButtonItemPressed:(UIBarButtonItem *)sender
{
    //Get URL for OPML file via alert view
    UIAlertView *opmlURL = [[UIAlertView alloc] initWithTitle:@"Import OPML" message:@"Enter URL to OPML file" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    opmlURL.alertViewStyle = UIAlertViewStylePlainTextInput;
    [opmlURL show];
}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"New Folder"])
    {
        if (buttonIndex == 1)
        {
            //Create new folder update datasource and user defaults
            NSString *folderName = [alertView textFieldAtIndex:0].text;
            [self createNewFolder:folderName];
        }
    }
    else if ([alertView.title isEqualToString:@"Import OPML"])
    {
        if (buttonIndex == 1)
        {
            //Get URL from alertView
            NSString *opmlURL = [alertView textFieldAtIndex:0].text;
            
            //Import OPML file from URL, parse, create folders and feeds
            [self importOPMLFile:opmlURL];
        }
    }
}

#pragma mark - Helper Methods

- (void)importOPMLFile:(NSString *)fromURL
{
    //Get OPML data from URL and init DDXML document
    NSURL *url = [NSURL URLWithString:fromURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    DDXMLDocument *opmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    
    //Select all of the outer most outline elements (i.e. outlines that are children of the body element)
    NSArray *outlines = [opmlDoc nodesForXPath:@"/opml/body/outline" error:nil];
    
    [self parseOutlineElements:outlines];
    [self.userDefaultsManager updateAllFolders:self.folders];
    
}

- (void)createNewFolder:(NSString *)folderName
{
    NSMutableDictionary *folder = [[NSMutableDictionary alloc] initWithObjects:@[folderName,[[NSMutableArray alloc] init]] forKeys: @[@"name",@"feeds"]];
    [self.folders addObject:folder];
    [self.userDefaultsManager addFolder:folder];
    [self.tableView reloadData];
}

- (NSMutableArray *)folderFromOPML:(DDXMLElement *)outlineElement
{
    //Container array to be returned holding the folder dictionary and feed array for separate processsing
    NSMutableArray *wrapperArray = [[NSMutableArray alloc] init];
    
    //Initialize folder dictionary
    NSMutableDictionary *folder = [[NSMutableDictionary alloc] initWithObjects:@[@"",[[NSMutableArray alloc] init]] forKeys:@[@"name",@"feeds"]];
    
    //The folder name will be stored in the DDXMLElement's attributes so we grab them
    NSArray *attributes = [outlineElement attributes];
    
    //The element's children will presumably be feeds, but could possibly be nested folders, we handle that case later
    NSMutableArray *children = [[outlineElement children] mutableCopy];
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    for (DDXMLElement *child in children)
    {
        NSArray *attributes = [child attributes];
        for (DDXMLElement *attribute in attributes)
        {
            if ([[attribute stringValue] isEqualToString:@"rss"])
            {
                [feeds addObject:child];
            }
        }
    }
    
    
    //Enumerate through the attributes set foldername equal to text attribute, replace existing folder of same name if found, otherwise add new folder
    for (DDXMLNode *attribute in attributes)
    {
        if ([[attribute name] isEqualToString:@"text"])
        {
            NSString *folderName = [attribute stringValue];
            [folder setObject:folderName forKey:@"name"];
            
            if ([self.folders count])
            {
                for (int i = 0; i < [self.folders count]; i++)
                {
                    if ([self.folders[i][@"name"] isEqualToString:folderName])
                    {
                        [self.folders replaceObjectAtIndex:i withObject:folder];
                        break;
                    }
                    else if (i == [self.folders count]-1)
                    {
                        [self.folders addObject:folder];
                    }
                }
            }
            else
            {
                [self.folders addObject:folder];
            }
        }
    }
    
    //Add newly created folder dictionary and feeds array to container array to be returned
    [wrapperArray addObject:folder];
    [wrapperArray addObject:feeds];
    
    return wrapperArray;
}

- (void)feedsFromOPML:(NSMutableArray *)feeds forFolder:(NSMutableDictionary *)folder
{
    //If folder exists re-initizalize it
    if ([self.folders containsObject:folder])
    {
        [folder setObject:[[NSMutableArray alloc] init] forKey:@"feeds"];
    }
    
    //Enumerate the feed elements creating dictionary's with the text attribute as the feedName and the xmlUrl attribute as the rssURL
    for (DDXMLElement *feed in feeds)
    {
        NSArray *feedAttributes = [feed attributes];
        NSMutableDictionary *feedDictionary = [[NSMutableDictionary alloc] initWithObjects:@[folder[@"name"],@"",@"",[NSMutableArray array]] forKeys:@[@"folder",@"feedName",@"rssURL",@"items"]];
        NSMutableArray *folderFeeds = folder[@"feeds"];
        for (DDXMLNode *feedAttribute in feedAttributes)
        {
            if ([[feedAttribute name] isEqualToString:@"text"])
            {
                [feedDictionary setObject:[feedAttribute stringValue] forKey:@"feedName"];
            }
            else if ([[feedAttribute name] isEqualToString:@"xmlUrl"])
            {
                [feedDictionary setObject:[feedAttribute stringValue] forKey:@"rssURL"];
            }
        }
        
        //Add feed dictionary to folder
        [folderFeeds addObject:feedDictionary];
    }
}

- (void)parseOutlineElements:(NSArray *)outlineElements
{
    //Default catch-all folder for feeds not in any folder
    NSMutableDictionary *myFeedsFolder = [[NSMutableDictionary alloc] initWithObjects:@[@"My Feeds",[NSMutableArray array]] forKeys: @[@"name",@"feeds"]];
    NSMutableArray *looseFeeds = [[NSMutableArray alloc] init];
    
    //Enumerate through the outline element creating folders and feeds
    for (DDXMLElement *element in outlineElements)
    {
        //Create copy so that we can remove child nodes that are nested folders while in fast enumeration
        DDXMLElement *elementCopy = [element copy];
        
        //Container array to receive return value from folderFromOPML method
        NSMutableArray *elementContainer = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *currentFolder = [[NSMutableDictionary alloc] init];
        NSArray *children = [element children];
        
        //If outline element has children, we assume it is a "folder"
        if ([children count])
        {
            for (DDXMLElement *child in children)
            {
                //If any of the folder's children have children then we call this method again with the nested folder, this brings all nested folders out to the top level
                if ([[child children] count])
                {
                    //Get index of child remove from copy, separate out nested folders and leave only feeds
                    NSUInteger index = [child index];
                    [elementCopy removeChildAtIndex:index];
                    
                    //Recursive call with nested folder element
                    [self parseOutlineElements:@[child]];
                }
            }
            
            //Create folder with element copy that has had nested folders removed (if any)
            elementContainer = [self folderFromOPML:elementCopy];
            currentFolder = elementContainer[0];
            NSMutableArray *feeds = elementContainer[1];
            [self feedsFromOPML:feeds forFolder:currentFolder];
            
        } else
        {
            if ([self.folders count])
            {
                //Deal with feeds outside of any folder by creating (or adding to) a default "My Feeds" folder
                for (int i = 0; i < [self.folders count]; i++)
                {
                    if ([self.folders[i][@"name"] isEqualToString:@"My Feeds"])
                    {
                        myFeedsFolder = self.folders[i];
                        break;
                    } else if (i == [self.folders count]-1)
                    {
                        [self.folders addObject:myFeedsFolder];
                    }
                }
            }
            else
            {
                [self.folders addObject:myFeedsFolder];
            }
            //Collect all of the feeds outside of a folder and put them into the default "My Feeds" folder
            [looseFeeds addObject:elementCopy];
        }
    }
    [self feedsFromOPML:looseFeeds forFolder:myFeedsFolder];
    [self.tableView reloadData];
}

@end
