//
//  DPRequestMonitor.m
//  DPMockKit
//
//  Created by Aurora on 2018/8/30.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "DPRequestMonitor.h"
#import "DPResponseManager.h"
#import "DPRequestManager.h"
#include <objc/runtime.h>
#import "RequestConfigure.h"

static NSString* const URLProtocolHandledKey = @"URLProtocolHandledKey";
static IMP g_implementationFunc = NULL;
@implementation DPRequestMonitor

static NSArray *ProtocolClasses(id self, SEL _cmd) {
    //    NSArray *array = ((NSArray *(*)(id, SEL))g_implementationFunc)(self, _cmd);
    //    if(![array containsObject:[DPRequestMonitor class]]) {
    //        NSMutableArray *_array = array.mutableCopy;
    //        [_array addObject:[DPRequestMonitor class]];
    //        array = _array.copy;
    //    }
    return @[[DPRequestMonitor class]];
}

+ (void)load {
    [NSURLProtocol registerClass:self];

    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    Method method = class_getInstanceMethod(cls, @selector(protocolClasses));
    g_implementationFunc = method_setImplementation(method, (IMP)ProtocolClasses);
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([[NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request] boolValue]) {
        return NO;
    }
    if (!([request.URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame) && !([request.URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame)) {
        return NO;
    }
    
    BOOL bFalg = [RequestConfigureI containsRecordsOfURLRequest:request];
    if(!bFalg) {
        [RequestConfigureI createRecordWithRequest:request];
    }
    if([RequestConfigureI isValidRecordsWithURLRequest:request]) {
        return YES;
    }
    return NO;
}
    
// 可以在开始加载中startLoading方法中 修改request，比如添加header，修改host,请求重定向等
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

// 主要判断两个request是否相同，如果相同的话可以使用缓存数据，通常只需要调用父类的实现。
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:(NSMutableURLRequest *)self.request];
    
    RequestDataInfo *requestDataInfo = [RequestConfigureI queryRequestDataInfoWithRequest:self.request];
    if(![DPResponseManager resourceExistsWithRequest:self.request] || [RequestConfigureI isUpdatableRecordsWithURLRequest:self.request]) {
        [DPRequestManager fetchDataWithRequest:self.request requestDataInfo:requestDataInfo
                                    completion:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if(!error) {
                if(response) {
                    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                }
                if(data) {
                    [self.client URLProtocol:self didLoadData:data];
                }
                [self.client URLProtocolDidFinishLoading:self];
            }
            else {
                [self.client URLProtocol:self didFailWithError:error];
            }
        }];
    } else {
        [DPResponseManager queryDataWithKey:self.request requestDataInfo:requestDataInfo completion:^(id data, NSError *error) {
             if(!error) {
                 NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png"
                                                        expectedContentLength:-1 textEncodingName:nil];
                 if(response) {
                     [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                 }
                 if(data) {
                     [self.client URLProtocol:self didLoadData:data];
                 }
                 [self.client URLProtocolDidFinishLoading:self];
             }
             else {
                 [self.client URLProtocol:self didFailWithError:error];
             }
         }];
    }
}

- (void)stopLoading {
    
}

@end
