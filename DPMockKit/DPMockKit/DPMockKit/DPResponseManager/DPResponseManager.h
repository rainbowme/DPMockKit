//
//  DPRequestMonitor.h
//  DPMockKit
//
//  Created by Aurora on 2018/8/30.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestConfigure.h"

@interface DPResponseManager : NSObject
+ (instancetype)defaultInstance;
+ (NSString *)pathOfResourceWithRequest:(NSURLRequest *)request;
+ (BOOL)resourceExistsWithRequest:(NSURLRequest *)request;
+ (void)queryDataWithKey:(NSURLRequest *)request
         requestDataInfo:(RequestDataInfo *)requestDataInfo
              completion:(void(^)(id data, NSError *error))completion;
@end
