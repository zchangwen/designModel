//
//  AppDelegate.h
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DTDownloadStore;
@class HWIFileDownloader;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (nonnull, nonatomic, strong, readonly) DTDownloadStore *downloadStore;
@property (nonnull, nonatomic, strong, readonly) HWIFileDownloader *fileDownloader;

@end

