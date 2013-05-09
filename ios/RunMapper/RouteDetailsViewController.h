//
//  RouteViewController.h
//  RunMapper
//
//  Created by Mick O Brien on 19/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
#import "CorePlot-CocoaTouch.h"

@interface RouteDetailsViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, CPTPlotDataSource>
{
    UIScrollView* scrollView;
    UIPageControl* pageControl;
    
	BOOL pageControlBeingUsed;
}

@property (nonatomic, strong) Route *thisRoute;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MKPolyline* polyline;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) CPTGraphHostingView *hostView;

- (IBAction)backButtonTapped:(id)sender;
-(void)prepareToShowRoute:(Route *)myRoute;
- (IBAction)changePage;
@end
