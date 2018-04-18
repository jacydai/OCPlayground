//
//  EOCPerson.h
//  EffectiveObjective-C
//
//  Created by jacydai on 18/04/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EOCPerson : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *firstName;

@property (nonatomic, copy, readonly) NSString *lastName;

@property (nonatomic, strong, readonly) NSMutableSet *friends;

- (instancetype)initWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName;

- (void)addFriends:(EOCPerson *)person;

- (void)removeFriends:(EOCPerson *)person;

@end
