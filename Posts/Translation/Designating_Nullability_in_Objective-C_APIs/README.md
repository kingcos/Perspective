# Translation - [译]在 Objective-C API 中指定可空性

作者 | 原文链接
--- | ---
Apple Inc. | [Designating Nullability in Objective-C APIs](https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/designating_nullability_in_objective-c_apis)

使用可空性（Nullability）标志或标志一块区域，以控制将 Objective-C 声明导入 Swift 中的方式。

- **框架：**
  - Swift 标准库

---

## 概览

在 Objective-C 中，常用可以为空的指针来和对象的引用打交道，这（个空）就是 Objective-C 中的 `nil`。在 Swift 中，所有值——包括对象实例——都被确保为非空（Non-null）。取而代之，表示一个可能丢失的值可以将其包裹在可选（Optional）类型中。当我们需要表示一个值的丢失，可以使用 `nil` 值。

我们可以在 Objective-C 的代码中标示声明，以指示一个实例是否可以有空（Null）或 `nil` 值。这些标志改变了 Swift 如何导入声明（的方式）。举个 Swift 如何导入未标示声明的例子，如下：

```objc
@interface MyList : NSObject
- (MyListItem *)itemWithName:(NSString *)name;
- (NSString *)nameForItem:(MyListItem *)item;
@property (copy) NSArray<MyListItem *> *allItems;
@end
```

Swift 导入了每个对象实例的参数、返回值、以及作为隐式包裹可选的属性（译者注：隐式包裹即 `Type!`，表示该值被保证为非 nil，即可在后续使用时省略 `?` 解包，但当该值为 nil 却没有使用可选解包时，程序将发生崩溃，该点也在另外一篇文章内有提及，有需要的读者可以参考文末 Reference 部分）。

```swift
class MyList: NSObject {
    func item(withName name: String!) -> MyListItem!
    func name(for item: MyListItem!) -> String!
    var allItems: [MyListItem]!
}
```

## 为单独的声明标记可空性

在 Objective-C 代码中使用可空性标志可以指定参数类型、属性类型、或者返回值类型是否为可空的。标示属性声明、参数类型、以及返回值类型这些简单对象或者 Block 指针，可以使用 `nullable`、`nonnull`、以及 `null_resettable` 属性标志。如果一个类型没有提供可空性信息，Swift 将不区分可选和非可选引用，并将该类型作为隐式可选解包导入。

下表描述了 Swift 如何导入带有不同可空性标志的类型：

- 非空（Nonnullable）——无论是直接标示抑或包含在一个标示区域内，都作为非可选（类型）导入
- 可空（Nullable）——作为可选（类型）导入
- 不带有可空性标示或 `null_resettable` 标志——作为隐式解包可选（类型）导入

下面的代码展示了标示后的 `MyList` 类型。两个方法的返回值被标示为 `nullable`，因为如果列表不包含给定的列表项或名称，方法将返回 `nil`。所有其他对象实例均被标示为 `nonnull`。

```objc
@interface MyList : NSObject
- (nullable MyListItem *)itemWithName:(nonnull NSString *)name;
- (nullable NSString *)nameForItem:(nonnull MyListItem *)item;
@property (copy, nonnull) NSArray<MyListItem *> *allItems;
@end
```

通过这些标志，Swift 将不使用任何隐式包裹可选来导入 `MyList` 类型：

```swift
class MyList: NSObject {
    func item(withName name: String) -> MyListItem?
    func name(for item: MyListItem) -> String?
    var allItems: [MyListItem]
}
```

`nullable` 和 `nonnull` 标志是 `_Nullable` 和 `_Nonnull` 的简化版。当对指针类型使用 `const` 关键字时，我们可以在绝大多数上下文中使用它们。复杂的指针类型，比如 `id *` 必须明确标示所使用的标志。举个例子，一个指向可空对象引用的不可空的指针，声明为 `_Nullable id * _Nonnull`。

## 标示区域不可空

>（译者注：原标题为 Annototate Regions as Nonnullable，但英文中并无 Annototate 一词，结合上下文此处应该是 Annotate 的笔误，特此注明。）

通过标示整个区域为可空性检查可以简化标示 Objective-C 代码的过程。标记 `NS_ASSUME_NONNULL_BEGIN` 和 `NS_ASSUME_NONNULL_END` 之间区域内的代码，只需要标示可空类型的声明。未标记声明的部分将被当作是非空的。

将 `MyList` 声明标记为可空性检查降低了所需要的标志数量。Swift 将以与上一节相同的方式导入该类型。

```objc
NS_ASSUME_NONNULL_BEGIN

@interface MyList : NSObject
- (nullable MyListItem *)itemWithName:(NSString *)name;
- (nullable NSString *)nameForItem:(MyListItem *)item;
@property (copy) NSArray<MyListItem *> *allItems;
@end

NS_ASSUME_NONNULL_END
```

注意，尽管在检查区域内，但`typedef` 的类型不会被假定为非空，因为它们内在并非是可空的。

## 参阅

### 定制 Objective-C API 

### [为 Swift 重命名 Objective-C API](https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/renaming_objective-c_apis_for_swift)

使用 `NS_SWIFT_NAME` 宏为 Swift 定制 API 名称。

### [为 Swift 改进 Objective-C 声明](https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/improving_objective-c_api_declarations_for_swift)

使用 `NS_REFINED_FOR_SWIFT` 宏以改变 API 是如何导入 Swift 中的。

### [组合相关的 Objective-C 常量](https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/grouping_related_objective-c_constants)

在 Objective-C 类型中添加宏以在 Swift 中组合他们的值。

### [在 Objective-C 中标记 API 可用性](https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/marking_api_availability_in_objective-c)

使用宏以表示 Objective-C API 的可用性。

### [让 Objective-C API 在 Swift 中不可用](https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/making_objective-c_apis_unavailable_in_swift)

使用 `NS_SWIFT_UNAVAILABLE` 宏以在 Swift 中禁用 API。

---

> 译者注：
>
> 1. API 即通用意义上的接口，不再翻译；
> 
> 2. 由于 Null 和 Nil 含义类似，均为空，在本文中为表区分，将 Null 翻译为「空」，Nil 不作翻译，代码中不会进行任何翻译；
> 
> 3. 由于英文语法规范，通常会有主语 You，我可能会在不改变核心意义的情况下，会忽略人称，在部分情况将其改为第一人称「我们」。

## Reference

- [kingcos - Objective-C 与 Swift 桥接中的坑](https://github.com/kingcos/Perspective/issues/68)