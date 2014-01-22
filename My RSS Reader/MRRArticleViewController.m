//
//  MRRArticleViewController.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRArticleViewController.h"
#import "MRRWebViewController.h"

@interface MRRArticleViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *viewWebsiteBarButtonItem;
@property (strong, nonatomic) NSString *url;

@end

@implementation MRRArticleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Extract RSS <link> element URL
    NSError *linkError;
    NSArray *itemLink = [self.item nodesForXPath:@"//link" error:&linkError];
    DDXMLDocument *link = [itemLink firstObject];
    self.url = [link stringValue];
    
	// Extract all child elements from item element
    NSArray *itemChildren = [self.item children];
    
    //Create mutable array to store stringValue of each child element
    NSMutableArray *itemChildrenStrings = [[NSMutableArray alloc] init];
    for (int i = 0; i < [itemChildren count]; i++)
    {
        itemChildrenStrings[i] = [itemChildren[i] stringValue];
    }
    
    //¨Uber hacky "algorithm" to select best element to display as article content in textView
    //Sort xml stringValues by length and store the longest
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [itemChildrenStrings sortUsingDescriptors:sortDescriptors];
    NSString *htmlString = [itemChildrenStrings lastObject];
    
    //Dispatch thread to convert longest string to NSAttributedString with attributes from HTML and set result to textView's attributed text
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString *longestAttributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                       options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]}
                                                                            documentAttributes:nil error:nil];
        self.textView.attributedText = longestAttributedString;
        [self.activityIndicator stopAnimating];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toWeb"])
    {
        NSLog(@"toWeb");
        if ([segue.destinationViewController isKindOfClass:[MRRWebViewController class]])
        {
            MRRWebViewController *webVC = (MRRWebViewController *)segue.destinationViewController;
            webVC.url = self.url;
        }
    }
}

@end
