
//  DPRequestMonitor.m
//  DPMockKit
//
//  Created by Aurora on 2018/8/30.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "DPResponseManager.h"
#import "DPDataConstructor.h"
#import "FileIOManager.h"

@interface DPResponseManager ()
{
    DPDataConstructor *dataConstructor;
}
@end

@implementation DPResponseManager

+ (instancetype)defaultInstance {
    static DPResponseManager *responseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        responseManager = [[DPResponseManager alloc] init];
    });
    return responseManager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        dataConstructor = [[DPDataConstructor alloc] init];
    }
    return self;
}

+ (NSString *)pathOfResourceWithRequest:(NSURLRequest *)request {
    NSString *resourceBundle = nil;
    {
        NSString *documentPath = [FileIOManager documentPath];
        resourceBundle = [documentPath stringByAppendingPathComponent:@"ResponseData.bundle/MockData"];
    }
    return [[NSBundle bundleWithPath:resourceBundle] pathForResource:request.URL.path ofType:@"plist"];
}

+ (BOOL)resourceExistsWithRequest:(NSURLRequest *)request {
    NSString *path = [self pathOfResourceWithRequest:request];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (void)queryDataWithKey:(NSURLRequest *)request
         requestDataInfo:(RequestDataInfo *)requestDataInfo
              completion:(void(^)(id data, NSError *error))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DPDataConstructor *dataConstructor = [DPResponseManager defaultInstance]->dataConstructor;
        if([requestDataInfo.responseType isEqualToString:@"TEXT"]) {
            NSData *data = [dataConstructor generateTEXTResponseWithRequest:request];
            completion(data, nil);
        }
        else if([requestDataInfo.responseType isEqualToString:@"JSON"]) {
            NSData *data = [dataConstructor generateJSONResponseWithRequest:request];
            completion(data, nil);
        }
        else if([requestDataInfo.responseType isEqualToString:@"ECCRYPT"]) {
            NSData *data = [dataConstructor generateEncryptResponseWithRequest:request];
            completion(data, nil);
        }
        else if([requestDataInfo.responseType isEqualToString:@"3DESKEY"]) {
            NSData *data = [dataConstructor generateDes3KeyWithRequest:request];
            completion(data, nil);
        }
        else if([requestDataInfo.responseType isEqualToString:@"FILE"]) {
            NSData *data = [dataConstructor generateFileWithRequest:request];
            completion(data, nil);
        }
        // [requestDataInfo.responseType isEqualToString:@"DATA"]
        else {
            NSData *data = [dataConstructor generateDataWithRequest:request];
            completion(data, nil);
        }
    });
}

@end
