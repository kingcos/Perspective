# Focus - iOS 中的 KVC

| Date | Notes |
|:-----:|:-----:|
| 2019-03-25 | 首次提交 |

## Preface

KVC，即 Key-Value Coding，译作键值编码（下文简称 KVC）。当对象兼容 KVC 时，可以通过统一的 API 访问对象中某个键对应的属性值。Cocoa 中的许多功能都依赖 KVC，比如，KVO、Cocoa 绑定机制、Core Data、以及 AppleScript 等。本文将主要探讨 KVC 及其本质相关，关于其它的内容可参考文末的「Reference」。

## How

### 基本使用

```objc
#import <Foundation/Foundation.h>

@interface Speaker : NSObject
@property (nonatomic) int volume;
@end

@implementation Speaker
@end

@interface Computer : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *speakers;
@end

@implementation Computer
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Computer *cpt = [[Computer alloc] init];
        // ➡️ 通过 setter 设置
        [cpt setName:@"My Mac 1"];
        // ➡️ 通过 getter 读取
        NSLog(@"name from getter - %@", [cpt name]);
        
        // ➡️ 通过 setValue:forKey: 设置
        [cpt setValue:@"My Mac 2" forKey:@"name"];
        // ➡️ 通过 valueForKey: 读取
        NSLog(@"name from KVC - %@", [cpt valueForKey:@"name"]);
        
        Speaker *s1 = [[Speaker alloc] init];
        s1.volume = 5;
        Speaker *s2 = [[Speaker alloc] init];
        s2.volume = 5;
        cpt.speakers = @[s1, s2];
        // ➡️ 通过 setValue:forKeyPath: 设置
        [cpt setValue:@10 forKeyPath:@"speakers.volume"];
        // ➡️ 通过 valueForKeyPath: 读取
        NSLog(@"speakers.volume - %@", [cpt valueForKeyPath:@"speakers.volume"]);
        
        // ➡️ dictionaryWithValuesForKeys
        NSLog(@"%@", [cpt dictionaryWithValuesForKeys:@[@"name", @"speakers"]]);
    }
    return 0;
}

// OUTPUT:
// name from getter - My Mac 1
// name from KVC - My Mac 2
// speakers.volume - (
//     10,
//     10
// )
// {
//     name = "My Mac 2";
//     speakers =     (
//         "<Speaker: 0x100501610>",
//         "<Speaker: 0x1005018f0>"
//     );
// }
```

定义一个 `Computer` 类，其拥有 `name` 和 `speakers` 属性，后者为数组类型，是容纳 `Speaker` 类型对象的集合。访问对象的属性，最自然的是通过 getter & setter，但 KVC 提供了通过键或键路径统一访问属性的方式。`setValue:forKey:` 和 `valueForKey:` 可以通过键来使用，键即是属性的名称，使用 ASCII 编码，不支持空格；`setValue:forKeyPath:` 和 `valueForKeyPath:` 是对应的键路径方法，键路径通过 `.` 连接键，对于多级嵌套的类型提供了便捷的方式。`dictionaryWithValuesForKeys:` 支持通过多个键（非键路径）的数组返回包含键和对应值的字典。

### mutableValueForKey

```objc
NSMutableArray *arr = [cpt mutableArrayValueForKeyPath:@"speakers"];
Speaker *s3 = [[Speaker alloc] init];
s3.volume = 20;
[arr addObject:s3];
NSLog(@"%@", [cpt mutableArrayValueForKey:@"speakers"]);

// OUTPUT:
// (
//     "<Speaker: 0x100505220>",
//     "<Speaker: 0x1005021a0>",
//     "<Speaker: 0x100502180>"
// )
```

对于对象中的集合类型 `NSArray`、`NSSet`、`NSOrderedSet`，KVC 提供了比 `setValue:forKey:` 和 `valueForKey:` 更便捷高效的 `mutableArrayValueForKey:`、`mutableSetValueForKey`、`mutableOrderedSetValueForKey:` 以及对应的 `KeyPath` 方法。它们都会返回一个可变（Mutable）类型的代理对象，在该代理对象上的操作将影响真实的属性值。

### 集合操作符

对于对象中的集合类型，KVC 提供了一些可以放置在键路径中的操作符，由 `@` 开头，整体结构为：`左键路径.@集合操作符.右键路径`，当然，左右键路径都可以根据需要选择是否忽略。集合操作符分为三种：聚合（Aggregation）操作符、数组操作符、嵌套（Nesting）操作符。

