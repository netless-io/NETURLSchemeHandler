//
//  NETViewController.m
//  NETURLSchemeHandler
//
//  Created by leavesster on 05/07/2020.
//  Copyright (c) 2020 leavesster. All rights reserved.
//

#import "NETViewController.h"
#import <WebKit/WebKit.h>
#import "NETURLSchemeHandler.h"

@interface NETViewController ()
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NETURLSchemeHandler *schemeHandler;
@end

@implementation NETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"load" style:UIBarButtonItemStylePlain target:self action:@selector(loadHTML)];
    self.navigationItem.rightBarButtonItem = item;

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    self.schemeHandler = [[NETURLSchemeHandler alloc] initWithScheme:@"netless" directory:NSTemporaryDirectory()];
    [config setURLSchemeHandler:self.schemeHandler forURLScheme:@"netless"];
    
    WKWebView *webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView = webview;
    [self.view addSubview:webview];

    [self downloadResources];
    [self loadHTML];
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"reload" style:UIBarButtonItemStylePlain target:self.webView action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)loadHTML
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - Donwload

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    }
    return _session;
}

- (void)downloadResources
{
    NSArray *resources = @[@"netless://white-pan.oss-cn-shanghai.aliyuncs.com/101/media5.wav", @"netless://white-pan.oss-cn-shanghai.aliyuncs.com/101/info.json", @"netless://white-pan.oss-cn-shanghai.aliyuncs.com/101/note1.xml", @"netless://white-pan.oss-cn-shanghai.aliyuncs.com/101/oceans.mp4", @"netless://white-pan.oss-cn-shanghai.aliyuncs.com/101/image/Rectangle.png", @"netless://white-pan.oss-cn-shanghai.aliyuncs.com/101/image/alin-rusu-1239275-unsplash_opt.jpg"];
    
    for (NSString *url in resources) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        request = [self.schemeHandler httpRequest:request];
        [self downloadResource:request];
    }
}

- (void)downloadResource:(NSURLRequest *)request
{
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"request %@ failed error:%@", request, error);
            return;
        }
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (![res isKindOfClass:[NSHTTPURLResponse class]]) {
            return;
        }
        
        if (res.statusCode < 200 || res.statusCode >= 400) {
            NSLog(@"response error: %@", response);
            return;
        }
        
        
        NSError *fileError = nil;
        NSURL *targetPath = [NSURL fileURLWithPath:[self.schemeHandler filePath:request]];

        
        BOOL result = [NETSchemeFileHelper copyItemAtURL:location toURL:targetPath error:&fileError];
        
        if (error || !result) {
            NSLog(@"copy failed, error: %@", fileError);
        } else {
            NSLog(@"request %@ download complete. move to %@", request, targetPath.absoluteString);
        }
    }];
    [task resume];
}


@end
