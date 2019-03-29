# Practice - Obj-C 中成员变量和类的访问控制

| Platform |
|:-----:|
| macOS 10.14.2 |

## Preface

Obj-C 中的成员变量，即 Instance Variables，通常称为 ivar。在面向对象的概念中，一个类的对外暴露决定了其所提供的能力，对子类则提供扩展性，但有些时候我们也不希望外界甚至子类不知道一些细节，这时就用到了访问控制（Access Control）。在 C++、Java、Swift 等大多数高级语言中都有这样的概念，Obj-C 中总共有四种等级，这次就来简单谈谈 Obj-C 中成员变量的访问控制。

## 访问控制修饰符

### @public

```objc
@interface Computer : NSObject {
    @public
    NSString *name;
}
@end

@implementation Computer
@end

Computer *cpt = [[Computer alloc] init];
cpt->name = @"My PC";
NSLog(@"%@", cpt->name);

// My PC
```

声明为 `@public` 的成员变量是访问控制中开放范围最大的，其允许外界可以直接访问到（当然，前提是引入包含该类的头文件）。

### @protected

```objc
@interface Computer : NSObject {
    int _memorySize;
    
    @protected
    int _diskSize;
}

@end

@implementation Computer
@end

@interface Mac : Computer
- (instancetype)initWithDiskSize:(int)diskSize memorySize:(int)memorySize;
- (instancetype)init NS_UNAVAILABLE;
- (void)printDiskAndMemoryInfo;
@end

@implementation Mac
- (instancetype)initWithDiskSize:(int)diskSize memorySize:(int)memorySize {
    self = [super init];
    if (self) {
        _diskSize = diskSize;
        _memorySize = memorySize;
    }
    return self;
}

- (void)printDiskAndMemoryInfo {
    NSLog(@"My Mac's disk size is %d GB, memory size is %d GB.", _diskSize, _memorySize);
}
@end

Mac *mac = [[Mac alloc] initWithDiskSize:512 memorySize:16];
[mac printDiskAndMemoryInfo];

// My Mac's disk size is 512 GB, memory size is 16 GB.
```

声明为 `@protected` 的成员变量只能在本类或子类中使用。注意，当不使用任何访问控制修饰符时，成员变量默认即为 `@protected`。

### @private

```objc
@interface Computer : NSObject {
    @private
    int _secretKey;
    int _secretData;
}
@end

@implementation Computer

- (instancetype)init {
    self = [super init];
    if (self) {
        _secretKey = arc4random();
    }
    return self;
}

- (void)setData:(int)data {
    _secretData = data ^ secretKey;
}
@end
```

声明为 `@public` 的成员变量是访问控制中开放范围最小的，只能被本类访问到。

### @package

建立一个 Cocoa Framework 的工程，导入以下代码：

```objc
// Fruit.h
#import <Foundation/Foundation.h>
@interface Fruit : NSObject {
    @package
    NSString *_name;
}
@end

// FrameworkPublicHeader.h
#import "Person.h"

// main.m
Fruit *fruit = [[Fruit alloc] init];
fruit->_name = @"Apple";
NSLog(@"%@", fruit->_name);

// Dynamic Library:
// Undefined symbols for architecture x86_64:
//   "_OBJC_IVAR_$_Fruit._name", referenced from:
//       _main in main.o
// ld: symbol(s) not found for architecture x86_64

// Static Library
// Apple
```

将构建后的 `.framework` 导入到另外的 macOS Command Line 工程中，尝试发现：当 Framework 的 Mach-O Type 为动态库（Dynamic Library）时，将出现上述错误，无法访问到 `@package` 修饰的 `_name` 成员变量；但当 Framework 的 Mach-O Type 为静态库（Static Library）时，却可以正常编译并运行。对于这里差别，我仍在尝试找寻答案。

在「Objective-C Runtime Release Notes for OS X v10.5」中，引入了该访问控制层级，官方称其类似于 C 语言中的 `private_extern`。

