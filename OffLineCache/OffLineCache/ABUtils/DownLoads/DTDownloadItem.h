//
//  DTDownloadItem.h
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTDownloadItemStatus.h"

@class HWIFileDownloadProgress;

@interface DTDownloadItem : NSObject

- (nonnull instancetype)initWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                                         remoteURL:(nonnull NSURL *)aRemoteURL;


@property (nonatomic, strong) NSString *downloadIdentifier;
@property (nonatomic, strong, readonly, nonnull) NSURL *remoteURL;

@property (nonatomic, strong, nullable) NSData *resumeData;
@property (nonatomic, assign) DTDownloadItemStatus status;

@property (nonatomic, strong, nullable) HWIFileDownloadProgress *progress;

@property (nonatomic, strong, nullable) NSError *downloadError;
@property (nonatomic, strong, nullable) NSArray<NSString *> *downloadErrorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;

- (nonnull DTDownloadItem *)init __attribute__((unavailable("use initWithDownloadIdentifier:remoteURL:")));
+ (nonnull DTDownloadItem *)new __attribute__((unavailable("use initWithDownloadIdentifier:remoteURL:")));

@end
