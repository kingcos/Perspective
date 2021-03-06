# Practice - Obj-C & Swift 的类型内省与反射

| Date | Notes | Swift | Demo |
|:-----:|:-----:|:-----:|:-----:|
| 2019-04-08 | 首次提交 | 4.2 | [Type_Introspection_and_Reflection](Type_Introspection_and_Reflection/) |

## Preface

许多编程语言中都有类型内省（又称自省，Introspection）和反射（Reflection）这两个概念，本文将探讨一下 Obj-C 和 Swift 中类型内省和反射的相关概念与具体使用。

### What

维基百科中对于类型内省定义如下：

> In computing, *type introspection* is the ability of a program to **examine** the type or properties of an object at runtime. Some programming languages possess this capability.
> 
> Introspection should not be confused with reflection, which goes a step further and is the ability for a program to manipulate the values, meta-data, properties and/or functions of an object at runtime. Some programming languages - e.g. Java, Python and Go - also possess that capability.
>
> —— Type introspection, Wikipedia
> 
> 译：
> 
> 在计算机科学中，类型内省指程序在运行时**检查**类型或属性的能力。一些编程语言拥有该能力。
>
> 内省不应该和反射混淆，反射更深入一步，其是一种程序在运行时制造对象的值、元数据、属性、和/或方法的能力。一些编程语言——如 Java、Python 和 Go，同样拥有该能力。
>
> —— 类型内省，维基百科

维基百科中对于反射定义如下：

> In computer science, **reflection** is the ability of a computer program to examine, introspect, and modify its own structure and behavior at runtime.
>
> —— Reflection (computer programming), Wikipedia
> 
> 译：
> 
> 在计算机科学中，**反射**是程序在运行时检查、内省并修改其自身结构和行为的能力。
>
> —— 反射（计算机编程），维基百科

从以上的定义中可以得知，类型内省和反射的共同点是程序在运行时的一种能力，不同点则是，内省只是一种检查机制，而反射广义上不仅包括检查，也拥有改变编译时刻原有结构的能力。对于具体的某种编程语言，可能根本不支持类型内省和反射，也可能仅支持内省，又或者同时支持内省和反射。

## Obj-C

### 内省

Obj-C 中的 `id` 类型本质是指向 Obj-C 任意对象的指针。

```objc
// objc.h
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

/// Represents an instance of a class.
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;
```

在 `Person` 类中定义一个参数为 `id` 类型的方法，并在运行时检查该参数的实际类型，以执行不同的方法。

```objc
@implementation Person
- (void)eat:(id)fruit {
    // 检查是否是 Fruit 类或其子类
    if ([fruit isKindOfClass:Fruit.class]) {
        if ([fruit isMemberOfClass:Apple.class]) {
            // 检查是否是 Apple 类
            [(Apple *)fruit tasteApple];
        } else if ([fruit isMemberOfClass:Orange.class]) {
            // 检查是否是 Orange 类
            [(Orange *)fruit tasteOrange];
        } else {
            [fruit taste];
        }
    }
}

+ (void)introspectionDemo {
    Person *person = [[Person alloc] init];
    Apple *apple = [[Apple alloc] init];
    
    [person eat:apple];
}
@end

// OUTPUT:
// Apple - -[Apple tasteApple]
```

在 Obj-C 中进行运行时检查的方法主要是 `isKindOfClass:` 检查对象是否为本类或其子类的类型，以及 `isMemberOfClass:` 只检查对象是否为本类的类型。

### 反射

```objc
+ (void)reflectionDemo {
    id person = [[NSClassFromString(@"Person") alloc] init];
    id orange = [[NSClassFromString(@"Orange") alloc] init];
    [person performSelector:NSSelectorFromString(@"eat:") withObject:orange];
}

// OUTPUT:
// Orange - -[Fruit tasteOrange]
```

由于 Obj-C 本身的运行时已经非常强大，反射的概念倒很少提及，但其实这些运行时的能力就可以被认为是反射。我们可以直接在运行时通过字符串得到类对象，进而创建实例对象，并执行方法。但这种灵活性也会带来一些风险，正如在 `performSelector:` 方法处，编译器会警告「PerformSelector may cause a leak because its selector is unknown」，所以 Apple 在设计 Swift 时，其实有意削减了类似 Obj-C 的动态特性。

## Swift

### 内省

由于 Swift 和 Obj-C 能够互相桥接，Swift 中也可以访问到 Obj-C 中的类和方法等信息。Swift 中的 `AnyObject` 类型即是桥接了 Obj-C 中的 `id` 类型，代表任何 `class` 类型的对象实例。

