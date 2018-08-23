//
//  Factory.m
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "Factory.h"
#import "Police.h"
#import "Student.h"

@implementation Factory

- (Person *) getPerson:(NSString *)name
{
    Person *person = nil;
    if([name isEqualToString:@"警察"])
    {
        person = [Police new];
    }
    else
    {
        person = [Student new];
    }
    [person obligation];
    return person;
}
@end
