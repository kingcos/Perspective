# Tips - Swift 源代码中的 GYB

| Date | Notes |
|:-----:|:-----:|
| 2018-12-03 | 首次提交 |

## Preface

翻看过 Swift 在 GitHub 开源仓库的同学一定会见过「.swift.gyb」结尾的文件。其中的内容不像是纯 Swift 语法的代码，但又似乎遵循了某些格式，那么 GYB 是什么呢？

![Codable.swift.gyb](1.png)

## What

GYB，全称 Generate Your Boilerplate。译成中文是「模版生成」，重点就在于「Boilerplate」。举个例子，在编写一门编程语言时，整型可能根据占据的不同大小内存以及有无符号而非为 Int，Int8，Int16，Int32，Int64，UInt，UInt8，UInt16，UInt32，UInt64 多种。而对于这些类型的一些通用操作、方法调用，其实都是重复性的。拷贝、粘贴虽然似乎也能解决问题，但后续如果有一些实现上的变更，则不利于快速同步变更。所以 GYB 文件就是 Swift 代码的模版，使用模版文件则即可很方便快捷地创建重复性的代码逻辑。

## Reference

- [apple/swift](https://github.com/apple/swift)

## Extension

- [Swift GYB - Mattt (EN)](https://nshipster.com/swift-gyb/)
- [Swift GYB - Mattt (CN)](https://nshipster.cn/swift-gyb/)
