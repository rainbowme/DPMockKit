//
//  DPDataSaver.h
//  DPMockKit
//
//  Created by Aurora on 2018/9/3.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPDataSaver : NSObject
+ (instancetype)defaultInstance;

- (void)storeWithRequest:(NSURLRequest *)request data:(id)data;
- (void)storeWithRequest:(NSURLRequest *)request text:(id)data;
- (NSURL *)storeWithRequest:(NSURLRequest *)request fileURL:(NSURL *)fileURL;

- (NSData *)storeWithRequest:(NSURLRequest *)request des3key:(id)data;
- (NSData *)storeWithRequest:(NSURLRequest *)request encryptData:(id)data;
- (void)storeWithRequest:(NSURLRequest *)request jsonData:(id)data;
@end
