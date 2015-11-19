//
//  RealmModel.m
//  LDBTests
//
//  Created by Emil Wojtaszek on 15.11.2015.
//  Copyright © 2015 AppUnite. All rights reserved.
//

#import "RealmModel.h"

@implementation RealmModel

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray *)indexedProperties {
    return @[@"identifier"];
}

@end
