# Practice - iOS 中的 KVO 

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019-03-13 | 首次提交 |  |

## Preface

KVO 即 Key-Value Observing，译作键值监听，通常用于监听对象的某个属性值的变化。下面将由浅入深，谈谈 iOS 中的 KVO。

## How

先来简单尝试下 KVO 的「魔力」吧。KVO 总共分为三个步骤，添加监听者、监听者得到通知、移除监听者。

在 `ViewController` 中，定义一个 `Computer` 类型的属性 `cpt`，并希望得知其中 `buttonClickTimes` 的每次变更。这时就可以将当前 `ViewController` 设置为 `cpt. buttonClickTimes` 的监听者；在按钮绑定的方法中，会对 `cpt.buttonClickTimes` 进行更新，所以当用户点击后，监听者就可以在 `observeValueForKeyPath:ofObject:change:context:` 中得知变更的通知；最后，在监听者销毁前，需要将其移除。

```objc
#import "ViewController.h"

@interface Computer : NSObject
@property (nonatomic, assign) int buttonClickTimes;
@end

@implementation Computer
@end


@interface ViewController ()
@property (nonatomic, strong) Computer *cpt;
@end

@implementation ViewController

- (Computer *)cpt {
    if (!_cpt) {
        _cpt = [[Computer alloc] init];
        // ➡️ 为 cpt 属性的键路径 buttonClickTimes 增加监听者 self（该控制器）
        // options 决定监听者将同时接收到新值和旧值
        // context 决定附带的上下文信息「ViewController-buttonClickTimes」。
        [_cpt addObserver:self
               forKeyPath:@"buttonClickTimes"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:@"ViewController-buttonClickTimes"];
    }
    return _cpt;
}

- (void)dealloc {
    // ➡️ 在监听者销毁前将其移除
    [self.cpt removeObserver:self forKeyPath:@"buttonClickTimes"];
}

- (IBAction)clickOnButton:(id)sender {
    self.cpt.buttonClickTimes += 1;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    // ➡️ 根据 context 判定
    if (context == @"ViewController-buttonClickTimes") {
        NSLog(@"%@ - %@ - %@ - %@", change, keyPath, object, context);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
```

## What

```objc
// NSKeyValueObserving.h

@interface NSObject(NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
```

### 添加监听者

为属性添加监听者的 `addObserver:forKeyPath:options:context:` 方法中一共接收四个参数，下面来逐个分析一下。

#### observer

```objc
// NSKeyValueObserving.h

@interface NSObject(NSKeyValueObserving)

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context;

@end
```

`observer` 即监听者，当监听值发生改变后，它的 `observeValueForKeyPath:ofObject:change:context:` 方法就会被调用。而由于该方法定义在 Obj-C 中 NSObject 的 `NSKeyValueObserving` 分类中，所以任何 NSObject 的子类可以通过实现该方法来成为监听者（但这并不代表可以实现 KVO）。

#### keyPath

`keyPath` 即键路径。如上我们要监听 `cpt` 的 `buttonClickTimes` 属性，那么其绝对键路径就是 `cpt.buttonClickTimes`。而这里的 `keyPath` 其实是相对于被监听者的相对键路径，所以 `buttonClickTimes` 即可。在单一键路径时，也可以使用 `NSStringFromSelector(@selector(buttonClickTimes))` 获取 getter 的方法名作为键路径，更加安全。

如果是嵌套多个对象，则使用多个 `.` 即可，比如下例中要监听 `cpt` 的 `screen. refreshedTimes` 可以拥有两种方式进行监听：

```objc
#import "ViewController.h"

@interface Screen : NSObject
@property (nonatomic, assign) int refreshedTimes;
@end

@implementation Screen
@end

@interface Computer : NSObject
@property (nonatomic, assign) int buttonClickTimes;
@property (nonatomic, strong) Screen *screen;
@end

@implementation Computer
@end

@interface ViewController ()
@property (nonatomic, strong) Computer *cpt;
@end

@implementation ViewController

- (Computer *)cpt {
    if (!_cpt) {
        _cpt = [[Computer alloc] init];
        _cpt.screen = [[Screen alloc] init];
        
        [_cpt addObserver:self
               forKeyPath:@"buttonClickTimes" // NSStringFromSelector(@selector(buttonClickTimes))
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:@"ViewController - buttonClickTimes"];
        // ➡️ 监听 cpt 的 screen.refreshedTimes
        [_cpt addObserver:self
               forKeyPath:@"screen.refreshedTimes"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:@"ViewController - screen.refreshedTimes"];
        // ➡️ 也可以监听 cpt.screen 的 refreshedTimes 
        // [_cpt.screen addObserver:self
        //               forKeyPath:@"refreshedTimes"
        //                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
        //                  context:@"ViewController - screen.refreshedTimes"];
    }
    return _cpt;
}

- (void)dealloc {
    [self.cpt removeObserver:self forKeyPath:@"buttonClickTimes"];
    [self.cpt removeObserver:self forKeyPath:@"screen.refreshedTimes"];
}

- (IBAction)clickOnButton:(id)sender {
    self.cpt.buttonClickTimes += 1;
    self.cpt.screen.refreshedTimes += 1;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == @"ViewController - buttonClickTimes") {
        NSLog(@"%@ - %@ - %@ - %@", change, keyPath, object, context);
    } else if (context == @"ViewController - screen.refreshedTimes") {
        NSLog(@"%@ - %@ - %@ - %@", change, keyPath, object, context);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
```

