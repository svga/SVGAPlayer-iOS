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
                SVGAVideoEntity *videoItem = [[SVGAVideoEntity alloc] init];
                videoItem.videoSize = CGSizeMake(310, 320);
                // parse images
                NSMutableDictionary<NSString *, UIImage *> *images = [[NSMutableDictionary alloc] init];
                NSDictionary<NSString *, NSString *> *JSONImages = JSONObject[@"images"];
                if ([JSONImages isKindOfClass:[NSDictionary class]]) {
                    [JSONImages enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[NSString class]]) {
                            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:obj options:kNilOptions];
                            if (imageData != nil) {
                                UIImage *image = [[UIImage alloc] initWithData:imageData scale:2.0];
                                if (image != nil) {
                                    [images setObject:image forKey:key];
                                }
                            }
                        }
                    }];
                }
                videoItem.images = images;
                // parse sprites
                NSMutableArray<SVGAVideoSpriteEntity *> *sprites = [[NSMutableArray alloc] init];
                NSArray<NSDictionary *> *JSONSprites = JSONObject[@"sprites"];
                if ([JSONSprites isKindOfClass:[NSArray class]]) {
                    [JSONSprites enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            NSString *sKey = obj[@"sKey"];
                            NSArray<NSDictionary *> *JSONFrames = obj[@"frames"];
                            if ([sKey isKindOfClass:[NSString class]] && [JSONFrames isKindOfClass:[NSArray class]]) {
                                SVGAVideoSpriteEntity *spriteItem = [[SVGAVideoSpriteEntity alloc] init];
                                spriteItem.sKey = sKey;
                                NSMutableArray<SVGAVideoSpriteFrameEntity *> *frames = [[NSMutableArray alloc] init];
                                [JSONFrames enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([obj isKindOfClass:[NSDictionary class]]) {
                                        [frames addObject:[[SVGAVideoSpriteFrameEntity alloc] initWithJSONObject:obj]];
                                    }
                                }];
                                spriteItem.frames = frames;
                                [sprites addObject:spriteItem];
                            }
                        }
                    }];
                }
                videoItem.sprites = sprites;
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
