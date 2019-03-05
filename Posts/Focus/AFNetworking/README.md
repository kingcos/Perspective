# Focus - AFNetworking 剖析

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019-03-03 | 首次提交 | [AFNetworking 3.2.1](https://github.com/AFNetworking/AFNetworking/releases/tag/3.2.1) |

> 许久未更！这次我将以 AFNetworking 最新 Release 版本 3.2.1 为例，作为深度剖析的第一个开源库。当然我也计划后续剖析 Alamofire，即 Swift 的网络库。第一次做剖析开源库的文章，不免会有所纰漏，但我会尽力将文章做到翔实。涉及到部分语法特性，可能会将其作为单独的内容提炼出去。其实网上已经有不少对 AFNetworking 剖析的文章，在本文基本完成后，我会参考前人之所见，查漏补缺。所有参考的资料都将在文末「Reference」中找到。那下面就开始吧！

![](afnetworking-logo.png)

## What

> AFNetworking is a delightful networking library for iOS, macOS, watchOS, and tvOS. It's built on top of the [Foundation URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system), extending the powerful high-level networking abstractions built into Cocoa. It has a modular architecture with well-designed, feature-rich APIs that are a joy to use.
> 
> Perhaps the most important feature of all, however, is the amazing community of developers who use and contribute to AFNetworking every day. AFNetworking powers some of the most popular and critically-acclaimed apps on the iPhone, iPad, and Mac.
> 
> Choose AFNetworking for your next project, or migrate over your existing projects—you'll be happy you did!

AFNetworking 是由 Objective-C 编写的适用于 iOS/macOS/watchOS/tvOS 全平台的网络库。但凡接触过 Obj-C iOS 开发的老同学都应该对 AFNetworking 这个名字感觉不陌生。但我们还是从其 GitHub Repo 的 README 开始说起。


## 总体概览

根据其开源在 GitHub 上最新的 3.2.1 版本 Tag，可以直接下载到该版本的源代码。AFNetworking 支持 CocoaPods 集成，所以只需要查看 Podspec 文件就可以得知真正的库文件，总共只有 14 个文件。文件结构如下：

```
➜  AFNetworking tree
.
├── AFCompatibilityMacros.h
├── AFHTTPSessionManager.h
├── AFHTTPSessionManager.m
├── AFNetworkReachabilityManager.h
├── AFNetworkReachabilityManager.m
├── AFNetworking.h
├── AFSecurityPolicy.h
├── AFSecurityPolicy.m
├── AFURLRequestSerialization.h
├── AFURLRequestSerialization.m
├── AFURLResponseSerialization.h
├── AFURLResponseSerialization.m
├── AFURLSessionManager.h
└── AFURLSessionManager.m

0 directories, 14 files
```

Podspec 不仅指定了源文件的路径，也可以较为容易地了解整体的架构和分层，根据其中的定义，AFNetworking 整体被分为 Serialization、Security、Reachability、NSURLSession、UIKit 五个子层级（Subspec），AFNetworking 本身只有 AFNetworking.h 一个源文件，作为对外暴露头文件的统一管理。

```ruby
  # AFNetworking.podspec
  # 注：此处仅作部分摘录

  s.subspec 'Serialization' do |ss|
    ss.source_files = 'AFNetworking/AFURL{Request,Response}Serialization.{h,m}'
    ss.public_header_files = 'AFNetworking/AFURL{Request,Response}Serialization.h'
    ss.ios.frameworks = 'MobileCoreServices', 'CoreGraphics'
  end

  s.subspec 'Security' do |ss|
    ss.source_files = 'AFNetworking/AFSecurityPolicy.{h,m}'
    ss.public_header_files = 'AFNetworking/AFSecurityPolicy.h'
    ss.frameworks = 'Security'
  end

  s.subspec 'Reachability' do |ss|
    ss.source_files = 'AFNetworking/AFNetworkReachabilityManager.{h,m}'
    ss.public_header_files = 'AFNetworking/AFNetworkReachabilityManager.h'

    ss.frameworks = 'SystemConfiguration'
  end

  s.subspec 'NSURLSession' do |ss|
    ss.dependency 'AFNetworking/Serialization'
    ss.ios.dependency 'AFNetworking/Reachability'
    ss.dependency 'AFNetworking/Security'

    ss.source_files = 'AFNetworking/AF{URL,HTTP}SessionManager.{h,m}', 'AFNetworking/AFCompatibilityMacros.h'
    ss.public_header_files = 'AFNetworking/AF{URL,HTTP}SessionManager.h', 'AFNetworking/AFCompatibilityMacros.h'
  end

  s.subspec 'UIKit' do |ss|
    ss.dependency 'AFNetworking/NSURLSession'

    ss.public_header_files = 'UIKit+AFNetworking/*.h'
    ss.source_files = 'UIKit+AFNetworking'
  end
```

所以，对于 iOS 平台（注：下文后如不特别注明，即以 iOS 平台为主，其他平台视情况针对性说明），AFNetworking 3.2.1 的大概层级关系如下图所示：

![](1.png)

需要注意的是，其中 UIKit 层主要是针对系统 UIKit 中部分 UI 控件以分类（Category）形式提供支持，不涉及 AFNetworking 核心功能，官方也没有将其直接放在 AFNetworking 文件夹下，而是放在了 UIKit+AFNetworking 文件夹下，共有 20 个文件。

```
➜  UIKit+AFNetworking tree
.
├── AFAutoPurgingImageCache.h
├── AFAutoPurgingImageCache.m
├── AFImageDownloader.h
├── AFImageDownloader.m
├── AFNetworkActivityIndicatorManager.h
├── AFNetworkActivityIndicatorManager.m
├── UIActivityIndicatorView+AFNetworking.h
├── UIActivityIndicatorView+AFNetworking.m
├── UIButton+AFNetworking.h
├── UIButton+AFNetworking.m
├── UIImage+AFNetworking.h
├── UIImageView+AFNetworking.h
├── UIImageView+AFNetworking.m
├── UIKit+AFNetworking.h
├── UIProgressView+AFNetworking.h
├── UIProgressView+AFNetworking.m
├── UIRefreshControl+AFNetworking.h
├── UIRefreshControl+AFNetworking.m
├── UIWebView+AFNetworking.h
└── UIWebView+AFNetworking.m

0 directories, 20 files
```

NSURLSession 层即为 AFNetworking 的核心所在。在上述两者的上层，是 Serialization、Security 以及 Reachability，分别主要作用于序列化、安全以及网络可用性方面；后面两者较为独立，后续将分开剖析；序列化部分将和 NSURLSession 部分一起剖析。


















## Reachability

## Security

## 3.x

## Reference

- [GitHub - AFNetworking](https://github.com/AFNetworking/AFNetworking)