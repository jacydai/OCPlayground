//
//  EOCPerson.m
//  EffectiveObjective-C
//
//  Created by jacydai on 18/04/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import "EOCPerson.h"

@implementation EOCPerson

- (instancetype)initWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName {

    if (self = [super init]) {
        _firstName = firstName;
        _lastName = lastName;
        _friends = [NSMutableSet set];

    }

    return self;
}

- (void)addFriends:(EOCPerson *)person {

    [_friends addObject:person];
}

- (void)removeFriends:(EOCPerson *)person {


    [_friends removeObject:person];
}
- (id)copyWithZone:(NSZone *)zone {

    EOCPerson *copy = [[[self class] allocWithZone:zone] initWithFirstName:_firstName andLastName:_lastName];

//    copy->_friends = [_friends copy]; // Using copy method, Crash

    copy->_friends = [_friends mutableCopy];
    return copy;
}

@end
