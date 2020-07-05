//
//  SVGAVideoEntity+mm.m
//  SVGAPlayer
//
//  Created by MOMO@song.meng on 2020/7/4.
//  Copyright © 2020 UED Center. All rights reserved.
//

#import "SVGAVideoEntity+mm.h"
#import "SVGAVideoMemoryCache.h"
#import <objc/runtime.h>

@interface SVGAVideoEntity()

@property (nonatomic, assign) NSUInteger mmMemoryCost;

@end


@implementation SVGAVideoEntity (mm)
static char mmMemoryCostKey;

/// 方法重写
+ (SVGAVideoEntity *)readCache:(NSString *)cacheKey {
    return [[SVGAVideoMemoryCache sharedCache] objectForKey:cacheKey];
}

/// 方法重写
- (void)saveCache:(NSString *)cacheKey {
    [[SVGAVideoMemoryCache sharedCache] setObject:self forKey:cacheKey];
}



/// 返回内存占用情况
- (NSUInteger)getMemoryCost {
    id obj = objc_getAssociatedObject(self, &mmMemoryCostKey);
    if (obj) {
        return self.mmMemoryCost;
    }
    
    [self resetMemoryCost];
    NSLog(@"======= %lu M", self.mmMemoryCost/1024/1024);
    return  self.mmMemoryCost;
}

/// 重置内存占用计算
- (void)resetMemoryCost {
    if (!self.images) {
        return;
    }
    
    [self.images enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImage class]]) {
            NSUInteger cost = [self costForImage:obj];
            self.mmMemoryCost += cost;
        }
    }];
    NSLog(@"------ %lu , image count:%ld", self.mmMemoryCost, self.images.count);
}

- (NSUInteger)costForImage:(UIImage *)image {
        CGImageRef imageRef = image.CGImage;
        if (!imageRef) {
            return 0;
        }
        NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
        NSUInteger frameCount = image.images.count > 0 ? image.images.count : 1;
        return bytesPerFrame * frameCount;
}

- (void)setMmMemoryCost:(NSUInteger)mmMemoryCost {
    objc_setAssociatedObject(self, &mmMemoryCostKey, @(mmMemoryCost), OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)mmMemoryCost {
    id obj = objc_getAssociatedObject(self, &mmMemoryCostKey);
    if ([obj respondsToSelector:@selector(unsignedIntegerValue)]) {
        return [obj unsignedIntegerValue];
    }
    return 0;
}


@end
