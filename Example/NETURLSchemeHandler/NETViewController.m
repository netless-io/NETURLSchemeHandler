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
@end

@implementation NETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"load" style:UIBarButtonItemStylePlain target:self action:@selector(loadHTML)];
    self.navigationItem.rightBarButtonItem = item;

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
#if defined(__LP64__) && __LP64__
    //https://mabin004.github.io/2018/06/25/iOS%E5%BA%94%E7%94%A8%E6%B2%99%E7%AE%B1/
    [config setValue:@"TRUE" forKey:@"allowUniversalAccessFromFileURLs"];
#else
    //32位 CPU 支持：https://www.jianshu.com/p/fe876b9d1f7c
    [config setValue:@(1) forKey:@"allowUniversalAccessFromFileURLs"];
#endif
    [config setURLSchemeHandler:[[NETURLSchemeHandler alloc] init] forURLScheme:@"netless"];
    
    WKWebView *webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView = webview;
    [self.view addSubview:webview];

    [self loadHTML];
}

- (void)loadHTML
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


@end
