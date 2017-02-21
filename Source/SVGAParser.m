//
//  SVGAParser.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGAParser.h"
#import "SVGAVideoEntity.h"
#import <SSZipArchive/SSZipArchive.h>
#import <CommonCrypto/CommonDigest.h>

@interface SVGAParser ()

@end

@implementation SVGAParser

- (void)parseWithURL:(nonnull NSURL *)URL
     completionBlock:(void ( ^ _Nonnull )(SVGAVideoEntity * _Nullable videoItem))completionBlock
        failureBlock:(void ( ^ _Nullable)(NSError * _Nullable error))failureBlock {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectory:[self cacheKey:URL]]]) {
        [self parseWithCacheKey:[self cacheKey:URL] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
            if (completionBlock) {
                completionBlock(videoItem);
            }
        } failureBlock:^(NSError * _Nonnull error) {
            [self clearCache:[self cacheKey:URL]];
            if (failureBlock) {
                failureBlock(error);
            }
        }];
        return;
    }
    [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && data != nil) {
            [self parseWithData:data cacheKey:[self cacheKey:URL] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                if (completionBlock) {
                    completionBlock(videoItem);
                }
            } failureBlock:^(NSError * _Nonnull error) {
                [self clearCache:[self cacheKey:URL]];
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        }
        else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }] resume];
}

- (void)parseWithCacheKey:(nonnull NSString *)cacheKey
          completionBlock:(void ( ^ _Nullable)(SVGAVideoEntity * _Nonnull videoItem))completionBlock
             failureBlock:(void ( ^ _Nullable)(NSError * _Nonnull error))failureBlock {
    [[NSOperationQueue new] addOperationWithBlock:^{
        SVGAVideoEntity *cacheItem = [SVGAVideoEntity readCache:cacheKey];
        if (cacheItem != nil) {
            if (completionBlock) {
                completionBlock(cacheItem);
            }
            return;
        }
        NSString *cacheDir = [self cacheDirectory:cacheKey];
        NSError *err;
        NSData *JSONData = [NSData dataWithContentsOfFile:[cacheDir stringByAppendingString:@"/movie.spec"]];
        if (JSONData != nil) {
            NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&err];
            if ([JSONObject isKindOfClass:[NSDictionary class]]) {
                SVGAVideoEntity *videoItem = [[SVGAVideoEntity alloc] initWithJSONObject:JSONObject cacheDir:cacheDir];
                [videoItem resetImagesWithJSONObject:JSONObject];
                [videoItem resetSpritesWithJSONObject:JSONObject];
                [videoItem saveCache:cacheKey];
                if (completionBlock) {
                    completionBlock(videoItem);
                }
            }
        }
        else {
            if (failureBlock) {
                failureBlock([NSError errorWithDomain:NSFilePathErrorKey code:-1 userInfo:nil]);
            }
        }
    }];
}

- (void)clearCache:(nonnull NSString *)cacheKey {
    NSString *cacheDir = [self cacheDirectory:cacheKey];
    [[NSFileManager defaultManager] removeItemAtPath:cacheDir error:NULL];
}

- (void)parseWithData:(nonnull NSData *)data
             cacheKey:(nonnull NSString *)cacheKey
      completionBlock:(void ( ^ _Nullable)(SVGAVideoEntity * _Nonnull videoItem))completionBlock
         failureBlock:(void ( ^ _Nullable)(NSError * _Nonnull error))failureBlock {
    [[NSOperationQueue new] addOperationWithBlock:^{
        SVGAVideoEntity *cacheItem = [SVGAVideoEntity readCache:cacheKey];
        if (cacheItem != nil) {
            if (completionBlock) {
                completionBlock(cacheItem);
            }
            return;
        }
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingFormat:@"%u.svga", arc4random()];
        if (data != nil) {
            [data writeToFile:tmpPath atomically:YES];
            NSString *cacheDir = [self cacheDirectory:cacheKey];
            if ([cacheDir isKindOfClass:[NSString class]]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:nil];
                [SSZipArchive unzipFileAtPath:tmpPath toDestination:[self cacheDirectory:cacheKey] progressHandler:nil completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
                    if (error != nil) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }
                    else {
                        NSError *err;
                        NSData *JSONData = [NSData dataWithContentsOfFile:[cacheDir stringByAppendingString:@"/movie.spec"]];
                        if (JSONData != nil) {
                            NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&err];
                            if ([JSONObject isKindOfClass:[NSDictionary class]]) {
                                SVGAVideoEntity *videoItem = [[SVGAVideoEntity alloc] initWithJSONObject:JSONObject cacheDir:cacheDir];
                                [videoItem resetImagesWithJSONObject:JSONObject];
                                [videoItem resetSpritesWithJSONObject:JSONObject];
                                [videoItem saveCache:cacheKey];
                                if (completionBlock) {
                                    completionBlock(videoItem);
                                }
                            }
                        }
                        else {
                            if (failureBlock) {
                                failureBlock([NSError errorWithDomain:NSFilePathErrorKey code:-1 userInfo:nil]);
                            }
                        }
                    }
                }];
            }
            else {
                if (failureBlock) {
                    failureBlock([NSError errorWithDomain:NSFilePathErrorKey code:-1 userInfo:nil]);
                }
            }
        }
        else {
            if (failureBlock) {
                failureBlock([NSError errorWithDomain:@"Data Error" code:-1 userInfo:nil]);
            }
        }
    }];
}

- (nonnull NSString *)cacheKey:(NSURL *)URL {
    return [self MD5String:URL.absoluteString];
}

- (nullable NSString *)cacheDirectory:(NSString *)cacheKey {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [cacheDir stringByAppendingFormat:@"/%@", cacheKey];
}

- (NSString *)MD5String:(NSString *)str {
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
