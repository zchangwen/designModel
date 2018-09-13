//
//  DTDownloadStore.h
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HWIFileDownloadDelegate.h"


@class DTDownloadItem;


@interface DTDownloadStore : NSObject<HWIFileDownloadDelegate>


@property (nonatomic, strong) NSMutableArray<DTDownloadItem *> *downloadItemsArray;


//开始下载
- (void)startDownloadWithDownloadItem:(nonnull DTDownloadItem *)aDemoDownloadItem;

//取消下载
- (void)cancelDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier;

//重新开始
- (void)resumeDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier;

@end
