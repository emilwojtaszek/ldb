//
//  LDBModel.h
//  LDBTests
//
//  Created by Emil Wojtaszek on 15.11.2015.
//  Copyright © 2015 AppUnite. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface LDBModel : MTLModel
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSDate *date;

+ (NSString *)prefix;
- (NSString *)index;

+ (NSString *)indexWithGroup:(NSString *)group;
@end
