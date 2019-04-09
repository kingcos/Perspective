# Tips - Obj-C & Swift 的类型内省与反射

| Date | Notes | Swift |
|:-----:|:-----:|:-----:|
| 2019-04-08 | 首次提交 | 4.2 |

## Preface

在许多编程语言中都有类型内省（Introspection）和反射（Reflection）这两个概念，但却很容易让人混淆。这两个概念在不同的编程语言中也有不同的具体解释，那么这次就简单谈谈 Obj-C 中的类型内省与反射。

### What

> In computing, *type introspection* is the ability of a program to **examine** the type or properties of an object at runtime. Some programming languages possess this capability.
> 
> Introspection should not be confused with reflection, which goes a step further and is the ability for a program to manipulate the values, meta-data, properties and/or functions of an object at runtime. Some programming languages - e.g. Java, Python and Go - also possess that capability.
>
> —— Type introspection, Wikipedia
> 
> 译：
> 在计算机科学中，类型内省指程序在运行时**检查**类型或属性的能力。一些编程语言拥有该能力。
>
> 内省不应该和反射混淆，反射更深入一步，其是一种程序在运行时制造对象的值、元数据、属性、和/或方法的能力。一些编程语言——如 Java、Python 和 Go，同样拥有该能力。
>
> —— 类型内省，维基百科

查阅了很多资料和博客，但其实最后发现维基百科中的定义更加明确些。类型内省和反射都是运行时的概念，但前者着重于运行时检查，而后者则强调运行时改变原有结构。运行时意味着编译时刻无法确定，只有当程序运行时才能根据其上下文确定具体的信息。

## Obj-C

Obj-C 作为一门消息发送机制的语言，其运行时非常强大，对于内省与反射的支持自然不在话下。为了 Demo，我们定义 `Furit`、`Apple`、`Orange` 和 `Person` 四个类，`Apple` 和 `Orange` 继承自 `Furit` 基类，`Person` 中定义一个参数为 `id` 类型的方法，并在其内部进行运行时检查。

```objc
@interface Fruit : NSObject
- (void)taste;
@end

@implementation Fruit
- (void)taste {
    NSLog(@"%@ - %s", NSStringFromClass(self.class), __func__);
}
@end

@interface Apple : Fruit
@end

@implementation Apple
@end

@interface Orange : Fruit
@end

@implementation Orange
@end

@interface Pencil : NSObject

@end

@interface Person : NSObject
- (void)eat:(id)fruit;
@end

@implementation Person
- (void)eat:(id)fruit {
    if ([fruit isKindOfClass:Fruit.class]) {
        if ([fruit isMemberOfClass:Apple.class]) {
            [(Apple *)fruit taste];
        }
        
        if ([fruit isMemberOfClass:Orange.class]) {
            [(Orange *)fruit taste];
        }
    }
}
@end
```

### 内省

```objc
Person *person = [[Person alloc] init];
Apple *apple = [[Apple alloc] init];
[person eat:apple];

// OUTPUT:
// Apple - -[Fruit taste]
```

Obj-C 中进行运行时检查的方法主要是 `isKindOfClass:` 和 `isMemberOfClass:`，前者可以检查是否为本类或其子类，后者只检查是否为本类。所以 Obj-C 中可以使用这两个方法来进行类型内省。

### 反射

```objc
id person = [[NSClassFromString(@"Person") alloc] init];
id orange = [[NSClassFromString(@"Orange") alloc] init];
[person performSelector:NSSelectorFromString(@"eat:") withObject:orange];

// OUTPUT:
// Orange - -[Fruit taste]
```

利用 Obj-C 强大的运行时，可以直接在运行时通过字符串得到类对象，进而创建实例对象，并执行方法。这就是 Obj-C 中的反射。

## Swift

### 内省

### 反射

## Reference

- [Wikipedia - Type introspection](https://en.wikipedia.org/wiki/Type_introspection)
- [Wikipedia - Reflection (computer programming)](https://en.wikipedia.org/wiki/Reflection_(computer_programming))