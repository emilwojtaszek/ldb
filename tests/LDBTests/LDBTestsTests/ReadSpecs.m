//
//  ReadSpecs.m
//  LDBTestsTests
//
//  Created by Emil Wojtaszek on 15.11.2015.
//  Copyright © 2015 AppUnite. All rights reserved.
//

#import <XCTest/XCTest.h>

//
#import "LevelDB.h"
#import "LDBWriteBatch.h"
#import <Realm/Realm.h>
#import <CoreData/CoreData.h>

//Models
#import "RealmModel.h"
#import "LDBModel.h"
#import "CoreDataModel.h"

@interface ReadSpecs : XCTestCase

@end

@implementation ReadSpecs

#pragma mark - 
#pragma mark LevelDB

- (void)testAccessRandomLevelDBRecord {
    NSUUID *uuid = [NSUUID UUID];
    LevelDB *ldb = [self randomLevelDBWithID:uuid];
    
    // insert objects
    NSArray *array = [self insert1000MantleObjectsLevelDB:ldb];
    
    //
    [self measureBlock:^{
        LDBModel *object = [array objectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)array.count)];
        XCTAssertNotNil([ldb objectForKey:object.index]);
    }];
}

- (void)testAccessFirst100LevelDBRecords {
    NSUUID *uuid = [NSUUID UUID];
    LevelDB *ldb = [self randomLevelDBWithID:uuid];

    // insert objects
    NSArray *array = [self insert1000MantleObjectsLevelDB:ldb];

    //
    [self measureBlock:^{
        NSMutableArray *fetchResult = [NSMutableArray new];
        NSString *prefix = [LDBModel indexWithGroup:@"A"];
        [ldb enumerateKeysAndObjectsBackward:NO lazily:NO startingAtKey:[array[0] index] filteredByPredicate:nil andPrefix:prefix usingBlock:^(LevelDBKey * key, id value, BOOL *stop) {
            [fetchResult addObject:value];
            
            if (fetchResult.count == 100) {
                *stop = YES;
            }
        }];
        
        XCTAssertEqual(fetchResult.count, 100);
    }];
}

- (void)testAccessSecond100LevelDBRecords {
    NSUUID *uuid = [NSUUID UUID];
    LevelDB *ldb = [self randomLevelDBWithID:uuid];

    // insert objects
    NSArray *array = [self insert1000MantleObjectsLevelDB:ldb];
    
    //
    [self measureBlock:^{
        NSMutableArray *fetchResult = [NSMutableArray new];
        NSString *prefix = [LDBModel indexWithGroup:@"A"];
        [ldb enumerateKeysAndObjectsBackward:NO lazily:NO startingAtKey:[array[101] index] filteredByPredicate:nil andPrefix:prefix usingBlock:^(LevelDBKey * key, id value, BOOL *stop) {
            [fetchResult addObject:value];
            
            if (fetchResult.count == 100) {
                *stop = YES;
            }
        }];
        XCTAssertEqual(fetchResult.count, 100);
    }];
}

#pragma mark -
#pragma mark Realm

- (void)testAccessRandomRealmRecord {
    // create random realm
    NSUUID *uuid = [NSUUID UUID];
    RLMRealm *realm = [self randomRealmWithID:uuid];

    // insert objects
    NSArray *array = [self insert1000RealmObjectsIntoRealm:realm];

    //
    [self measureBlock:^{
        RealmModel *object = [array objectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)array.count)];
        XCTAssertNotNil([RealmModel objectInRealm:realm forPrimaryKey:object.identifier]);
    }];
}

- (void)testAccessFirst100RealmRecords {
    // create random realm
    NSUUID *uuid = [NSUUID UUID];
    RLMRealm *realm = [self randomRealmWithID:uuid];
    
    // insert objects
    [self insert1000RealmObjectsIntoRealm:realm];

    //
    [self measureBlock:^{
        NSMutableArray *fetchResult = [NSMutableArray new];
        RLMResults *results = [[RealmModel objectsInRealm:realm where:@"group = 'A'"] sortedResultsUsingProperty:@"date" ascending:YES];

        for (int i=0; i<100; i++) {
            RealmModel *model = [results objectAtIndex:i];
            [fetchResult addObject:[model identifier]];
        }

        [realm invalidate];
        XCTAssertEqual(fetchResult.count, 100);
    }];
}

- (void)testAccessSecond100RealmRecords {
    // create random realm
    NSUUID *uuid = [NSUUID UUID];
    RLMRealm *realm = [self randomRealmWithID:uuid];
    
    // insert objects
    [self insert1000RealmObjectsIntoRealm:realm];
    
    //
    [self measureBlock:^{
        NSMutableArray *fetchResult = [NSMutableArray new];
        RLMResults *results = [[RealmModel objectsInRealm:realm where:@"group = 'A'"] sortedResultsUsingProperty:@"date" ascending:YES];
        
        for (int i=100; i<200; i++) {
            RealmModel *model = [results objectAtIndex:i];
            [fetchResult addObject:[model identifier]];
        }

        [realm invalidate];
        XCTAssertEqual(fetchResult.count, 100);
    }];
}