<table>
    <tr>
        <th>类型</th>
        <th>操作符</th>
        <th>作用</th>
    </tr>
    <tr>
        <td rowspan="6" align="center">聚合操作符<br>（针对数组或集合类型，最终返回反应集合某个特性的单一值）</td>
    </tr>
    <tr>
        <td><code>@avg</code></td>
        <td>将数值转换为 <code>double</code> 类型求和并计算平均值（<code>nil</code> 值为 <code>0</code>），并返回 <code>NSNumber</code> 类型的实例</td>
    </tr>
    <tr>
        <td><code>@count</code></td>
        <td>计算集合类型中的对象数量，将忽略右键路径</td>
    </tr>
    <tr>
        <td><code>@max</code></td>
        <td>内部使用 <code>compare:</code> 方法比对出最大值（忽略 <code>nil</code> 值），并返回 <code>NSNumber</code> 类型的实例</td>
    </tr>
    <tr>
        <td><code>@min</code></td>
        <td>内部使用 <code>compare:</code> 方法比对出最小值（忽略 <code>nil</code> 值），并返回 <code>NSNumber</code> 类型的实例</td>
    </tr>
    <tr>
        <td><code>@sum</code></td>
        <td>将数值转换为 <code>double</code> 类型求和（<code>nil</code> 值为 <code>0</code>），并返回 <code>NSNumber</code> 类型的实例</td>
    </tr>
    <tr>
        <td rowspan="3" align="center">数组操作符<br>（返回特定的对象数组）</td>
    </tr>
    <tr>
        <td><code>@unionOfObjects</code></td>
        <td>返回包含右键路径指定属性的对象数组（即值为 <code>nil</code> 时不会被包含进来）</td>
    </tr>
    <tr>
        <td><code>@distinctUnionOfObjects</code></td>
        <td>返回包含右键路径指定属性的对象数组（即值为 <code>nil</code> 时不会被包含进来），并去重</td>
    </tr>
    <tr>
        <td rowspan="4" align="center">嵌套操作符<br>（嵌套意为包含集合的集合）</td>
    </tr>
    <tr>
        <td><code>@unionOfArrays</code></td>
        <td>返回调用数组中所有数组中包含右键路径指定属性的对象数组（当指定属性的值为 <code>nil</code> 时，对象将返回空）</td>
    </tr>
    <tr>
        <td><code>@distinctUnionOfArrays</code></td>
        <td>返回调用数组中所有数组中包含右键路径指定属性的对象数组（当指定属性的值为 <code>nil</code> 时，对象将返回空，多个空对象也会被去重），并去重</td>
    </tr>
    <tr>
        <td><code>@distinctUnionOfSets</code></td>
        <td>返回调用集合（Set）中所有集合（Set）中包含右键路径指定属性的对象数组（即值为 <code>nil</code> 时不会被包含进来，多个空对象也会被去重），并去重</td>
    </tr>
</table>

