//
//  NSURLProtocolCustom.m
//  OffLineCache
//
//  Created by ken on 2018/9/4.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "NSURLProtocolCustom.h"
#import "NSString+MD5.h"
#import "JKSandBoxManager.h"
#import <AFNetworking/AFNetworking.h>

@interface NSURLProtocolCustom ()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

static NSString* const FilteredKey = @"FilteredKey";

@implementation NSURLProtocolCustom

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *strURL = request.URL.absoluteString;
    NSString *extension = request.URL.pathExtension;
    
    //www.rv2go.com/resources/js/rem.js
    //https://www.rv2go.com/resources/css/traveldetail.css
    //http://cdn.rv2go.com/Fq0k7wgx2ytzdKo6hEs43kNC31oc?imageView2/2/w/750
    
    NSLog(@"strURL = %@",strURL);
    NSLog(@"extension = %@",extension);
    
    
    //查找数组中第一个符合条件的对象（代码块过滤），返回对应索引
    BOOL isSource = [[self resourceTypes] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"extension = %@ , obj = %@",extension,obj);
        NSComparisonResult result = [extension compare:obj options:NSCaseInsensitiveSearch];
        return result == NSOrderedSame;
    }] != NSNotFound;
    
    return [NSURLProtocol propertyForKey:FilteredKey inRequest:request] == nil && isSource;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [super.request mutableCopy];
    
    //url 加密为文件名称
    NSString *sURL = super.request.URL.absoluteString;
    NSString *sURLMD5 = [sURL MD5Hash];
    NSString *sPathExtension = super.request.URL.pathExtension;
    
    if(sPathExtension==nil || [sPathExtension isEqualToString:@""])
    {
        return;
    }
    
    //标记该请求已经处理
    [NSURLProtocol setProperty:@YES forKey:FilteredKey inRequest:mutableReqeust];
    
    //拼接文件名
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",sURLMD5,sPathExtension];
    
    //如若有权限控制可针对不同用户
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserName"];
    NSString *nameSpace = [NSString stringWithFormat:@"UserName%@",userName];
    
    NSString *fileDir = [JKSandBoxManager createDocumentsFilePathWithFolderName:nameSpace];
    NSString *filePath = [fileDir stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    NSLog(@"targetpath %@",filePath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        //文件不存在，去下载
        NSLog(@"---------  下载 = %@  ----------",sURL);
        [self downloadResourcesWithRequest:[mutableReqeust copy]];
        return;
    }
    
    NSLog(@"---------  本地资源 = %@  ----------",sURL);
    //加载本地资源（嵌入本地资源）
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *sMimeType = [self getMimeTypeWithFilePath:filePath];
    [self sendResponseWithData:data mimeType:sMimeType];
}

- (void)stopLoading
{
    
}

- (void)sendResponseWithData:(NSData *)data mimeType:(nullable NSString *)mimeType
{
    // 这里需要用到MIMEType
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:super.request.URL
                                                        MIMEType:mimeType
                                           expectedContentLength:-1
                                                textEncodingName:nil];
    
    //    使用分类进行statusCode的管理或提示
    //    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    //    httpResponse.statusCode
    
    //硬编码 开始嵌入本地资源到web中
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
}

/**
 * manager的懒加载
 */
- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}

//下载资源文件
- (void)downloadResourcesWithRequest:(NSURLRequest *)request
{
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",[super.request.URL.absoluteString MD5Hash],super.request.URL.pathExtension];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserName"];
    NSString *nameSpace = [NSString stringWithFormat:@"UserName%@",userName];
    NSString *fileDir = [JKSandBoxManager createDocumentsFilePathWithFolderName:nameSpace];
    NSString *targetFilePath =[fileDir stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        // 下载进度
        
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *path =  [NSURL fileURLWithPath:JKSandBoxPathTemp];
        return [path URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [JKSandBoxManager moveFileFrom:filePath.path to:targetFilePath];
        NSLog(@"targetpath %@",targetFilePath);
        NSData *data = [NSData dataWithContentsOfFile:targetFilePath];
        
        NSString *strType = [self getMimeTypeWithFilePath:targetFilePath];
        //        if(strType!=nil)
        //        {
        [self sendResponseWithData:data mimeType:strType];
        //        }
        //        else
        //        {
        //            NSLog(@"fileName = %@",fileName);
        //        }
    }];
    
    // 4. 开启下载任务
    [downloadTask resume];
    
}

- (NSString *)getMimeTypeWithFilePath:(NSString *)filePath
{
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
    
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    
    CFRelease(pathExtension);
    
    //The UTI can be converted to a mime type:
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    
    return mimeType;
}

+ (NSArray *)resourceTypes
{
    return @[@"png", @"jpeg", @"gif", @"jpg",@"json", @"js", @"css",@"mp3",@"fnt"];
}

@end
