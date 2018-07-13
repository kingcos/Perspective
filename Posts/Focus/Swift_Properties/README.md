# Focus - 浅谈 Swift 中的属性（Property）

| Date | Notes | Swift | Xcode |
|:-----:|:-----:|:-----:|:-----:|
| 2017-04-27 | 扩充 #延迟存储属性# 部分并新增 #devxoul/Then# | 3.1 | 8.3.2 |
| 2016-10-26 | 首次提交 | 3.0 | 8.1 Beta 3 |

## 前言

Swift 中的属性分为存储属性与计算属性，存储属性即为我们平时常用的属性，可以直接赋值使用，而计算属性不直接存储值，而是根据其他（存储）属性计算得来的值。

在其他面向对象的编程语言中，例如 Java 和 Objective-C 中，get 和 set 方法提供了统一、规范的接口，可以使得外部访问或设置对象的私有属性，而不破坏封装性，也可以很好的控制权限（选择性实现 get 或 set 方法）。而 Swift 中似乎并没有见到类似的 get 和 set 方法，而 Swift 使用了一种名为属性观察器的概念来解决该问题。

本文简单介绍下 Swift 中的这两种属性，以及属性观察器。

## 延迟存储属性

- 存储属性使用广泛，即是类或结构体中的变量或常量，可以直接赋初始值，也可以修改其初始值（仅指变量）。
- 延迟存储属性是指第一次使用到该变量再进行运算（这里的运算不能依赖其他成员属性，但可以使用静态／类属性）。
- 延迟存储属性必须声明为 `var` 变量，因为其属性值在对象实例化前可能无法得到，而常量必须在初始化完成前拥有初始值。
- 在 Swift 中，可以将消耗性能才能得到的值作为延迟存储属性，即懒加载。
- 全局的常量和变量也是延迟存储属性，但不需要显式声明为 lazy（不支持 Playground）。

### Demo

- 这里假定在 ViewController.swift 有一个属性，需要从 plist 文件读取内容，将其中的字典转为模型。如果 plist 文件中内容很多，那么就十分消耗性能。如果用户不触发相应事件，也没有必要加载这些数据。那么这里就很适合使用懒加载，即延迟存储属性。

ViewController.swift

```swift
class ViewController: UIViewController {

    lazy var goods: NSArray? = {
        var goodsArray: NSMutableArray = []

        if let path = Bundle.main.path(forResource: "Goods", ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                for goodsDict in array {
                    goodsArray.add(Goods(goodsDict as! NSDictionary))
                }
                return goodsArray
            }
        }

        return nil
    }()

    // 这样也是允许的，可以把初始化的代码直接放在构造方法中
    lazy var testLazy = Person()
}

class Person {}
```

*可以在延迟存储属性运算的代码中加入打印语句，即可验证其何时初始化。*

### Lazy 初始化的「演变」过程

