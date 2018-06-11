# Translation - 起底 SourceKit

作者 | 发表时间 | 原文链接
--- | --- | ---
JP Simard | 20140706 | [https://www.jpsim.com/uncovering-sourcekit/](https://www.jpsim.com/uncovering-sourcekit/)

> 为了支持一门[奇特的新编程语言](http://developer.apple.com/swift)（译者注：即 Swift），漂亮的[实时 IDE](https://developer.apple.com/library/prerelease/ios/recipes/xcode_help-source_editor/ExploringandEvaluatingSwiftCodeinaPlayground/ExploringandEvaluatingSwiftCodeinaPlayground.html) 特性，以及令人印象深刻的[跨语言协同性](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html)（译者注：即 Swift 与 Obj-C），Apple 不得不开发一些新的底层工具。这里我们将专注于 SourceKit，Xcode 背后的功臣。

![SourceKitSidekick 暂时披着披肩](https://www.jpsim.com/images/posts/sidekick.jpg)

## 什么是 SourceKit？

SourceKit 是一套工具集，使得大多数 Swift 源代码层面的操作特性得以支持，例如源代码解析、语法高亮、排版（typesetting）、自动补全、跨语言头文件生成，等等。

## 架构

传统上，Xcode 在运行时跑着其编译器（[Clang](http://clang.llvm.org/)），即意味着编译器将可能在任何时候崩溃，IDE 同样。

![Xcode 架构示意图](https://www.jpsim.com/images/posts/house_of_cards.jpg)

更有甚者，Xcode 容易唤起编译器进行成千上万次解析、高亮、以及排版源代码，所有这一切都在用户键入「⌘ + B」之前。这是因为不像大多数编辑器（Vim/Sublime/...），Xcode 并不使用正则表达式解析源代码，而是使用 Clang 强大的（也更加复杂的）解析器（parser）和标记器（tokenizer）。

庆幸的是，Xcode 6 中的 Swift 移除了该特性<sup>1</sup>，合并所有源代码操作特性至一个独立的进程，并和 Xcode 通过 [XPC](https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/chapters/CreatingXPCServices.html) 交流：`sourcekitd`。无论 Xcode 6 何时加载任何 Swift 代码，该 XPC 守护进程将被启动。

![如果每次出现如图情况时 Xcode 都会崩溃，生活将变得痛苦不堪](https://www.jpsim.com/images/posts/sourcekit_terminated.jpg)

## Xcode 如何使用 SourceKit

因为 SourceKit 是一个私有且无文档的工具，我们需要获得一些小点子来学习如何使用它。通过设定 `SOURCEKIT_LOGGING`<sup>2</sup> 环境变量，Xcode 将记录 SourceKit 与 `stdout` 间的通信，允许我们观察到它们的实时通信。这就是如何发现本文中的许多命令。

## 统一符号解析

SourceKit 借助 Clang 中称作 USR（Unified Symbol Resolution，即统一符号解析）的特性，为源代码令牌（token，例如类，属性，方法等）对应一个唯一标识符。这使得你可以使用 「⌘ + 点击」Xcode 编辑器中任何一处令牌，即可以导航至其定义处。USR 现在甚至更加强大了，可以跨语言（Swift/Obj-C）统一一个代表。

![运作中的 USR](https://www.jpsim.com/images/posts/usr.jpg)

为了从一个 Swift 文件（以及其位置）中打印 USR，你可以运行以下命令： 

```
$ xcrun swift-ide-test -print-usrs -source-filename=Musician.swift
10:7 s:C14swift_ide_test8Musician
14:9 s:vC14swift_ide_test8Musician4nameSS
19:9 s:vC14swift_ide_test8Musician9birthyearSu
33:5 s:FC14swift_ide_test8MusiciancFMS0_FT4nameSS9birthyearSu_S0_
33:10 s:vFC14swift_ide_test8MusiciancFMS0_FT4nameSS9birthyearSu_S0_L_4nameSS
33:24 s:vFC14swift_ide_test8MusiciancFMS0_FT4nameSS9birthyearSu_S0_L_9birthyearSu
34:9 s:vFC14swift_ide_test8MusiciancFMS0_FT4nameSS9birthyearSu_S0_L_4selfS0_
34:21 s:vFC14swift_ide_test8MusiciancFMS0_FT4nameSS9birthyearSu_S0_L_4nameSS
35:9 s:vFC14swift_ide_test8MusiciancFMS0_FT4nameSS9birthyearSu_S0_L_4selfS0_
35:26 s:vFC14swift_ide_test8MusiciancFMS0_FT4nameSS9birthyearSu_S0_L_9birthyearSu
```

## Swift 头文件生成

在 Swift 中使用「⌘ + 点击」一个定义在 Obj-C 中令牌，Xcode 将会触发生成一个类 Swift 头文件。称其为类 Swift 是因为该生成的文件并非有效的 Swift<sup>3</sup>，但至少显示了等效于 Obj-C 令牌的 Swift 语法。

![左：原始 Obj-C 头文件，右：SourceKit 生成的类 Swift 版本](https://www.jpsim.com/images/posts/generated_swift_header.jpg)

## 在命令行使用 SourceKit

![](https://www.jpsim.com/images/posts/sourcekit_playground.jpg)

主要有 3 个命令行工具允许和 SourceKit 交互：`sourcekitd-test`，`swift-ide-test`，以及 `swift`。

笔者编译了一个带有文档的 Shell 脚本，其运行了许多有用的命令，例如：语法高亮，接口生成，AST 解析，还原（demangling）等。

该脚本可在 GitHub 中获得：[GitHub Gist](https://gist.github.com/jpsim/13971c81445219db1c63#file-sourcekit_playground-sh)。

## 第三方使用 SourceKit 的工具

因为 SourceKit 独立于 Xcode 之外，使其可以利用以构建从 Swift IDE 到文档生成器等任何东西。

### Jazzy♪♫

![](https://www.jpsim.com/images/posts/jazzy.jpg)

[jazzy](https://github.com/realm/jazzy) 是一个命令行工具，可以为你的 Swift 或 Obj-C 项目生成文档。其利用 SourceKit 以获得从 Obj-C 定义令牌（例如类，属性，方法等）的 Swift 语法。

### SwiftEdit

[SwiftEdit](https://github.com/jpsim/SwiftEdit) 是一款支持 Swift 文件语法高亮的概念型编辑器。

![](https://www.jpsim.com/images/posts/SwiftEdit.png)

## SourceKit 与你

我们刚刚初探了使用 SourceKit 的可能。这些工具可以做出来处理跨语言代码覆盖，或者提供支持 Swift 和 Obj-C 同时编辑的编辑器。希望本文能启发你利用 SourceKit 开发一些什么，并在这过程中改善我们的工具。

- 注：
  1. Obj-C 在 Xcode 6（Beta 2）中完全没有使用 SourceKit，仍保留了 Xcode 传统的运行中 Clang 架构。我预计在 Xcode 6 GM 前能有所改变。
  2. 为了 SourceKit 打印日志，使用以下命令启动 Xcode `export SOURCEKIT_LOGGING=3 && /Applications/Xcode6-Beta2.app/Contents/MacOS/Xcode`。
  3. 猜测：我预计一旦编程语言拥有访问控制机制，私有 Swift 模块暴露公有接口将使用相似的语法。

---

## Reference

- [apple/swift/tools/SourceKit/](https://github.com/apple/swift/tree/master/tools/SourceKit)
- [SourceKit and You - by JP Simard](https://academy.realm.io/posts/appbuilders-jp-simard-sourcekit/)