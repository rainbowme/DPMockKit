//
//  RequestConfigure.h
//  DPMockKit
//
//  Created by Aurora on 2018/9/26.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportFromOtherModule.h"

@interface RequestDataInfo:NSObject
@property (strong, nonatomic) NSString *responseType; // <FILE>、<JSON>、<TEXT>、<DATA>、<ENCRYPT>、<3DESKEY>
@property (assign, nonatomic) BOOL bEnable;
@property (assign, nonatomic) BOOL bUpdatable;
@property (strong, nonatomic) NSString *desc;
@end
#define RequestConfigureI [RequestConfigure defaultInstance]

@interface RequestConfigure: NSObject
{
    NSMutableDictionary *recordsDic;
    NSString *recordsPath;
}
+ (instancetype)defaultInstance;
+ (NSString *)clipURL:(NSString *)url;
- (BOOL)containsRecordsOfURLRequest:(NSURLRequest *)request;
- (BOOL)isValidRecordsWithURLRequest:(NSURLRequest *)request;
- (BOOL)isUpdatableRecordsWithURLRequest:(NSURLRequest *)request;
- (void)createRecordWithRequest:(NSURLRequest *)request;
- (RequestDataInfo *)queryRequestDataInfoWithRequest:(NSURLRequest *)request;
@end
