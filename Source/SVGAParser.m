//
//  SVGAParser.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGAParser.h"
#import "SVGAVideoEntity.h"
#import "SVGADownloader.h"

@interface SVGAParser ()

@property (nonatomic, strong) SVGADownloader *downloader;

@end

@implementation SVGAParser

- (void)parseWithURL:(nonnull NSURL *)URL completionBlock:(void ( ^ _Nonnull )(SVGAVideoEntity * _Nullable videoItem))completionBlock {
    [self.downloader loadDataWithURL:URL completionBlock:^(NSData *data) {
        if (completionBlock) {
            completionBlock([self parseWithData:data]);
        }
    } failureBlock:^(NSError *error) {
        // failure
    }];
}

- (nullable SVGAVideoEntity *)parseWithData:(nonnull NSData *)data {
    if (data != nil) {
        NSError *err;
        NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (err == nil) {
            if ([JSONObject isKindOfClass:[NSDictionary class]]) {
                SVGAVideoEntity *videoItem = [[SVGAVideoEntity alloc] initWithJSONObject:JSONObject];
                [videoItem resetImagesWithJSONObject:JSONObject];
                [videoItem resetSpritesWithJSONObject:JSONObject];
                return videoItem;
            }
        }
    }
    return nil;
}

- (SVGADownloader *)downloader {
    if (_downloader == nil) {
        _downloader = [[SVGADownloader alloc] init];
    }
    return _downloader;
}

@end
