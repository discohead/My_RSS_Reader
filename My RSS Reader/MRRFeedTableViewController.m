//
//  MRRFeedTableViewController.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRFeedTableViewController.h"
#import "MRRArticleViewController.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@interface MRRFeedTableViewController ()

@property (strong, nonatomic) NSMutableArray *items; //of DDXMLDocument

@end

@implementation MRRFeedTableViewController


//Lazily instantiate items and convert back to DDXML object from plist NSData
- (NSMutableArray *)items
{
    if (!_items)
    {
        _items = [[NSMutableArray alloc] init];
        for (NSData *itemData in self.feed[@"items"])
        {
            NSError *xmlFromDataError;
            DDXMLDocument *xmlFromData = [[DDXMLDocument alloc] initWithData:itemData options:0 error:&xmlFromDataError];
            if (!xmlFromDataError)
            {
                [_items addObject:xmlFromData];
            } else
            {
                NSLog(@"xmlFromDataError on %@ = %@",xmlFromData.name, xmlFromDataError);
            }
            
        }
        return _items;
    } else
    {
        return _items;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Item Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Get DDXML object for cell and use xpath to extract title and description
    DDXMLNode *itemNode = self.items[indexPath.row];
    NSError *titleError = nil;
    DDXMLNode *itemTitle = (DDXMLNode *)[[itemNode nodesForXPath:@"//title" error:&titleError] firstObject];
    if (titleError)
    {
        NSLog(@"titeError = %@",titleError);
    }
    NSError *descriptionError = nil;
    DDXMLNode *itemDescription = (DDXMLNode *)[[itemNode nodesForXPath:@"//description" error:&descriptionError] firstObject];
    if (descriptionError)
    {
        NSLog(@"descriptionError = %@",descriptionError);
    }
    // Configure the cell...
    cell.textLabel.text = [itemTitle stringValue];
    cell.detailTextLabel.text = [itemDescription stringValue];
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toArticle"])
    {
        if ([sender isKindOfClass:[UITableViewCell class]])
        {
            //Get selected article's DDXML object
            UITableViewCell *itemCell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:itemCell];
            DDXMLDocument *itemNode = self.items[indexPath.row];
            if ([segue.destinationViewController isKindOfClass:[MRRArticleViewController class]])
            {
                MRRArticleViewController *articleVC = (MRRArticleViewController *)segue.destinationViewController;
                articleVC.navigationItem.title = itemCell.textLabel.text;
                articleVC.item = itemNode;
            }
            
        }
        
    }
}



@end
