//
//  FirstViewController.m
//  RunMapper
//
//  Created by Mick O Brien on 11/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import "MapperViewController.h"
#import "Constants.h"
#import "Route.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

@interface MapperViewController ()
@end


@implementation MapperViewController

CLLocationManager *locationManager;
NSMutableArray *routePoints;
//NSDate *startTime;
//NSDate *endTime;
CLGeocoder *geocoder;
CLGeocoder *geocoder2;
bool startAddressReverseGeocoded;
bool endAddressReverseGeocoded;
NSString *startAddress;
NSString *endAddress;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _stopButton.hidden = YES;
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 100;
    
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    //NSString *str=[[NSString alloc] initWithFormat:@" latitude:%f longitude:%f",coordinate.latitude,coordinate.longitude];
    //NSLog(@"%@",str);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
    
    
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f, altitude %+.6f",
              location.coordinate.latitude,
              location.coordinate.longitude,
              location.altitude);
        
        [routePoints addObject:location];
        
        int numPoints = [routePoints count];
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [routePoints objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        if(self.polyline != nil){
            [_mapView removeOverlay:self.polyline];
            self.polyline = nil;
        }
        
        self.polyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        
        [_mapView addOverlay:self.polyline];
        [_mapView setNeedsDisplay];
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coords[numPoints-1], 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        free(coords);
        // 3
        [_mapView setRegion:viewRegion animated:YES];
    }
}

- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:self.polyline];
    lineView.fillColor = [UIColor blueColor];
    lineView.strokeColor = [UIColor blueColor];
    lineView.lineWidth = 4;
    return lineView;
}

- (IBAction)startButtonTapped:(id)sender {
    _startButton.hidden = YES;
    _stopButton.hidden = NO;
    startAddress = @"";
    endAddress = @"";
    
    //get user location and start tracking
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    [self startStandardUpdates];
    
    routePoints = [[NSMutableArray alloc] init];
    [_mapView removeAnnotations:_mapView.annotations];
    
   //startTime = [NSDate date];
}

- (IBAction)stopButtonTapped:(id)sender
{
    _startButton.hidden = NO;
    _stopButton.hidden = YES;
    
    //stop tracking location
    [locationManager stopUpdatingLocation];
    
    //endTime = [NSDate date];
    
    startAddressReverseGeocoded = NO;
    endAddressReverseGeocoded = NO;
    
    //reverse geocode to get the start address and end address
    if(routePoints.count < 1)
    {
        [_saveRouteAlertLabel removeFromSuperview];
        _saveRouteAlertLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 155, 170, 100)];
        _saveRouteAlertLabel.backgroundColor = [UIColor blackColor];
        _saveRouteAlertLabel.layer.cornerRadius = 10.0;
        _saveRouteAlertLabel.textAlignment = NSTextAlignmentCenter;
        _saveRouteAlertLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        _saveRouteAlertLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:0.95686274509804 green:0.77254901960784 blue:0.30196078431373 alpha:1];
        _saveRouteAlertLabel.text = @"No route found to save";
        [_mapView addSubview:_saveRouteAlertLabel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutLabels) object:NULL];
            [self performSelector:@selector(fadeOutLabels) withObject:nil afterDelay:2];
        });
        
        return;
    }
    
    CLLocation* startLocation = [routePoints objectAtIndex:0];
    if(geocoder == nil)
    {
        geocoder = [[CLGeocoder alloc] init];
    }
    
    [geocoder reverseGeocodeLocation:startLocation completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         startAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         startAddressReverseGeocoded = YES;
         [self saveRoute];
     }];
    
    CLLocation* endLocation = [routePoints objectAtIndex:routePoints.count-1];
    if(geocoder2 == nil)
    {
        geocoder2 = [[CLGeocoder alloc] init];
    }
    
    [geocoder2 reverseGeocodeLocation:endLocation completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         endAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         endAddressReverseGeocoded = YES;
         [self saveRoute];
     }];
}

- (void)saveRoute
{
    if(startAddressReverseGeocoded && endAddressReverseGeocoded)
    {
        //calculate distance
        double totalDistance = 0;
        CLLocation *startPoint = [routePoints objectAtIndex:0];
        CLLocation *endPoint = [routePoints objectAtIndex:routePoints.count-1];
        
        for (int i = 0; routePoints.count > 1 && i < routePoints.count-1; i++) {
            NSLog(@"index = %i, altitude = %f", i, [[routePoints objectAtIndex:i] altitude]);
            CLLocation* current = [routePoints objectAtIndex:i];
            CLLocation* next = [routePoints objectAtIndex:i+1];
            totalDistance = [current distanceFromLocation:next];
        }
        
        NSTimeInterval duration = [endPoint.timestamp timeIntervalSinceDate:startPoint.timestamp];
        
        Route* route = [[Route alloc] initWithRoutePoints:routePoints
                                         startAddress:startAddress
                                           endAddress:endAddress
                                             distance:totalDistance
                                             duration:duration];
        
        [_appDelegate.routes addObject:route];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_appDelegate.routes];
        
        Utils* utils = [[Utils alloc] init];
        [utils storeModel:@"myroutes" withData:data];
        
        //startTime = 0;
        //endTime = 0;
        routePoints = nil;
        
        [_saveRouteAlertLabel removeFromSuperview];
        _saveRouteAlertLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 155, 170, 100)];
        _saveRouteAlertLabel.backgroundColor = [UIColor blackColor];
        _saveRouteAlertLabel.layer.cornerRadius = 10.0;
        _saveRouteAlertLabel.textAlignment = NSTextAlignmentCenter;
        _saveRouteAlertLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        _saveRouteAlertLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:0.95686274509804 green:0.77254901960784 blue:0.30196078431373 alpha:1];
        _saveRouteAlertLabel.text = @"Route Saved";
        [_mapView addSubview:_saveRouteAlertLabel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutLabels) object:NULL];
            [self performSelector:@selector(fadeOutLabels) withObject:nil afterDelay:2];
        });
    }
}

-(void)fadeOutLabels
{
    [UIView animateWithDuration:1
                          delay:0.0  /* starts the animation after 3 seconds */
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         _saveRouteAlertLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [_saveRouteAlertLabel removeFromSuperview];
                     }];
}

@end