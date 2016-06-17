//
//  SVGADownloader.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGADownloader.h"
#import <AVKit/AVKit.h>

@implementation SVGADownloader

- (void)loadDataWithURL:(NSURL *)URL completionBlock:(void (^)(NSData *))completionBlock failureBlock:(void (^)(NSError *))failureBlock {
    [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil || data == nil) {
            if (failureBlock) {
                failureBlock(error);
            }
        }
        else {
            if (completionBlock) {
                completionBlock(data);
            }
        }
    }] resume];
}

@end
