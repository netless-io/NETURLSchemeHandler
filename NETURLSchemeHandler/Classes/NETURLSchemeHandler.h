//
//  NETURLSchemeHandler.h
//  NETURLSchemeHandler
//
//  Created by yleaf on 2020/5/7.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETSchemeFileHelper : NSObject

/**
 copy item, remove dstURL if exist, and create directory for dstURL
 */
+ (BOOL)copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error;

@end


@interface NETURLSchemeHandler : NSObject<WKURLSchemeHandler>

@property (nonatomic, readonly, copy) NSString *scheme;
@property (nonatomic, readonly, copy) NSString *directory;

- (instancetype)initWithScheme:(NSString *)scheme directory:(NSString *)dir;

- (NSString *)filePath:(NSURLRequest *)request;
- (NSURLRequest *)httpRequest:(NSURLRequest *)originRequest;

@end

NS_ASSUME_NONNULL_END
