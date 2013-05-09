//
//  FirstViewController.h
//  RunMapper
//
//  Created by Mick O Brien on 11/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface MapperViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MKPolyline* polyline;
@property (nonatomic) IBOutlet UILabel *saveRouteAlertLabel;

- (IBAction)startButtonTapped:(id)sender;
- (IBAction)stopButtonTapped:(id)sender;

@end