```objc
@interface Speaker : NSObject
// ⚠️ 注意：这里将 volume 改为 NSNumber * 类型，因为 int 时，属性将有默认值 0，不便于后续结果演示
@property (nonatomic) NSNumber *volume;
@end

@implementation Speaker
@end

// main()
Computer *cpt1 = [[Computer alloc] init];
Speaker *s1 = [[Speaker alloc] init];
s1.volume = @1;
Speaker *s2 = [[Speaker alloc] init];
s2.volume = @2;
Speaker *s3 = [[Speaker alloc] init];
s3.volume = @2;
Speaker *s4 = [[Speaker alloc] init];
// s4.volume = nil;
Speaker *s5 = [[Speaker alloc] init];
s5.volume = @5;

[cpt1 setValue:@[s1, s2, s3, s4, s5] forKey:@"speakers"];

// Aggregation Operators:
NSLog(@"Aggregation Operators:");
NSLog(@"Volumes at avg: %.2lf", [[cpt1 valueForKeyPath:@"speakers.@avg.volume"] doubleValue]);
NSLog(@"Speakers at count: %d", [[cpt1 valueForKeyPath:@"speakers.@count"] intValue]);
NSLog(@"Volumes at max: %.2lf", [[cpt1 valueForKeyPath:@"speakers.@max.volume"] doubleValue]);
NSLog(@"Volumes at min: %.2lf", [[cpt1 valueForKeyPath:@"speakers.@min.volume"] doubleValue]);
NSLog(@"Volumes at sum: %.2lf", [[cpt1 valueForKeyPath:@"speakers.@sum.volume"] doubleValue]);

// OUTPUT:
// Aggregation Operators:
// Volumes at avg: 2.00
// Speakers at count: 5
// Volumes at max: 5.00
// Volumes at min: 1.00
// Volumes at sum: 10.00

// Array Operators:
NSLog(@"Array Operators:");
NSLog(@"%@", [cpt1.speakers valueForKeyPath:@"@unionOfObjects.volume"]);
NSLog(@"%@", [cpt1.speakers valueForKeyPath:@"@distinctUnionOfObjects.volume"]);

Computer *cpt2 = [[Computer alloc] init];
Speaker *s6 = [[Speaker alloc] init];
s6.volume = @5;
Speaker *s7 = [[Speaker alloc] init];
// s7.volume = nil;
Speaker *s8 = [[Speaker alloc] init];
s8.volume = @8;
cpt2.speakers = @[s6, s7, s8];

// OUTPUT:
// Array Operators:
// (
//     1,
//     2,
//     2,
//     5
// )
// (
//     2,
//     5,
//     1
// )

// Nesting Operators:
NSLog(@"Nesting Operators:");
NSArray *arrayOfArrays = @[cpt1.speakers, cpt2.speakers];
NSLog(@"%@", [arrayOfArrays valueForKeyPath:@"@unionOfArrays.volume"]);
NSLog(@"%@", [arrayOfArrays valueForKeyPath:@"@distinctUnionOfArrays.volume"]);

NSSet *setOfSets = [NSSet setWithArray:@[[NSSet setWithArray:cpt1.speakers], [NSSet setWithArray:cpt2.speakers]]];
NSLog(@"%@", [setOfSets valueForKeyPath:@"@distinctUnionOfSets.volume"]);

// OUTPUT:
// Nesting Operators:
// (
//     1,
//     2,
//     2,
//     "<null>",
//     5,
//     5,
//     "<null>",
//     8
// )
// (
//     5,
//     1,
//     2,
//     "<null>",
//     8
// )
// {(
//     2,
//     5,
//     8,
//     1
// )}
```

### 非对象属性

当 KVC 中的 `valueForKey:` 或 `valueForKeyPath:` 获取到的值不是 Obj-C 对象时，将会以其值初始化 	`NSNumber` 对象（针对标量（Scalar））或 `NSValue` 对象（针对结构体）并返回。

- 标量值

```objc
@interface Computer : NSObject {
    @public
    int _diskSize;
}
@end

@implementation Computer
@end

Computer *cpt = [[Computer alloc] init];
cpt->_diskSize = 512;
NSNumber *diskSizeNum = [cpt valueForKey:@"diskSize"];
NSLog(@"Disk size: %d.", [diskSizeNum intValue]);

// LLDB:
// (lldb) po object_getClass([cpt valueForKey:@"diskSize"])
// __NSCFNumber

// OUTPUT:
// Disk size: 512.
```

- 结构体

```objc
typedef struct {
    NSSize size;
    double inch;
} Screen;

@interface Computer : NSObject {
    @public
    Screen _screen;
}
@end

@implementation Computer
@end

Computer *cpt = [[Computer alloc] init];
cpt->_screen.size = NSMakeSize(1920, 1090);
cpt->_screen.inch = 15.6;

// ➡️ valueForKey
NSValue *value = [cpt valueForKey:@"screen"];

Screen screen;
[value getValue:&screen];

NSLog(@"Screen size: %.f * %.f\nScreen inch: %.1lf", screen.size.width, screen.size.height, screen.inch);

Screen retinaScreen;
retinaScreen.size = NSMakeSize(2560, 1600);
retinaScreen.inch = 13.3;

NSValue *retinaValue = [NSValue valueWithBytes:&retinaScreen objCType:@encode(Screen)];

// ➡️ setValue:forKey
[cpt setValue:retinaValue forKey:@"screen"];

NSLog(@"Screen size: %.f * %.f\nScreen inch: %.1lf", cpt->_screen.size.width, cpt->_screen.size.height, cpt->_screen.inch);

// OUTPUT:
// Screen size: 1920 * 1090
// Screen inch: 15.6
// Screen size: 2560 * 1600
// Screen inch: 13.3
```

## Reference

- [Key-Value Coding Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/index.html)
- [Practice - iOS 中的 KVO](https://github.com/kingcos/Perspective/tree/writing/Posts/Focus/KVO_in_iOS)
