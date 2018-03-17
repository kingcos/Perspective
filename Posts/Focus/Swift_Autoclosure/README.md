# Focus - Swift 中的 @autoclosure

| Date | Notes | Swift | Xcode |
|:-----:|:-----:|:-----:|:-----:|
| 2018-01-13 | 首次提交 | 4.0.3 | 9.2 |

![@autoclosure](title.png)

## Preface

> Focus，即专注。笔者希望可以尽力将一些不是那么透彻的点透过 Demo 和 Source Code 而看到其本质。由于国内软件开发仍很大程度依赖国外的语言、知识，所以该博客中的术语将使用英文表述，除非一些特别统一的词汇或整段翻译时将使用中文，但也会在首次提及时标注英文。笔者英文水平有限，这样的目的也是尽可能减少歧义，但在其中不免有所错误，遗漏，还请大家多多批评、指正。
> 
> 本文也会同步在笔者的 GitHub 的 Perspective 仓库：[https://github.com/kingcos/Perspective](https://github.com/kingcos/Perspective)，欢迎 Star 🌟。

## What

> *Closures* are self-contained blocks of functionality that can be passed around and used in your code. Closures in Swift are similar to blocks in C and Objective-C and to lambdas in other programming languages.
> 
> — *The Swift Programming Language (Swift 4.0.3)*

Closure 在 Swift 等许多语言中普遍存在。熟悉 Objective-C 的同学一定对 Block 不陌生。两者其实是比较类似的，相较于 Block，Closure 的写法简化了许多，也十分灵活。

在 Swift 中，`@` 开头通常代表着 Attribute。`@autoclosure` 属于 Type Attribute，意味着其可以对类型（Type）作出一些限定。

## How

### 自动（Auto-）

- `@autoclosure` 名称中即明确了这是一种「自动」的 Closure，即可以让表达式（Expression）的类型转换为相应的 Closure 的类型，即在调用原本的 `func` 时，可以省略 Closure 参数的大括号；
- 其只可以修饰作为参数的 Closure，但该 Closure 必须为无参，返回值可有可无。

```Swift
func logIfTrue(_ predicate: () -> Bool) {
    if predicate() {
        print("True")
    }
}

// logIfTrue(predicate: () -> Bool)
logIfTrue { 1 < 2 }

func logIfTrueWithAutoclosure(_ predicate: @autoclosure () -> Bool) {
    if predicate() {
        print("True")
    }
}

// logIfTrueWithAutoclosure(predicate: Bool)
logIfTrueWithAutoclosure(1 < 2)
```

### Closure 的 Delay Evaluation

- Swift 中的 Closure 调用将会被延迟（Delay），即该 Closure 只有在真正被调用时，才被执行；
- Delay Evaluation 有利于有副作用或运算开销较大的代码；
- Delay Evaluation 非 `@autoclosure` 独有，但通常搭配使用。

```Swift
var array = [1, 2, 3, 4, 5]

array.removeLast()
print(array.count)

var closure = { array.removeLast() }
print(array.count)

closure()
print(array.count)

// OUTPUT:
// 4
// 4
// 3
```

### `@escaping`

- 当 Closure 的真正执行时机可能要在其所在 `func` 返回（Return）之后时，通常使用 `@esacping`，可以用于处理一些耗时操作的回调；
- `@autoclosure` 与 `@escaping` 是可以兼容的，顺序可以颠倒。

```Swift
func foo(_ bar: @autoclosure @escaping () -> Void) {
    DispatchQueue.main.async {
        bar()
    }
}
```

### 测试用例

- `swift/test/attr/attr_autoclosure.swift`
- Swift 作为完全开源的一门编程语言，这就意味着可以随时去查看其内部的实现的机制，而根据相应的测试用例，也能将正确和错误的用法一探究竟。

#### `inout`

- `autoclosure + inout doesn't make sense.`
- `inout` 与 `@autoclosure` 没有意义，不兼容；
- 下面是一个简单的 `inout` Closure 的 Demo，其实并没有什么意义。一般来说也很少会去将一个 `func` 进行 `inout`，更多的其实是用在值类型（Value Type）的变量（Variable）中。

```Swift
var demo: () -> () = {
    print("func - demo")
}

func foo(_ closure: @escaping () -> ()) {
    var closure = closure // Ignored the warning
    closure = {
        print("func - escaping closure")
    }
}

foo(demo)
demo()
// OUTPUT:
// func - demo

func bar(_ closure: inout () -> ()) {
    closure = {
        print("func - inout closure")
    }
}

bar(&demo)
demo()
// OUTPUT:
// func - inout closure
```

#### 可变参数（Variadic Parameters）

- `@autoclosure` 不适用于 `func` 可变参数。

```Swift
// ERROR
func variadicAutoclosure(_ fn: @autoclosure () -> ()...) {
    for _ in fn {}
}
```

### 源代码用例

- `swift/stdlib/public/core/Bool.swift`
- 在一些其他语言中，`&&` 和 `||` 属于短路（Short Circuit）运算符，在 Swift 中也不例外，恰好就利用了 Closure 的 Delay Evaluation 特性。

```Swift
extension Bool {
  @_inlineable // FIXME(sil-serialize-all)
  @_transparent
  @inline(__always)
  public static func && (lhs: Bool, rhs: @autoclosure () throws -> Bool) rethrows
      -> Bool {
    return lhs ? try rhs() : false
  }

  @_inlineable // FIXME(sil-serialize-all)
  @_transparent
  @inline(__always)
  public static func || (lhs: Bool, rhs: @autoclosure () throws -> Bool) rethrows
      -> Bool {
    return lhs ? true : try rhs()
  }
}
```

- `swift/stdlib/public/core/Optional.swift`
- 在 Swift 中，`??` 也属于短路运算符，这里两个实现的唯一不同是第二个 `func` 的 `defaultValue` 参数会再次返回可选（Optional）型，使得 `??` 可以链式使用。

```Swift
@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func ?? <T>(optional: T?, defaultValue: @autoclosure () throws -> T)
    rethrows -> T {
  switch optional {
  case .some(let value):
    return value
  case .none:
    return try defaultValue()
  }
}

@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func ?? <T>(optional: T?, defaultValue: @autoclosure () throws -> T?)
    rethrows -> T? {
  switch optional {
  case .some(let value):
    return value
  case .none:
    return try defaultValue()
  }
}
```

- `swift/stdlib/public/core/AssertCommon.swift`
- `COMPILER_INTRINSIC` 代表该 `func` 为编译器的内置函数：
  - `swift/stdlib/public/core/StringSwitch.swift` 中提到 `The compiler intrinsic which is called to lookup a string in a table of static string case values.`（笔者译：`编译器内置，即在一个静态字符串值表中查找一个字符串。`）；
  - WikiPedia 中解释：`In computer software, in compiler theory, an intrinsic function (or builtin function) is a function (subroutine) available for use in a given programming language which implementation is handled specially by the compiler. Typically, it may substitute a sequence of automatically generated instructions for the original function call, similar to an inline function. Unlike an inline function, the compiler has an intimate knowledge of an intrinsic function and can thus better integrate and optimize it for a given situation.`（笔者译：`在计算机软件领域，编译器理论中，内置函数（或称内建函数）是在给定编程语言中可以被编译器所专门处理的的函数（子程序）。通常，它可以用一系列自动生成的指令代替原来的函数调用，类似于内联函数。与内联函数不同的是，编译器更加了解内置函数，因此可以更好地整合和优化特定情况。`）。
- `_assertionFailure()`：断言（Assert）失败，返回类型为 `Never`；
- 该 `func` 的返回值类型为范型 `T`，主要是为了类型推断，但 `_assertionFailure()` 执行后程序就会报错并停止执行，类似 `fatalError()`，所以并无实际返回值。

```Swift
// FIXME(ABI)#21 (Type Checker): rename to something descriptive.
@_inlineable // FIXME(sil-serialize-all)
public // COMPILER_INTRINSIC
func _undefined<T>(
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file, line: UInt = #line
) -> T {
  _assertionFailure("Fatal error", message(), file: file, line: line, flags: 0)
}
```

- `swift/stdlib/public/SDK/Dispatch/Dispatch.swift`
- 这里的 Closure 的返回值 `DispatchPredicate`，本质其实是枚举类型，可以直接填入该类型的值，也可以传入 Closure，大大地提高了灵活性。

```Swift
@_transparent
@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public func dispatchPrecondition(condition: @autoclosure () -> DispatchPredicate) {
	// precondition is able to determine release-vs-debug asserts where the overlay
	// cannot, so formulating this into a call that we can call with precondition()
	precondition(_dispatchPreconditionTest(condition()), "dispatchPrecondition failure")
}
```

- `swift/stdlib/public/core/Assert.swift`
- 断言相关的方法很多的参数选为了 Closure，并标注了 `@autoclosure`，一是可以直接将表达式直接作为参数，而不需要参数，二是当 Release 模式时，Closure 没有必要执行，即可节省开销。

```Swift
@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func assert(
  _ condition: @autoclosure () -> Bool,
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file, line: UInt = #line
) {
  // Only assert in debug mode.
  if _isDebugAssertConfiguration() {
    if !_branchHint(condition(), expected: true) {
      _assertionFailure("Assertion failed", message(), file: file, line: line,
        flags: _fatalErrorFlags())
    }
  }
}

@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func precondition(
  _ condition: @autoclosure () -> Bool,
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file, line: UInt = #line
) {
  // Only check in debug and release mode.  In release mode just trap.
  if _isDebugAssertConfiguration() {
    if !_branchHint(condition(), expected: true) {
      _assertionFailure("Precondition failed", message(), file: file, line: line,
        flags: _fatalErrorFlags())
    }
  } else if _isReleaseAssertConfiguration() {
    let error = !condition()
    Builtin.condfail(error._value)
  }
}

@_inlineable // FIXME(sil-serialize-all)
@inline(__always)
public func assertionFailure(
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file, line: UInt = #line
) {
  if _isDebugAssertConfiguration() {
    _assertionFailure("Fatal error", message(), file: file, line: line,
      flags: _fatalErrorFlags())
  }
  else if _isFastAssertConfiguration() {
    _conditionallyUnreachable()
  }
}

@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func preconditionFailure(
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file, line: UInt = #line
) -> Never {
  // Only check in debug and release mode.  In release mode just trap.
  if _isDebugAssertConfiguration() {
    _assertionFailure("Fatal error", message(), file: file, line: line,
      flags: _fatalErrorFlags())
  } else if _isReleaseAssertConfiguration() {
    Builtin.int_trap()
  }
  _conditionallyUnreachable()
}

@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func fatalError(
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file, line: UInt = #line
) -> Never {
  _assertionFailure("Fatal error", message(), file: file, line: line,
    flags: _fatalErrorFlags())
}

@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func _precondition(
  _ condition: @autoclosure () -> Bool, _ message: StaticString = StaticString(),
  file: StaticString = #file, line: UInt = #line
) {
  // Only check in debug and release mode. In release mode just trap.
  if _isDebugAssertConfiguration() {
    if !_branchHint(condition(), expected: true) {
      _fatalErrorMessage("Fatal error", message, file: file, line: line,
        flags: _fatalErrorFlags())
    }
  } else if _isReleaseAssertConfiguration() {
    let error = !condition()
    Builtin.condfail(error._value)
  }
}

@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func _debugPrecondition(
  _ condition: @autoclosure () -> Bool, _ message: StaticString = StaticString(),
  file: StaticString = #file, line: UInt = #line
) {
  // Only check in debug mode.
  if _isDebugAssertConfiguration() {
    if !_branchHint(condition(), expected: true) {
      _fatalErrorMessage("Fatal error", message, file: file, line: line,
        flags: _fatalErrorFlags())
    }
  }
}

@_inlineable // FIXME(sil-serialize-all)
@_transparent
public func _sanityCheck(
  _ condition: @autoclosure () -> Bool, _ message: StaticString = StaticString(),
  file: StaticString = #file, line: UInt = #line
) {
#if INTERNAL_CHECKS_ENABLED
  if !_branchHint(condition(), expected: true) {
    _fatalErrorMessage("Fatal error", message, file: file, line: line,
      flags: _fatalErrorFlags())
  }
#endif
}
```

## Why

- Q: 总结一下为什么要使用 `@autoclosure` 呢？
- A: 通过上述官方源代码的用例可以得出：当开发者需要的 `func` 的参数可能需要额外执行一些开销较大的操作的时候，可以使用。
- 因为如果开销不大，完全可以直接将参数类型设置为返回值的类型，只是此时无论是否参数后续被用到，得到的过程必然是会被调用的。
- 而如果不需要执行多个操作，也可以不使用 `@autoclosure`，而是直接传入 `func`，无非是括号的区分。

> It’s common to *call* functions that take autoclosures, but it’s not common to *implement* that kind of function.
> 
> **NOTE**
> 
> Overusing autoclosures can make your code hard to understand. The context and function name should make it clear that evaluation is being deferred.
>
> — *The Swift Programming Language (Swift 4.0.3)*

- 官网文档其实指出了开发者应当尽量不要滥用 `@autoclosure`，如果必须使用，也需要做到明确、清晰，否则可能会让他人感到疑惑。

> 也欢迎您关注我的微博 [@萌面大道V](http://weibo.com/375975847)

## Reference

- [apple/swift](https://github.com/apple/swift)
- [The Swift Programming Language (Swift 4.0.3)](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/)
- [Short-circuit evaluation](https://en.wikipedia.org/wiki/Short-circuit_evaluation)
- [Intrinsic function](https://en.wikipedia.org/wiki/Intrinsic_function)
- [what is a compiler intrinsic function?](https://cs.stackexchange.com/questions/57116/what-is-a-compiler-intrinsic-function)
- [@AUTOCLOSURE 和 ??](http://swifter.tips/autoclosure/)
