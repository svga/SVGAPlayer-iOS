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
    [parser parseWithNamed:@"rose_2.0.0"
                  inBundle:[NSBundle mainBundle] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                      if (videoItem != nil) {
                          self.aPlayer.videoItem = videoItem;
                          [self.aPlayer startAnimation];
                      }
                  } failureBlock:^(NSError * _Nonnull error) {
                  }];
}

- (IBAction)onSlide:(UISlider *)sender {
    [self.aPlayer stepToPercentage:sender.value andPlay:NO];
}
@end
