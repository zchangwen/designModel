//
//  Strategy_Cat.m
//  DesignModel
//
//  Created by ken on 2018/8/22.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "Strategy_Cat.h"

@implementation Strategy_Cat

+ (void)price:(NSInteger)count
{
    NSLog(@"%ld只猫，%ld块", count,count*80);
}

@end
