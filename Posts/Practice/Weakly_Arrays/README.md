# Practice - 在 Swift 中对数组元素的弱引用

- Source link: [Weakly Arrays - objc.io](https://www.objc.io/blog/2017/12/28/weak-arrays/)

| Date | Notes | Swift | Xcode |
|:-----:|:-----:|:-----:|:-----:|
| 2018-03-08 | 首次提交 | 4.1 | 9.2 |

## Preface

Practice，即实践。该系列将会把网上各处的知识点进行实际的代码总结、扩展。文章将着重 Demo，非核心相关将以链接方式放置在文末。

为了方便下述 Demo，这里定义一个 Pencil 类，并会使用 `func CFGetRetainCount(_ cf: CoreFoundation.CFTypeRef!) -> CFIndex` 方法，即传入一个 `CFTypeRef` 类型的对象即可获取其引用计数。什么是 `CFTypeRef`？查阅[官方文档](https://developer.apple.com/documentation/corefoundation/cftyperef)即可得知 `typealias CFTypeRef = AnyObject`，所以 `CFTypeRef` 其实就是 `AnyObject`。而 `AnyObject` 又是所有类隐含遵守的协议。

```Swift
class Pencil {
    var type: String
    var price: Double
    
    init(_ type: String, _ price: Double) {
        self.type = type
        self.price = price
    }
}

CFGetRetainCount(Pencil("2B", 1.0) as CFTypeRef)
// 1

let pencil2B = Pencil("2B", 1.0)
let pencilHB = Pencil("HB", 2.0)

CFGetRetainCount(pencil2B as CFTypeRef)
CFGetRetainCount(pencilHB as CFTypeRef)
// 2 2
```

## What

在 Swift 中，当创建一个数组时，数组本身对于添加进去的对象元素默认是强引用（Strong），会使得其引用计数自增。

```
let pencilBox = [pencil2B, pencilHB]

CFGetRetainCount(pencil2B as CFTypeRef)
CFGetRetainCount(pencilHB as CFTypeRef)
// 3 3
```

那么今天的问题即是，如何使得数组本身对数组元素进行弱引用？

## How

### WeakBox

```Swift
final class WeakBox<A: AnyObject> {
    weak var unbox: A?
    init(_ value: A) {
        unbox = value
    }
}

struct WeakArray<Element: AnyObject> {
    private var items: [WeakBox<Element>] = []
    
    init(_ elements: [Element]) {
        items = elements.map { WeakBox($0) }
    }
}

extension WeakArray: Collection {
    var startIndex: Int { return items.startIndex }
    var endIndex: Int { return items.endIndex }
    
    subscript(_ index: Int) -> Element? {
        return items[index].unbox
    }
    
    func index(after idx: Int) -> Int {
        return items.index(after: idx)
    }
}
```

定义好一个可以将所有类型的对象转化为弱引用的类，再通过构建好的新类型，将每个强引用元素转换为弱引用元素。利用 Extension，还可以遵守协议，扩展一些集合方法。

```Swift
let weakPencilBox1 = WeakArray([pencil2B, pencilHB])

CFGetRetainCount(pencil2B as CFTypeRef)
CFGetRetainCount(pencilHB as CFTypeRef)
// 3 3

let firstElement = weakPencilBox1.filter { $0 != nil }.first
firstElement!!.type
// 2B

CFGetRetainCount(pencil2B as CFTypeRef)
CFGetRetainCount(pencilHB as CFTypeRef)
// 4 3 Note: 这里的 4 是因为 firstElement 持有（Retain）了 pencil2B，导致其引用计数增 1
```

### NSPointerArray

```Swift
let weakPencilBox2 = NSPointerArray.weakObjects()

let pencil2BPoiter = Unmanaged.passUnretained(pencil2B).toOpaque()
let pencilHBPoiter = Unmanaged.passUnretained(pencilHB).toOpaque()

CFGetRetainCount(pencil2B as CFTypeRef)
CFGetRetainCount(pencilHB as CFTypeRef)
// 4 3

weakPencilBox2.addPointer(pencil2BPoiter)
weakPencilBox2.addPointer(pencilHBPoiter)

CFGetRetainCount(pencil2B as CFTypeRef)
CFGetRetainCount(pencilHB as CFTypeRef)
// 4 3
```

> A collection similar to an array, but with a broader range of available memory semantics.
> 
> — [*Apple Documentation*](https://developer.apple.com/documentation/foundation/nspointerarray)

即 `NSPointerArray` 比普通的 Array 多了一层内存语义。可以更方便的控制其中元素的引用关系。但由于仍是 `NS-` 开头，少了 Swift 中着重强调的类型安全，所以更推荐第一种做法。

### Extension

其实不只是数组，集合类型的数据结构对其中的元素默认均是强引用。所以为了更加方便地自定义内存管理方式，Objective-C/Swift 中均有普通类型的对应。但为了突出 Swift 的类型安全，仍然建议采取第一种的 `WeakBox` 方式。

- Set: 

```Swift
// NSHashTable - Set
let weakPencilSet = NSHashTable<Pencil>(options: .weakMemory)

weakPencilSet.add(pencil2B)
weakPencilSet.add(pencilHB)
```

- Dictionary:

```Swift
// NSMapTable - Dictionary
class Eraser {
    var type: String
    
    init(_ type: String) {
        self.type = type
    }
}

let weakPencilDict = NSMapTable<Eraser, Pencil>(keyOptions: .strongMemory,
                                                valueOptions: .weakMemory)
let paintingEraser = Eraser("Painting")

weakPencilDict.setObject(pencil2B, forKey: paintingEraser)
```

## Reference

- [Weakly Arrays - objc.io](https://www.objc.io/blog/2017/12/28/weak-arrays/)
- [Automatic Reference Counting - The Swift Programming Language (Swift 4.1)](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html)
- [How do I declare an array of weak references in Swift? - StackOverflow](https://www.google.com.sg/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi3lrPE4dnZAhWBLo8KHcimAwwQFggqMAA&url=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F24127587%2Fhow-do-i-declare-an-array-of-weak-references-in-swift&usg=AOvVaw0XHV471sUykyviiUH7TX2o)
- [Swift Arrays Holding Elements With Weak References - Macro Santa](https://marcosantadev.com/swift-arrays-holding-elements-weak-references/)