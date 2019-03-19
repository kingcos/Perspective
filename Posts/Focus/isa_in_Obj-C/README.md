# Focus - iOS 中的 isa

| Date | Notes |
|:-----:|:-----:|
| 2019-03-18 | 首次提交 |

## 对象的分类

Obj-C 中的对象，主要有三种，实例（Instance）对象、类（Class）对象，以及元类（Meta-class）对象。类对象和元类对象的类型均为 `Class`，即 `typedef struct objc_class *Class;`，所以它们的结构其实是一致的。

![](1.png)

## isa

![](2.png)

## superclass

![](3.png)

---


`objc_getClass`

参数是类名（字符串），返回类对象

`object_getClass`

如果参数是实例对象，返回类对象；如果参数是类对象，返回元类对象；如果参数是元类对象，返回 NSObject（基类）的元类对象。


isa -> superclass -> super -> ... -> superclass == nil ? nil : method

Intsance Method: isa from instance
Class Method: isa from class

ISA_MASK

