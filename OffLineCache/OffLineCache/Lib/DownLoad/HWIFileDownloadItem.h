#import <Foundation/Foundation.h>


/**
 HWIFileDownloadItem is used internally by HWIFileDownloader.
 */
@interface HWIFileDownloadItem : NSObject

- (nonnull instancetype)initWithDownloadToken:(nonnull NSString *)aDownloadToken
                          sessionDownloadTask:(nullable NSURLSessionDownloadTask *)aSessionDownloadTask
                                urlConnection:(nullable NSURLConnection *)aURLConnection;


@property (nonatomic, strong, nullable) NSDate *downloadStartDate;
@property (nonatomic, assign) int64_t receivedFileSizeInBytes;
@property (nonatomic, assign) int64_t expectedFileSizeInBytes;
@property (nonatomic, assign) int64_t resumedFileSizeInBytes;
@property (nonatomic, assign) NSUInteger bytesPerSecondSpeed;
@property (nonatomic, strong, readonly, nonnull) NSProgress *progress;
@property (nonatomic, strong, readonly, nonnull) NSString *downloadToken;

@property (nonatomic, strong, readonly, nullable) NSURLSessionDownloadTask *sessionDownloadTask;

@property (nonatomic, strong, readonly, nullable) NSURLConnection *urlConnection;

@property (nonatomic, strong, nullable) NSArray<NSString *> *errorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;
@property (nonatomic, strong, nullable) NSURL *finalLocalFileURL;


- (nonnull HWIFileDownloadItem *)init __attribute__((unavailable("use initWithDownloadToken:sessionDownloadTask:urlConnection:")));
+ (nonnull HWIFileDownloadItem *)new __attribute__((unavailable("use initWithDownloadToken:sessionDownloadTask:urlConnection:")));

@end
