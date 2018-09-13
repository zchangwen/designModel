//
//  DTDownloadStore.m
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "DTDownloadStore.h"
#import "HWIFileDownloadDelegate.h"
#import "HWIFileDownloader.h"
#import "DTDownloadNotifications.h"

#import "DTDownloadItem.h"
#import "AppDelegate.h"

static void *DTDownloadStoreProgressObserverContext = &DTDownloadStoreProgressObserverContext;

@interface DTDownloadStore()
@property (nonatomic, assign) NSUInteger networkActivityIndicatorCount;//网络进度个数
//@property (nonatomic, strong, readwrite, nonnull) NSMutableArray<DTDownloadItem *> *downloadItemsArray;//资源数量
@property (nonatomic, strong, nonnull) NSProgress *progress;//进度
@end

@implementation DTDownloadStore

- (nullable DTDownloadStore *)init
{
    self = [super init];
    if (self)
    {
        //网络进度个数
        self.networkActivityIndicatorCount = 0;
        
        // 初始化进度对象, 并设置进度总量
        self.progress = [NSProgress progressWithTotalUnitCount:0];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            //使用KVO观察fractionCompleted的改变
            [self.progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                               options:NSKeyValueObservingOptionInitial
                               context:DTDownloadStoreProgressObserverContext];
        }
        
        //初始化下载资源
        [self setupDownloadItems];
    }
    return self;
}


- (void)setupDownloadItems
{
    //获取本地下载资源
    self.downloadItemsArray = [self restoredDownloadItems];
    NSLog(@"本地资源共 = %ld 个",_downloadItemsArray.count);
    
    for(int i=0; i<_downloadItemsArray.count;i++)
    {
        DTDownloadItem *item = [_downloadItemsArray objectAtIndex:i];
        NSString *aDownloadIdentifier = item.downloadIdentifier;
        
        NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDTDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
            if ([aDTDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
            {
                return YES;
            }
            return NO;
        }];
        
        //读取本地下载资源
        DTDownloadItem *aDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        if (aDownloadItem.status == DtItemStatusNotStarted)
        {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            HWIFileDownloader *fileDwon = delegate.fileDownloader;
            BOOL isDownloading = [fileDwon isDownloadingIdentifier:aDownloadItem.downloadIdentifier];
            if (isDownloading == NO)
            {
                aDownloadItem.status = DtItemStatusInterrupted;
            }
        }
    }
    //测试item
//    for (NSUInteger aDownloadIdentifierUInteger = 1; aDownloadIdentifierUInteger < 11; aDownloadIdentifierUInteger++)
//    {
//        NSString *aDownloadIdentifier = [NSString stringWithFormat:@"%@", @(aDownloadIdentifierUInteger)];
//        NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDTDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
//            if ([aDTDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
//            {
//                return YES;
//            }
//            return NO;
//        }];
//
//        if (aFoundDownloadItemIndex == NSNotFound)
//        {
//            //设置默认下载资源
//            NSURL *aRemoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.imagomat.de/testimages/%@.tiff", @(aDownloadIdentifierUInteger)]];
//            if ([aDownloadIdentifier isEqualToString:@"4"])
//            {
//                aRemoteURL = [NSURL URLWithString:@"http://www.imagomat.de/testimages/900.tiff"];
//            }
//            DTDownloadItem *aDownloadItem = [[DTDownloadItem alloc] initWithDownloadIdentifier:aDownloadIdentifier remoteURL:aRemoteURL];
//            [self.downloadItemsArray addObject:aDownloadItem];
//        }
//        else
//        {
//            //读取本地下载资源
//            DTDownloadItem *aDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
//            if (aDownloadItem.status == DtItemStatusNotStarted)
//            {
//                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                HWIFileDownloader *fileDwon = delegate.fileDownloader;
//                BOOL isDownloading = [fileDwon isDownloadingIdentifier:aDownloadItem.downloadIdentifier];
//                if (isDownloading == NO)
//                {
//                    aDownloadItem.status = DtItemStatusInterrupted;
//                }
//            }
//        }
//    };
    
    [self storeDownloadItems];
    
    self.downloadItemsArray = [[self.downloadItemsArray sortedArrayUsingComparator:^NSComparisonResult(DTDownloadItem*  _Nonnull aDownloadItemA, DTDownloadItem*  _Nonnull aDownloadItemB) {
        return [aDownloadItemA.downloadIdentifier compare:aDownloadItemB.downloadIdentifier options:NSNumericSearch];
    }] copy];
}


- (void)dealloc
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [self.progress removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                              context:DTDownloadStoreProgressObserverContext];
    }
}


#pragma mark - HWIFileDownloadDelegate (mandatory)


