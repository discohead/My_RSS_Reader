//
//  MRRArticleViewController.h
//  My RSS Reader
//
//  Created by Jared McFarland on 1/18/14.
//  Copyright (c) 2014 Jared McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDXML.h"

@interface MRRArticleViewController : UIViewController

@property (strong,nonatomic) DDXMLNode *item;

@end
