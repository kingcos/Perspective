# Translation - [译]为 App 执行一次性设置

作者 | 原文链接
--- | ---
Apple Inc. | [Performing One-Time Setup for Your App](https://developer.apple.com/documentation/uikit/core_app/managing_your_app_s_life_cycle/responding_to_the_launch_of_your_app/performing_one-time_setup_for_your_app)

确保 App 环境被正确配置。

---

## 概览

当用户第一次启动 App，我们可能希望通过一些一次性任务预备 App 环境。举个例子，可能想要：

- 从服务器下载必要的数据。
- 从 App 包（bundle）中拷贝文档模版或可修改的数据文件至一个可写入的目录。
- 为用户配置默认偏好设置。
- 设置用户账户或获取其他必要数据。

在 App 代理的 [`application(_:willFinishLaunchingWithOptions:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623032-application) 或 [`application(_:didFinishLaunchingWithOptions:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application) 方法中执行任何一次性任务。当非必需用户输入时，绝不要因任务阻塞 App 的主线程。取而代之，使用调度队列（dispatch queue）异步开启任务，当 App 完成启动时，让其运行在后台。对于那些必需用户输入的任务，在 `application(_:didFinishLaunchingWithOptions:)` 方法中作出用户界面的改变。

### 在合适的位置安放文件

App 拥有其自身包含的目录来保存文件，我们也应当总是将 App 特定的文件放在 `~/Library` 的子目录中。特别地，将以下文件保存在 `~/Library` 的子目录：

- `~/Library/Application Support/` —— 保存想要备份用户的其他内容的 App 特定文件（可以根据需要创建自定义的子目录。）使用该目录保存数据文件，配置文件，文档模版，等等。
- `~/Library/Caches/` —— 保存便于重复产生或下载的临时文件。

使用 [`FileManager `](https://developer.apple.com/documentation/foundation/filemanager) 的 [`urls(for:in:) `](https://developer.apple.com/documentation/foundation/filemanager/1407726-urls) 方法获得 App 容器的目录 URL。

```swift
// 列表 1 获取 App 制定目录的位置
let appSupportURL = FileManager.default.urls(for: 
      .applicationSupportDirectory, in: .userDomainMask)

let cachesURL = FileManager.default.urls(for: 
      .cachesDirectory, in: .userDomainMask)
```

在 App 的 `tmp/` 目录下存放任何的临时文件。临时文件可能包含压缩文件，一旦其内容被提取并装载到其他地方后我们就打算删除。使用 [`FileManager `](https://developer.apple.com/documentation/foundation/filemanager) 的 [`temporaryDirectory `](https://developer.apple.com/documentation/foundation/filemanager/1642996-temporarydirectory) 方法获取 App 临时目录的 URL。

## 参阅

### 启动时间

- [关于 App 启动顺序（About the App Launch Sequence）](https://developer.apple.com/documentation/uikit/core_app/managing_your_app_s_life_cycle/responding_to_the_launch_of_your_app/about_the_app_launch_sequence)

> 学习在启动时的代码执行顺序。

---

> 以下内容为译者添加：

## 参考

- [[译]关于 App 启动顺序](https://github.com/kingcos/Perspective/issues/58)