//
//  NETURLSchemeHandler.m
//  NETURLSchemeHandler
//
//  Created by yleaf on 2020/5/7.
//

#import "NETURLSchemeHandler.h"

@interface NETSchemeFileHelper()

@end

@implementation NETSchemeFileHelper

+ (BOOL)copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *fileError = nil;
    
    if ([defaultManager fileExistsAtPath:dstURL.path]) {
        [defaultManager removeItemAtURL:dstURL error:&fileError];
    }

    if (fileError) {
        *error = fileError;
        return NO;
    }
    
    NSURL *directoryURL = [dstURL URLByDeletingLastPathComponent];
    if (![defaultManager fileExistsAtPath:directoryURL.absoluteString]) {
        BOOL result = [self createDirectory:directoryURL error:&fileError];
        if (!result) {
            *error = fileError;
            return result;
        }
    }
    
    return [defaultManager moveItemAtURL:srcURL toURL:dstURL error:error];
}

+ (BOOL)createDirectory:(NSURL *)path error:(NSError **)error
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    return [defaultManager createDirectoryAtURL:path withIntermediateDirectories:YES attributes:@{} error:error];
}

@end


@interface NETURLSchemeHandler ()
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *directory;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSHashTable *hashTable;
@property (nonatomic, assign) BOOL disable;
@end

@implementation NETURLSchemeHandler

- (instancetype)init
{
    self = [super init];
    _scheme = @"netless";
    _directory = NSTemporaryDirectory();
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return self;
}

- (instancetype)initWithScheme:(NSString *)scheme directory:(NSString *)dir
{
    self = [self init];
    _scheme = scheme;
    _directory = dir;
    return self;
}

#pragma mark -
#pragma mark - Request
#pragma mark -

- (NSString *)filePath:(NSURLRequest *)request {
    NSString *urlString = request.URL.absoluteString;
    
    
    NSArray<NSString *>* prefixs = @[[self.scheme stringByAppendingString:@"://"], @"https://", @"http://"];
    
    for (NSString *prefix in prefixs) {
        if ([urlString hasPrefix:prefix]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:prefix withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, prefix.length)];
        }
    }
    
    return [NSURL fileURLWithPath:[self.directory stringByAppendingPathComponent:urlString]].path;
}

- (NSURLRequest *)httpRequest:(NSURLRequest *)originRequest
{
    NSMutableURLRequest *request = [originRequest mutableCopy];

    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:self.scheme]) {
        urlString = [urlString stringByReplacingCharactersInRange:NSMakeRange(0, self.scheme.length) withString:@"https"];
    }
    request.URL = [NSURL URLWithString:urlString];
    
    return request;
}

- (BOOL)resourcesExist:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

#pragma mark - Private
- (void)stop
{
    self.disable = YES;
}

- (void)restart
{
    self.disable = NO;
}

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
    if (self.disable) {
        return;
    }
    NSURLRequest *request = urlSchemeTask.request;
    NSString *filePath = [self filePath:request];
    if ([self resourcesExist:filePath]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];

        NSURLResponse *response;
        // js fetch need http status code
        if ([[filePath pathExtension] isEqualToString:@"json"] || [[filePath pathExtension] isEqualToString:@"xml"]) {
            response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
        } else {
            NSString *mimeType = [[self class] mimeTypeForData:data];
            response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:mimeType expectedContentLength:data.length textEncodingName:nil];
        }
        
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
