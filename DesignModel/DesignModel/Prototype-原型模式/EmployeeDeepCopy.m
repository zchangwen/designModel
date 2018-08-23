//
//  EmployeeDeepCopy.m
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "EmployeeDeepCopy.h"

@implementation EmployeeDeepCopy

- (id)copyWithZone:(NSZone *)zone {
    Employee *employee = [[Employee allocWithZone:zone] init];
    employee.name = [self.name copy];
    employee.age = self.age;
    employee.sex = [self.sex copy];
    employee.company = [self.company copy];
    return employee;
}

@end
