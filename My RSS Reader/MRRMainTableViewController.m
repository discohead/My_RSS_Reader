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

- (IBAction)settingsBarButtonItemPressed:(id)sender
{
    //To do:
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1)
    {
        //Create new folder update datasource and user defaults
        UITextField *folderName = [alertView textFieldAtIndex:0];
        NSMutableDictionary *folder = [[NSMutableDictionary alloc] initWithObjects:@[folderName.text,[[NSMutableArray alloc] init]] forKeys: @[@"name",@"feeds"]];
        [self.folders addObject:folder];
        [self.userDefaultsManager addFolder:folder];
        [self.tableView reloadData];
    }
}

@end
