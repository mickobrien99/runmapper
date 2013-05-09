//
//  RouteModel.h
//  RunMapper
//
//  Created by Mick O Brien on 19/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject <NSCoding>

//@property (nonatomic, assign) int routeId;
@property (nonatomic, strong) NSMutableArray* routePoints;
@property (nonatomic, copy) NSString* startAddress;
@property (nonatomic, copy) NSString* endAddress;
@property (nonatomic, assign) NSTimeInterval duration;
//@property (nonatomic, strong) NSDate* endTime;
@property (nonatomic, assign) double distance;

- (id)initWithRoutePoints:(NSArray *)routePoints
         startAddress:(NSString *)startAddress
           endAddress:(NSString *)endAddress
             distance:(double)distance
             duration:(NSTimeInterval)duration;

@end
