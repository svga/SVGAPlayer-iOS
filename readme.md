# SVGAPlayer

## 咨询服务

* 如果你发现 SVGAPlayer 存在 BUG，请在 GitHub 上按照模板提交 issue。
* 如果有使用上的问题，请勿提交 issue（会被立刻关闭），请至[知乎付费问答](https://www.zhihu.com/zhi/people/1011556735563157504)提问，我们会全程跟踪你的疑问。

#### New Features

* Add SVGA-Format 2.0.0 support.
* Add SVGAImageView.
* Add more UIViewContentMode support.

#### Improvements

* SVGAParser now can works up-to 8 concurrent tasks.
* Improves BezierPath performance.

## SVGA Format

@see https://github.com/yyued/SVGA-Format

## Install

### CocoaPods

Add following dependency to Podfile
```
pod 'SVGAPlayer'
```

## Usage

### code

```objectivec
SVGAParser *parser = [[SVGAParser alloc] init];
SVGAPlayer *player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
[self.view addSubview:player];
[parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-samples/angel.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
    if (videoItem != nil) {
        player.videoItem = videoItem;
        [player startAnimation];
    }
} failureBlock:nil];

```

### xib

1. Add UIView to IB layout area.
2. Let UIView subclass SVGAImageView.
3. Input imageName on IB Properties Area.
4. Animation will start after loaded.

## Cache

SVGAParser use NSURLSession request remote data via network. You may use following ways to control cache.

### Response Header

Server response SVGA files in Body, and response header either. response header has cache-control / etag / expired keys, all these keys telling NSURLSession how to handle cache.

### Request NSData By Yourself

If you couldn't fix Server Response Header, You should build NSURLRequest with CachePolicy by yourself, and fetch NSData.

Deliver NSData to SVGAParser, as usual.

## API

### Properties
* id<SVGAPlayerDelegate> delegate; - Callbacks
* SVGAVideoEntity *videoItem; - Animation Instance
* Int loops; - Loop Count，0 = Infinity Loop
* BOOL clearsAfterStop; - Clears Canvas After Animation Stop
* String fillMode; - defaults to Forward，optional Forward / Backward，fillMode = Forward，Animation will pause on last frame while finished，fillMode = Backward , Animation will pause on first frame.

### Methods

* (void)startAnimation; - Play Animation from 0 frame.
* (void)startAnimationWithRange:(NSRange)range reverse:(BOOL)reverse;
* (void)pauseAnimation; - Pause Animation and keep on current frame.
* (void)stopAnimation; - Stop Animation，Clears Canvas while clearsAfterStop == YES.
* (void)clear; - Clear Canvas force.
* (void)stepToFrame:(NSInteger)frame andPlay:(BOOL)andPlay; - Step to N frame, and then Play Animation if andPlay === true.
* (void)stepToPercentage:(CGFloat)percentage andPlay:(BOOL)andPlay; - Step to x%, and then Play Animation if andPlay === true.
* (void)setImage:(UIImage *)image forKey:(NSString *)aKey; - Set Dynamic Image.
* (void)setImageWithURL:(NSURL *)URL forKey:(NSString *)aKey; - Set Dynamic Image via remote URL.
* (void)setAttributedText:(NSAttributedString *)attributedText forKey:(NSString *)aKey; - Set Dynamic Text.
* (void)clearDynamicObjects; - Clear all dynamic Images and Texts.

### SVGAPlayerDelegate

* @optional
* - (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player; - Call after animation finished.
* - (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame; - Call after animation play to specific frame.
* - (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage; - Call after animation play to specific percentage.

### Dynamic Object

Use this way to replace specific image, or add text to it. (可以通过以下方式，替换动画文件中的指定图像，以及动态添加富文本。)

#### Dynamic Image

```objectivec
CALayer *iconLayer = [CALayer layer];
iconLayer.cornerRadius = 84.0;
iconLayer.masksToBounds = YES;
iconLayer.borderWidth = 4.0;
iconLayer.borderColor = [UIColor colorWithRed:0xea/255.0 green:0xb3/255.0 blue:0x7d/255.0 alpha:1.0].CGColor;
[self.aPlayer setImage:iconImage forKey:@"99" referenceLayer:iconLayer];
```

* Ask designer tell you the imageKey(or unzip the svga file, find it).

#### Dynamic Text

```objectivec
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

* Ask designer tell you the imageKey(or unzip the svga file, find it).

#### Dynamic Hidden

Now use setHidden to hide an element prevents drawing.

```objectivec
[self.aPlayer setHidden:YES forKey:@"99"];
```

#### Dynamic Drawing

You can set a block, it will callback while frame step.

```objectivec
[self.aPlayer setDrawingBlock:^(CALayer *contentLayer, NSInteger frameIndex) {
    // do thing by yourself
} forKey:@"99"];
```
