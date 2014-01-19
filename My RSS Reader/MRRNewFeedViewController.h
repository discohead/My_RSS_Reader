//
//  MRRNewFeedViewController.h
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>


//Protocol to send new feed name and url back to folder view controller
@protocol MRRNewFeedViewControllerDelegate <NSObject>

- (void)newFeed:(NSString *)name withURL:(NSString *)url;

@end

@interface MRRNewFeedViewController : UIViewController

@property (weak) id <MRRNewFeedViewControllerDelegate> delegate;

@end
