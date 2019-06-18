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

@property (weak, nonatomic) IBOutlet SVGAPlayer *aPlayer;

@end

@implementation ViewController

static SVGAParser *parser;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aPlayer.delegate = self;
    self.aPlayer.loops = 0;
    self.aPlayer.clearsAfterStop = YES;
    parser = [[SVGAParser alloc] init];
    [self onChange:nil];
}

- (IBAction)onChange:(id)sender {
    NSArray *items = @[
                       @"https://github.com/yyued/SVGA-Samples/blob/master/EmptyState.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/HamburgerArrow.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/PinJump.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/TwitterHeart.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/Walkthrough.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/angel.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/halloween.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/kingset.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/posche.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/rose.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/matteBitmap.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/matteBitmap_1.x.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/matteRect.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/mutiMatte.svga?raw=true",
                       ];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [parser parseWithURL:[NSURL URLWithString:items[arc4random() % items.count]]
         completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if (videoItem != nil) {
                 self.aPlayer.videoItem = videoItem;
                 [self.aPlayer startAnimation];
             }
         } failureBlock:nil];
    //    [parser parseWithNamed:@"heartbeat" inBundle:nil completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
    //        if (videoItem != nil) {
    //            self.aPlayer.videoItem = videoItem;
    //            [self.aPlayer startAnimation];
    //        }
    //    } failureBlock:nil];
}


- (IBAction)onSlide:(UISlider *)sender {
    [self.aPlayer stepToPercentage:sender.value andPlay:NO];
}
@end
