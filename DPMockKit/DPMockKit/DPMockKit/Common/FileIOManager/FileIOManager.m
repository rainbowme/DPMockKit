//
//  FileIOManager.m
//  DPMockKit
//
//  Created by Aurora on 2018/9/30.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "FileIOManager.h"

@implementation FileIOManager

+ (NSString *)documentPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)createFolder:(NSString*)strPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:strPath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)correctFilePath:(NSString*)filePath
{
    //filePath = [filePath stringByDeletingLastPathComponent];
    [self createFolder:filePath];
}
@end
