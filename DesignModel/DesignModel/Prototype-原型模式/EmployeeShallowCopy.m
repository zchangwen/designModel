//
//  EmployeeShallowCopy.m
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "EmployeeShallowCopy.h"

@implementation EmployeeShallowCopy

- (id)copyWithZone:(NSZone *)zone {
    Employee *employee = [[Employee allocWithZone:zone] init];
    employee.name = self.name;
    employee.age = self.age;
    employee.sex = self.sex;
    employee.company = self.company;
    return employee;
}

@end
