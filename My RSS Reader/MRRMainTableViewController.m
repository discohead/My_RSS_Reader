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
    NSURL *url = [NSURL URLWithString:fromURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    DDXMLDocument *opmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    
    //Select all of the outer most outline elements (i.e. outlines that are children of the body element)
    NSArray *outline = [opmlDoc nodesForXPath:@"/opml/body/outline" error:nil];
    
    //Enumerate through them creating folders and feeds
    for (DDXMLElement *element in outline)
    {
        NSMutableDictionary *currentFolder = [[NSMutableDictionary alloc] initWithObjects:@[@"",[[NSMutableArray alloc] init]] forKeys:@[@"name",@"feeds"]];
        
        //If outline element has children, I believe it is safe to assume it is a "folder" and the children are feeds
        if ([[element children] count])
        {
            //OPML stores all of the info as attributes. There is no text between tags.
            NSArray *attributes = [element attributes];
            NSArray *feeds = [element children];
            
            for (DDXMLNode *attribute in attributes)
            {
                if ([[attribute name] isEqualToString:@"text"])
                {
                    NSString *folderName = [attribute stringValue];
                    [currentFolder setObject:folderName forKey:@"name"];
                    [self.folders addObject:currentFolder];
                }
            }
            
            for (DDXMLElement *feed in feeds)
            {
                NSArray *feedAttributes = [feed attributes];
                NSMutableDictionary *feedDictionary = [[NSMutableDictionary alloc] initWithObjects:@[currentFolder[@"name"],@"",@"",[NSMutableArray array]] forKeys:@[@"folder",@"feedName",@"rssURL",@"items"]];
                NSMutableArray *folderFeeds = currentFolder[@"feeds"];
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
                [folderFeeds addObject:feedDictionary];
            }
            
        }
    }
    [self.userDefaultsManager updateAllFolders:self.folders];
    [self.tableView reloadData];
    
}

- (void)createNewFolder:(NSString *)folderName
{
    NSMutableDictionary *folder = [[NSMutableDictionary alloc] initWithObjects:@[folderName,[[NSMutableArray alloc] init]] forKeys: @[@"name",@"feeds"]];
    [self.folders addObject:folder];
    [self.userDefaultsManager addFolder:folder];
    [self.tableView reloadData];
}

@end
