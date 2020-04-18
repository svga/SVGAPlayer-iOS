//
//  SVGAVideoEntityMemoryCache.m
//  SVGAPlayer
//
//  Created by song.meng on 2020/4/18.
//  Copyright © 2020 UED Center. All rights reserved.
//

#import "SVGAVideoEntityMemoryCache.h"


#define MemoryLock(lock)    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define MemoryUnLock(lock)  dispatch_semaphore_signal(lock);


@interface SVGAVideoEntityMemoryCache()

@property (nonatomic, strong) NSCache *strongCache;
@property (nonatomic, strong) NSMapTable *weakCache;
@property (nonatomic, strong) dispatch_semaphore_t  lock;
@property (nonatomic, assign) BOOL  startedAutoClear;

@end

@implementation SVGAVideoEntityMemoryCache

static SVGAVideoEntityMemoryCache * instance = nil;
+ (instancetype)defaultCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)clearCache
{
    [[self defaultCache] clearCache];
}

+ (void)setVideoEntity:(SVGAVideoEntity *)object forKey:(id)key
{
    [[self defaultCache] setVideoEntity:object forKey:key];
}

+ (void)removeVideoEntityWithKey:(id)key
{
    [[self defaultCache] removeVideoEntityWithKey:key];
}

+ (id)videoEntityForKey:(id)key
{
    return [[self defaultCache] videoEntityForKey:key];
}

#pragma mark - instance

- (instancetype)init
{
    if (self = [super init]) {
        _strongCache = [[NSCache alloc] init];
        _weakCache = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                               valueOptions:NSPointerFunctionsWeakMemory
                                                   capacity:128];
        _lock = dispatch_semaphore_create(1);
        _useStrongCache = YES;
        _maxPixelLimit = 50 * 1024 * 1024 / 4;
        _autoClearInterval = 0;
    }
    return self;
}

- (void)clearCache
{
    [_strongCache removeAllObjects];
}

- (void)setVideoEntity:(SVGAVideoEntity *)object forKey:(id)key
{
    if (!key) {
        return;
    }
    
    if ([object isKindOfClass:[SVGAVideoEntity class]]) {
        if (_useStrongCache && (_maxPixelLimit == 0 || object.totalPixelCount < _maxPixelLimit)) {
            [_strongCache setObject:object forKey:key];
        }
        
        MemoryLock(_lock);
        [_weakCache setObject:object forKey:key];
        MemoryUnLock(_lock);
    } else {
        [self removeVideoEntityWithKey:key];
    }
}

- (void)removeVideoEntityWithKey:(id)key
{
    if (key) {
        [self.strongCache removeObjectForKey:key];
    }
}

- (SVGAVideoEntity *)videoEntityForKey:(id)key
{
    if (!key) {
        return nil;
    }
    
    SVGAVideoEntity * object = [_strongCache objectForKey:key];
    if (!object) {
        MemoryLock(_lock);
        object = [_weakCache objectForKey:key];
        MemoryUnLock(_lock);
        if (object && _useStrongCache && (_maxPixelLimit == 0 || object.totalPixelCount < _maxPixelLimit)) {
            [_strongCache setObject:object forKey:key];
        }
    }
    return object;
}

#pragma mark - auto clear
- (void)setAutoClearInterval:(NSUInteger)autoClearInterval
{
    if (autoClearInterval < 10) {
        autoClearInterval = 10;
    }
    
    _autoClearInterval = autoClearInterval;
    [self clearCache];
    
    if (!_startedAutoClear) {
        [self _autoClear];
    }
}

- (void)_autoClear
{
    _startedAutoClear = YES;
    __weak typeof(self) weak_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoClearInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weak_self) s = weak_self;
        if (!s) {
            return;
        }
        
        [s clearCache];
        [s _autoClear];
    });
    
}

@end
