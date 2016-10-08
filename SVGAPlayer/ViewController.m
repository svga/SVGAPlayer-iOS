//
//  ViewController.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "ViewController.h"
#import "SVGA.h"

@interface ViewController ()<SVGAPlayerDelegate>

@property (nonatomic, strong) SVGAPlayer *aPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.aPlayer];
    self.aPlayer.delegate = self;
    self.aPlayer.frame = CGRectMake(0, 0, 320, 100);
    self.aPlayer.loops = 0;
    self.aPlayer.clearsAfterStop = YES;
    SVGAParser *parser = [[SVGAParser alloc] init];
    [parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-me/rose.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
        if (videoItem != nil) {
            self.aPlayer.videoItem = videoItem;
            [self.aPlayer startAnimation];
        }
    } failureBlock:nil];
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
    NSLog(@"finished.");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SVGAParser *parser = [[SVGAParser alloc] init];
        [parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-me/rose.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
            if (videoItem != nil) {
                self.aPlayer.videoItem = videoItem;
                [self.aPlayer startAnimation];
            }
        } failureBlock:nil];
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.aPlayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
}

- (SVGAPlayer *)aPlayer {
    if (_aPlayer == nil) {
        _aPlayer = [[SVGAPlayer alloc] init];
    }
    return _aPlayer;
}

@end
