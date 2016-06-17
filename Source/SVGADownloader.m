//
//  SVGADownloader.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGADownloader.h"
#import "NSData+GZIP.h"
#import <AVKit/AVKit.h>

@implementation SVGADownloader

- (void)loadDataWithURL:(NSURL *)URL completionBlock:(void (^)(NSData *))completionBlock failureBlock:(void (^)(NSError *))failureBlock {
    NSData *cacheData = [self readCacheWithURL:URL];
    if (cacheData != nil) {
        completionBlock(cacheData);
        return;
    }
    [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil || data == nil) {
            if (failureBlock) {
                failureBlock(error);
            }
        }
        else {
            [self saveCacheWithURL:URL data:data];
            if (completionBlock) {
                completionBlock(data);
            }
        }
    }] resume];
}

- (nullable NSData *)readCacheWithURL:(NSURL *)URL {
    NSString *cacheFilePath = [[URL absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    return [NSData dataWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingString:cacheFilePath] options:kNilOptions error:nil];
}

- (void)saveCacheWithURL:(nonnull NSURL *)URL data:(nonnull NSData *)data {
    if (data != nil) {
        NSData *unzipData = [data svga_gunzippedData];
        if (unzipData != nil) {
            data = unzipData;
        }
        NSString *cacheFilePath = [[URL absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        [data writeToFile:[NSTemporaryDirectory() stringByAppendingString:cacheFilePath] atomically:YES];
    }
}

@end
