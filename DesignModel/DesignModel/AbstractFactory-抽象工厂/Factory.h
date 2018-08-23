//
//  Factory.h
//  DesignModel
//
//  Created by ken on 2018/8/23.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Factory : NSObject

- (Person *) getPerson:(NSString *)name;

@end
