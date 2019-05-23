//
//  DPMessagePiple.m
//  DPMockKit
//
//  Created by Aurora on 2018/9/11.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "DPMessagePiple.h"
#import <UIKit/UIKit.h>

@interface NSObject (DefineMSG)
- (void)pipleType:(NSInteger)msgType messageDidReceived:(id)message;
@end
@implementation NSObject (DefineMSG)
@end

void messageTypeAndContent(MessageType msgType, id content) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSObject *delegate = [UIApplication sharedApplication].delegate;
        if(delegate && [delegate respondsToSelector:@selector(pipleType:messageDidReceived:)]) {
            [delegate pipleType:msgType messageDidReceived:content];
        }
    });
}

void logWithLevelAndFormat(MessageType msgType, NSString *format, ...)
{
    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    messageTypeAndContent(msgType, message);
}
