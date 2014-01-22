//
//  MRRWebViewController.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/21/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRWebViewController.h"
#import "MRRHTMLSourceViewController.h"

@interface MRRWebViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong,nonatomic) NSString *html;
@end

@implementation MRRWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSURL *articleURL = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:articleURL];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)viewSourceBarButtonItemPressed:(id)sender
{
    self.html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    [self performSegueWithIdentifier:@"toSource" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toSource"])
    {
        if ([segue.destinationViewController isKindOfClass:[MRRHTMLSourceViewController class]])
        {
            MRRHTMLSourceViewController *sourceVC = (MRRHTMLSourceViewController *)segue.destinationViewController;
            sourceVC.html = self.html;
        }
    }
}

@end
