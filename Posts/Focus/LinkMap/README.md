# Focus - Xcode 中的 Link Map 文件

| Date | Notes | Xcode |
|:-----:|:-----:|:-----:|
| 2019-04-01 | 首次提交 | 10.1 |

## Preface

Link Map File，译作链接映射文件（下文将称 Link Map 文件）。在构建可执行文件之前，需要先编译为目标文件（Object File），并链接所需要的其他库，那么 Link Map 文件就记录了链接器（Linker）在链接过程中产生的一些信息，从这些信息我们也能分析出一些有用的内容，那么本文就将谈谈这个文件。

## What

Xcode 中默认是不会将 Link Map 文件在构建时暴露出来的，但我们可以在「Build Settings」-「Write Link Map File」-「Yes」打开该选项。这样当我们再次编译项目，默认就可以在 `~/Library/Developer/Xcode/DerivedData/<TARGET_NAME>-<Random_ID>/Build/Intermediates.noindex/<TARGET_NAME>.build/Debug-<Device_Type>/<TARGET_NAME>.build/<TARGET_NAME>-LinkMap-normal-<Arch>.txt` 中找到。

![](1.png)

举个例子，我这里的 Link Map 文件的完整路径就是：`/Users/kingcos/Library/Developer/Xcode/DerivedData/DemoiOS-hifhuapijabsaxgpelrpiwhbzlqv/Build/Intermediates.noindex/DemoiOS.build/Debug-iphonesimulator/DemoiOS.build/DemoiOS-LinkMap-normal-x86_64.txt`。

![](2.png)

## How

下面来分析一下 Xcode Link Map 文件的构成。

### Path

```
# Path: /Users/kingcos/Library/Developer/Xcode/DerivedData/DemoiOS-hifhuapijabsaxgpelrpiwhbzlqv/Build/Products/Debug-iphonesimulator/DemoiOS.app/DemoiOS
```

Path 为最终生成的「可执行文件」mach-o 的路径。

### Arch

```
// Target: Simulator
# Arch: x86_64

// Target: iPhone
# Arch: arm64
```

Arch 为「可执行文件」的架构，具体架构如下表。

| Device | System | Arch |
|:---:|:---:|:---:| 
| iOS 模拟器 | iOS | x86_64 |
| 搭载 A7 及以上的 iOS 真机 | iOS | arm64（A12 架构为「arm64e」，但 Link Map 文件尚未体现） |
| 搭载 A7 以下的 iOS 真机 | iOS | armv7 |
| Apple Watch 模拟器 | watchOS | i386 |
| Apple Watch 真机 | watchOS | armv7s/arm64_32（Apple Watch S4 为「arm64_32」） |
| Mac | macOS | x86_64 |

### Object files

```
# Object files:
[  0] linker synthesized
[  1] /Users/kingcos/Library/Developer/Xcode/DerivedData/DemoiOS-hifhuapijabsaxgpelrpiwhbzlqv/Build/Intermediates.noindex/DemoiOS.build/Debug-iphonesimulator/DemoiOS.build/DemoiOS.app-Simulated.xcent
[  2] /Users/kingcos/Library/Developer/Xcode/DerivedData/DemoiOS-hifhuapijabsaxgpelrpiwhbzlqv/Build/Intermediates.noindex/DemoiOS.build/Debug-iphonesimulator/DemoiOS.build/Objects-normal/x86_64/ViewController.o
[  3] /Users/kingcos/Library/Developer/Xcode/DerivedData/DemoiOS-hifhuapijabsaxgpelrpiwhbzlqv/Build/Intermediates.noindex/DemoiOS.build/Debug-iphonesimulator/DemoiOS.build/Objects-normal/x86_64/main.o
[  4] /Users/kingcos/Library/Developer/Xcode/DerivedData/DemoiOS-hifhuapijabsaxgpelrpiwhbzlqv/Build/Intermediates.noindex/DemoiOS.build/Debug-iphonesimulator/DemoiOS.build/Objects-normal/x86_64/AppDelegate.o
[  5] /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator12.1.sdk/System/Library/Frameworks//Foundation.framework/Foundation.tbd
[  6] /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator12.1.sdk/usr/lib/libobjc.tbd
[  7] /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator12.1.sdk/System/Library/Frameworks//UIKit.framework/UIKit.tbd
```

Object files 为目标文件，该部分主要为目标文件，但也有一些其他文件，详见下表。

| No. | File | Notes |
|:---:|:---:|:---:|:---:|
| 0 | linker synthesized | 首行是一个提示，即下方为链接器合成所需要的文件。 |
| 1 | DemoiOS.app-Simulated.xcent | xcent 是 XML 1.0 文档文本文件，可以使用编辑器直接打开。其中存储了 `application-identifier` 和 `keychain-access-groups`，但该行仅在模拟器作为构建目标时存在。 | 
| 2~4 | *.o | 编译后的目标文件 |
| 5~7 | *.tbd | tbd 是文本基础（Text-based）文件，也可以用编辑器打开，其中包含了动态库的信息，例如系统 Foundation.tbd 如下图 |

![](3.png)

### Sections

```
# Sections:
# Address	Size    	Segment	Section
0x100001730	0x00000333	__TEXT	__text
0x100001A64	0x0000002A	__TEXT	__stubs
0x100001A90	0x00000056	__TEXT	__stub_helper
0x100001AE6	0x00000A27	__TEXT	__objc_methname
0x10000250D	0x0000003C	__TEXT	__objc_classname
0x100002549	0x0000086D	__TEXT	__objc_methtype
0x100002DB6	0x0000007A	__TEXT	__cstring
0x100002E30	0x0000017A	__TEXT	__entitlements
0x100002FAC	0x00000048	__TEXT	__unwind_info
0x100003000	0x00000010	__DATA	__nl_symbol_ptr
0x100003010	0x00000010	__DATA	__got
0x100003020	0x00000038	__DATA	__la_symbol_ptr
0x100003058	0x00000010	__DATA	__objc_classlist
0x100003068	0x00000010	__DATA	__objc_protolist
0x100003078	0x00000008	__DATA	__objc_imageinfo
0x100003080	0x00000BE8	__DATA	__objc_const
0x100003C68	0x00000010	__DATA	__objc_selrefs
0x100003C78	0x00000008	__DATA	__objc_classrefs
0x100003C80	0x00000008	__DATA	__objc_superrefs
0x100003C88	0x00000008	__DATA	__objc_ivar
0x100003C90	0x000000A0	__DATA	__objc_data
0x100003D30	0x000000C0	__DATA	__data
```



## Reference

- [TBD - fileinfo.com](https://fileinfo.com/extension/tbd)