#pragma mark -
#pragma mark CoreData

- (void)testAccessRandomCoreDataRecord {
    // create random realm
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // insert objects
    NSArray *array = [self insert1000CoreDataObjectsContext:context];
    
    //
    [self measureBlock:^{
        // random identifier
        NSString *identifier = [array objectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)array.count)];
        
        // request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
        
        // entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Model" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];

        //
        XCTAssertNotNil([[context executeFetchRequest:fetchRequest error:nil] firstObject]);
    }];
}

- (void)testAccessFirst100CoreDataRecords {
    // create random realm
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // insert objects
    NSArray *array = [self insert1000CoreDataObjectsContext:context];
    
    //
    [self measureBlock:^{
        // random identifier
        NSString *identifier = [array objectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)array.count)];
        
        // request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group == 'A'", identifier];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        fetchRequest.fetchLimit = 100;
        
        // entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Model" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        //
        XCTAssertEqual([[context executeFetchRequest:fetchRequest error:nil] count], 100);
    }];
}

- (void)testAccessSecond100CoreDataRecords {
    // create random realm
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // insert objects
    NSArray *array = [self insert1000CoreDataObjectsContext:context];
    
    //
    [self measureBlock:^{
        // random identifier
        NSString *identifier = [array objectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)array.count)];
        
        // request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group == 'A'", identifier];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        fetchRequest.fetchLimit = 100;
        fetchRequest.fetchOffset = 100;
        
        // entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Model" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        //
        XCTAssertEqual([[context executeFetchRequest:fetchRequest error:nil] count], 100);
    }];
}

#pragma mark -
#pragma mark Private

- (NSArray *)insert1000RealmObjectsIntoRealm:(RLMRealm *)realm {
    NSMutableArray *array = [NSMutableArray new];
    // begin transaction
    [realm beginWriteTransaction];
    
    for (int i=0; i<1000; i++) {
        // create random object
        RealmModel *object = [[RealmModel alloc] init];
        object.group = i%2 == 0 ? @"A" : @"B";
        object.identifier = [[NSUUID UUID] UUIDString];
        object.date = [NSDate dateWithTimeIntervalSince1970:i*1000];
        
        // insert object
        [realm addObject:object];
        
        //
        [array addObject:object];
    }
    
    // end transaction
    [realm commitWriteTransaction];
    return [array copy];
}

- (NSArray *)insert1000MantleObjectsLevelDB:(LevelDB *)ldb {
    NSMutableArray *array = [NSMutableArray new];
    
    for (int i=0; i<1000; i++) {
        // create random object
        LDBModel *object = [[LDBModel alloc] init];
        object.group = i%2 == 0 ? @"A" : @"B";
        object.identifier = [[NSUUID UUID] UUIDString];
        object.date = [NSDate dateWithTimeIntervalSince1970:i*1000];
        
        // insert object
        [ldb setObject:object.identifier forKey:object.index];

        //
        [array addObject:object];
    }
    
    return [array copy];
}

- (NSArray *)insert1000CoreDataObjectsContext:(NSManagedObjectContext *)context {
    NSMutableArray *array = [NSMutableArray new];
    
    for (int i=0; i<1000; i++) {
        CoreDataModel *object = [NSEntityDescription insertNewObjectForEntityForName:@"Model" inManagedObjectContext:context];
        
        object.group = i%2 == 0 ? @"A" : @"B";
        object.identifier = [[NSUUID UUID] UUIDString];
        object.date = [NSDate dateWithTimeIntervalSince1970:i*1000];
        
        [context insertObject:object];
        
        //
        [array addObject:object.identifier];
    }
    [context save:nil];

    return [array copy];
}

- (RLMRealm *)randomRealmWithID:(NSUUID *)uuid {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    
    // generate random storage path
    config.path = [[[config.path stringByDeletingLastPathComponent]
                    stringByAppendingPathComponent:[uuid UUIDString]]
                   stringByAppendingPathExtension:@"realm"];
    
    // open the realm with the configuration
    return [RLMRealm realmWithConfiguration:config error:nil];
}

- (LevelDB *)randomLevelDBWithID:(NSUUID *)uuid {
    LevelDBOptions options = [LevelDB makeOptions];
//    options.createIfMissing = false;
    options.errorIfExists   = false;
    options.paranoidCheck   = false;
    options.compression     = true;
    options.filterPolicy    = 1024 * 100;      // Size in bits per key, allocated for a bloom filter, used in testing presence of key
    options.cacheSize       = 1024 * 100;      // Size in bytes, allocated for a LRU cache used for speeding up lookups
    
    
    return [LevelDB databaseInLibraryWithName:[NSString stringWithFormat:@"%@.ldb", [uuid UUIDString]] andOptions:options];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    //
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    //
    return managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // path
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *storeURL = [[NSURL fileURLWithPath:[searchPaths objectAtIndex:0]] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", [[NSUUID UUID] UUIDString]]];
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelURL = [bundle URLForResource:@"Model" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

@end
