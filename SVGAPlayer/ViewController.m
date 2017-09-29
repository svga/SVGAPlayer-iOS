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

static SVGAParser *parser;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.aPlayer];
    self.aPlayer.delegate = self;
    self.aPlayer.frame = CGRectMake(0, 0, 320, 320);
    self.aPlayer.loops = 0;
    self.aPlayer.clearsAfterStop = YES;
    parser = [[SVGAParser alloc] init];
    [self onChange:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.aPlayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (IBAction)onChange:(id)sender {
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EmptyState" ofType:@"svga"]
                                          options:kNilOptions
                                            error:NULL];
    [parser parseWithData:data
                 cacheKey:@"EmptyState" completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                     if (videoItem != nil) {
                         self.aPlayer.videoItem = videoItem;
                         [self.aPlayer startAnimation];
                     }
                 } failureBlock:nil];
    
//    NSArray *items = @[
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/EmptyState.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/HamburgerArrow.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/PinJump.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/TwitterHeart.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/Walkthrough.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/angel.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/halloween.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/kingset.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/posche.svga?raw=true",
//                       @"https://github.com/yyued/SVGA-Samples/blob/master/rose.svga?raw=true",
//                       ];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [parser parseWithURL:[NSURL URLWithString:items[arc4random() % 10]]
//         completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
//             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        if (videoItem != nil) {
//            self.aPlayer.videoItem = videoItem;
//            [self.aPlayer startAnimation];
//        }
//    } failureBlock:nil];
}

- (SVGAPlayer *)aPlayer {
    if (_aPlayer == nil) {
        _aPlayer = [[SVGAPlayer alloc] init];
    }
    return _aPlayer;
}

@end
