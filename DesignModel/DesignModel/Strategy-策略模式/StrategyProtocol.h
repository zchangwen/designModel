//
//  StrategyProtocol.h
//  DesignModel
//
//  Created by ken on 2018/8/22.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StrategyProtocol<NSObject>

//    对普通客户或者是新客户报的是全价
//    对老客户报的价格，根据客户年限，给予一定的折扣
//    对大客户报的价格，根据大客户的累计消费金额，给予一定的折扣
+ (void)price:(NSInteger)count;

@end
