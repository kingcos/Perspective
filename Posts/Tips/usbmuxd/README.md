# Tips - 使用 usbmuxd 连接 iPhone

| macOS | iOS | libimobiledevice/usbmuxd |
|:-----:|:-----:|:-----:|
| 10.13.6 | 9.0.1 (Jailbroken) | v1.0.8 |

## What

usbmuxd 全称「USB Multiplexing Daemon」，即 USB 多路传输驻留程序。当 Mac/PC 与 iPhone 之间使用 USB 数据线连接时，iTunes 与 iPhone 间的通信交流便是通过 usbmuxd 服务。usbmuxd 通过给定的端口号和 localhost 建立 TCP 连接。

在 Mac 端，是由「/System/Library/PrivateFrameworks/MobileDevice.framework/Resources/usbmuxd」处理，并通过 launchd 启动。其将会在「/var/run/usbmuxd」创建一个 UNIX Domain Socket（UNIX 域套接字），usbmuxd 将监听 USB 接口的 iPhone 连接。当 iPhone 在正常模式下连接，其将会连接到该 iPhone，并将开始转发通过「/var/run/usbmuxd」接收到的请求。

## Solution

> 通过 usbmuxd 用 USB 代替 Wi-Fi 转发 SSH 请求。

- 这里注意选择 1.0.8 版本，更高版本使用了 C/C++ 等方式实现，和以下操作将有较大差异。
- 开启服务：

```shell
cd usbmuxd-1.0.8/python-client

# python tcprelay.py -t 22:PORT_NUMBER
python tcprelay.py -t 22:9090
```

- 之后便可以 SSH 到本机的 9090 端口即可：

```shell
ssh root@localhost -p 9090
```

## Reference

- [Usbmux](https://www.theiphonewiki.com/wiki/Usbmux)
- [libimobiledevice/usbmuxd](https://github.com/libimobiledevice/usbmuxd)