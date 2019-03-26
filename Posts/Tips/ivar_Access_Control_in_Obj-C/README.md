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
    int memorySize;
    
    @protected
    int diskSize;
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
        self->diskSize = diskSize;
        self->memorySize = memorySize;
    }
    return self;
}

- (void)printDiskAndMemoryInfo {
    NSLog(@"My Mac's disk size is %d GB, memory size is %d GB.", diskSize, memorySize);
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
    int secretKey;
    int secretData;
}
@end

@implementation Computer

- (instancetype)init {
    self = [super init];
    if (self) {
        secretKey = arc4random();
    }
    return self;
}

- (void)setData:(int)data {
    secretData = data ^ secretKey;
}
@end
```

声明为 `@public` 的成员变量是访问控制中开放范围最小的，只能被本类访问到。

### @package

> 其实本文主要是为 `@package` 所作。

在「Objective-C Runtime Release Notes for OS X v10.5」中，Obj-C 引入了该访问控制层级，其类似于 C 语言中的 `private_extern`。

- 在 32 位系统中，`@package` 等同于 `@public`
- 在 64 位系统中，且在定义该类的 Framework 中，为 `@public`
- 在 64 位系统中，但不在定义该类的 Framework 中，为 `@private`

在 64 位系统，将不会导出声明为 `@package` 的成员变量符号，当在该类框架外使用时，将会出现链接错误。

### 类扩展

在类扩展（Class Extension）中，我们可以定义一些不想暴露在外界（.h）的属性或成员变量，做到「物理」隔离。

## 类的访问控制

在 64 位的 Obj-C 中，每个类以及实例变量的访问控制都有一个与之关联的符号。类或实例变量的所有使用都是通过引用此符号。这些符号受链接器的访问控制。

类符号具有 ` _OBJC_CLASS_$_ClassName` `_OBJC_METACLASS_$_ClassName`。

```objc
__attribute__((visibility("hidden")))
@interface ClassName : SomeSuperclass
```

## Reference

- [The Objective-C Programming Language - Apple](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocDefiningClasses.html#//apple_ref/doc/uid/TP30001163-CH12-SW1)
- [Objective-C Release Notes - Apple](https://developer.apple.com/library/archive/releasenotes/Cocoa/RN-ObjectiveC/index.html#//apple_ref/doc/uid/TP40004309-CH1-DontLinkElementID_7)
- [64-bit Class and Instance Variable Access Control - Apple](https://developer.apple.com/library/archive/releasenotes/Cocoa/RN-ObjectiveC/index.html#//apple_ref/doc/uid/TP40004309-CH1-SW1)