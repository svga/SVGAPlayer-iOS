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
#import <CommonCrypto/CommonDigest.h>

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
    NSString *cacheFilePath = [self MD5String:[URL absoluteString]];
    return [NSData dataWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingString:cacheFilePath] options:kNilOptions error:nil];
}

- (void)saveCacheWithURL:(nonnull NSURL *)URL data:(nonnull NSData *)data {
    if (data != nil) {
        NSData *unzipData = [data svga_gunzippedData];
        if (unzipData != nil) {
            data = unzipData;
        }
        NSString *cacheFilePath = [self MD5String:[URL absoluteString]];
        [data writeToFile:[NSTemporaryDirectory() stringByAppendingString:cacheFilePath] atomically:YES];
    }
}

- (NSString *)MD5String:(NSString *)str {
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end
