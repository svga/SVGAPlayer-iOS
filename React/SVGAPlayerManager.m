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

@interface SVGAPlayer (React)<SVGAPlayerDelegate>

@property(nonatomic, copy) NSString *source;
@property(nonatomic, copy) NSString *currentState;
@property(nonatomic, assign) NSInteger toFrame;
@property(nonatomic, assign) NSInteger toPercentage;
@property(nonatomic, copy) RCTBubblingEventBlock onFinished;
@property(nonatomic, copy) RCTBubblingEventBlock onFrame;
@property(nonatomic, copy) RCTBubblingEventBlock onPercentage;

@end

@implementation SVGAPlayer (React)

static int kReactSourceIdentifier;
static int kReactCurrentStateIdentifier;
static int kReactOnFinishedIdentifier;
static int kReactOnFrameIdentifier;
static int kReactOnPercentageIdentifier;

- (void)loadWithSource:(NSString *)source {
    SVGAParser *parser = [[SVGAParser alloc] init];
    if ([source hasPrefix:@"http"] || [source hasPrefix:@"https"]) {
        [parser parseWithURL:[NSURL URLWithString:source]
             completionBlock:^(SVGAVideoEntity *_Nullable videoItem) {
               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [self setVideoItem:videoItem];
                 [self startAnimation];
               }];
             }
                failureBlock:nil];
    } else {
        NSString *localPath = [[NSBundle mainBundle] pathForResource:source ofType:@"svga"];
        if (localPath != nil) {
            [parser parseWithData:[NSData dataWithContentsOfFile:localPath]
                         cacheKey:source
                  completionBlock:^(SVGAVideoEntity *_Nonnull videoItem) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                      [self setVideoItem:videoItem];
                      [self startAnimation];
                    }];
                  }
                     failureBlock:nil];
        }
    }
}

- (void)setSource:(NSString *)source {
    if ([source isKindOfClass:[NSString class]] && ([self source] == nil || ![source isEqualToString:[self source]])) {
        objc_setAssociatedObject(self, &kReactSourceIdentifier, source, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self loadWithSource:source];
    }
}

- (NSString *)source {
    return objc_getAssociatedObject(self, &kReactSourceIdentifier);
}

- (void)setCurrentState:(NSString *)currentState {
    if ([currentState isKindOfClass:[NSString class]] &&
        ([self currentState] == nil || ![currentState isEqualToString:[self currentState]])) {
        objc_setAssociatedObject(self, &kReactCurrentStateIdentifier, currentState, OBJC_ASSOCIATION_COPY_NONATOMIC);
        if ([currentState isEqualToString:@"start"]) {
            [self startAnimation];
        } else if ([currentState isEqualToString:@"pause"]) {
            [self pauseAnimation];
        } else if ([currentState isEqualToString:@"stop"]) {
            [self stopAnimation];
        } else if ([currentState isEqualToString:@"clear"]) {
            [self stopAnimation];
            [self clear];
        }
    }
}

- (NSString *)currentState {
    return objc_getAssociatedObject(self, &kReactCurrentStateIdentifier);
}

- (void)setOnFinished:(RCTBubblingEventBlock)onFinished {
    objc_setAssociatedObject(self, &kReactOnFinishedIdentifier, onFinished, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RCTBubblingEventBlock)onFinished {
    return objc_getAssociatedObject(self, &kReactOnFinishedIdentifier);
}

- (void)setOnFrame:(RCTBubblingEventBlock)onFrame {
    objc_setAssociatedObject(self, &kReactOnFrameIdentifier, onFrame, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RCTBubblingEventBlock)onFrame {
    return objc_getAssociatedObject(self, &kReactOnFrameIdentifier);
}

- (void)setOnPercentage:(RCTBubblingEventBlock)onPercentage {
    objc_setAssociatedObject(self, &kReactOnPercentageIdentifier, onPercentage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RCTBubblingEventBlock)onPercentage {
    return objc_getAssociatedObject(self, &kReactOnPercentageIdentifier);
}

- (void)setToFrame:(NSInteger)toFrame {
    if (toFrame < 0) {
        return;
    }
    [self stepToFrame:toFrame andPlay:[self.currentState isEqualToString:@"play"]];
}

- (NSInteger)toFrame {
    return 0;
}

- (void)setToPercentage:(NSInteger)toPercentage {
    if (toPercentage < 0) {
        return;
    }
    [self stepToPercentage:toPercentage andPlay:[self.currentState isEqualToString:@"play"]];
}

- (NSInteger)toPercentage {
    return 0.0;
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
    if (self.onFinished) {
        self.onFinished(@{});
    }
}

- (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame {
    if (self.onFrame) {
        self.onFrame(@{ @"value" : @(frame) });
    }
}

- (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage {
    if (self.onPercentage) {
        self.onPercentage(@{ @"value" : @(percentage) });
    }
}

@end

@interface SVGAPlayerManager ()

@end

@implementation SVGAPlayerManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(loops, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(clearsAfterStop, BOOL)
RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(currentState, NSString)
RCT_EXPORT_VIEW_PROPERTY(toFrame, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(toPercentage, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(onFinished, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFrame, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPercentage, RCTBubblingEventBlock)

- (UIView *)view {
    SVGAPlayer *aPlayer = [[SVGAPlayer alloc] init];
    aPlayer.delegate = aPlayer;
    return aPlayer;
}

@end
