//
//  RealmModel.h
//  LDBTests
//
//  Created by Emil Wojtaszek on 15.11.2015.
//  Copyright © 2015 AppUnite. All rights reserved.
//

#import <Realm/Realm.h>

@interface RealmModel : RLMObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSDate *date;
@end
