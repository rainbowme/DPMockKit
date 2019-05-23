//
//  FileIOManager.h
//  DPMockKit
//
//  Created by Aurora on 2018/9/30.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileIOManager : NSObject
+ (NSString *)documentPath;
+ (void)createFolder:(NSString*)strPath;
+ (void)correctFilePath:(NSString*)filePath;
@end
