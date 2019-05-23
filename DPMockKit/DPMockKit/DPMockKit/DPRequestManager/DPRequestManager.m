//
//  DPRequestManager.m
//  DPMockKit
//
//  Created by Aurora on 2018/8/31.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "DPRequestManager.h"
#import "DPDataSaver.h"
#import "DPMessagePiple.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach_time.h>

@interface DPRequestManager ()
{
    DPDataSaver *dataSaver;
}
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) DPRequestManager *requestManager;
@end

@implementation DPRequestManager

- (instancetype)init {
    self = [super init];
    if(self) {
        _session = [NSURLSession sharedSession];
         dataSaver = [[DPDataSaver alloc] init];
    }
    return self;
}

+ (instancetype)defaultInstance {
    static DPRequestManager *requestManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestManager = [[DPRequestManager alloc] init];
    });
    return requestManager;
}

- (void)dealloc {
    
}

//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
//    uint64_t start = CACurrentMediaTime(); // 此时是秒
//    uint64_t startt = mach_absolute_time ();

//        uint64_t end = mach_absolute_time (); // 此时是纳秒
//        uint64_t deltaElapsed = end - startt;
//        mach_timebase_info_data_t info;
//        uint64_t nanos = 0;
//        if (mach_timebase_info(&info) == KERN_SUCCESS) {
//            nanos = deltaElapsed * info.numer / info.denom;
//        }
//        CGFloat test =  (CGFloat)nanos / (NSEC_PER_SEC/1000);
//
//
//        uint64_t elapsed = CACurrentMediaTime() - start;
//
//        NSTimeInterval deltaTime = [[NSDate date] timeIntervalSince1970]-timeInterval;
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"url"] = request.URL.absoluteString;
//        dic[@"DateTime"] = @(deltaTime);
//        dic[@"MediaTime"] = @(elapsed);
//        dic[@"MachTime"] = @(test);
//        NSDicInfomation(dic);
//printf("MyRequest = %s\n", request.description.UTF8String);
//printf("MyResponse1 data = %s\n", (data?[[NSString alloc] initWithData:data encoding:0]:nil).description.UTF8String);
//printf("MyResponse2 response = %s\n", response.description.UTF8String);
//printf("MyResponse3 error = %s\n", error.description.UTF8String);
//printf("=============================================================================\n");
+ (void)fetchDataWithRequest:(NSURLRequest *)request
             requestDataInfo:(RequestDataInfo *)requestDataInfo
                  completion:(void(^)(id data, NSURLResponse *response, NSError *error))completion
{
    __weak DPRequestManager *requestManager = [self defaultInstance];
    if([requestDataInfo.responseType isEqualToString:@"FILE"]) {
        NSURLSessionDownloadTask *downloadTask = [requestManager.session downloadTaskWithRequest:request
                                                                               completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
        {
            DPDataSaver *saver = [DPDataSaver defaultInstance];
            NSURL *fileURL = [saver storeWithRequest:request fileURL:location];
            
            NSData *data = [NSData dataWithContentsOfURL:fileURL];
            if(completion) {
                completion(data, response, error);
            }
        }];
        [downloadTask resume];
    } else {
        if([requestDataInfo.responseType isEqualToString:@"ENCRYPT"]) {
            NSString *query = request.URL.query;
            //data = [saver storeWithRequest:request encryptData:data];
        }
        NSURLSessionDataTask *dataTask = [requestManager.session dataTaskWithRequest:request
                                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if(!error && data) {
                DPDataSaver *saver = [DPDataSaver defaultInstance];
                if([requestDataInfo.responseType isEqualToString:@"TEXT"]) {
                    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [saver storeWithRequest:request text:text];
                }
                else if([requestDataInfo.responseType isEqualToString:@"JSON"]) {
                    [saver storeWithRequest:request jsonData:data];
                }
                else if([requestDataInfo.responseType isEqualToString:@"ECRYPT"]) {
                    data = [saver storeWithRequest:request encryptData:data];
                }
                else if([requestDataInfo.responseType isEqualToString:@"3DESKEY"]) {
                    data = [saver storeWithRequest:request des3key:data];
                }
                // [requestDataInfo.responseType isEqualToString:@"DATA"]
                else {
                    [saver storeWithRequest:request data:data];
                }
            }
            if(completion) {
                completion(data, response, error);
            }
        }];
        [dataTask resume];
    }
}

@end