- 根据上面 Demo，延迟存储属性的初始化代码部分可能有些让人迷惑，但其实也是初始化的一步步的演变过程。在 [@Onetaway](https://weibo.com/u/1683298872) 的 [【菜鸡Playground 1】Swift 中 lazy initialization](http://www.bilibili.com/video/av10139582/) 中也有描述这个过程，简单用代码表示也如下所示：

```Swift
struct Person {
    var name = ""

    init() {
        print(#function)
    }
}

// 直接初始化
let p1 = Person()

// 利用闭包
let getOnePerson = { () -> Person in
    let p = Person()
    return p
}

let p2 = getOnePerson()

// 闭包执行
let p3 = { () -> Person in
    let p = Person()
    return p
}()

// 简化
let p4: Person = {
    let p = Person()
    return p
}()
```

### Lazy 方法

- [@Onevcat](https://onevcat.com) 的 Swifter Tips 中也提到，在 Swift 标准库中，也有一些 Lazy 方法，就可以在不需要运行时，避免消耗太多的性能。

```Swift
let data = 0...3
let result = data.lazy.map { (i: Int) -> Int in
    print("Handling...")
    return i * 2
}

print("Begin:")
for i in result {
    print(i)
}
// OUTPUT:
// Begin:
// Handling...
// 0
// Handling...
// 2
// Handling...
// 4
// Handling...
// 6
```

## devxoul/Then

- 在 [@没故事的卓同学](http://www.jianshu.com/u/88a056103c02)的[【菜鸡Playground 2】Swift 中 lazy initialization 的使用场景](http://www.bilibili.com/video/av10142408/)中提到了一个 [devxoul/Then](https://github.com/devxoul/Then) 库，为 Swift 的构造方法加入语法糖。

### Demo

ViewController.swift

```Swift
import UIKit
import Then

class ViewController: UIViewController {
    lazy var myLabel = UILabel().then {
        $0.text = "My Label"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        myLabel.frame = CGRect(x: 0.0, y: 0.0,
                               width: 100.0, height: 100.0)
        view.addSubview(myLabel)
    }
}
```

### Source Code

- Then 的核心源码部分总共只有不到 20 行，非常简单易懂。
- Then 库中定义了一个名为 Then 的空协议，之后通过协议扩展（Protocol Extension），来为协议添加默认的方法实现。

### `then()`

- 因为 `then()` 内部将 `self` 返回，即可在初始化完成后，调用该方法，并在闭包中设置属性，而且不需要再将自身返回。
- 支持 NSObject 子类，也可以将自定义类型（仅支持 AnyObject 类型，即 class）声明实现该协议即可（协议扩展已经拥有默认实现，所以仅声明实现协议即可）。

```Swift
extension Then where Self: AnyObject {

  /// Makes it available to set properties with closures just after initializing.
  public func then(_ block: (Self) -> Void) -> Self {
    block(self)
    return self
  }

}
```

### `with()`

- `then()` 适用于引用类型，而 `with()` 适用于值类型。
- 使用了 `inout` 确保方法内外共用一个值类型变量。

```Swift
extension Then where Self: Any {

  /// Makes it available to set properties with closures just after initializing and copying the value types.
  public func with(_ block: (inout Self) -> Void) -> Self {
    var copy = self
    block(&copy)
    return copy
  }

}
```

### `do()`

- `do()` 使得可以直接在闭包中简单地执行一些操作。

```Swift
extension Then where Self: Any {
  /// Makes it available to execute something with closures.
  public func `do`(_ block: (Self) -> Void) {
    block(self)
  }

}
```

## 计算属性

- 举个例子，一个**矩形**结构体（类同理），拥有**宽度**和**高度**两个存储属性，以及一个只读**面积**的计算属性，因为通过设置矩形的宽度和高度即可**计算**出矩形的面积，而无需直接设置其值。当宽度或高度改变，面积也应当可以跟随其变化（反之不能推算，因此为只读）。为说明 setter 以及便捷 setter 说明，另外添加了**原点**（矩形左下角）存储属性，以及**中心**计算属性。

### Demo

```swift
struct Point {
    var x = 0.0
    var y = 0.0
}

struct Rectangle {
    var width = 0.0
    var height = 0.0
    var origin = Point()

    // 只读计算属性
    var size: Double {
        get {
            return width * height
        }
    }

    // 只读计算属性简写为
//    var size: Double {
//        return width * height
//    }

    var center: Point {
        get {
            return Point(x: origin.x + width / 2,
                         y: origin.y + height / 2)
        }

        set(newCenter) {
            origin.x = newCenter.x - width / 2
            origin.y = newCenter.y - height / 2
        }

        // 便捷 setter 声明
//        set {
//            origin.x = newValue.x - width / 2
//            origin.y = newValue.y - height / 2
//        }
    }

}

var rect = Rectangle()
rect.width = 100
rect.height = 50
print(rect.size)

rect.origin = Point(x: 0, y: 0)
print(rect.center)

rect.center = Point(x: 100, y: 100)
print(rect.origin)

// 5000.0
// Point(x: 50.0, y: 25.0)
// Point(x: 50.0, y: 75.0)
```

*综上，getter 可以根据存储属性推算计算属性的值，setter 可以在被赋值时根据新值倒推存储属性，但它们与我们在其他语言中的 get/set 方法却不一样。*

## 属性观察器

- 属性观察器算是 Swift 中的一个 feature，变量在设值**前**会先进入 `willSet`，这时默认 `newValue` 等于即将要赋值的值，而变量本身尚未改变。变量在设值**后**会先进入 `didSet`，这时默认 `oldValue` 等于赋值前变量的值，而变量变为新值。
- 这样，开发者即可在 `willSet` 和 `didSet` 中进行相应的操作，如果只是取值和设值而不进行额外操作，那么直接使用点语法即可。但是有时候一个变量只需要被访问，而不能在外界赋值，那么可以使用[访问控制修饰符](https://maimieng.com/2016/25/)加上 `(set)` 即可私有化 set 方法。例如 `fileprivate(set)`，`private(set)`，以及 `internal(set)`。值得注意的是，这里的访问控制修饰符修饰的是 set 方法，访问权限（即 get）是另外设置的。例如 `public fileprivate(set) var prop = 0`，该变量全局可以访问，但只有同文件内可以使用 set 方法。

### Demo

```swift
struct Animal {
    // internal 为默认权限，可不加
    internal private(set) var privateSetProp = 0

    var hungryValue = 0 {
        // 设置前调用
        willSet {
            print("willSet \(hungryValue) newValue: \(newValue)")
        }

        // 设置后调用
        didSet {
            print("didSet \(hungryValue) oldValue: \(oldValue)")
        }

        // 也可以自己命名默认的 newValue/oldValue
        // willSet(new) {}
        // didSet(old) {}
    }
}

var cat = Animal()

// private(set) 即只读
// cat.privateSetProp = 10
print(cat.privateSetProp)

cat.hungryValue += 10
print(cat.hungryValue)

// 0
// willSet 0 newValue: 10
// didSet 10 oldValue: 0
// 10
```

## 总结

Swift 的这几个 feature 我未曾在其他语言中见过，对于初学者确实容易造成凌乱。特别是 getter/setter 以及属性观察器中均没有代码提示，容易造成手误，代码似乎也变得臃肿。但是熟悉之后，这些也都能完成之前的功能，甚至更加细分。保持每一部分可控，也使得整个程序更加严谨，更加安全。

## 参考

- [浅谈 Swift 3 中的访问控制](http://www.jianshu.com/p/80810efe5229)
- [Access Control](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AccessControl.html)
- [Properties](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html)
- [【菜鸡Playground 1】Swift 中 lazy initialization](http://www.bilibili.com/video/av10139582/)
- [【菜鸡Playground 2】Swift 中 lazy initialization 的使用场景](http://www.bilibili.com/video/av10142408/)
- [devxoul/Then](https://github.com/devxoul/Then)
- [lazy 修饰符和 lazy 方法](http://swifter.tips/lazy/)
