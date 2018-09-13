//
//  DTDownloadUtils.h
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTDownloadItem;

@interface DTDownloadUtils : NSObject

- (void)addDownloadItems:(NSArray<DTDownloadItem *> *)arrItems;

@end
