# Tips - 将 Obj-C 代码翻译为 C++ 代码

| Platform | Notes |
|:-----:|:-----:|
| macOS 10.13.4 | clang |

## Solution

```
➜  ~ clang --version
Apple LLVM version 10.0.0 (clang-1000.11.45.5)
Target: x86_64-apple-darwin18.2.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

Xcode 中，C/C++/Obj-C/C++ 的编译器是 `clang`。其加上 `-rewrite-objc` 参数可以将 Obj-C 代码翻译为 C++ 代码，即 `clang -rewrite-objc main.m -o main.cpp`。也可以结合 `xcrun` 设置编译所基于的 SDK，以及其本身支持的 `-arch` 指定编译架构参数，`-framework` 指定需要依赖的框架，即 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-arm64.cpp -framework UIKit`。

`-rewrite-objc` 虽然是翻译为 C++ 代码，但其实大部分代码都属于 C 语言。那么翻译后的代码和源 Obj-C 代码有什么关系呢？这个问题我也十分疑惑，所以在 StackOverflow 发起了提问。但根据目前我所了解的而言，翻译后的代码仅仅是为其他编译器可以编译。在使用 Xcode 构建 iOS/macOS 项目时并不会将 Obj-C 先翻译再链接运行。而之所以可以被翻译，主要依赖于 Obj-C 的类其实就是 C 语言中的结构体，Obj-C 中的消息发送可以被翻译为 `obj_msgSend()` 方法调用。

## Reference

- [StackOverflow - -rewrite-objc and Objective-C in clang](https://stackoverflow.com/questions/44561285/rewrite-objc-and-objective-c-in-clang)