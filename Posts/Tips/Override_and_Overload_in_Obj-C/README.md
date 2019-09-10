# Tips - Obj-C 中的重载与重写

| Platform |
|:-----:|
| macOS 10.14.2 |

## 重载

> In some programming languages, function overloading or method overloading is the ability to create multiple functions of the same name with different implementations. Calls to an overloaded function will run a specific implementation of that function appropriate to the context of the call, allowing one function call to perform different tasks depending on context.
>
> Function overloading - Wikipedia
>
> 译：
>
> 在某些编程语言中，函数重载或方法重载是指一种可以创建多个同名函数但拥有不同实现的能力。调用重载函数将执行符合上下文的函数调用，即允许一个函数调用根据上下文执行不同的任务。
>
> 函数重载 - 维基百科

如维基百科所讲，简言之，重载（Overload）指在同一个类中，存在相同函数名但不同参数个数或不同参数类型或不同返回值的函数。但由于 Obj-C 是消息结构的语言，其意义上的方法调用实质上是消息传递。

```objc
@interface Computer : NSObject

- (void)run;
- (void)run:(NSString *)sth;

@end

@implementation Computer

- (void)run {
    NSLog(@"run");
}
- (void)run:(NSString *)sth {
    NSLog(@"run - %@", sth);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Computer *cpt = [[Computer alloc] init];
        [cpt run];
        [cpt run:@"sth"];
    }
    return 0;
}
```

我们定义一个继承自 `NSObject` 的 `Computer` 类，其拥有两个实例方法。尝试将上述代码翻译为 C++，`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-64.cpp`。由于 Obj-C 是消息结构的语言，`objc_msgSend` 处便是其消息传递之处，我们可以发现原本的方法都被变成了字符串：`sel_registerName("alloc")`、`sel_registerName("init")`、`sel_registerName("run")` 和 `sel_registerName("run:")`。实际上这些字符串就是 Obj-C 方法的方法名，方法名忽略了参数名以及返回值，实例方法与类方法的区别也只是不同的消息接收对象。所以严格意义上讲，Obj-C 是不支持方法重载的，因为它不允许同名函数的存在。但如果按不同参数个数也属于方法重载来说，Obj-C 仅支持参数个数不同的重载，每个参数都将在方法名后多生成一个 `:` 从而可以区分。

```cpp
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        Computer *cpt = ((Computer *(*)(id, SEL))(void *)objc_msgSend)((id)((Computer *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("Computer"), sel_registerName("alloc")), sel_registerName("init"));
        ((void (*)(id, SEL))(void *)objc_msgSend)((id)cpt, sel_registerName("run"));
        ((void (*)(id, SEL, NSString *))(void *)objc_msgSend)((id)cpt, sel_registerName("run:"), (NSString *)&__NSConstantStringImpl__var_folders_qt_ctbfp1yd2gn7bv6y6v6qgvgm0000gn_T_main_ea7dac_mi_0);
    }
    return 0;
}
```

## 重写

> Method overriding, in object-oriented programming, is a language feature that allows a subclass or child class to provide a specific implementation of a method that is already provided by one of its superclasses or parent classes. The implementation in the subclass overrides (replaces) the implementation in the superclass by providing a method that has same name, same parameters or signature, and same return type as the method in the parent class. The version of a method that is executed will be determined by the object that is used to invoke it. If an object of a parent class is used to invoke the method, then the version in the parent class will be executed, but if an object of the subclass is used to invoke the method, then the version in the child class will be executed. Some languages allow a programmer to prevent a method from being overridden.
> 
> Method overriding - Wikipedia
>
> 译：
> 
> 在面向对象编程中，方法重写是一种语言特性，它允许子类提供其父类或超类已经提供的特定方法实现。子类中的实现通过提供与父类中的方法相同的名称、相同的参数或签名以及相同的返回类型的方法来覆盖（替换）超类中的实现。执行方法的版本将由调用对象确定。如果父类对象调用该方法，则将执行父类中的版本，但如果使用子类对象调用该方法，则将执行子类中的版本。某些语言允许程序员阻止方法被覆盖。
>
> 方法重写 - 维基百科

```objc
@interface Mac : Computer
@end

@implementation Mac

- (void)run:(NSString *)sth {
    NSLog(@"Mac - run - %@", sth);
}

@end
```

完全不同于重载，重写（Override）是指在子类中重写父类的方法，且方法名、参数类型、参数个数、返回值类型等必须一致。Obj-C 是完全支持方法重写的：

```objc
Computer *cpt = [[Computer alloc] init];
[cpt run:@"cpt_run"];
Computer *mac = [[Mac alloc] init];
[mac run:@"mac_run"];

// OUTPUT:
// run - cpt_run
// Mac - run - mac_run
```

## Reference

- [Function overloading - Wikipedia](https://en.wikipedia.org/wiki/Function_overloading)
- [Tips - 将 Obj-C 代码翻译为 C++ 代码](https://github.com/kingcos/Perspective/issues/72)
- [Method overriding - Wikipedia](https://en.wikipedia.org/wiki/Method_overriding)