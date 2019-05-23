//
//  DPDataSaver.m
//  DPMockKit
//
//  Created by Aurora on 2018/9/3.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "DPDataSaver.h"
#import "ImportFromOtherModule.h"
#import "FileIOManager.h"


// 原定在另一个文件，目的在于引入工程成种的加解密模块，特殊原因不在此实现。
#define HMDataSecurityManager [ImportClassMethod DataSecurityManagerI]
#define HMBase64 [ImportClassMethod Base64I]
#define HMDESWrapper [ImportClassMethod DESWrapperI]


@interface DPDataSaver ()
{
    NSString *des3Key;
}
@end

@implementation DPDataSaver

+ (instancetype)defaultInstance {
    static DPDataSaver *dataSaver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataSaver = [[DPDataSaver alloc] init];
    });
    return dataSaver;
}

- (void)writeToFile:(NSString *)filePath withData:(id)data {
    NSString *path = [filePath stringByDeletingLastPathComponent];
    [FileIOManager correctFilePath:path];
    
    [data writeToFile:filePath atomically:YES];
}

- (NSString *)writeConfigFile:(NSURLRequest *)request data:(id)data {
    NSString *documentPath = [FileIOManager documentPath];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"ResponseData.bundle/MockData"];
    filePath = [filePath stringByAppendingPathComponent:request.URL.path];
    NSString *cfgFilePath = [filePath stringByAppendingPathExtension:@"plist"];
    NSMutableArray *dataArray = [NSMutableArray arrayWithContentsOfFile:cfgFilePath];
    if(!dataArray) {
        dataArray  = [NSMutableArray array];
    }
    [dataArray addObject:@{@"RequestParam":@"",@"ResponseData":data}];
    [self writeToFile:cfgFilePath withData:dataArray];
    
    return cfgFilePath;
}

- (void)storeWithRequest:(NSURLRequest *)request data:(id)data {
    [self writeConfigFile:request data:data];
}

- (void)storeWithRequest:(NSURLRequest *)request text:(id)data {
    [self writeConfigFile:request data:data];
}

- (NSURL *)storeWithRequest:(NSURLRequest *)request fileURL:(NSURL *)fileURL {
    // 文件路径
    NSString *retriPath = [NSString stringWithFormat:@"ResponseData.bundle/MockData%@", request.URL.path];
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@", [FileIOManager documentPath], retriPath];
    NSString *path = [targetPath stringByDeletingLastPathComponent];
    [FileIOManager correctFilePath:path];
    NSURL *destURL = [NSURL fileURLWithPath:targetPath isDirectory:NO];
    
    NSError *error = nil;
    if(![[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:destURL error:&error];
    }
    if(!error) {
        [self writeConfigFile:request data:retriPath];
        return destURL;
    }
    return nil;
}

- (NSData *)storeWithRequest:(NSURLRequest *)request des3key:(id)data {
    NSDictionary *resultData = nil;
    NSString *retriPath = [NSString stringWithFormat:@"ResponseData.bundle/MockData%@", request.URL.path];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [FileIOManager documentPath], retriPath];
    filePath = [filePath stringByAppendingPathExtension:@"plist"];
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    // 解密body，得到一个字串
    NSMutableDictionary *tmpData = response.mutableCopy;
    NSData *encriptData = [tmpData[@"content"][@"body"] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decriptData = [HMBase64 decodeData:encriptData];
    decriptData = [HMDataSecurityManager decryptData:decriptData publicKey:[HMDataSecurityManager testPublicKey]];
    tmpData[@"content"] = [tmpData[@"content"] mutableCopy];
    tmpData[@"content"][@"body"] = [[NSString alloc] initWithData:decriptData encoding:NSUTF8StringEncoding];
    des3Key = tmpData[@"content"][@"body"];
    
    // 组装数据
    resultData = @{@"ResponseData":tmpData, @"Name":@"3DesKey"};
    [self writeToFile:filePath withData:resultData];
    
    
    // 重新加密返回客户端
    data = [HMDataSecurityManager encryptData:decriptData privateKey:[HMDataSecurityManager testPrivateKey]];
    tmpData[@"content"][@"body"] = [HMBase64 stringByEncodingData:data];
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:tmpData options:0 error:nil];
    return responseData;
}

- (NSData *)storeWithRequest:(NSURLRequest *)request encryptData:(id)data {
    NSString *retriPath = [NSString stringWithFormat:@"ResponseData.bundle/MockData%@", request.URL.path];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [FileIOManager documentPath], retriPath];
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSMutableDictionary *tmpData = response.mutableCopy;
    
    // 接口结果, 1：明文， 2：密文。
    NSInteger contentType =  [tmpData[@"contentType"] integerValue];
    if(contentType==2) {
        // 解密body，得到一个字串
        NSDictionary *content = tmpData[@"content"];
        NSData *encriptData = [content[@"returnEncMsg"] dataUsingEncoding:NSUTF8StringEncoding];
        encriptData = [HMBase64 decodeData:encriptData];
        NSData *decriptData = [HMDESWrapper decryptData:encriptData key:[des3Key dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 去除null
        NSString *str = [[NSString alloc] initWithData:decriptData encoding:NSUTF8StringEncoding];
        str = [str stringByReplacingOccurrencesOfString:@":null" withString:@":\"empty_value\""];
        
        tmpData[@"content"] = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
    
    // 组装数据
    filePath = [filePath stringByAppendingPathExtension:@"plist"];
    NSMutableArray *dataArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    if(!dataArray) {
        dataArray  = [NSMutableArray array];
    }
    [dataArray addObject:@{@"RequestParam":@"",@"ResponseData":tmpData}];
    [self writeToFile:filePath withData:dataArray];
    
    // 数据重新加密返回
    return nil;
}

- (void)storeWithRequest:(NSURLRequest *)request jsonData:(id)data {
    NSString *retriPath = [NSString stringWithFormat:@"ResponseData.bundle/MockData%@", request.URL.path];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [FileIOManager documentPath], retriPath];
    filePath = [filePath stringByAppendingPathExtension:@"plist"];
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *dataArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    if(!dataArray) {
        dataArray  = [NSMutableArray array];
    }
    [dataArray addObject:@{@"RequestParam":@"",@"ResponseData":response}];
    
    [self writeToFile:filePath withData:dataArray];
}
@end
