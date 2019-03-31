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

对于对象中的集合类型 `NSArray`、`NSSet`、`NSOrderedSet`，KVC 提供了比 `setValue:forKey:` 和 `valueForKey:` 更便捷、高效的 `mutableArrayValueForKey:`、`mutableSetValueForKey`、`mutableOrderedSetValueForKey:` 以及对应的 `KeyPath` 方法。它们都会返回一个可变（Mutable）类型的代理对象，在该代理对象上的操作将影响真实的属性值。

### 集合类型操作符

对于对象中的集合类型，


## Reference

- [Key-Value Coding Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/index.html)
- [Practice - iOS 中的 KVO](https://github.com/kingcos/Perspective/tree/writing/Posts/Focus/KVO_in_iOS)