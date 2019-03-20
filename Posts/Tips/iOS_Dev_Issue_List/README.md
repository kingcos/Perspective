# Tips - iOS 开发问题解决集锦

## Unable to boot device in current state: Creating

- Xcode: 9.4.1
- macOS: 10.13
- 在使用模拟器或者 `xcodebuild test` 时可能会出现此问题。

### Solution

- 使用 `xcrun simctl list` 命令列出所有模拟器机型，用 `xcrun simctl erase UDID` 还原相应的设备，重试即可。
- 下面是一个 Python 3 脚本，可以使用 `python erase_simulators.py -d 'DEVICE_TYPE'` 来直接还原相应设备类型的所有设备。

```python
# -*- coding: utf-8 -*-

import argparse
import subprocess
import re

def erase_device(device):
    status, output = subprocess.getstatusoutput('xcrun simctl list | grep \'' + device + ' (\'')
    if status == 0:
        outputs = output.split('\n')
        for output in outputs:
            simulator_udids = re.findall('[A-Z0-9-]{36}', output)
            if simulator_udids != []:
                for udid in simulator_udids:
                    subprocess.getstatusoutput('xcrun simctl erase' + udid)
                    print('Already erased ' + device + ' - UDID: ' + udid)

if __name__ == '__main__':
    iphone_64_devices = ['iPhone 5s', 'iPhone 6', 'iPhone 6 Plus', 'iPhone 6s', 'iPhone 6s Plus', 'iPhone 7', 'iPhone 7 Plus', 'iPhone 8', 'iPhone 8 Plus', 'iPhone X']
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--device', help='Specify the simulator device, eg. iPhone X', choices=iphone_64_devices)
    args = parser.parse_args()
    if args.device is not None:
        erase_device(args.device)
    else:
        print('Please specify the device option!')
```

### The operation couldn’t be completed. (DVTCoreSimulatorAdditionsErrorDomain error 0.)

- Xcode: 10
- macOS: 10.14
- 在清空了 `~/Library/Developer/CoreSimulator/Devices` 后 `xcodebuild test` 时出现此问题。

### Solution

```sh
xcrun simctl erase all
```

## Cannot find "$(SRCROOT)/*/Info.plist"

- Fastlane `increment_version_number`
- `agvtool new-marketing-version x.x.x`
- 某些 Target 无法使用命令批量更新版本号时出现此问题。

### Solution

- 在项目的 Build Settings 中搜索 `$(SRCROOT)`，删除包含该内容条目中的 `$(SRCROOT)` 变量（通常是 `INFOPLIST_FILE` 字段）。

## Failed to verify bitcode in *

- 当主 Target 未开启 Bitcode 时，Archive 后，通常有「Rebuild from bitcode」选项，勾选时可能会出现此问题；
- 抑或使用 Fastlane「build_ios_app」打包，出现该问题。

### Solution

- 手动打包不勾选「Rebuild from bitcode」选项即可；
- Fastlane 需要在关闭 Bitcode，具体如下：

```ruby
build_ios_app(export_options: { compileBitcode: false })
```

## Missing password for user xxx@yyy.com, and running in non-interactive shell

- Fastlane 上传 App Store 时会出现该问题。

### Solution

- 根据 [https://github.com/fastlane/fastlane/tree/master/credentials_manager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) 添加打包上传 App Store 的 Apple ID 资格，如需更改密码，可先移除再添加即可（需搭配 unlock_keychain 使用）。

## No value found for 'username'

- Fastlane 上传 App Store 时会出现该问题。

### Solution

- `No value found for 'username'` 是 Pilot（[upload_to_testflight](https://docs.fastlane.tools/actions/upload_to_testflight/)）的报错信息；
- 可在 AppFile 配置上传 App Store 的 Apple ID，或在 upload_to_testflight 添加 username 参数，并按照上条 Tips 添加账号密码至 Key Chain。

## Please see Simulator Help for information on adjusting system settings to allow more simulated devices to boot at once.

- 在使用模拟器作为 destination 时出现此错误。

### Solution

- [官方文档](https://help.apple.com/simulator/mac/9.0/index.html#/dev8a5f2aa4e)。

```shell
sudo launchctl limit maxproc 2000 2500
```

## 在 iPhone X 及以上全面屏机型 UIWebView 的内容未填充整个视图

- 视图层级关系：UIWebView > UIWebScrollView > UIWebBrowserView
- 由于 iPhone X 带来的全面屏，系统会自动对其中的 UIWebBrowserView 进行调整，导致即使设置 UIWebView 整体的约束，显示的内容区域也时有问题。

### Solution

- 将其中的 UIScrollView 的自动调整行为关闭即可。

```swift
if #available(iOS 11.0, *) {
    webView.scrollView.contentInsetAdjustmentBehavior = .never
}
```
