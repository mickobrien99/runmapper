//
//  SecondViewController.h
//  RunMapper
//
//  Created by Mick O Brien on 11/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RoutesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *routesTableView;

@end
