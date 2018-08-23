//
//  Singleton.h
//  DesignModel
//
//  Created by ken on 2018/8/22.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject

//  1.定义: 单例模式能够确保某个类在应用中只存在一个实例，创建之后会向整个系统共用这个实例。
//  2. 使用场景： 需要用来保存全局的状态，并且不和任何作用域绑定的时候可以考虑单例。
+ (instancetype)sharedInstance;

@end
