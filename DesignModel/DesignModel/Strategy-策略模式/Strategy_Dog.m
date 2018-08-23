//
//  Strategy_Dog.m
//  DesignModel
//
//  Created by ken on 2018/8/22.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "Strategy_Dog.h"

@implementation Strategy_Dog

+ (void)price:(NSInteger)count
{
    NSLog(@"%ld只狗，%ld块", count,count*100);
}

@end
