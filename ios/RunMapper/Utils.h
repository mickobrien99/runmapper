//
//  Utils.h
//  RunMapper
//
//  Created by Mick O Brien on 19/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataEntity.h"

@interface Utils : NSObject

- (void)storeModel:(NSString *)url withData:(NSData *)data;
- (NSData *)getModel:(NSString *)url;

@end