- 在 32 位系统中，`@package` 等同于 `@public`
- 在 64 位系统中，且在定义该类的 Framework 中，为 `@public`
- 在 64 位系统中，但不在定义该类的 Framework 中，为 `@private`

在 64 位系统，将不会导出声明为 `@package` 的成员变量符号，当在该类框架外使用时，将会出现链接错误。

### 类扩展

在类扩展（Class Extension）中，我们可以定义一些不想暴露在外界（.h）的属性、成员变量、或方法，做到「物理」隔离。

```objc
// Person-Inner.h
#import "Person.h"

@interface Person ()

- (void)doSomething;

@end

// Person.m
#import "Person.h"
#import "Person-Inner.h"

@implementation Person
- (void)doSomething {
    NSLog(@"Do something.");
}
@end
```

如上，对外我们只需要暴露 Person.h，而将类扩展所在的 Inner.h 不暴露为 Public Header 即可。

## 类和成员变量符号

```
// 误 import "Fruit.m" 文件时的错误
// duplicate symbol _OBJC_CLASS_$_Fruit in:
//     /path/to/Fruit.o
//     /path/to/main.o
// duplicate symbol _OBJC_METACLASS_$_Fruit in:
//     /path/to/Fruit.o
//     /path/to/main.o
// ld: 2 duplicate symbols for architecture x86_64
``` 

在 64 位的 Obj-C 中，每个类以及实例变量的访问控制都有一个与之关联的符号，类或实例变量都会通过引用此符号来使用。类符号的格式为 ` _OBJC_CLASS_$_ClassName` 和 `_OBJC_METACLASS_$_ClassName`，前者类符号用于在消息发送机制中发送消息的一方（eg. `[ClassName someMessage]`），后者元类符号用于子类化的一方。成员变量符号的格式为 `_OBJC_IVAR_$_ClassName.IvarName`，用于读写成员变量的一方。

## Visibility

![]()

默认情况下（即不明确指定），类符号均是暴露的。但 gcc 编译器可以通过 `-fvisibility` 参数设定编译时的可见程度，但优先级低于直接在源代码中声明可见程度。`-fvisibility=default` 即默认可见程度，`-fvisibility=hidden`，使得编译源文件内未明确指定的符号隐藏。

在 C/C++源文件中，也可以通过 `__attribute((visibility("hidden")))` 设定某个方法或类的可见程度。

```objc
__attribute__((visibility("hidden")))
@interface ClassName : SomeSuperclass
```

在 Obj-C 中是 `__attribute__((visibility("hidden")))`，且定义为一个更简单使用的宏 `OBJC_VISIBLE`（当然，该宏在 Win 32 系统中为 `__declspec(dllexport)` 或 `__declspec(dllimport)`。

```objc
// objc-api.h
#if !defined(OBJC_VISIBLE)
#   if TARGET_OS_WIN32
#       if defined(BUILDING_OBJC)
#           define OBJC_VISIBLE __declspec(dllexport)
#       else
#           define OBJC_VISIBLE __declspec(dllimport)
#       endif
#   else
#       define OBJC_VISIBLE  __attribute__((visibility("default")))
#   endif
#endif
```

## Reference

- [The Objective-C Programming Language - Apple](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocDefiningClasses.html#//apple_ref/doc/uid/TP30001163-CH12-SW1)
- [Objective-C Release Notes - Apple](https://developer.apple.com/library/archive/releasenotes/Cocoa/RN-ObjectiveC/index.html#//apple_ref/doc/uid/TP40004309-CH1-DontLinkElementID_7)
- [64-bit Class and Instance Variable Access Control - Apple](https://developer.apple.com/library/archive/releasenotes/Cocoa/RN-ObjectiveC/index.html#//apple_ref/doc/uid/TP40004309-CH1-SW1)
- [What does the @package directive do in Objective-C? - StackOverflow](https://stackoverflow.com/questions/772600/what-does-the-package-directive-do-in-objective-c)
- [GCC系列: __attribute__((visibility(""))) - veryitman](https://blog.csdn.net/veryitman/article/details/46756683)