//
//  MRRNewFeedViewController.m
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import "MRRNewFeedViewController.h"

@interface MRRNewFeedViewController ()

@property (strong, nonatomic) IBOutlet UITextField *feedNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *feedURLTextField;

@end

@implementation MRRNewFeedViewController

- (IBAction)createNewFeedButtonPressed:(UIButton *)sender
{
    //Call delegate method to add new feed
    [self.delegate newFeed:self.feedNameTextField.text withURL:self.feedURLTextField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
