//: Playground - noun: a place where people can play
// Powered by [Kingcos](https://github.com/kingcos)

import UIKit

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

let pencilBox = [pencil2B, pencilHB]

CFGetRetainCount(pencil2B as CFTypeRef)
CFGetRetainCount(pencilHB as CFTypeRef)
// 3 3

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

// NSHashTable - Set
let weakPencilSet = NSHashTable<Pencil>(options: .weakMemory)
let weakPencilSet2 = NSHashTable<Pencil>.weakObjects()

weakPencilSet.add(pencil2B)
weakPencilSet.add(pencilHB)

// NSMapTable - Dictionary
class Eraser {
    var type: String

    init(_ type: String) {
        self.type = type
    }
}

let weakPencilDict = NSMapTable<Eraser, Pencil>(keyOptions: .strongMemory,
                                                valueOptions: .weakMemory)
let weakPencilDict2 = NSMapTable<Eraser, Pencil>.strongToWeakObjects()

let paintingEraser = Eraser("Painting")

weakPencilDict.setObject(pencil2B, forKey: paintingEraser)
