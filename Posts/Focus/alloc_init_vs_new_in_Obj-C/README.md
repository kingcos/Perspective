# Focus - Obj-C 中的 alloc init 与 new

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019- | 首次提交 | [objc4-750](https://opensource.apple.com/tarballs/objc4/) |

## What

以 `NSObject` 为例，通常使用 `[[NSObject alloc] init]`，或者 `[NSObject new]`，来创建一个新的实例（Instance）对象。在开发中，很多人都会混用这两个方式，分不清其中的区别，似乎只是后者写起来更加简单。那么它们的本质到底是否一致呢？

## Why

```objc
// NSObject.h
+ (instancetype)alloc OBJC_SWIFT_UNAVAILABLE("use object initializers instead");

- (instancetype)init
#if NS_ENFORCE_NSOBJECT_DESIGNATED_INITIALIZER
    NS_DESIGNATED_INITIALIZER
#endif
    ;
    
+ (instancetype)new OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
```

在 Xcode 中，我们只能看到系统库的头文件，而无法看到其中的实现。但我们可以了解到，`alloc` 和 `new` 都是类方法，而 `init` 是对象方法。在 Apple 开源的 objc4 中，我们就可以根据这些信息找到其实现：

```objc
// NSObject.mm
@implementation NSObject

+ (id)alloc {
    return _objc_rootAlloc(self);
}

// Base class implementation of +alloc. cls is not nil.
// Calls [cls allocWithZone:nil].
id
_objc_rootAlloc(Class cls)
{
    return callAlloc(cls, false/*checkNil*/, true/*allocWithZone*/);
}

- (id)init {
    return _objc_rootInit(self);
}

+ (id)new {
    return [callAlloc(self, false/*checkNil*/) init];
}

@end
```

通过源代码，我们就能清晰地看出来，`new` 中其实也调用了 `init`，即初始化是相同的。所以他们的本质区别就在分配内存阶段的 `callAlloc`，`alloc` 的 `allocWithZone` 参数为 `true`，而 `new` 中使用了默认的 `false` 参数。

```objc
// Call [cls alloc] or [cls allocWithZone:nil], with appropriate 
// shortcutting optimizations.
static ALWAYS_INLINE id
callAlloc(Class cls, bool checkNil, bool allocWithZone=false)
{
    if (slowpath(checkNil && !cls)) return nil;

#if __OBJC2__
    if (fastpath(!cls->ISA()->hasCustomAWZ())) {
        // No alloc/allocWithZone implementation. Go straight to the allocator.
        // fixme store hasCustomAWZ in the non-meta class and 
        // add it to canAllocFast's summary
        if (fastpath(cls->canAllocFast())) {
            // No ctors, raw isa, etc. Go straight to the metal.
            bool dtor = cls->hasCxxDtor();
            id obj = (id)calloc(1, cls->bits.fastInstanceSize());
            if (slowpath(!obj)) return callBadAllocHandler(cls);
            obj->initInstanceIsa(cls, dtor);
            return obj;
        }
        else {
            // Has ctor or raw isa or something. Use the slower path.
            id obj = class_createInstance(cls, 0);
            if (slowpath(!obj)) return callBadAllocHandler(cls);
            return obj;
        }
    }
#endif

    // No shortcuts available.
    if (allocWithZone) return [cls allocWithZone:nil];
    return [cls alloc];
}
```

## Reference

- [objc4-750](https://opensource.apple.com/tarballs/objc4/)