//
//  Seller.h
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandWheatCakeBuilder.h"

@interface Seller : NSObject

@property (nonatomic, strong) id<HandWheatCakeBuilder> handWheatCakeBuilder;

- (void)cookFood;

@end
