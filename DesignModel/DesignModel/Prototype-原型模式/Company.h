//
//  Company.h
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

//公司
@interface Company : NSObject<NSCopying>

@property (nonatomic, strong) NSString *name;             ///< 公司名字
@property (nonatomic, strong) NSString *establishmentTime;///< 成立时间
@property (nonatomic, strong) NSString *level;            ///< 规模

- (instancetype)initWithName:(NSString *)name establishmentTime:(NSString *)establishmentTime level:(NSString *)level;

@end
