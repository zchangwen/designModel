//
//  PriceTest.m
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "PriceTest.h"
#import "Strategy_Cat.h"
#import "Strategy_Dog.h"

@implementation PriceTest

+ (void)price:(NSInteger)count
{
    if(count>10)
    {
        [Strategy_Dog price:count];
    }
    else
    {
        [Strategy_Cat price:count];
    }
}

@end
