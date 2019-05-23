//
//  ViewController.m
//  DPMockKitDemo
//
//  Created by Aurora on 2018/8/30.
//  Copyright © 2018年 Jerry.GI. All rights reserved.
//

#import "ViewController.h"
#import <DPMockKit/DPRequestMonitor.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/pic/item/72f082025aafa40fafb5fbc1a664034f78f019be.jpg"]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        NSData *data = [NSData dataWithContentsOfURL:location];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            CGRect frame = CGRectZero;
            frame.size = [UIScreen mainScreen].bounds.size;
            imageView.frame = frame;
            
            [[UIApplication sharedApplication].keyWindow addSubview:imageView];
        });
    }];
    [downloadTask resume];
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.xinhuanet.com/politics/leaders/2018-09/26/c_1123485137.htm"]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
