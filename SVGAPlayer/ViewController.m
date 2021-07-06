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
@property (weak, nonatomic) IBOutlet UISlider *aSlider;
@property (weak, nonatomic) IBOutlet UIButton *onBeginButton;

@end

@implementation ViewController

static SVGAParser *parser;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aPlayer.delegate = self;
    self.aPlayer.loops = 1;
    self.aPlayer.clearsAfterStop = YES;
    parser = [[SVGAParser alloc] init];
    [self onChange:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self onBeginButton:self.onBeginButton];
}

- (IBAction)onChange:(id)sender {
    NSArray *items = @[
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/EmptyState.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/HamburgerArrow.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/PinJump.svga?raw=true",
                       @"https://github.com/svga/SVGA-Samples/raw/master/Rocket.svga",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/TwitterHeart.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/Walkthrough.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/angel.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/halloween.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/kingset.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/posche.svga?raw=true",
                       @"https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/rose.svga?raw=true",
                       ];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    parser.enabledMemoryCache = YES;
    [parser parseWithURL:[NSURL URLWithString:items[arc4random() % items.count]]
         completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if (videoItem != nil) {
                 self.aPlayer.videoItem = videoItem;
                 NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
                 [para setLineBreakMode:NSLineBreakByTruncatingTail];
                 [para setAlignment:NSTextAlignmentCenter];
                 NSAttributedString *str = [[NSAttributedString alloc]
                                            initWithString:@"Hello, World! Hello, World!"
                                            attributes:@{
                                                NSFontAttributeName: [UIFont systemFontOfSize:28],
                                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                                NSParagraphStyleAttributeName: para,
                                            }];
                 [self.aPlayer setAttributedText:str forKey:@"banner"];

                 [self.aPlayer startAnimation];
                 
//                 [self.aPlayer startAnimationWithRange:NSMakeRange(10, 25) reverse:YES];
             }
         } failureBlock:nil];
//
//        [parser parseWithURL:[NSURL URLWithString:@"https://github.com/svga/SVGA-Samples/raw/master_aep/BitmapColorArea1.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
//            if (videoItem != nil) {
//                self.aPlayer.videoItem = videoItem;
//                [self.aPlayer setImageWithURL:[NSURL URLWithString: @"https://i.imgur.com/vd4GuUh.png"] forKey:@"matte_EEKdlEml.matte"];
//                [self.aPlayer startAnimation];
//            }
//        } failureBlock:nil];
    
//    [parser parseWithNamed:@"Rocket" inBundle:nil completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
//        self.aPlayer.videoItem = videoItem;
//        [self.aPlayer startAnimation];
//    } failureBlock:nil];
}

- (IBAction)onSliderClick:(UISlider *)sender {
    [self.aPlayer stepToPercentage:sender.value andPlay:NO];
}

- (IBAction)onSlide:(UISlider *)sender {
    [self.aPlayer stepToPercentage:sender.value andPlay:NO];
}

- (IBAction)onChangeColor:(UIButton *)sender {
    self.view.backgroundColor = sender.backgroundColor;
}

- (IBAction)onBeginButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        [self.aPlayer pauseAnimation];
    } else {
        [self.aPlayer stepToPercentage:(self.aSlider.value == 1 ? 0 : self.aSlider.value) andPlay:YES];
    }
}

- (IBAction)onRetreatButton:(UIButton *)sender {
    
}

- (IBAction)onForwardButton:(UIButton *)sender {
    
}


#pragma - mark SVGAPlayer Delegate
- (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage {
    self.aSlider.value = percentage;
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
    self.onBeginButton.selected = YES;
}
@end
