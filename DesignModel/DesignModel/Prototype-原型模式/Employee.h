//
//  Employee.h
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"

//雇员
@interface Employee : NSObject<NSCopying>

@property(nonatomic, strong) NSString *name;    //姓名
@property(nonatomic, assign) NSInteger age;     //年龄
@property(nonatomic, strong) NSString *sex;     //性别

@property(nonatomic, strong) Company *company;  //公司信息

- (instancetype)initWithName:(NSString *)name configWithAge:(NSInteger)age sex:(NSString *)sex company:(Company *)company;
@end
