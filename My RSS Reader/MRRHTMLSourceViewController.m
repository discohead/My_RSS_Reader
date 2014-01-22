//
//  MRRHTMLSourceViewController.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/21/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRHTMLSourceViewController.h"

@interface MRRHTMLSourceViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MRRHTMLSourceViewController

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
	
    //Set textView's text property to NSstring of the site's HTML source
    self.textView.text = self.html;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
