//
//  DPDataConstructor.m
//  DPMockKit
//
//  Created by Aurora on 2018/8/31.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "DPDataConstructor.h"
#import "ImportFromOtherModule.h"
#import "DPResponseManager.h"
#import "FileIOManager.h"


// 原定在另一个文件，目的在于引入工程成种的加解密模块，特殊原因不在此实现。
#define HMDataSecurityManager [ImportClassMethod DataSecurityManagerI]
#define HMBase64 [ImportClassMethod Base64I]
#define HMDESWrapper [ImportClassMethod DESWrapperI]

@interface DPDataConstructor ()
{
    NSString *des3Key;
}
@end

@implementation DPDataConstructor
- (NSData *)generateDataWithRequest:(NSURLRequest *)request{
    NSString *path = [DPResponseManager pathOfResourceWithRequest:request];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    __block NSData *data = nil;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
        data = dic[@"ResponseData"];
        *stop = YES;
    }];
    return data;
}

- (NSData *)generateFileWithRequest:(NSURLRequest *)request {
    NSString *path = [DPResponseManager pathOfResourceWithRequest:request];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    __block NSString *filePath = nil;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
        filePath = dic[@"ResponseData"];
        filePath = [[FileIOManager documentPath] stringByAppendingPathComponent:filePath];
        *stop = YES;
    }];
    return [NSData dataWithContentsOfFile:filePath];
}

- (NSData *)generateDes3KeyWithRequest:(NSURLRequest *)request {
    NSString *documentPath = [FileIOManager documentPath];
    NSString *resourceBundle = [documentPath stringByAppendingPathComponent:@"ResponseData.bundle/MockData"];
    NSString *filePath = [[NSBundle bundleWithPath:resourceBundle] pathForResource:request.URL.path ofType:@"plist"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSData *tmpData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *tmpStr = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@":\"empty_value\"" withString:@":null"];
    dic = [NSJSONSerialization JSONObjectWithData:[tmpStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSMutableDictionary *responseData = ((NSDictionary *)dic[@"ResponseData"]).mutableCopy;
    NSString *body = responseData[@"content"][@"body"];
    des3Key = body;
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    data = [HMDataSecurityManager encryptData:data privateKey:[HMDataSecurityManager testPrivateKey]];
    responseData[@"content"] = ((NSDictionary *)responseData[@"content"]).mutableCopy;
    responseData[@"content"][@"body"] = [HMBase64 stringByEncodingData:data];
    
    return responseData?[NSJSONSerialization dataWithJSONObject:responseData options:0 error:nil]:nil;
}

- (NSData *)generateEncryptResponseWithRequest:(NSURLRequest *)request {
    NSString *documentPath = [FileIOManager documentPath];
    NSString *resourceBundle = [documentPath stringByAppendingPathComponent:@"ResponseData.bundle/MockData"];
    NSString *filePath = [[NSBundle bundleWithPath:resourceBundle] pathForResource:request.URL.path ofType:@"plist"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSData *tmpData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *tmpStr = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@":\"empty_value\"" withString:@":null"];
    dic = [NSJSONSerialization JSONObjectWithData:[tmpStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    // 密文
    NSMutableDictionary *responseData = ((NSDictionary *)dic[@"ResponseData"]).mutableCopy;
    NSInteger contentType =  [responseData[@"contentType"] integerValue];
    if(contentType==2) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseData[@"content"] options:0 error:nil];
        // encMsg
        NSString *encMsg = nil;
        if(des3Key) {
            NSData *encData = [HMDESWrapper encryptData:jsonData key:[des3Key dataUsingEncoding:NSUTF8StringEncoding]];
            encMsg = [HMBase64 stringByEncodingData:encData];
        }
        
        // signMsg
        NSString *md5 = [jsonData md5];
        NSString *signMsg = [HMBase64 stringByEncodingBytes:[md5 UTF8String] length:[md5 length]];
        
        // 重新拼接参数
        NSDictionary *newDic = @{@"returnEncMsg":encMsg,@"returnSignMsg":signMsg};
        responseData[@"content"] = newDic;
    }
    return responseData?[NSJSONSerialization dataWithJSONObject:responseData options:0 error:nil]:nil;
}

- (NSData *)generateTEXTResponseWithRequest:(NSURLRequest *)request
{
    NSString *documentPath = [FileIOManager documentPath];
    NSString *resourceBundle = [documentPath stringByAppendingPathComponent:@"ResponseData.bundle/MockData"];
    NSString *filePath = [[NSBundle bundleWithPath:resourceBundle] pathForResource:request.URL.path ofType:@"plist"];
    
    NSData *dataStr = [NSData dataWithContentsOfFile:filePath];
    return dataStr;
}

- (NSData *)generateJSONResponseWithRequest:(NSURLRequest *)request
{
    NSString *documentPath = [FileIOManager documentPath];
    NSString *resourceBundle = [documentPath stringByAppendingPathComponent:@"ResponseData.bundle/MockData"];
    NSString *filePath = [[NSBundle bundleWithPath:resourceBundle] pathForResource:request.URL.path ofType:@"plist"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableDictionary *responseData = ((NSDictionary *)dic[@"ResponseData"]).mutableCopy;
    return responseData?[NSJSONSerialization dataWithJSONObject:responseData options:0 error:nil]:nil;
}
@end
