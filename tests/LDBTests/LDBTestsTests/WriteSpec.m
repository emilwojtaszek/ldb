//
//  WriteSpec.m
//  LDBTests
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

@interface WriteSpec : XCTestCase

@end

@implementation WriteSpec

#pragma mark -
#pragma mark LevelDB

- (void)testInsert_10_LevelDBObjectsWithoutTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:10 transaction:NO];
    }];
}

- (void)testInsert_100_LevelDBObjectsWithoutTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:100 transaction:NO];
    }];
}

- (void)testInsert_1_000_LevelDBObjectsWithoutTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:1000 transaction:NO];
    }];
}

- (void)testInsert_10_000_LevelDBObjectsWithoutTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:10000 transaction:NO];
    }];
}

- (void)testInsert_10_LevelDBObjectsInTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:10 transaction:YES];
    }];
}

- (void)testInsert_100_LevelDBObjectsInTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:100 transaction:YES];
    }];
}

- (void)testInsert_1_000_LevelDBObjectsInTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:1000 transaction:YES];
    }];
}

- (void)testInsert_10_000_LevelDBObjectsInTransaction {
    [self measureBlock:^{
        [self insertMantleObjectsOfCount:10000 transaction:YES];
    }];
}

#pragma mark -
#pragma mark Realm

- (void)testInsert10_RealmObjects {
    [self measureBlock:^{
        [self insertRealmObjectsOfCount:10];
    }];
}

- (void)testInsert100_RealmObjects {
    [self measureBlock:^{
        [self insertRealmObjectsOfCount:100];
    }];
}

- (void)testInsert_1_000_RealmObjects {
    [self measureBlock:^{
        [self insertRealmObjectsOfCount:1000];
    }];
}

- (void)testInsert_10_000_RealmObjects {
    [self measureBlock:^{
        [self insertRealmObjectsOfCount:10000];
    }];
}

#pragma mark -
#pragma mark CoreData

- (void)testInsert10_CoreDataObjects_saveOnEach {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:10 context:context save:YES];
    }];
}

- (void)testInsert100_CoreDataObjects_saveOnEach {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:100 context:context save:YES];
    }];
}

- (void)testInsert_1_000_CoreDataObjects_saveOnEach {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:1000 context:context save:YES];
    }];
}

- (void)testInsert_10_000_CoreDataObjects_saveOnEach {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:10000 context:context save:YES];
    }];
}

- (void)testInsert10_CoreDataObjects_OneSave {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:10 context:context save:NO];
        [context save:nil];
    }];
}

- (void)testInsert100_CoreDataObjects_OneSave {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:100 context:context save:NO];
        [context save:nil];
    }];
}

- (void)testInsert_1_000_CoreDataObjects_OneSave {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:1000 context:context save:NO];
        [context save:nil];
    }];
}

- (void)testInsert_10_000_CoreDataObjects_OneSave {
    NSManagedObjectContext *context = self.managedObjectContext;
    [self measureBlock:^{
        [self insertCoreDataObjectsOfCount:10000 context:context save:NO];
        [context save:nil];
    }];
}

#pragma mark - 
#pragma mark Private

- (void)insertRealmObjectsOfCount:(NSUInteger)count {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];

    // generate random storage path
    config.path = [[[config.path stringByDeletingLastPathComponent]
                    stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]
                   stringByAppendingPathExtension:@"realm"];
    
    // open the realm with the configuration
    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:nil];
    
    // begin transaction
    [realm beginWriteTransaction];
    
    for (int i=0; i<count; i++) {
        // create random object
        RealmModel *object = [[RealmModel alloc] init];
        object.group = i%2 == 0 ? @"A" : @"B";
        object.identifier = [[NSUUID UUID] UUIDString];
        object.date = [NSDate dateWithTimeIntervalSince1970:i*1000];
        
        // insert object
        [realm addObject:object];
    }
    
    // end transaction
    [realm commitWriteTransaction];
}

- (void)insertMantleObjectsOfCount:(NSUInteger)count transaction:(BOOL)transaction {
    LevelDB *ldb = [LevelDB databaseInLibraryWithName:[NSString stringWithFormat:@"%@.ldb", [[NSUUID UUID] UUIDString]]];

    LDBWritebatch *wb = nil;
    if (transaction)
        wb = [ldb newWritebatch];
    
    for (int i=0; i<count; i++) {
        // create random object
        LDBModel *object = [[LDBModel alloc] init];
        object.group = i%2 == 0 ? @"A" : @"B";
        object.identifier = [[NSUUID UUID] UUIDString];
        object.date = [NSDate dateWithTimeIntervalSince1970:i*1000];
        
        // insert object
        if (transaction) {
            [wb setObject:object forKey:object.index];
        } else {
            [ldb setObject:object forKey:object.index];
        }
    }
    
    if (transaction)
        [wb apply];
}

- (void)insertCoreDataObjectsOfCount:(NSUInteger)count context:(NSManagedObjectContext *)context save:(BOOL)save {

    for (int i=0; i<count; i++) {
        CoreDataModel *object = [NSEntityDescription insertNewObjectForEntityForName:@"Model" inManagedObjectContext:context];

        object.group = i%2 == 0 ? @"A" : @"B";
        object.identifier = [[NSUUID UUID] UUIDString];
        object.date = [NSDate dateWithTimeIntervalSince1970:i*1000];
        
        [context insertObject:object];

        if (save) {
            [context save:nil];
        }
    }
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
