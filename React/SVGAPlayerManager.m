//
//  SVGAPlayerManager.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/6/15.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAPlayerManager.h"
#import "SVGAPlayer.h"
#import "SVGAParser.h"
#import <objc/runtime.h>

@implementation SVGAPlayer (React)

static int kReactSourceIdentifier;

- (void)loadWithSource:(NSString *)source {
    SVGAParser *parser = [[SVGAParser alloc] init];
    if ([source hasPrefix:@"http"] || [source hasPrefix:@"https"]) {
        [parser parseWithURL:[NSURL URLWithString:source] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self setVideoItem:videoItem];
                [self startAnimation];
            }];
        } failureBlock:nil];
    }
    else {
        NSString *localPath = [[NSBundle mainBundle] pathForResource:source ofType:@"svga"];
        if (localPath != nil) {
            [parser parseWithData:[NSData dataWithContentsOfFile:localPath] cacheKey:source completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self setVideoItem:videoItem];
                    [self startAnimation];
                }];
            } failureBlock:nil];
        }
    }
}

- (void)setSource:(NSString *)source {
    if ([source isKindOfClass:[NSString class]] &&
        ([self source] == nil || ![source isEqualToString:[self source]])) {
        objc_setAssociatedObject(self, &kReactSourceIdentifier, source, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self loadWithSource:source];
    }
}

- (NSString *)source {
    return objc_getAssociatedObject(self, &kReactSourceIdentifier);
}

@end

@implementation SVGAPlayerManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(loops, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(clearsAfterStop, BOOL)

- (UIView *)view {
    return [[SVGAPlayer alloc] init];
}

RCT_EXPORT_METHOD(load:(NSString *)source) {
    if ([self.view isKindOfClass:[SVGAPlayer class]]) {
        [(SVGAPlayer *)self.view loadWithSource:source];
    }
}

@end
