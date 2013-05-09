//
//  RouteViewController.m
//  RunMapper
//
//  Created by Mick O Brien on 19/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import "RouteDetailsViewController.h"
#import "Constants.h"
#import "Route.h"

@interface RouteDetailsViewController ()

@end

@implementation RouteDetailsViewController

@synthesize scrollView, pageControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self drawRoute];
    [self addDetailsView];
    [self addGraphView];
}

-(void) addDetailsView
{
    CLLocation *startPoint = [_thisRoute.routePoints objectAtIndex:0];
    //create view for run details and add it to scroll view
    UIView *detailsSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    
    UILabel *startAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 27, 68, 14)];
    startAddressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    startAddressLabel.text = @"Start:";
    [detailsSubview addSubview:startAddressLabel];
    
    UILabel *startAddressValue = [[UILabel alloc] initWithFrame:CGRectMake(70, 27, detailsSubview.frame.size.width-80, 14)];
    startAddressValue.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    startAddressValue.text = _thisRoute.startAddress;
    startAddressLabel.numberOfLines = 0;
    [detailsSubview addSubview:startAddressValue];
    
    UILabel *endAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 46, 68, 14)];
    endAddressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    endAddressLabel.text = @"Finish:";
    [detailsSubview addSubview:endAddressLabel];
    
    UILabel *endAddressValue = [[UILabel alloc] initWithFrame:CGRectMake(70, 46, detailsSubview.frame.size.width-75, 14)];
    endAddressValue.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    endAddressValue.text = _thisRoute.endAddress;
    [detailsSubview addSubview:endAddressValue];
    
    UILabel *startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 65, 68, 14)];
    startDateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    startDateLabel.text = @"Date:";
    [detailsSubview addSubview:startDateLabel];
    
    UILabel *startDateValue = [[UILabel alloc] initWithFrame:CGRectMake(70, 65, detailsSubview.frame.size.width-75, 14)];
    startDateValue.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"d'/'M'/'Y' 'HH':'mm':'ss"];
    startDateValue.text = [outputDateFormatter stringFromDate:startPoint.timestamp];
    NSLog(@"%@", startDateValue.text);
    [detailsSubview addSubview:startDateValue];
    
    UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 84, 68, 14)];
    durationLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    durationLabel.text = @"Duration:";
    [detailsSubview addSubview:durationLabel];
    
    
    NSInteger ti = (NSInteger)_thisRoute.duration;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    NSString *durationString;
    
    if(hours > 0) {
        durationString = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
    } else {
        durationString = [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
    }
    
    UILabel *durationValue = [[UILabel alloc] initWithFrame:CGRectMake(70, 84, detailsSubview.frame.size.width-75, 14)];
    durationValue.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    durationValue.text = durationString;
    [detailsSubview addSubview:durationValue];
    
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 103, 68, 14)];
    distanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    distanceLabel.text = @"Distance:";
    [detailsSubview addSubview:distanceLabel];
    
    UILabel *distancesValue = [[UILabel alloc] initWithFrame:CGRectMake(70, 103, detailsSubview.frame.size.width-75, 14)];
    distancesValue.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    distancesValue.text = [NSString stringWithFormat:@"%.2fkm", _thisRoute.distance/1000];
    [detailsSubview addSubview:distancesValue];
    
    [self.scrollView addSubview:detailsSubview];
}

-(void) addGraphView
{
    //create view for elevation graph and add it to scroll view
    UIView *graphSubview = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 320, 200)];
    graphSubview.tag = 1000;
    [self.scrollView addSubview:graphSubview];
    
	self.scrollView.contentSize = CGSizeMake(640, 200);
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = 2;
    
    [self initPlot];
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [_thisRoute.routePoints count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSInteger valueCount = [_thisRoute.routePoints count];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:@"mick"] == YES) {
                CLLocation *thisLocation = [_thisRoute.routePoints objectAtIndex:index];
                NSLog(@"index = %i, altitude = %f", index, thisLocation.altitude);
                
                if(thisLocation.altitude < 1){
                    return [NSNumber numberWithDouble:index * 10.0];
                } else {
                    return [NSNumber numberWithDouble:thisLocation.altitude];
                }
                
            }
            //            } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
            //                return [[[CPDStockPriceStore sharedInstance] monthlyPrices:CPDTickerSymbolGOOG] objectAtIndex:index];
            //            } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT] == YES) {
            //                return [[[CPDStockPriceStore sharedInstance] monthlyPrices:CPDTickerSymbolMSFT] objectAtIndex:index];
            //            }
            break;
    }
    return [NSDecimalNumber zero];
}


#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    UIView* graphSubview = (UIView *)[self.scrollView viewWithTag:1000];
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:graphSubview.bounds];
    self.hostView.allowPinchScaling = NO;
    [graphSubview addSubview:self.hostView];
}

-(void)configureGraph {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Run Title";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 10.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:10.0f];
    [graph.plotAreaFrame setPaddingBottom:10.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the three plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = @"mick";
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
    //[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, googPlot, msftPlot, nil]];
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 2.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
    aaplPlot.plotSymbol = aaplSymbol;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 8.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 7.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Day of Month";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 10.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat pointsCount = [_thisRoute.routePoints count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:pointsCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:pointsCount];
    NSInteger i = 0;
    for (CLLocation *myLocation in _thisRoute.routePoints) {
        NSString *altitude;
        if(myLocation.altitude < 1){
            altitude = [NSString stringWithFormat:@"%f", i * 10.0];
        } else {
            altitude = [NSString stringWithFormat:@"%f", myLocation.altitude];
        }
        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:altitude  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Elevation (m)";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 4.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 10.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 10;
    NSInteger minorIncrement = 5;
    CGFloat yMax = 20.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}


#pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage
{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareToShowRoute:(Route *)myRoute
{
    _thisRoute = myRoute;
}

-(void)drawRoute
{
    int numPoints = [_thisRoute.routePoints count];
    CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < numPoints; i++)
    {
        CLLocation* current = [_thisRoute.routePoints objectAtIndex:i];
        
        coords[i] = current.coordinate;
        //_startDateLabel.text = [NSString stringWithFormat:@"%@ lat:%f long:%f",_startDateLabel.text, current.coordinate.latitude, current.coordinate.longitude];
    }
    
    self.polyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
    
    [_mapView addOverlay:self.polyline];
    [_mapView setNeedsDisplay];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coords[0], METERS_PER_MILE, METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    
    free(coords);
}

- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:self.polyline];
    lineView.fillColor = [UIColor blueColor];
    lineView.strokeColor = [UIColor blueColor];
    lineView.lineWidth = 4;
    return lineView;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    _mapView = nil;
	self.scrollView = nil;
	self.pageControl = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIDeviceOrientationPortrait ||  interfaceOrientation ==  UIDeviceOrientationPortraitUpsideDown)
    {
        return YES;
    }
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {   
        pageControl.frame = CGRectMake(141, 172, 38, 36);
    } else {
        pageControl.frame = CGRectMake((self.scrollView.frame.size.width-38)/2, 172, 38, 36);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

@end