```swift
class Animal {
    func play(_ toy: AnyObject) {
        // 检查是否是 Toy 或其子类
        // Type.self 可以得到类型本身
        if toy.isKind(of: Toy.self) {
            if toy.isMember(of: Ball.self) {
                // 检查是否是 Ball 类
                (toy as! Ball).playWithBall()
            } else if toy.isMember(of: Doll.self) {
                // 检查是否是 Doll 类
                (toy as! Doll).playWithDoll()
            } else {
                (toy as! Toy).playWithToy()
            }
        }
    }
    
    class func introspectionDemo() {
        let ball = Ball()
        let dog = Animal()
        
        dog.play(ball)
    }
}

// OUTPUT:
// playWithBall()
````

仿照 Obj-C 中的方法，桥接过来的 `isKind(of: )` 和 `isMember(of: )` 也可以用于运行时检查 `class` 类型。但其实在 Swift 中使用更多的是结构体和枚举类型，所以 `Any` 类型应运而出。

```swift
struct ToyCar {
    func playWithToyCar() {
        print(#function)
    }
}

class Animal {
    func play2(_ toy: Any) {
        // 检查是否是 Toy 或其子类
        if toy is Toy {
            (toy as! Toy).playWithToy()
        } else if (toy is ToyCar) {
            // 检查是否是 ToyCar 结构体类型
            (toy as! ToyCar).playWithToyCar()
        }
    }

    class func introspectionDemo2() {
        let car = ToyCar()
        let dog = Animal()
        
        dog.play2(car)
    }
}

// OUTPUT:
// playWithToyCar()
```

Swift 中的 `Any` 比 `AnyObject` 更加通用，可以代表任何类型的对象实例。Swift 中的 `is` 关键字，可以判断是否为某种结构体或枚举等类型；对于 `class` 类型，`is` 等同于 `isKind(of: )` 的作用，即判断是否为本类或子类的类型。

### 反射

```swift
/// A type that explicitly supplies its own mirror.
///
/// You can create a mirror for any type using the `Mirror(reflecting:)`
/// initializer, but if you are not satisfied with the mirror supplied for
/// your type by default, you can make it conform to `CustomReflectable` and
/// return a custom `Mirror` instance.
public protocol CustomReflectable {

    /// The custom mirror for this instance.
    ///
    /// If this type has value semantics, the mirror should be unaffected by
    /// subsequent mutations of the instance.
    public var customMirror: Mirror { get }
}
```

虽然 Swift 的运行时远不如 Obj-C 强大，但 Swift 中反射设计了专门的 API，默认情况下所有类型都支持创建镜像（Mirror），开发者也可以根据需要实现 `CustomReflectable` 协议来自定义镜像。

```swift
struct Computer {
    var system: String
    var memorySize: Int
    
    let run = {
        print(#function)
    }
}

let cpt = Computer(system: "macOS", memorySize: 16)
let mirror = Mirror(reflecting: cpt)

if let displayStyle = mirror.displayStyle {
    print("mirror's style: \(displayStyle).")
}

print("mirror's properties count: \(mirror.children.count)")

for (label, value) in mirror.children {
    switch value {
    case let function as () -> Void:
        function()
    default:
        print("\(label ?? "nil") - \(value)")
    }
}

// DEBUG OUTPUT:
// mirror's style: struct.
// mirror's properties count: 2
// system - macOS
// memorySize - 16
// Computer
// param: 
```

通过镜像类型，可以从任意实例（包括 `class`、`struct`、`enum` 的实例）中获取到属性等信息，`Mirro` 中的 `children` 属性是 `Mirror.Child` 集合类型，`Child` 是键值元组类型：`(label: String?, value: Any)`。在 Swift 中，函数也是一类公民（First class），完全可以当作一种属性，因此也可以作为 `children` 内的信息，尝试将 `value` 其转换为函数类型，即可以执行（如上 `function()`）。需要注意的是，这里的函数其实是闭包（Closure），即匿名函数，此时 `#function` 并不能得到函数名称。另外，含有参数的函数类型属性暂时还不能支持，在 Debug 模式下，程序没有崩溃，但参数无法打印；切换到 Release 模式下，程序将发生参数野指针错误导致崩溃「Thread 1: EXC_BAD_ACCESS」。

由此可见，反射在 Swift 中目前还比较弱，在类型安全还是运行时强大的自由选择题中，Swift 显然更加倾向于前者。

## Reference

- [Type introspection - Wikipedia](https://en.wikipedia.org/wiki/Type_introspection)
- [Reflection (computer programming) - Wikipedia](https://en.wikipedia.org/wiki/Reflection_(computer_programming))
- [REFLECTION 和 MIRROR - onevcat](https://swifter.tips/reflect/)
- [Swift 中的 Reflection（反射） - 贾物体](https://zhuanlan.zhihu.com/p/33945268)
