//
//  MRRFolderTableViewController.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRFolderTableViewController.h"
#import "MRRNewFeedViewController.h"
#import "MRRFeedTableViewController.h"
#import "DDXML.h"
#import "MRRNSUserDefaultsManager.h"

@interface MRRFolderTableViewController () <UIAlertViewDelegate, MRRNewFeedViewControllerDelegate>

@end

@implementation MRRFolderTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = self.folder[@"name"];
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
    return [self.folder[@"feeds"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Feed Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Get feed dictionary
    NSMutableArray *feeds = self.folder[@"feeds"];
    NSMutableDictionary *feedDictionary = feeds[indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = feedDictionary[@"feedName"];
    cell.detailTextLabel.text = feedDictionary[@"rssURL"];
    
    return cell;
}


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
        //Delete feed from data source
        [self.folder[@"feeds"] removeObject:self.folder[@"feeds"][indexPath.row]];
        //Update userdefaults
        [self.userDefaultsManager updateFolder:self.folder];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



 //Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.folder[@"feeds"] exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    [self.userDefaultsManager updateFolder:self.folder];
}



 //Override to support conditional rearranging of the table view.
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
    if ([segue.identifier isEqualToString:@"newFeed"])
    {
        if ([segue.destinationViewController isKindOfClass:[MRRNewFeedViewController class]])
        {
            MRRNewFeedViewController *newFeedVC = (MRRNewFeedViewController *)segue.destinationViewController;
            //Set NewFeedViewControllerDelegate
            newFeedVC.delegate = self;
        }
    }
    
    if ([segue.identifier isEqualToString:@"toFeed"])
    {
        if ([sender isKindOfClass:[UITableViewCell class]])
        {
            //Get selected feed dictionary
            UITableViewCell *feedCell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:feedCell];
            NSMutableDictionary *feedDictionary = self.folder[@"feeds"][indexPath.row];
            if ([segue.destinationViewController isKindOfClass:[MRRFeedTableViewController class]])
            {
                MRRFeedTableViewController *feedVC = (MRRFeedTableViewController *)segue.destinationViewController;
                //Pass selected feed dictionary to feed view controller
                feedVC.feed = feedDictionary;
            }
        }
    }
    
}

#pragma mark - MRRNewFeedViewControllerDelegate

- (void)newFeed:(NSString *)feedName withURL:(NSString *)url
{
    //Create new feed dictionary with folder name, feed name, rss url, and empty mutable array for rss items
    NSMutableDictionary *newFeed = [[NSMutableDictionary alloc] initWithObjects:@[self.folder[@"name"],feedName,url,[NSMutableArray array]] forKeys:@[@"folder",@"feedName",@"rssURL",@"items"]];
    
    //Dispatch thread to fetch rss xml data
    dispatch_queue_t rssThread = dispatch_queue_create("fetchRSS", NULL);
    dispatch_async(rssThread, ^{
        [self fetchRSS:newFeed];
    });
}

#pragma mark - Helper Methods

- (void)fetchRSS:(NSMutableDictionary *)feed
{
    NSURL *url = [NSURL URLWithString:feed[@"rssURL"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    
    //Create XML document from fetched NSData
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:data options:1 error:&error];
    if (!error)
    {
        [self parseXML:xmlDoc forFeed:feed];
    }
    
}

- (void)parseXML:(DDXMLDocument *)xmlDoc forFeed:(NSMutableDictionary *)feed
{
    NSError *error = nil;
    
    //Use xpath to extract each item element from rss xml
    NSArray *itemNodes = [xmlDoc nodesForXPath:@"//item" error:&error];
    if (!error)
    {
        for (DDXMLNode *node in itemNodes)
        {
            NSMutableArray *items = (NSMutableArray *)feed[@"items"];
            NSError *xmlDocError;
            //Convert DDXML objects to plist (NSData) so it can be stored in NSUserDefaults
            DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:[node XMLString] options:0 error:&xmlDocError];
            NSData *nodeAsData = [xmlDoc XMLData];
            [items addObject:nodeAsData];
        }
    }
    
    //Update tableview datasource, user defaults and reload tableview on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addFeed:feed];
    });
}

- (void)addFeed:(NSMutableDictionary *)feed
{
    [self.folder[@"feeds"] addObject:feed];
    [self.userDefaultsManager updateFolder:self.folder];
    [self.tableView reloadData];
}





















@end