需要注意的是，当 `keyPath` 为空时，编译器会警告「Null passed to a callee that requires a non-null argument」，此时监听是无意义的；当需要监听本类中无需嵌套的属性时，为 `self` 添加监听即可，若将 `keyPath` 设置为 `@""` 也是无效的。

#### options

`options` 即配置选项，其类型为 `NSKeyValueObservingOptions` 枚举，用来确定监听通知的内容和发送时机，其一共有四个枚举值，但可以通过 `|` 按位或运算符进行组合。

```objc
// NSKeyValueObserving.h
typedef NS_OPTIONS(NSUInteger, NSKeyValueObservingOptions) {
    NSKeyValueObservingOptionNew = 0x01,
    NSKeyValueObservingOptionOld = 0x02,
    NSKeyValueObservingOptionInitial API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) = 0x04,
    NSKeyValueObservingOptionPrior API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) = 0x08
};
```

在四个枚举值中，`NSKeyValueObservingOptionNew` 和 `NSKeyValueObservingOptionOld` 选项决定了监听者接收改变前的值和改变后的值，使用 `NSKeyValueChangeNewKey` 和 `NSKeyValueChangeOldKey` 即可取得 `change` 中对应的值：

```objc
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == @"ViewController - buttonClickTimes") {
        NSLog(@"New: %@, old: %@ - %@ - %@ - %@", change[NSKeyValueChangeNewKey], change[NSKeyValueChangeOldKey], keyPath, object, context);
    } else if (context == @"ViewController - screen.refreshedTimes") {
        NSLog(@"New: %@, old: %@ - %@ - %@ - %@", change[NSKeyValueChangeNewKey], change[NSKeyValueChangeOldKey], keyPath, object, context);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// OUTPUT:
// New: 1, old: 0 - buttonClickTimes - <Computer: 0x600001a1c3e0> - ViewController - buttonClickTimes
// New: 1, old: 0 - refreshedTimes - <Screen: 0x600001844680> - ViewController - screen.refreshedTimes
```

`NSKeyValueObservingOptionInitial` 选项可以当添加监听者后立刻收到仅且一次的通知。

```objc
[_cpt addObserver:self
       forKeyPath:NSStringFromSelector(@selector(buttonClickTimes))
          options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
          context:@"ViewController - buttonClickTimes"];

// ➡️ 首次触发是由于添加了监听者而无需改变值，NSKeyValueObservingOptionInitial 会立刻触发
// 注意如果加了 NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 选项，则新值为添加时属性的值，旧值为空
// New: 0, old: (null) - buttonClickTimes - <Computer: 0x6000016464c0> - ViewController - buttonClickTimes
// ➡️ buttonClickTimes 增加，监听者接收到通知
// New: 1, old: 0 - buttonClickTimes - <Computer: 0x6000016464c0> - ViewController - buttonClickTimes
```

`NSKeyValueObservingOptionPrior` 选项可以在属性改变前，还未得到新值时收到通知。我们可以在 `change` 中 `NSKeyValueChangeNotificationIsPriorKey` 对应值里检查是否来自该选项触发。

```objc
[_cpt addObserver:self
       forKeyPath:NSStringFromSelector(@selector(buttonClickTimes))
          options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionPrior
          context:@"ViewController - buttonClickTimes"];

// NSLog(@"New: %@, old: %@ - isPrior %@ - %@ - %@ - %@", change[NSKeyValueChangeNewKey], change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNotificationIsPriorKey], keyPath, object, context);

// ➡️ NSKeyValueObservingOptionInitial：一旦添加监听者，立即触发
// New: 0, old: (null) - isPrior (null) - buttonClickTimes - <Computer: 0x60000168dd00> - ViewController - buttonClickTimes
// ➡️ NSKeyValueObservingOptionPrior：属性改变前触发
// New: (null), old: 0 - isPrior 1 - buttonClickTimes - <Computer: 0x60000168dd00> - ViewController - buttonClickTimes
// ➡️ 属性已更新为新值
// New: 1, old: 0 - isPrior (null) - buttonClickTimes - <Computer: 0x60000168dd00> - ViewController - buttonClickTimes
```

#### context

`context` 即上下文。上下文是一个在阅读中常用的词，指文章的上文与下文，编程中常用的上下文也与此类似，泛指环境条件等信息。关于此处的 `context`，主要意义是来区分不同的监听通知，在后续也可以根据 `context` 移除指定的通知。

关于 `context` 的最佳实践，这里参考了 StackOverflow 上的一个高赞回答（Reference 详见文末），需要

### 移除监听者

// 通过相对于接收者的键路径上，注册或反注册一个值的监听者。其中选项（options）参数用来确定监听通知的内容和发送时机，上下文（context）参数用来在监听通知中传递。应当尽可能使用 removeObserver:forKeyPath:context: 取代 removeObserver:forKeyPath:，因为前者允许更加精确指定意图。当同一个监听者多次注册相同的键路径，但每次使用不同的上下文指针时，removeObserver:forKeyPath: 在确定移除时不得不猜测上下文指针，且有可能猜错。

## Why

## Reference

- [Key-Value Observing Programming Guide - Apple Inc.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)
- [Best practices for context parameter in addObserver (KVO) - StackOverflow](https://stackoverflow.com/questions/12719864/best-practices-for-context-parameter-in-addobserver-kvo)