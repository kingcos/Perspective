# Translation - [译]URL 加载系统

作者 | 原文链接
--- | ---
Apple Inc. | [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system)

使用标准互联网协议与 URL 交互，并和服务器通信。

- **框架：**
  - Foundation 

---

## 概览

URL 加载系统通过标准协议比如 HTTPS 或自建协议提供对 URL 标识资源的访问。加载过程是异步的，所以 App 可以保持响应并当数据到达或出错时进行处理。

使用 [URLSession](https://developer.apple.com/documentation/foundation/urlsession) 实例可以创建一个或多个 [URLSessionTask](https://developer.apple.com/documentation/foundation/urlsessiontask) 实例，来抓取并返回数据给 App、下载文件、或者上传数据和文件到远程地址。使用 [URLSessionConfiguration](https://developer.apple.com/documentation/foundation/urlsessionconfiguration) 对象可以配置会话（Session），可以控制类似如何使用缓存和 Cookie 的行为、以及是否允许蜂窝网络连接。

一个会话可以重复地创建任务。举个例子，浏览器可能有分隔的会话以区分普通和隐私浏览，隐私会话将不缓存数据。图 1 展示了不同配置的两种会话可以创建许多任务。

![图 1 为 URL 会话创建任务](1.png)

1. 默认浏览：URLSession [默认配置] -> URLSessionDataTask
2. 隐私浏览：URLSession [临时配置] -> URLSessionDataTask

为了接收定期的更新（或错误），每个会话都与一个代理关联。默认代理将调用提供的回调 Block；如果选择提供自定义的代理，该 Block 不再调用。

通过配置 App 运行在后台时的会话，即可当 App 被挂起时，系统可以代替其下载数据并唤起 App 以分发结果。

## 话题

### 第一步

配置并创建会话，并用来创建与 URL 交互的任务。

- [取回网页数据到内存](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory)
  - 通过从 URL 会话创建数据任务来直接用内存接收数据。
- [`class URLSession`](https://developer.apple.com/documentation/foundation/urlsession)
  - 定位一组相关网络数据传输任务的对象。
- [`class URLSessionTask`](https://developer.apple.com/documentation/foundation/urlsessiontask)
  - 在 URL 会话中执行类似下载特定资源的任务。

### 请求与响应

- [`struct URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest)
  - 不依赖协议或 URL Scheme 的加载请求。
- [`class URLResponse`](https://developer.apple.com/documentation/foundation/urlresponse)
  - 与 URL 加载请求响应有关的元数据，不依赖协议或 URL Scheme。
- [`class HTTPURLResponse`](https://developer.apple.com/documentation/foundation/httpurlresponse)
  - 与 HTTP 协议 URL 加载请求响应有关的元数据。

### 上传

- [上传数据到网站](https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website)
  - 从 App 发送数据到服务器。
- [上传数据流](https://developer.apple.com/documentation/foundation/url_loading_system/uploading_streams_of_data)
  - 向服务器发送数据流。

### 下载

- [从网站下载文件](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_from_websites)
  - 直接下载文件到文件系统。
- [暂停和恢复下载](https://developer.apple.com/documentation/foundation/url_loading_system/pausing_and_resuming_downloads)
  - 允许用户无需重新开始的恢复下载。
- [后台下载文件](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background)
  - 创建当 App 不活跃时的下载任务。

### 缓存行为

- [访问缓存数据](https://developer.apple.com/documentation/foundation/url_loading_system/accessing_cached_data)
  - 控制 URL 请求如何使用原先的缓存数据。
- [`class CachedURLResponse`](https://developer.apple.com/documentation/foundation/cachedurlresponse)
  - URL 请求的缓存响应。
- [`class URLCache`](https://developer.apple.com/documentation/foundation/urlcache)
  - 映射 URL 请求到缓存的响应对象。

### 身份验证与资格

- [处理身份验证校验](https://developer.apple.com/documentation/foundation/url_loading_system/handling_an_authentication_challenge)
  - 当服务器要求 URL 请求进行身份验证时的合适响应。
- [`class URLAuthenticationChallenge`](https://developer.apple.com/documentation/foundation/urlauthenticationchallenge)
  - 来自需要客户端身份验证的服务器校验。
- [`class URLCredential`](https://developer.apple.com/documentation/foundation/urlcredential)
  - 由特定凭证类型的信息和持久化存储使用的类型（如果存在）组成的身份验证凭证。
- [`class URLCredentialStorage`](https://developer.apple.com/documentation/foundation/urlcredentialstorage)
  - 共享凭证缓存管理。
- [`class URLProtectionSpace`](https://developer.apple.com/documentation/foundation/urlprotectionspace)
  - 需要认证的服务器或者服务器的某个区域，或称为领域（Realm）。

### Cookies

- [`class HTTPCookie`](https://developer.apple.com/documentation/foundation/httpcookie)
  - HTTP Cookie 的代表。
- [`class HTTPCookieStorage`](https://developer.apple.com/documentation/foundation/httpcookiestorage)
  - 管理 Cookie 存储的容器。

### 错误

- [`struct URLError`](https://developer.apple.com/documentation/foundation/urlerror)
  - URL 加载 API 返回的错误码。
- [URL 加载系统错误信息键](https://developer.apple.com/documentation/foundation/url_loading_system/url_loading_system_error_info_keys)
  - 从 URL 加载 API 产生的错误对象的用户信息字典中识别这些键。

### 遗留

- [遗留 URL 加载系统](https://developer.apple.com/documentation/foundation/url_loading_system/legacy_url_loading_systems)
  - 将代码迁移远离使用这些旧对象。

## 参阅

### 网络 

#### [Bonjour](https://developer.apple.com/documentation/foundation/bonjour)

- 指便于在本地网络发现的服务，或者由其他发现的服务。
