//
//  Company.m
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "Company.h"

@implementation Company

- (instancetype)initWithName:(NSString *)name establishmentTime:(NSString *)establishmentTime level:(NSString *)level {
    if (self = [super init]) {
        _name = name;
        _establishmentTime = establishmentTime;
        _level = level;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Company *company = [[Company allocWithZone:zone] init];
    company.name = [self.name copy];
    company.establishmentTime = [self.establishmentTime copy];
    company.level = [self.level copy];
    return company;
}

@end