- (void)downloadDidCompleteWithIdentifier:(nonnull NSString *)aDownloadIdentifier
localFileURL:(nonnull NSURL *)aLocalFileURL
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    DTDownloadItem *aCompletedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSLog(@"INFO: Download completed (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        aCompletedDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        aCompletedDownloadItem.status = DtItemStatusCompleted;  //完成
        [self storeDownloadItems];
    }
    else
    {
        NSLog(@"ERR: Completed download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:downloadDidCompleteNotification object:aCompletedDownloadItem];
}


- (void)downloadFailedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
error:(nonnull NSError *)anError
httpStatusCode:(NSInteger)aHttpStatusCode
errorMessagesStack:(nullable NSArray<NSString *> *)anErrorMessagesStack
resumeData:(nullable NSData *)aResumeData
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    DTDownloadItem *aFailedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        aFailedDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        aFailedDownloadItem.lastHttpStatusCode = aHttpStatusCode;
        aFailedDownloadItem.resumeData = aResumeData;
        aFailedDownloadItem.downloadError = anError;
        aFailedDownloadItem.downloadErrorMessagesStack = anErrorMessagesStack;
        
        // download status heuristics
        if (aFailedDownloadItem.status != DtItemStatusPaused)
        {
            if (aResumeData.length > 0)
            {
                aFailedDownloadItem.status = DtItemStatusInterrupted;
            }
            else if ([anError.domain isEqualToString:NSURLErrorDomain] && (anError.code == NSURLErrorCancelled))
            {
                aFailedDownloadItem.status = DtItemStatusCancelled;
            }
            else
            {
                aFailedDownloadItem.status = DtItemStatusError;
            }
        }
        [self storeDownloadItems];
        
        switch (aFailedDownloadItem.status) {
            case DtItemStatusError:
                NSLog(@"ERR: Download with error %@ (http status: %@) - id: %@ (%@, %d)", @(anError.code), @(aHttpStatusCode), aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case DtItemStatusInterrupted:
                NSLog(@"ERR: Download interrupted with error %@ - id: %@ (%@, %d)", @(anError.code), aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case DtItemStatusCancelled:
                NSLog(@"INFO: Download cancelled - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case DtItemStatusPaused:
                NSLog(@"INFO: Download paused - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
                
            default:
                break;
        }
        
    }
    else
    {
        NSLog(@"ERR: Failed download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:downloadDidCompleteNotification object:aFailedDownloadItem];
}


- (void)incrementNetworkActivityIndicatorActivityCount
{
    [self toggleNetworkActivityIndicatorVisible:YES];
}


- (void)decrementNetworkActivityIndicatorActivityCount
{
    [self toggleNetworkActivityIndicatorVisible:NO];
}


#pragma mark HWIFileDownloadDelegate (optional)


- (void)downloadProgressChangedForIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    DTDownloadItem *aChangedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        aChangedDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        HWIFileDownloadProgress *aFileDownloadProgress = [theAppDelegate.fileDownloader downloadProgressForIdentifier:aDownloadIdentifier];
        if (aFileDownloadProgress)
        {
            aChangedDownloadItem.progress = aFileDownloadProgress;
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
            {
                aChangedDownloadItem.progress.lastLocalizedDescription = aChangedDownloadItem.progress.nativeProgress.localizedDescription;
                aChangedDownloadItem.progress.lastLocalizedAdditionalDescription = aChangedDownloadItem.progress.nativeProgress.localizedAdditionalDescription;
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:downloadProgressChangedNotification object:aChangedDownloadItem];
}


- (void)downloadPausedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
resumeData:(nullable NSData *)aResumeData
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSLog(@"INFO: Download paused - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        DTDownloadItem *aPausedDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        aPausedDownloadItem.status = DtItemStatusPaused;
        aPausedDownloadItem.resumeData = aResumeData;
        [self storeDownloadItems];
    }
    else
    {
        NSLog(@"ERR: Paused download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}


- (void)resumeDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        DTDownloadItem *aDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        [self startDownloadWithDownloadItem:aDownloadItem];
    }
}


- (BOOL)downloadAtLocalFileURL:(nonnull NSURL *)aLocalFileURL isValidForDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    BOOL anIsValidFlag = YES;
    
    // just checking for file size
    // you might want to check by converting into expected data format (like UIImage) or by scanning for expected content
    
    NSError *anError = nil;
    NSDictionary <NSString *, id> *aFileAttributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:aLocalFileURL.path error:&anError];
    if (anError)
    {
        NSLog(@"ERR: Error on getting file size for item at %@: %@ (%@, %d)", aLocalFileURL, anError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        anIsValidFlag = NO;
    }
    else
    {
        unsigned long long aFileSize = [aFileAttributesDictionary fileSize];
        if (aFileSize == 0)
        {
            anIsValidFlag = NO;
        }
        else
        {
            if (aFileSize < 40000)
            {
                NSError *anError = nil;
                NSString *aString = [NSString stringWithContentsOfURL:aLocalFileURL encoding:NSUTF8StringEncoding error:&anError];
                if (anError)
                {
                    NSLog(@"ERR: %@ (%@, %d)", anError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                }
                else
                {
                    NSLog(@"INFO: Downloaded file content for download identifier %@: %@ (%@, %d)", aDownloadIdentifier, aString, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                }
                anIsValidFlag = NO;
            }
        }
    }
    return anIsValidFlag;
}

- (nullable NSProgress *)rootProgress
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        return self.progress;
    }
    else
    {
        return nil;
    }
}

#pragma mark - NSProgress


- (void)observeValueForKeyPath:(nullable NSString *)aKeyPath
ofObject:(nullable id)anObject
change:(nullable NSDictionary<NSString*, id> *)aChange
context:(nullable void *)aContext
{
    if (aContext == DTDownloadStoreProgressObserverContext)
    {
        NSProgress *aProgress = anObject; // == self.progress
        if ([aKeyPath isEqualToString:@"fractionCompleted"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:totalDownloadProgressChangedNotification object:aProgress];
        }
        else
        {
            NSLog(@"ERR: Invalid keyPath (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
    }
    else
    {
        [super observeValueForKeyPath:aKeyPath
                             ofObject:anObject
                               change:aChange
                              context:aContext];
    }
}


- (void)resetProgressIfNoActiveDownloadsRunning
{
    AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL aHasActiveDownloadsFlag = [theAppDelegate.fileDownloader hasActiveDownloads];
    if (aHasActiveDownloadsFlag == NO)
    {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [self.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
        }
        self.progress = [NSProgress progressWithTotalUnitCount:0];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [self.progress addObserver:self
                            forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                               options:NSKeyValueObservingOptionInitial
                               context:DTDownloadStoreProgressObserverContext];
        }
    }
}


#pragma mark - Start Download


- (void)startDownloadWithDownloadItem:(nonnull DTDownloadItem *)aDownloadItem
{
    [self resetProgressIfNoActiveDownloadsRunning];
    
    if ((aDownloadItem.status != DtItemStatusCancelled) && (aDownloadItem.status != DtItemStatusCompleted))
    {
        AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        BOOL isDownloading = [theAppDelegate.fileDownloader isDownloadingIdentifier:aDownloadItem.downloadIdentifier];
        if (isDownloading == NO)
        {
            aDownloadItem.status = DtItemStatusStarted;
            
            [self storeDownloadItems];
            
            // kick off individual download
            if (aDownloadItem.resumeData.length > 0)
            {
                [theAppDelegate.fileDownloader startDownloadWithIdentifier:aDownloadItem.downloadIdentifier usingResumeData:aDownloadItem.resumeData];
            }
            else
            {
                [theAppDelegate.fileDownloader startDownloadWithIdentifier:aDownloadItem.downloadIdentifier fromRemoteURL:aDownloadItem.remoteURL];
            }
        }
    }
}


- (void)resumeDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    [self resetProgressIfNoActiveDownloadsRunning];
    
    NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        DTDownloadItem *aDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4)
        {
            if (aDownloadItem.progress.nativeProgress)
            {
                [aDownloadItem.progress.nativeProgress resume];
            }
            else
            {
                [self startDownloadWithDownloadItem:aDownloadItem];
            }
        }
        else
        {
            [self startDownloadWithDownloadItem:aDownloadItem];
        }
    }
}


#pragma mark - Cancel Download


- (void)cancelDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        DTDownloadItem *aCancelledDownloadItem = [self.downloadItemsArray objectAtIndex:aFoundDownloadItemIndex];
        aCancelledDownloadItem.status = DtItemStatusCancelled;
        [self storeDownloadItems];
    }
    else
    {
        NSLog(@"ERR: Cancelled download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}


#pragma mark - Network Activity Indicator


- (void)toggleNetworkActivityIndicatorVisible:(BOOL)visible
{
    visible ? self.networkActivityIndicatorCount++ : self.networkActivityIndicatorCount--;
    NSLog(@"INFO: NetworkActivityIndicatorCount: %@", @(self.networkActivityIndicatorCount));
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkActivityIndicatorCount > 0);
}


#pragma mark - Persistence
- (void)storeDownloadItems
{
    NSMutableArray <NSData *> *aDownloadItemsArchiveArray = [NSMutableArray arrayWithCapacity:self.downloadItemsArray.count];
    for (DTDownloadItem *aDownloadItem in self.downloadItemsArray)
    {
        NSData *aDownloadItemEncoded = [NSKeyedArchiver archivedDataWithRootObject:aDownloadItem];
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
