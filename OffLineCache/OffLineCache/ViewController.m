//
//  ViewController.m
//  OffLineCache
//
//  Created by ken on 2018/8/27.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import "HWIFileDownloader.h"
#import "DTDownloadNotifications.h"
#import "DTDownloadItem.h"
#import "DTDownloadStore.h"

#import "DTDownloadUtils.h"

#import "BaseWebViewController.h"

@interface ViewController ()

@property (nonatomic, weak) UIProgressView *totalProgressView;
@property (nonatomic, weak) UILabel *totalProgressLocalizedDescriptionLabel;
@property (nonatomic, strong) BaseWebViewController *webVC;
@property (nonatomic, strong, nullable) NSDate *lastProgressChangedUpdate;

@end

@implementation ViewController

-(instancetype)init
{
    if(self = [super init])
    {
        //下载完成
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadDidComplete:) name:downloadDidCompleteNotification object:nil];
        
        //下载进度变更
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProgressDidChange:) name:downloadProgressChangedNotification object:nil];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            //总进度变更
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTotalProgressDidChange:) name:totalDownloadProgressChangedNotification object:nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *url = @"http://www.imagomat.de/testimages/1.tiff";
    NSURL *aRemoteURL = [NSURL URLWithString:url];
    DTDownloadItem *item = [[DTDownloadItem alloc] initWithDownloadIdentifier:url remoteURL:aRemoteURL];
    
    DTDownloadUtils *dtUtil = [[DTDownloadUtils alloc] init];
    [dtUtil addDownloadItems:@[item]];
    
    UIProgressView *aProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    CGRect aProgressViewRect = CGRectMake(0, 150, self.view.frame.size.width, 10);
    [aProgressView setFrame:aProgressViewRect];
    [aProgressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:aProgressView];
    self.totalProgressView = aProgressView;
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 30)];
    lable.font = [UIFont systemFontOfSize:14];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = @"总进度";
    [self.view addSubview:lable];
    self.totalProgressLocalizedDescriptionLabel = lable;
    
    CGRect rect = CGRectMake(100, 200, 100, 50);
    UIButton *btnStart = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStart setFrame:rect];
    [btnStart setBackgroundColor:[UIColor yellowColor]];
    [btnStart addTarget:self action:@selector(pressStart) forControlEvents:UIControlEventTouchUpInside];
    [btnStart setTitle:@"开始下载" forState:UIControlStateNormal];
    [btnStart.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnStart setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnStart];
    
    CGRect rect1 = CGRectMake(100, 260, 100, 50);
    UIButton *btnStart1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStart1 setFrame:rect1];
    [btnStart1 setBackgroundColor:[UIColor yellowColor]];
    [btnStart1 addTarget:self action:@selector(pressCancel) forControlEvents:UIControlEventTouchUpInside];
    [btnStart1 setTitle:@"取消下载" forState:UIControlStateNormal];
    [btnStart1.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnStart1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnStart1];
    
    CGRect rect2 = CGRectMake(100, 320, 100, 50);
    UIButton *btnStart2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStart2 setFrame:rect2];
    [btnStart2 setBackgroundColor:[UIColor yellowColor]];
    [btnStart2 addTarget:self action:@selector(pressPause) forControlEvents:UIControlEventTouchUpInside];
    [btnStart2 setTitle:@"暂停下载" forState:UIControlStateNormal];
    [btnStart2.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnStart2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnStart2];
    
    CGRect rect3 = CGRectMake(100, 380, 100, 50);
    UIButton *btnStart3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStart3 setFrame:rect3];
    [btnStart3 setBackgroundColor:[UIColor yellowColor]];
    [btnStart3 addTarget:self action:@selector(pressLoadWeb) forControlEvents:UIControlEventTouchUpInside];
    [btnStart3 setTitle:@"加载资源---1" forState:UIControlStateNormal];
    [btnStart3.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnStart3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnStart3];
    
    CGRect rect4 = CGRectMake(100, 440, 100, 50);
    UIButton *btnStart4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStart4 setFrame:rect4];
    [btnStart4 setBackgroundColor:[UIColor yellowColor]];
    [btnStart4 addTarget:self action:@selector(pressLoadWeb1) forControlEvents:UIControlEventTouchUpInside];
    [btnStart4 setTitle:@"加载资源---2" forState:UIControlStateNormal];
    [btnStart4.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnStart4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btnStart4];
}
- (void) pressLoadWeb
{
//    if(!self.webVC)
//    {
        self.webVC = [BaseWebViewController new];
//    }
    _webVC.urlStr = @"https://www.rv2go.com/share/travel/detail-1619.html";
//    webVC.urlStr = @"https://www.rv2go.com/share/shoot/detail-14990.html";
    [self.navigationController pushViewController:_webVC animated:YES];
}
- (void) pressLoadWeb1
{
//    if(!self.webVC)
//    {
        self.webVC = [BaseWebViewController new];
//    }
    _webVC.urlStr = @"https://www.rv2go.com/share/travel/detail-1620.html";
    //    webVC.urlStr = @"https://www.rv2go.com/share/shoot/detail-14990.html";
    [self.navigationController pushViewController:_webVC animated:YES];
}

