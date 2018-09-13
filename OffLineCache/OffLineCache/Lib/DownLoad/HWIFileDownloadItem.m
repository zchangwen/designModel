#import "HWIFileDownloadItem.h"


@interface HWIFileDownloadItem()
@property (nonatomic, strong, readwrite, nonnull) NSString *downloadToken;
@property (nonatomic, strong, readwrite, nullable) NSURLSessionDownloadTask *sessionDownloadTask;
@property (nonatomic, strong, readwrite, nullable) NSURLConnection *urlConnection;
@property (nonatomic, strong, readwrite, nonnull) NSProgress *progress;
@end


@implementation HWIFileDownloadItem


#pragma mark - Initialization


- (nonnull instancetype)initWithDownloadToken:(nonnull NSString *)aDownloadToken
                          sessionDownloadTask:(nullable NSURLSessionDownloadTask *)aSessionDownloadTask
                                urlConnection:(nullable NSURLConnection *)aURLConnection
{
    self = [super init];
    if (self)
    {
        self.downloadToken = aDownloadToken;
        self.sessionDownloadTask = aSessionDownloadTask;
        self.urlConnection = aURLConnection;
        self.receivedFileSizeInBytes = 0;
        self.expectedFileSizeInBytes = 0;
        self.bytesPerSecondSpeed = 0;
        self.resumedFileSizeInBytes = 0;
        self.lastHttpStatusCode = 0;
        
        self.progress = [[NSProgress alloc] initWithParent:[NSProgress currentProgress] userInfo:nil];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            self.progress.kind = NSProgressKindFile;
            [self.progress setUserInfoObject:NSProgressFileOperationKindKey forKey:NSProgressFileOperationKindDownloading];
            [self.progress setUserInfoObject:aDownloadToken forKey:@"downloadToken"];
            self.progress.cancellable = YES;
            self.progress.pausable = NO;
            self.progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
            self.progress.completedUnitCount = 0;
        }
        
    }
    return self;
}


- (void)setExpectedFileSizeInBytes:(int64_t)anExpectedFileSizeInBytes
{
    _expectedFileSizeInBytes = anExpectedFileSizeInBytes;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        if (anExpectedFileSizeInBytes > 0)
        {
            self.progress.totalUnitCount = anExpectedFileSizeInBytes;
        }
    }
}


- (void)setReceivedFileSizeInBytes:(int64_t)aReceivedFileSizeInBytes
{
    _receivedFileSizeInBytes = aReceivedFileSizeInBytes;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        if (aReceivedFileSizeInBytes > 0)
        {
            if (self.expectedFileSizeInBytes > 0)
            {
                self.progress.completedUnitCount = aReceivedFileSizeInBytes;
            }
        }
    }
}


#pragma mark - Description


- (NSString *)description
{
    NSMutableDictionary *aDescriptionDict = [NSMutableDictionary dictionary];
    [aDescriptionDict setObject:@(self.receivedFileSizeInBytes) forKey:@"receivedFileSizeInBytes"];
    [aDescriptionDict setObject:@(self.expectedFileSizeInBytes) forKey:@"expectedFileSizeInBytes"];
    [aDescriptionDict setObject:@(self.bytesPerSecondSpeed) forKey:@"bytesPerSecondSpeed"];
    [aDescriptionDict setObject:self.downloadToken forKey:@"downloadToken"];
    [aDescriptionDict setObject:self.progress forKey:@"progress"];
    if (self.sessionDownloadTask)
    {
        [aDescriptionDict setObject:@(YES) forKey:@"hasSessionDownloadTask"];
    }
    if (self.urlConnection)
    {
        [aDescriptionDict setObject:@(YES) forKey:@"hasUrlConnection"];
    }
    
    NSString *aDescriptionString = [NSString stringWithFormat:@"%@", aDescriptionDict];
    
    return aDescriptionString;
}

@end
