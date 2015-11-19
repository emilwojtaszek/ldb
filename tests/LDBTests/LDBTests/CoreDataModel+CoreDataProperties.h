//
//  CoreDataModel+CoreDataProperties.h
//  LDBTests
//
//  Created by Emil Wojtaszek on 18.11.2015.
//  Copyright © 2015 AppUnite. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSString *group;
@property (nullable, nonatomic, retain) NSDate *date;

@end

NS_ASSUME_NONNULL_END
