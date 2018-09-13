//
//  DTDownloadUtils.m
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "DTDownloadUtils.h"
#import "DTDownloadItem.h"

@implementation DTDownloadUtils

- (void)addDownloadItems:(NSArray<DTDownloadItem *> *)arrItems
{
    NSMutableArray <NSData *> *aDownloadItemsArchiveArray = [NSMutableArray arrayWithCapacity:arrItems.count];
    
    //历史数据
    NSMutableArray<DTDownloadItem *> *arr = [self restoredDownloadItems];
    
    for (DTDownloadItem *aDownloadItem in arrItems)
    {
        NSData *aDownloadItemEncoded = [NSKeyedArchiver archivedDataWithRootObject:aDownloadItem];
        [aDownloadItemsArchiveArray addObject:aDownloadItemEncoded];
    }
    
    for (DTDownloadItem *aItem in arr) {
        NSData *aDownloadItemEncoded = [NSKeyedArchiver archivedDataWithRootObject:aItem];
        [aDownloadItemsArchiveArray addObject:aDownloadItemEncoded];
    }
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:aDownloadItemsArchiveArray forKey:@"downloadItems"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (nonnull NSMutableArray<DTDownloadItem *> *)restoredDownloadItems
{
    NSMutableArray <DTDownloadItem *> *aRestoredMutableDownloadItemsArray = [NSMutableArray array];
    
    //获取userDefault中下载资源
    NSMutableArray <NSData*> *aRestoredMutableDataItemsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"downloadItems"] mutableCopy];
    if (aRestoredMutableDataItemsArray == nil)
    {
        aRestoredMutableDataItemsArray = [NSMutableArray array];
    }
    
    //返回下载资源model
    for (NSData *aDataItem in aRestoredMutableDataItemsArray)
    {
        DTDownloadItem *aDownloadItem = [NSKeyedUnarchiver unarchiveObjectWithData:aDataItem];
        [aRestoredMutableDownloadItemsArray addObject:aDownloadItem];
    }
    return aRestoredMutableDownloadItemsArray;
}

@end
