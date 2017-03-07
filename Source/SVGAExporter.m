//
//  SVGAExporter.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/3/7.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAExporter.h"
#import "SVGAVideoEntity.h"
#import "SVGAVideoSpriteEntity.h"
#import "SVGAVideoSpriteFrameEntity.h"
#import "SVGAContentLayer.h"
#import "SVGAVectorLayer.h"

@interface SVGAExporter ()

@property (nonatomic, strong) CALayer *drawLayer;
@property (nonatomic, assign) NSInteger currentFrame;

@end

@implementation SVGAExporter

- (NSArray<UIImage *> *)toImages {
    NSMutableArray *images = [NSMutableArray array];
    if (self.videoItem != nil && self.videoItem.videoSize.width > 0.0 && self.videoItem.videoSize.height > 0.0) {
        [self draw];
        for (NSInteger i = 0; i < self.videoItem.frames; i++) {
            self.currentFrame = i;
            [self update];
            UIGraphicsBeginImageContextWithOptions(self.drawLayer.frame.size, NO, 1.0);
            [self.drawLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            if (image != nil) {
                [images addObject:image];
            }
            UIGraphicsEndImageContext();
        }
    }
    return [images copy];
}

- (void)saveImages:(NSString *)toPath filePrefix:(NSString *)filePrefix {
    if (filePrefix == nil) {
        filePrefix = @"";
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:NULL];
    if (self.videoItem != nil && self.videoItem.videoSize.width > 0.0 && self.videoItem.videoSize.height > 0.0) {
        [self draw];
        for (NSInteger i = 0; i < self.videoItem.frames; i++) {
            self.currentFrame = i;
            [self update];
            UIGraphicsBeginImageContextWithOptions(self.drawLayer.frame.size, NO, 1.0);
            [self.drawLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            if (image != nil) {
                NSData *imageData = UIImagePNGRepresentation(image);
                if (imageData != nil) {
                    [imageData writeToFile:[NSString stringWithFormat:@"%@/%@%ld.png", toPath, filePrefix, (long)i] atomically:YES];
                }
            }
            UIGraphicsEndImageContext();
        }
    }
}

- (void)draw {
    self.drawLayer = [[CALayer alloc] init];
    self.drawLayer.frame = CGRectMake(0, 0, self.videoItem.videoSize.width, self.videoItem.videoSize.height);
    self.drawLayer.masksToBounds = true;
    [self.videoItem.sprites enumerateObjectsUsingBlock:^(SVGAVideoSpriteEntity * _Nonnull sprite, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *bitmap = self.videoItem.images[sprite.imageKey];;
        SVGAContentLayer *contentLayer = [sprite requestLayerWithBitmap:bitmap];
        [self.drawLayer addSublayer:contentLayer];
    }];
    self.currentFrame = 0;
    [self update];
}

- (void)update {
    for (SVGAContentLayer *layer in self.drawLayer.sublayers) {
        if ([layer isKindOfClass:[SVGAContentLayer class]]) {
            [layer stepToFrame:self.currentFrame];
        }
    }
}

@end
