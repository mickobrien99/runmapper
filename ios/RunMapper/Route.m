//
//  RouteModel.m
//  RunMapper
//
//  Created by Mick O Brien on 19/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import "Route.h"

@implementation Route

- (id) init
{
    //self.routeId = 0;
    self.routePoints = [[NSMutableArray alloc] init];
    self.startAddress = [[NSString alloc] init];
    self.endAddress = [[NSString alloc] init];
    self.duration = 0.0;
    //self.endTime = 0;
    
    return self;
}

- (id)initWithRoutePoints:(NSMutableArray *)routePoints
         startAddress:(NSString *)startAddress
           endAddress:(NSString *)endAddress
             distance:(double)distance
             duration:(NSTimeInterval)duration
{
    //self.routeId = routeId;
    self.routePoints = routePoints;
    self.startAddress = startAddress;
    self.endAddress = endAddress;
    self.duration = duration;
    //self.endTime = endTime;
    self.distance = distance;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        //self.routeId = [decoder decodeDoubleForKey:@"routeId"];
        self.routePoints = [decoder decodeObjectForKey:@"routePoints"];
        self.startAddress = [decoder decodeObjectForKey:@"startAddress"];
        self.endAddress = [decoder decodeObjectForKey:@"endAddress"];
        self.duration = [decoder decodeDoubleForKey:@"duration"];
      //  self.endTime = [decoder decodeObjectForKey:@"endTime"];
        self.distance = [decoder decodeDoubleForKey:@"distance"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //[encoder encodeInt:_routeId forKey:@"routeId"];
    [encoder encodeObject:_routePoints forKey:@"routePoints"];
    [encoder encodeObject:_startAddress forKey:@"startAddress"];
    [encoder encodeObject:_endAddress forKey:@"endAddress"];
    [encoder encodeDouble:_duration forKey:@"duration"];
    //[encoder encodeObject:_endTime forKey:@"endTime"];
    [encoder encodeDouble:_distance forKey:@"distance"];
}

@end