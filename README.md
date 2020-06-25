# NETURLSchemeHandler

[![CI Status](https://img.shields.io/travis/leavesster/NETURLSchemeHandler.svg?style=flat)](https://travis-ci.org/leavesster/NETURLSchemeHandler)
[![Version](https://img.shields.io/cocoapods/v/NETURLSchemeHandler.svg?style=flat)](https://cocoapods.org/pods/NETURLSchemeHandler)
[![License](https://img.shields.io/cocoapods/l/NETURLSchemeHandler.svg?style=flat)](https://cocoapods.org/pods/NETURLSchemeHandler)
[![Platform](https://img.shields.io/cocoapods/p/NETURLSchemeHandler.svg?style=flat)](https://cocoapods.org/pods/NETURLSchemeHandler)

## How to use

```Objective-C
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

NETURLSchemeHandler *schemeHandler = [[NETURLSchemeHandler alloc] initWithScheme:@"scheme" directory:NSTemporaryDirectory()];
[config setURLSchemeHandler:self.schemeHandler forURLScheme:@"scheme"];

WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

`0.1.0 ~ 0.1.2` require `iOS 11`.  
`0.1.3+` require `iOS 9` for low deployment target, but `NETURLSchemeHandler` API is based on `WKURLSchemeHandler` , so it only available on `iOS 11`.

## Installation

NETURLSchemeHandler is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NETURLSchemeHandler'
```

## License

NETURLSchemeHandler is available under the MIT license. See the LICENSE file for more info.
