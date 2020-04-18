//
//  SVGAVideoEntityMemoryCache.h
//  SVGAPlayer
//
//  Created by song.meng on 2020/4/18.
//  Copyright © 2020 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGAVideoEntity.h"
NS_ASSUME_NONNULL_BEGIN

@interface SVGAVideoEntityMemoryCache : NSObject

// 内存缓存最大像素数限制，默认为：50 * 1024 * 1024 / 4，大约在内存中占用50M
@property (nonatomic, assign) NSUInteger maxPixelLimit;
//自动清理周期，默认0，即不清理，最小限制10s
@property (nonatomic, assign) NSUInteger autoClearInterval;
// 是否使用强引用缓存，默认YES
@property (nonatomic, assign) BOOL useStrongCache;

+ (instancetype)defaultCache;

+ (void)clearCache;

+ (void)setVideoEntity:(SVGAVideoEntity *)object forKey:(id)key;
+ (void)removeVideoEntityWithKey:(id)key;
+ (SVGAVideoEntity *)videoEntityForKey:(id)key;


@end

NS_ASSUME_NONNULL_END
