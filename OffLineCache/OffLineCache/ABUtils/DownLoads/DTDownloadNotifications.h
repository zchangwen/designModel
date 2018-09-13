//
//  DTDownloadNotifications.h
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

//下载完成
extern NSString* _Nonnull const downloadDidCompleteNotification;

//下载进度变更
extern NSString* _Nonnull const downloadProgressChangedNotification;

//总下载进度变更通知
extern NSString* _Nonnull const totalDownloadProgressChangedNotification;
