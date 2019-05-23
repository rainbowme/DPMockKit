//
//  RequestConfigure.m
//  DPMockKit
//
//  Created by Aurora on 2018/9/26.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "RequestConfigure.h"
#import "FileIOManager.h"

@implementation RequestDataInfo:NSObject
@end

@implementation RequestConfigure

+ (NSString *)clipURL:(NSString *)url {
    if(!url) {
        return nil;
    }
    const char *pBuffer = url.UTF8String;
    const char *pTmp = pBuffer;
    
    NSUInteger length = url.length;
    while(pTmp && length>0) {
        if(*pTmp == '?') {
            break;
        }
        length--;
        pTmp++;
    }
    int count=0;
    while (pBuffer) {
        if(*pBuffer=='/') {
            if(count++==2) {
                break;
            }
        }
        pBuffer++;
    }
    long int len = pTmp-pBuffer;
    return [[NSString alloc] initWithBytes:(pBuffer+1) length:(len-1) encoding:NSUTF8StringEncoding];
}

+ (instancetype)defaultInstance
{
    static RequestConfigure *requestRecord = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestRecord = [[RequestConfigure alloc] init];
    });
    return requestRecord;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        NSString *documentPath = [FileIOManager documentPath];
        documentPath = [documentPath stringByAppendingPathComponent:@"ResponseData.bundle/ConfigInfo"];
        [FileIOManager correctFilePath:documentPath];
        recordsPath = [documentPath stringByAppendingPathComponent:@"RequestConfigure.plist"];
        recordsDic = [NSMutableDictionary dictionaryWithContentsOfFile:recordsPath];
        if(!recordsDic) {
            recordsDic = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    }
    return self;
}

- (RequestDataInfo *)queryRequestDataInfoWithRequest:(NSURLRequest *)request {
    NSString *key = [RequestConfigure clipURL:request.URL.absoluteString];
    NSDictionary *dictionary = recordsDic[key];
    RequestDataInfo *info = [RequestDataInfo new];
    info.responseType = dictionary[@"ResponseType"];
    info.bEnable = [dictionary[@"Enable"] boolValue];
    info.bUpdatable = [dictionary[@"Updatable"] boolValue];
    info.desc = dictionary[@"Description"];
    return info;
}

- (BOOL)containsRecordsOfURLRequest:(NSURLRequest *)request
{
    NSString *key = [RequestConfigure clipURL:request.URL.absoluteString];
    return (recordsDic[key]!=nil);
}

- (BOOL)isValidRecordsWithURLRequest:(NSURLRequest *)request {
    NSString *key = [RequestConfigure clipURL:request.URL.absoluteString];
    NSDictionary *dic = [recordsDic objectForKey:key];
    return [dic[@"Enable"] boolValue];
}

- (BOOL)isUpdatableRecordsWithURLRequest:(NSURLRequest *)request {
    NSString *key = [RequestConfigure clipURL:request.URL.absoluteString];
    NSDictionary *dic = [recordsDic objectForKey:key];
    return [dic[@"Updatable"] boolValue];
}

// contentType: <JSON>、<DATA>、<ENCRYPT>、<>
- (void)createRecordWithRequest:(NSURLRequest *)request {
    NSString *key = [RequestConfigure clipURL:request.URL.absoluteString];
    NSDictionary *dictionary = @{@"Enable":@(YES),
                                 @"Updatable":@(NO),
                                 @"Description":@"No Description",
                                 @"ResponseType":@"DATA"};
    [recordsDic setObject:dictionary forKey:key];
    [recordsDic writeToFile:recordsPath atomically:NO];
}

@end
