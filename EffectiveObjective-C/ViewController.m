//
//  ViewController.m
//  EffectiveObjective-C
//
//  Created by jacydai on 18/04/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import "ViewController.h"
#import "EOCPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self eoc__copyObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)eoc__copyObject {

    EOCPerson *friend1 = [[EOCPerson alloc] initWithFirstName:@"Adam" andLastName:@"Lambert"];
//    friend1 addFriends:<#(EOCPerson *)#>

    EOCPerson *friend2 = [[EOCPerson alloc] initWithFirstName:@"Bill" andLastName:@"Green"];




    EOCPerson *person = [[EOCPerson alloc] initWithFirstName:@"dai" andLastName:@"jacy"];
    [person addFriends:friend1];
    EOCPerson *person2 = [person copy];

    [person2 addFriends:friend2];

    NSLog(@"address1 %p, address2: %p object1:%@ object2:%@",&person,&person2,person,person2);

    NSLog(@"person: %@ person2:%@ ",person.friends,person2.friends);

    [person2 addFriends:friend2];
    [person2 addFriends:friend2];
    [person2 addFriends:friend2];

    NSLog(@"person: %@ person2:%@ ",person.friends,person2.friends);

}

@end
