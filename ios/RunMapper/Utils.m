//
//  Utils.m
//  RunMapper
//
//  Created by Mick O Brien on 19/04/2013.
//  Copyright (c) 2013 TSSG. All rights reserved.
//

#import "Utils.h"

@implementation Utils

- (void)storeModel:(NSString *)url withData:(NSData *)data
{
    NSError *error = nil;
    
    NSEntityDescription *entity;
    entity = [[NSEntityDescription alloc] init];
    [entity setName:@"dataEntity"];
    [entity setManagedObjectClassName:@"dataClass"];
    
    NSAttributeDescription *urlAttribute = [[NSAttributeDescription alloc] init];
    [urlAttribute setName:@"url"];
    [urlAttribute setAttributeType: NSStringAttributeType];
    [urlAttribute setOptional:NO];
    
    NSAttributeDescription *dataAttribute = [[NSAttributeDescription alloc] init];
    [dataAttribute setName:@"data"];
    [dataAttribute setAttributeType: NSBinaryDataAttributeType];
    [dataAttribute setOptional:NO];
    
    NSMutableArray *properties = [NSMutableArray array];
    [properties addObject:urlAttribute];
    [properties addObject:dataAttribute];
    
    [entity setProperties:properties];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
    [model setEntities:[NSArray arrayWithObject:entity]];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"DataStore.sqlite"];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@", url];
    [fetchRequest setPredicate:predicate];
    
    DataEntity *object = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
    
    if (object != nil) {
        [context deleteObject:(NSManagedObject *)object];
    }
    
    object = [NSEntityDescription insertNewObjectForEntityForName:@"dataEntity" inManagedObjectContext:context];
    object.url = url;
    object.data = data;
    
    [context save:&error];
}


- (NSData *)getModel:(NSString *)url
{
    NSError *error = nil;
    
    NSEntityDescription *entity;
    entity = [[NSEntityDescription alloc] init];
    [entity setName:@"dataEntity"];
    [entity setManagedObjectClassName:@"dataClass"];
    
    NSAttributeDescription *urlAttribute = [[NSAttributeDescription alloc] init];
    [urlAttribute setName:@"url"];
    [urlAttribute setAttributeType: NSStringAttributeType];
    [urlAttribute setOptional:NO];
    
    NSAttributeDescription *dataAttribute = [[NSAttributeDescription alloc] init];
    [dataAttribute setName:@"data"];
    [dataAttribute setAttributeType: NSBinaryDataAttributeType];
    [dataAttribute setOptional:NO];
    
    NSMutableArray *properties = [NSMutableArray array];
    [properties addObject:urlAttribute];
    [properties addObject:dataAttribute];
    
    [entity setProperties:properties];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
    [model setEntities:[NSArray arrayWithObject:entity]];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"DataStore.sqlite"];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@", url];
    [fetchRequest setPredicate:predicate];
    
    DataEntity *object = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
    
    return object.data;
}

@end
