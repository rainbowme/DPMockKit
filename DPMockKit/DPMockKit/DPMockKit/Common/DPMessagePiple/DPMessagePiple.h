//
//  DPMessagePiple.h
//  DPMockKit
//
//  Created by Aurora on 2018/9/11.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

// - (void)pipleMessageType:(NSInteger)msgType didReceived:(id)message
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MessageType) {
    MT_Logger,
    MT_DicInfo,
};

void logWithLevelAndFormat(MessageType msgType, NSString *format, ...);
void messageTypeAndContent(MessageType msgType, id content);

#define NSLogNetRequest(...)    logWithLevelAndFormat(MT_Logger, __VA_ARGS__)
#define NSDicInfomation(...)    messageTypeAndContent(MT_DicInfo, __VA_ARGS__)
#define NSLogTemporary(...)     logWithLevelAndFormat(MT_Logger, __VA_ARGS__)
