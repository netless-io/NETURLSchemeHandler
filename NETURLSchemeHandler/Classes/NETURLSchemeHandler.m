//
//  NETURLSchemeHandler.m
//  NETURLSchemeHandler
//
//  Created by yleaf on 2020/5/7.
//

#import "NETURLSchemeHandler.h"

@interface NETURLSchemeHandler ()
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *directory;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSHashTable *hashTable;
@end

@implementation NETURLSchemeHandler

- (instancetype)init
{
    self = [super init];
    _scheme = @"netless";
    _directory = NSTemporaryDirectory();
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    _hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return self;
}

#pragma mark - Public

- (void)registerCustomSchemeHandler:(NSString *)customHandler
{
    _scheme = customHandler;
}

#pragma mark -
#pragma mark - Private
#pragma mark -

- (NSString *)filePath:(NSURLRequest *)request {
    NSString *urlString = request.URL.absoluteString;
    NSString *prefix = [self.scheme stringByAppendingString:@"://"];
    urlString = [urlString stringByReplacingOccurrencesOfString:prefix withString:@"" options:NSCaseInsensitiveSearch range:NSRangeFromString(prefix)];
    NSURL *filePath = [NSURL fileURLWithPath:[self.directory stringByAppendingPathComponent:urlString]];
    return filePath.absoluteString;
}

- (NSURLRequest *)httpRequest:(NSURLRequest *)originRequest
{
    NSMutableURLRequest *request = [originRequest mutableCopy];

    NSString *urlString = request.URL.absoluteString;
    urlString = [urlString stringByReplacingCharactersInRange:NSMakeRange(0, self.scheme.length) withString:@"https"];
    request.URL = [NSURL URLWithString:urlString];
    
    return request;
}

- (BOOL)resourcesExist:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark - HTTP
+ (NSString *)mimeTypeForData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}

#pragma mark - WKURLSchemeHandler
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    NSURLRequest *request = urlSchemeTask.request;
    NSString *filePath = [self filePath:request];
    if ([self resourcesExist:filePath]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[[self class] mimeTypeForData:data] expectedContentLength:data.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    } else {
        NSURLRequest *httpRequest = [self httpRequest:request];
        [self.hashTable addObject:urlSchemeTask];
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:httpRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (![self.hashTable containsObject:urlSchemeTask]) {
                return ;
            }
            if (response) {
                [urlSchemeTask didReceiveResponse:response];
            }
            if (data) {
                [urlSchemeTask didReceiveData:data];
            }
            if (error) {
                [urlSchemeTask didFailWithError:error];
            } else {
                [urlSchemeTask didFinish];
            }
            [self.hashTable removeObject:urlSchemeTask];
        }];
        [task resume];
    }
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    [self.hashTable removeObject:urlSchemeTask];
}

@end
