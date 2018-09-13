//
//  AppDelegate.m
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "HWIFileDownloader.h"
#import "DTDownloadStore.h"

@interface AppDelegate ()

@property (nonnull, nonatomic, strong, readwrite) DTDownloadStore *downloadStore;
@property (nonnull, nonatomic, strong, readwrite) HWIFileDownloader *fileDownloader;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier; // iOS 6

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid; // iOS 6
    
    // setup UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window setRootViewController:nav];
    
    [self.window makeKeyAndVisible];
    
    
    //设置app下载仓库
    self.downloadStore = [[DTDownloadStore alloc] init];
    NSMutableArray<DTDownloadItem *> *list = _downloadStore.downloadItemsArray;
    NSLog(@"---下载资源共---%ld",list.count);
    
    //设置下载器
    self.fileDownloader = [[HWIFileDownloader alloc] initWithDelegate:self.downloadStore];
    [self.fileDownloader setupWithCompletion:nil];
    
    return YES;
}

// iOS 7 保证应用即使在后台也不影响数据的上传和下载
- (void)application:(UIApplication *)anApplication handleEventsForBackgroundURLSession:(NSString *)aBackgroundURLSessionIdentifier completionHandler:(void (^)(void))aCompletionHandler
{
    [self.fileDownloader setBackgroundSessionCompletionHandlerBlock:aCompletionHandler];
}


//当有电话进来或者锁屏，这时你的应用程会挂起，在这时，UIApplicationDelegate委托会收到通知，调用 applicationWillResignActive 方法，你可以重写这个方法，做挂起前的工作，比如关闭网络，保存数据
- (void)applicationDidBecomeActive:(UIApplication *)anApplication
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }
}

//当程序复原时，另一个名为 applicationDidBecomeActive 委托方法会被调用，在此你可以通过之前挂起前保存的数据来恢复你的应用程序
- (void)applicationDidEnterBackground:(UIApplication *)anApplication
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        if (self.fileDownloader.hasActiveDownloads)
        {
            if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid)
            {
                __weak AppDelegate *weakSelf = self;
                dispatch_block_t anExpirationHandler = ^{
                    [[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTaskIdentifier];
                    weakSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
                };
                self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:anExpirationHandler];
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
