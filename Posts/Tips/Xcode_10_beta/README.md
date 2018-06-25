# Tips - Xcode 10 beta 趟坑

| Xcode | macOS |
|:-----:|:-----:|
| 10 beta 2 | 10.14 beta 2 |

## $(TeamIdentifierPrefix)

- Xcode 10 已知 Bug，无法自动替换。

### Workaround

- 可以手动将 entitlements 文件的 `Pass Type ID` 值设置为 mobileversion 文件中`com.apple.developer.pass-type-identifiers` 对应值。

## libstdc++

- Xcode 10 取消了内置支持的 libstdc++ 库，需等待某些第三方 SDK 修复。

### Workaround

- 手动将 Xcode 9（`/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib`）中的库 `libstdc++.6.tbd` & `libstdc++.6.0.9.tbd` 复制到 Xcode 10（`/Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib`）。

## SWIFT_UNAVALIABLE

- 在 Obj-C 中调用 Swift 子类的 Obj-C 父类的构造器，提示 Unavaliable，由 Xcode 生成的 `*-Swift.h` 会将方法标记为 `SWIFT_UNAVALIABLE`。这是因为子类没有继承的构造器，将无法被调用。
- Reference：
  - [https://github.com/apple/swift/commit/0473e99988fcab251adc251cf8f44673bdabad9d](https://github.com/apple/swift/commit/0473e99988fcab251adc251cf8f44673bdabad9d)

### Workaround

- 将构造器在 Swift 子类中重写（内部直接调用 `super` 即可），并用 `public` 修饰。

## ld: symbol(s) not found for architecture arm64

- 可以尝试仍使用传统构建系统（Legacy build system）构建，在 File-Workspace Settings 中设置；
- 但在我们的项目中，使用新旧构建系统均会出错，具体原因和解决方法未知。
