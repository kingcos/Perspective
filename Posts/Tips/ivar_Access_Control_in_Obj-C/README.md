# Tips - Obj-C 中成员变量和类的访问控制

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

在类扩展（Class Extension）中，我们可以定义一些不想暴露在外界（.h）的属性或成员变量，做到「物理」隔离。

## 类的访问控制

```
// 误 import .m 文件时的错误
// duplicate symbol _OBJC_CLASS_$_Fruit in:
//     /path/to/Fruit.o
//     /path/to/main.o
// duplicate symbol _OBJC_METACLASS_$_Fruit in:
//     /path/to/Fruit.o
//     /path/to/main.o
// ld: 2 duplicate symbols for architecture x86_64
```

在 64 位的 Obj-C 中，每个类以及实例变量的访问控制都有一个与之关联的符号，类或实例变量都会通过引用此符号来使用，这些符号受链接器的访问控制。

类符号的格式为 ` _OBJC_CLASS_$_ClassName` 和 `_OBJC_METACLASS_$_ClassName`，前者类符号用于在消息发送机制中发送消息的一方（eg. `[ClassName someMessage]`），后者元类符号用于子类化的一方。默认情况下，类符号是暴露的。但可被 gcc 符号标志控制，`-fvisibility=hidden` 使得类符号不暴露。链接器在导出表（Export List）中辨识出旧符号名 `.objc_class_name_ClassName`，并将其翻译为这些符号。

`__attribute__` 中设置单个类的可见程度：

```objc
__attribute__((visibility("hidden")))
@interface ClassName : SomeSuperclass
```

默认情况下，`default` 可见程度，类符号暴露，成员变量符号依下述决定；`hidden` 可见程度，类符号和成员变量赋均不暴露。

成员变量符号的格式为 `_OBJC_IVAR_$_ClassName.IvarName`，用户读写成员变量的一方。默认情况下，`@private` 和 `@package` 修饰的成员变量不暴露，而 `@public` 和 `@protected` 修饰的成员变量暴露。但可由导出表、 `-fvisibility` 或类的可见程度属性改变（针对成员变量的可见程度属性暂不支持）。

## Reference

- [The Objective-C Programming Language - Apple](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocDefiningClasses.html#//apple_ref/doc/uid/TP30001163-CH12-SW1)
- [Objective-C Release Notes - Apple](https://developer.apple.com/library/archive/releasenotes/Cocoa/RN-ObjectiveC/index.html#//apple_ref/doc/uid/TP40004309-CH1-DontLinkElementID_7)
- [64-bit Class and Instance Variable Access Control - Apple](https://developer.apple.com/library/archive/releasenotes/Cocoa/RN-ObjectiveC/index.html#//apple_ref/doc/uid/TP40004309-CH1-SW1)
- [What does the @package directive do in Objective-C? - StackOverflow](https://stackoverflow.com/questions/772600/what-does-the-package-directive-do-in-objective-c)