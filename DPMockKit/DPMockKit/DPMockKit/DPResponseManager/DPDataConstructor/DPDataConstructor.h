//
//  DPDataConstructor.h
//  DPMockKit
//
//  Created by Aurora on 2018/8/31.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPDataConstructor : NSObject
- (NSData *)generateDataWithRequest:(NSURLRequest *)request;
- (NSData *)generateFileWithRequest:(NSURLRequest *)request;

- (NSData *)generateDes3KeyWithRequest:(NSURLRequest *)request;
- (NSData *)generateEncryptResponseWithRequest:(NSURLRequest *)request;
- (NSData *)generateJSONResponseWithRequest:(NSURLRequest *)request;
- (NSData *)generateTEXTResponseWithRequest:(NSURLRequest *)request;
@end