//开始下载
- (void) pressStart
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    DTDownloadStore *dtStore = delegate.downloadStore;
//
//    NSString *url = @"http://www.imagomat.de/testimages/1.tiff";
//    NSURL *aRemoteURL = [NSURL URLWithString:url];
//    DTDownloadItem *item = [[DTDownloadItem alloc] initWithDownloadIdentifier:url remoteURL:aRemoteURL];
//
//    [dtStore startDownloadWithDownloadItem:item];
    NSArray *arr = [delegate downloadStore].downloadItemsArray;
    DTDownloadItem *aDownloadItem = [arr objectAtIndex:0];
    
    [delegate.downloadStore startDownloadWithDownloadItem:aDownloadItem];
}

//取消
- (void) pressCancel
{
    AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    DTDownloadItem *aDownloadItem = [[theAppDelegate downloadStore].downloadItemsArray objectAtIndex:0];
    
    [self cancelDownloadWithIdentifier:aDownloadItem.downloadIdentifier];
}

//暂停下载
- (void) pressPause
{
    AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    DTDownloadItem *aDownloadItem = [[theAppDelegate downloadStore].downloadItemsArray objectAtIndex:0];
    
    if(aDownloadItem.status == DtItemStatusNotStarted)
    {
        NSLog(@"未启动");
    }
    else if(aDownloadItem.status == DtItemStatusPaused)
    {
        NSLog(@"暂停--->开始");
        [self resumeDownloadWithIdentifier:aDownloadItem.downloadIdentifier];
    }
    else
    {
        [self pauseDownloadWithIdentifier:aDownloadItem.downloadIdentifier];
    }

//
}

- (void)pauseDownloadWithIdentifier:(NSString *)aDownloadIdentifier
{
    AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL isDownloading = [theAppDelegate.fileDownloader isDownloadingIdentifier:aDownloadIdentifier];
    if (isDownloading)
    {
        HWIFileDownloadProgress *aFileDownloadProgress = [theAppDelegate.fileDownloader downloadProgressForIdentifier:aDownloadIdentifier];
        [aFileDownloadProgress.nativeProgress pause];
    }
}

- (void)resumeDownloadWithIdentifier:(NSString *)aDownloadIdentifier
{
    AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [theAppDelegate.downloadStore resumeDownloadWithDownloadIdentifier:aDownloadIdentifier];
}

- (void)cancelDownloadWithIdentifier:(NSString *)aDownloadIdentifier
{
    AppDelegate *theAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL isDownloading = [theAppDelegate.fileDownloader isDownloadingIdentifier:aDownloadIdentifier];
    if (isDownloading)
    {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            HWIFileDownloadProgress *aFileDownloadProgress = [theAppDelegate.fileDownloader downloadProgressForIdentifier:aDownloadIdentifier];
            [aFileDownloadProgress.nativeProgress cancel];
        }
        else
        {
            [theAppDelegate.fileDownloader cancelDownloadWithIdentifier:aDownloadIdentifier];
        }
    }
    else
    {
        // app client bookkeeping
        [theAppDelegate.downloadStore cancelDownloadWithDownloadIdentifier:aDownloadIdentifier];
        
        NSUInteger aFoundDownloadItemIndex = [[theAppDelegate downloadStore].downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
            if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
            {
                return YES;
            }
            return NO;
        }];
        if (aFoundDownloadItemIndex != NSNotFound)
        {
//            NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:aFoundDownloadItemIndex inSection:0];
//            [self.tableView reloadRowsAtIndexPaths:@[anIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:downloadDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:downloadProgressChangedNotification object:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:totalDownloadProgressChangedNotification object:nil];
    }
}

#pragma mark - Download Notifications

//下载完成
- (void)onDownloadDidComplete:(NSNotification *)aNotification
{
    DTDownloadItem *aDownloadItem = (DTDownloadItem *)aNotification.object;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    DTDownloadStore *dtStore = delegate.downloadStore;
    NSUInteger aFoundDownloadItemIndex = [dtStore.downloadItemsArray indexOfObjectPassingTest:^BOOL(DTDownloadItem *aTempDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aTempDownloadItem.downloadIdentifier isEqualToString:aDownloadItem.downloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSLog(@"资源未找到 Index = %ld",aFoundDownloadItemIndex);
    }
    else
    {
        NSLog(@"WARN: Completed download item not found (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

//总进度变更
- (void)onTotalProgressDidChange:(NSNotification *)aNotification
{
    NSProgress *aProgress = aNotification.object;
    self.totalProgressView.progress = (float)aProgress.fractionCompleted;
    if (aProgress.completedUnitCount != aProgress.totalUnitCount)
    {
        self.totalProgressLocalizedDescriptionLabel.text = aProgress.localizedDescription;
    }
    else
    {
        self.totalProgressLocalizedDescriptionLabel.text = @"";
    }
}

//下载进度变更
- (void)onProgressDidChange:(NSNotification *)aNotification
{
    NSTimeInterval aLastProgressChangedUpdateDelta = 0.0;
    if (self.lastProgressChangedUpdate)
    {
        aLastProgressChangedUpdateDelta = [[NSDate date] timeIntervalSinceDate:self.lastProgressChangedUpdate];
    }
    //刷新进度大约每秒显示4次
    if ((aLastProgressChangedUpdateDelta == 0.0) || (aLastProgressChangedUpdateDelta > 0.25))
    {
        //刷新显示资源
        self.lastProgressChangedUpdate = [NSDate date];
    }
}
@end
