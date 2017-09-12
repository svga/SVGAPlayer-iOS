# SVGAPlayer

## Version

### 1.1.6

Change CADisplayLink mode to NSRunLoopCommonModes, SVGAPlayer will not pause while ScrollView tracking.

### 1.1.4

Improve SVGAParser under multi-thread.

## SVGA Format

* SVGA is an opensource animation library, develop by YY UED.
* SVGA base on SVG's concept, but not compatible to SVG.
* SVGA can play on iOS/Android/Web.

@see https://github.com/yyued/SVGA-Format

## 安装

### CocoaPods

Add following dependency to Podfile
```
pod 'SVGAPlayer'
```

## 使用

### Init Player

```
@interface XXX()
@property (nonatomic, strong) SVGAPlayer *aPlayer; // Init SVGAPlayer by yourself.
@end
```

### Init Parser, Load Resource

```
SVGAParser *parser = [[SVGAParser alloc] init];
[parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-samples/angel.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
    if (videoItem != nil) {
        self.aPlayer.videoItem = videoItem;
        [self.aPlayer startAnimation];
    }
} failureBlock:nil];

```

## API

### Properties
* id<SVGAPlayerDelegate> delegate; - Callbacks
* SVGAVideoEntity *videoItem; - Animation Instance
* int loops; - Loop Count，0 = Infinity Loop
* BOOL clearsAfterStop; - Clears Canvas After Animation Stop

### Methods

* (void)startAnimation; - Play Animation from 0 frame.
* (void)pauseAnimation; - Pause Animation and keep on current frame.
* (void)stopAnimation; - Stop Animation，Clears Canvas while clearsAfterStop == YES.
* (void)clear; - Clear Canvas force.
* (void)stepToFrame:(NSInteger)frame andPlay:(BOOL)andPlay; - Step to N frame, and then Play Animation if andPlay === true.
* (void)stepToPercentage:(CGFloat)percentage andPlay:(BOOL)andPlay; - Step to x%, and then Play Animation if andPlay === true.
* (void)setImage:(UIImage *)image forKey:(NSString *)aKey referenceLayer:(CALayer *)referenceLayer; - Set Dynamic Image.
* (void)setAttributedText:(NSAttributedString *)attributedText forKey:(NSString *)aKey; - Set Dynamic Text.
* (void)clearDynamicObjects; - Clear all dynamic Images and Texts.

### SVGAPlayerDelegate

* @optional
* - (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player; - Call after animation finished.
* - (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame; - Call after animation play to specific frame.
* - (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage; - Call after animation play to specific percentage.

### Dynamic Object

Use this way to replace specific image, or add text to it.

ZH: 可以通过以下方式，替换动画文件中的指定图像，以及动态添加富文本。

* Must set before startAnimation method call (必须在 startAnimation 方法执行前进行配置)

#### Dynamic Image

```
CALayer *iconLayer = [CALayer layer];
iconLayer.cornerRadius = 84.0;
iconLayer.masksToBounds = YES;
iconLayer.borderWidth = 4.0;
iconLayer.borderColor = [UIColor colorWithRed:0xea/255.0 green:0xb3/255.0 blue:0x7d/255.0 alpha:1.0].CGColor;
[self.aPlayer setImage:iconImage forKey:@"99" referenceLayer:iconLayer];
```

* Designer should told you the imageKey.

#### Dynamic Text

```
NSShadow *shadow = [NSShadow new];
shadow.shadowColor = [UIColor blackColor];
shadow.shadowOffset = CGSizeMake(0, 1);
NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"崔小姐不吃鱼 送了魔法奇缘"
                                                            attributes:@{
                                                                        NSForegroundColorAttributeName: [UIColor colorWithRed:0xff/255.0 green:0xe0/255.0 blue:0xa4/255.0 alpha:1.0],
                                                                        NSFontAttributeName: [UIFont boldSystemFontOfSize:30.0],
                                                                        NSShadowAttributeName: shadow,
                                                                        }];
[self.aPlayer setAttributedText:text forKey:@"banner"];
```

* Designer should told you the imageKey.
