//
//  SVGAVideoMemoryCache.m
//  SVGAPlayer
//
//  Created by MOMO@song.meng on 2020/7/4.
//  Copyright © 2020 UED Center. All rights reserved.
//
//  用于处理SVGA内存缓存
//

#define safe_async_to_main(block) \
if ([NSThread isMainThread]) { \
    block(); \
} else { \
    dispatch_async(dispatch_get_main_queue(), block); \
}

#import "SVGAVideoMemoryCache.h"

@interface SVGAVideoMemoryCache()<NSCacheDelegate>

@property (nonatomic, strong) NSCache *strongCache;
@property (nonatomic, strong) NSMapTable *weakCache;
@property (nonatomic, readwrite) NSUInteger totalMemoryCost;
@property (nonatomic, strong) dispatch_semaphore_t  dispatchLock;
/// 内存占用Tip
@property (nonatomic, strong) UILabel *memoryCostTip;

@end

@implementation SVGAVideoMemoryCache

static SVGAVideoMemoryCache *instance;
+ (instancetype)sharedCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SVGAVideoMemoryCache alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self cutomeInit];
    }
    
    return self;
}

- (void)cutomeInit {
    _weakCache = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:128];
    _dispatchLock = dispatch_semaphore_create(1);
    _memoryCacheEnable = YES;
    _clearInBackground = YES;
    
#ifdef DEBUG
    _showMemoryCostTip = YES;
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - public

- (void)setObject:(SVGAVideoEntity *)object forKey:(id)key {
    if (object && key) {
        [self saveStrongCache:object forKey:key];
        
        dispatch_semaphore_wait(_dispatchLock, DISPATCH_TIME_FOREVER);
        [self.weakCache setObject:object forKey:key];
        dispatch_semaphore_signal(_dispatchLock);
    }
}

- (SVGAVideoEntity *)objectForKey:(id)key {
    id obj = [self.strongCache objectForKey:key];
    if (!obj) {
        obj = [self.weakCache objectForKey:key];
        if ([obj isKindOfClass:[SVGAVideoEntity class]]) {
            [self saveStrongCache:obj forKey:key];
            return obj;
        }
    }
    
    return nil;
}

- (void)removeAllObjects {
    if (_memoryCacheEnable) {
        [self.strongCache removeAllObjects];
        
        dispatch_semaphore_wait(_dispatchLock, DISPATCH_TIME_FOREVER);
        NSUInteger cost = 0;
        NSEnumerator *enu = self.weakCache.objectEnumerator;
        SVGAVideoEntity *ent;
        while ((ent = enu.nextObject)) {
            cost += ent.memoryCost;
        }
        self.totalMemoryCost = cost;
        dispatch_semaphore_signal(_dispatchLock);
    }
}

- (void)removeObjectForKey:(id)key {
    SVGAVideoEntity * ent = [self objectForKey:key];
    if (ent) {
        self.totalMemoryCost -= ent.memoryCost;
    }
    
    [self.strongCache removeObjectForKey:key];
}

- (void)updateCost:(NSInteger)cost {
    self.totalMemoryCost += cost;
}

- (void)didEnterBackground {
    if (_clearInBackground) {
        [self removeAllObjects];
    }
}

#pragma mark - ptivate

- (SVGAVideoEntity *)readStrongCache:(id)key {
    if (_memoryCacheEnable) {
        return [self.strongCache objectForKey:key];
    }
    return nil;
}

- (void)saveStrongCache:(SVGAVideoEntity *)object forKey:(id)key {
    if (_memoryCacheEnable) {
        if ([self.strongCache objectForKey:key]) {
            return;
        }
        NSUInteger cost = object.memoryCost;
        [self.strongCache setObject:object forKey:key cost:cost];
        self.totalMemoryCost += cost;
    }
}


#pragma mark - NSCache delegate

/// NSCache将要移除元素
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    SVGAVideoEntity * ent = (SVGAVideoEntity *)obj;
    self.totalMemoryCost -= ent.memoryCost;
}

#pragma mark - setter & getter

- (void)setTotalMemoryCost:(NSUInteger)totalMemoryCost {
    _totalMemoryCost = totalMemoryCost;
    
    if (_showMemoryCostTip) {
        void(^showTip)() = ^{
            NSString * tip = [NSString stringWithFormat:@"svga cost: %.2fM",_totalMemoryCost/1024.f/1024.f];
            self.memoryCostTip.text = tip;
            if (!self.memoryCostTip.superview) {
                [[UIApplication sharedApplication].keyWindow addSubview:self.memoryCostTip];
            }
        };
        safe_async_to_main(showTip);
    } else if (self.memoryCostTip && self.memoryCostTip.superview) {
        void(^removeView)() = ^{
            [self.memoryCostTip removeFromSuperview];
        };
        safe_async_to_main(removeView);
    }
}

- (UILabel *)memoryCostTip {
    if (!_memoryCostTip) {
        _memoryCostTip = [[UILabel alloc] initWithFrame:self.memoryCostTipFrame];
        _memoryCostTip.textColor = [UIColor redColor];
        _memoryCostTip.font = [UIFont systemFontOfSize:12];
    }
    return _memoryCostTip;
}

- (CGRect)memoryCostTipFrame {
    if (CGRectEqualToRect(_memoryCostTipFrame, CGRectZero)) {
        _memoryCostTipFrame = CGRectMake(10, [UIApplication sharedApplication].keyWindow.bounds.size.height - 75, 150, 15);
    }
    return _memoryCostTipFrame;
}

- (void)setMemoryCostLimit:(NSUInteger)memoryCostLimit {
    _memoryCostLimit = memoryCostLimit;
    self.strongCache.totalCostLimit = memoryCostLimit;
}

- (NSCache *)strongCache {
    if (!_strongCache) {
        _strongCache = [NSCache new];
    }
    return _strongCache;
}

@end
