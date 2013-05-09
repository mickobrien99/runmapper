//
//  SecondViewController.m
//  RunMapper
//
//  Created by Mick O Brien on 11/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import "RoutesViewController.h"
#import "RouteCell.h"
#import "Route.h"
#import "RouteDetailsViewController.h"
#import "Utils.h"

@interface RoutesViewController ()

@end

@implementation RoutesViewController

- (void)viewWillAppear:(BOOL)animated
{
    if(_appDelegate == nil){
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    } else {
        _appDelegate = nil;
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    [_routesTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:YES];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark table delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"];
    
    Route *route = (_appDelegate.routes)[indexPath.row];
    
    NSArray *startAddressSplit = [route.startAddress componentsSeparatedByString:@","];
    NSArray *endAddressSplit = [route.endAddress componentsSeparatedByString:@","];
    cell.startAddressLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    cell.startAddressLabel.text = [NSString stringWithFormat:@"%@ to %@", [startAddressSplit objectAtIndex:0], [endAddressSplit objectAtIndex:0]];
    
    CLLocation *startPoint = [route.routePoints objectAtIndex:0];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"d'/'MM'/'Y'"]; //@"d'/'M'/'Y' 'HH':'mm':'ss"];
    
    
    NSInteger ti = (NSInteger)route.duration;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    NSString *durationString;

    
    if(hours > 0) {
        durationString = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
    } else {
        durationString = [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
    }
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@, %@, %.2fk",
                                                   [outputDateFormatter stringFromDate:startPoint.timestamp],
                                                   durationString,
                                                   route.distance/1000];
    
    cell.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
   // NSLog(@"route = %@", route.startTime);
    //cell.distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", route.distance/1000];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _appDelegate.routes.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        [_appDelegate.routes removeObjectAtIndex:indexPath.row];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_appDelegate.routes];
        
        Utils* utils = [[Utils alloc] init];
        [utils storeModel:@"myroutes" withData:data];
        
        [_routesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hidesBottomBarWhenPushed = YES;
    [self performSegueWithIdentifier:@"routeDetail" sender:[_routesTableView cellForRowAtIndexPath:indexPath]];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark end of table delegates


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.routesTableView indexPathForCell:sender];
    Route* selectedRoute = _appDelegate.routes[indexPath.row];
    
    [segue.destinationViewController prepareToShowRoute:selectedRoute];
}

@end