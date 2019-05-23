//
//  DPRequestManager.h
//  DPMockKit
//
//  Created by Aurora on 2018/8/31.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestConfigure.h"

@interface DPRequestManager : NSObject
+ (void)fetchDataWithRequest:(NSURLRequest *)request
             requestDataInfo:(RequestDataInfo *)requestDataInfo
                  completion:(void(^)(id data, NSURLResponse *response, NSError *error))completion;
@end
