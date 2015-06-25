//
//  ViewController.m
//  NSURLSESSION
//
//  Created by 王德康 on 15/6/25.
//  Copyright (c) 2015年 王德康. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *Btn;
- (IBAction)btnAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSURLSessionDownloadTask *task;
// 任务数据
@property(nonatomic, strong) NSData *resumeData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (NSURLSession *)session {
    if (_session == nil) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}

- (void)start {
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:[NSURL URLWithString:@"http://lx.cdn.baidupcs.com/file/d5422aa34ed9af9c721fe65e953ef7d8?bkt=p2-nj-837&xcode=9895ef2e998c3e14947ea81e914fde8e2f8771d996fa23bded03e924080ece4b&fid=2232202584-250528-1047605211033133&time=1435206803&sign=FDTAXERLBH-DCb740ccc5511e5e8fedcff06b081203-sl4dOTkS6E%2Fdx9QIRoMPcl1iHL4%3D&to=sc&fm=Nin,B,U,nc&sta_dx=2&sta_cs=131&sta_ft=pptx&sta_ct=5&newver=1&newfm=1&flow_ver=3&sl=83034188&expires=8h&rt=pr&r=772682363&mlogid=3867818850&vuk=2232202584&vbdid=834121574&fin=%E4%BC%A0%E6%99%BA%E6%92%AD%E5%AE%A2C%E8%AF%AD%E8%A8%80%E5%85%A5%E9%97%A87.pptx&fn=%E4%BC%A0%E6%99%BA%E6%92%AD%E5%AE%A2C%E8%AF%AD%E8%A8%80%E5%85%A5%E9%97%A87.pptx&slt=pm&uta=0&rtype=1&iv=0"]];
    
    self.task = task;
    
    // 开始下载
    [task resume];
    
}

// 恢复继续下载
- (void)resume {
    // 载入上次的进度，并开始下载
    self.task  = [self.session downloadTaskWithResumeData:self.resumeData];
    [self.task resume];
}

- (void)stop {
    // 取消下载任务
    __weak typeof(self) weakSelf = self;
    [self.task cancelByProducingResumeData:^(NSData *resumeData) {
        // 保存下次开始的进度
        weakSelf.resumeData = resumeData;
        weakSelf.task = nil;
    }];
}

- (IBAction)btnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        if (self.resumeData) {
            // 恢复下载
            [self resume];
        } else {
            // 开始下载
            [self start];
        }
    } else {
        // 暂停下载
        [self stop];
    }
}

- (void)dealloc {
    self.session = nil;
    self.task = nil;
    self.resumeData = nil;
}


#pragma mark  NSURLSessionDownloadDelegate
// 数据下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [cacheDir stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    NSFileManager *manage = [NSFileManager defaultManager];
    [manage moveItemAtPath:location.path toPath:file error:nil];
    
    NSLog(@"%@", file);
}


// 下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    self.progressView.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
}

// 恢复下载的时候调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
}


@end
