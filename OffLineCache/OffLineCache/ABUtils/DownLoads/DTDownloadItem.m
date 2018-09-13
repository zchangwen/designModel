//
//  DTDownloadItem.m
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "DTDownloadItem.h"
#import "NSString+MD5.h"

@interface DTDownloadItem()<NSCoding>
@property (nonatomic, strong, readwrite, nonnull) NSURL *remoteURL;
@end



@implementation DTDownloadItem

-(void)setDownloadIdentifier:(NSString *)downloadIdentifier
{
    NSString *md5 = [downloadIdentifier MD5Hash];
    _downloadIdentifier = md5;
}

- (nonnull instancetype)initWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                                         remoteURL:(nonnull NSURL *)aRemoteURL
{
    self = [super init];
    if (self)
    {
        self.downloadIdentifier = aDownloadIdentifier;
        self.remoteURL = aRemoteURL;
        self.status = DtItemStatusNotStarted;   //默认未启动
    }
    return self;
}

#pragma mark - 序列化model
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.downloadIdentifier forKey:@"downloadIdentifier"];
    [aCoder encodeObject:self.remoteURL forKey:@"remoteURL"];
    [aCoder encodeObject:@(self.status) forKey:@"status"];
    if (self.resumeData.length > 0)
    {
        [aCoder encodeObject:self.resumeData forKey:@"resumeData"];
    }
    if (self.progress)
    {
        [aCoder encodeObject:self.progress forKey:@"progress"];
    }
    if (self.downloadError)
    {
        [aCoder encodeObject:self.downloadError forKey:@"downloadError"];
    }
    if (self.downloadErrorMessagesStack)
    {
        [aCoder encodeObject:self.downloadErrorMessagesStack forKey:@"downloadErrorMessagesStack"];
    }
    [aCoder encodeObject:@(self.lastHttpStatusCode) forKey:@"lastHttpStatusCode"];
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super init];
    if (self)
    {
        self.downloadIdentifier = [aCoder decodeObjectForKey:@"downloadIdentifier"];
        self.remoteURL = [aCoder decodeObjectForKey:@"remoteURL"];
        self.status = [[aCoder decodeObjectForKey:@"status"] unsignedIntegerValue];
        self.resumeData = [aCoder decodeObjectForKey:@"resumeData"];
        self.progress = [aCoder decodeObjectForKey:@"progress"];
        self.downloadError = [aCoder decodeObjectForKey:@"downloadError"];
        self.downloadErrorMessagesStack = [aCoder decodeObjectForKey:@"downloadErrorMessagesStack"];
        self.lastHttpStatusCode = [[aCoder decodeObjectForKey:@"lastHttpStatusCode"] integerValue];
    }
    return self;
}


#pragma mark - Description


- (NSString *)description
{
    NSMutableDictionary *aDescriptionDict = [NSMutableDictionary dictionary];
    [aDescriptionDict setObject:self.downloadIdentifier forKey:@"downloadIdentifier"];
    [aDescriptionDict setObject:self.remoteURL forKey:@"remoteURL"];
    [aDescriptionDict setObject:@(self.status) forKey:@"status"];
    if (self.progress)
    {
        [aDescriptionDict setObject:self.progress forKey:@"progress"];
    }
    if (self.resumeData.length > 0)
    {
        [aDescriptionDict setObject:@"hasData" forKey:@"resumeData"];
    }
    
    NSString *aDescriptionString = [NSString stringWithFormat:@"%@", aDescriptionDict];
    
    return aDescriptionString;
}

@end
