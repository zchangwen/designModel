//
//  DTDownloadItemStatus.h
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, DTDownloadItemStatus) {
    DtItemStatusNotStarted = 0, //未启动
    DtItemStatusStarted,        //启动
    DtItemStatusCompleted,      //完成
    DtItemStatusPaused,         //暂停
    DtItemStatusCancelled,      //取消
    DtItemStatusInterrupted,    //打断（电话）
    DtItemStatusError           //异常
};
