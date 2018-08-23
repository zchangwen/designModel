//
//  Employee.m
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "Employee.h"

@implementation Employee

- (instancetype)initWithName:(NSString *)name configWithAge:(NSInteger)age sex:(NSString *)sex company:(Company *)company
{
    if (self = [super init]) {
        _name = name;
        _age = age;
        _sex = sex;
        _company = company;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    return nil;
}
@end
