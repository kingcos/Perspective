# Practice - iOS 中的归档（Archive）相关

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019-03-08 | 首次提交 | |

## What

虽然我非常喜欢使用 Swift 来开发 iOS，但现实是还有很多机会能够接触到 Obj-C。在目前阶段，完全摒弃 Obj-C 是不现实的，毕竟 UIKit 仍然是由 Obj-C 编写的。

今天来谈谈 Obj-C 中归档相关的内容。在官方文档中，还有另外一个类似作用的机制称作序列化（Serialization）。这里的序列化特指 iOS 中序列化属性列表（Property list，即 plist）并不是广义上的序列化。它们两者都可以将结构化数据转换为与结构无关的字节流，便于传输，也可以在需要时解码为结构化数据。序列化部分并不属于本文的重点，下面将简述略过。

### Serializing Property Lists

序列化属性列表并不会记录值的数据类型，也不会记录它们之间的关系，只有值本身才会被记录。












## NSCoder/NSCoding

`NSCoding` 是 Obj-C 中的一个协议，总共包含以下两个方法：

```objc
@protocol NSCoding

// 使用 NSCoder 编码器编码
- (void)encodeWithCoder:(NSCoder *)aCoder;
// 使用 NSCoder 反编码器反编码
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder; // NS_DESIGNATED_INITIALIZER

@end
```





## NSSecureCoding


## NSCopying



## Reference

- [Apple Inc. - Archives and Serializations Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Archiving/Archiving.html)