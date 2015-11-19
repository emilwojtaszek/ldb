//
//  LDBModel.m
//  LDBTests
//
//  Created by Emil Wojtaszek on 15.11.2015.
//  Copyright © 2015 AppUnite. All rights reserved.
//

#import "LDBModel.h"

@implementation LDBModel

+ (NSString *)prefix {
    return @"field:model";
}

+ (NSString *)indexWithGroup:(NSString *)group {
    return [NSString stringWithFormat:@"field:model:group:%@", group];
}

- (NSString *)index {
    return [NSString stringWithFormat:@"field:model:group:%@:id:%@:created_at:%016llX", _group, _identifier, UINT64_MAX - (uint64_t)[_date timeIntervalSince1970]];
}

@end
