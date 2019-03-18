# Practice - iOS 中的 NSObject

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019-03-13 | 首次提交 | [objc4-750](https://opensource.apple.com/tarballs/objc4/)、[libmalloc-166.220.1](https://opensource.apple.com/tarballs/libmalloc/)、[glibc-2.29](http://ftp.gnu.org/gnu/glibc/) |

## NSObject 实例对象的大小

```cpp
// NSObject Obj-C -> C NSObject_IMPL
struct NSObject_IMPL {
	Class isa;
};

// 指向 objc_class 结构体的指针
typedef struct objc_class *Class;
```

将 Obj-C 源码通过 `clang -rewrite-objc` 翻译为 C++（其实大部分为 C），可以发现 Obj-C 中的 `NSObject` 类其实就是 C 中的 `NSObject_IMPL` 结构体，其中只有一个成员变量，即 `isa`。`isa` 的类型是 `Class`，本质是一个指向 `objc_class` 结构体的指针。在 64 位系统中，指针占用 8 个字节（Byte），即 `NSObject` 的实例对象大小应该为 8 个字节。我们也可以尝试用 C 语言中的 `sizeof()` 运算符来证明这一点：

```objc
NSObject *obj = [[NSObject alloc] init];
NSLog(@"%zd", sizeof(NSObject *));
// 8
```

但系统分配给 `NSObject` 实例对象的内存空间真的是 8 个字节吗？在 `NSObject` 对象初始化后，打个断点，运行程序。得到 `obj` 的内存地址，放在 Xcode - Debug - Debug Workflow - View Memory - Address 中进行查看。1 个字节为 8 位（Bit），为了便于观察，通常会使用十六进制代表二进制，即使用 1 个十六进制表示 4 个二进制，则 2 个十六进制即代表 1 个字节。观察图中上方红框处，除了 `obj` 对象实际使用的 8 个字节，其后面还有 8 个空（`00`）字节。这 8 个字节是否也是系统分配给 `obj` 的呢？

![](1.png)

## alloc

在 `[[NSObject alloc] init]` 中，`alloc` 是为了向系统申请内存空间。

```ojbc
// NSObject.mm
+ (id)alloc {
    // ➡️ 调用 _objc_rootAlloc
    return _objc_rootAlloc(self);
}

// Base class implementation of +alloc. cls is not nil.
// Calls [cls allocWithZone:nil].
id
_objc_rootAlloc(Class cls)
{
    // ➡️ 调用 callAlloc
    return callAlloc(cls, false/*checkNil*/, true/*allocWithZone*/);
}

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
            // ➡️ 调用 class_createInstance，extraBytes == 0
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

// objc-runtime-new.mm
id 
class_createInstance(Class cls, size_t extraBytes)
{
    // ➡️ 调用 _class_createInstanceFromZone，extraBytes == 0
    return _class_createInstanceFromZone(cls, extraBytes, nil);
}

// objc-runtime-new.mm
/***********************************************************************
* class_createInstance
* fixme
* Locking: none
**********************************************************************/

static __attribute__((always_inline)) 
id
_class_createInstanceFromZone(Class cls, size_t extraBytes, void *zone, 
                              bool cxxConstruct = true, 
                              size_t *outAllocatedSize = nil)
{
    if (!cls) return nil;

    assert(cls->isRealized());

    // Read class's info bits all at once for performance
    bool hasCxxCtor = cls->hasCxxCtor();
    bool hasCxxDtor = cls->hasCxxDtor();
    bool fast = cls->canAllocNonpointer();

    // ➡️ 调用 instanceSize，extraBytes == 0
    size_t size = cls->instanceSize(extraBytes);
    if (outAllocatedSize) *outAllocatedSize = size;

    id obj;
    if (!zone  &&  fast) {
        obj = (id)calloc(1, size);
        if (!obj) return nil;
        obj->initInstanceIsa(cls, hasCxxDtor);
    } 
    else {
        if (zone) {
            obj = (id)malloc_zone_calloc ((malloc_zone_t *)zone, 1, size);
        } else {
            obj = (id)calloc(1, size);
        }
        if (!obj) return nil;

        // Use raw pointer isa on the assumption that they might be 
        // doing something weird with the zone or RR.
        obj->initIsa(cls);
    }

    if (cxxConstruct && hasCxxCtor) {
        obj = _objc_constructOrFree(obj, cls);
    }

    return obj;
}

// objc-runtime-new.h
size_t instanceSize(size_t extraBytes) {
    // ➡️ 调用 alignedInstanceSize
    size_t size = alignedInstanceSize() + extraBytes;
    // CF requires all objects be at least 16 bytes.
    // ⚠️ CF 要求所有对象至少 16 字节
    if (size < 16) size = 16;
    return size;
}

// Class's ivar size rounded up to a pointer-size boundary.
uint32_t alignedInstanceSize() {
    // ➡️ 调用 unalignedInstanceSize，再调用 word_align
    return word_align(unalignedInstanceSize());
}

// objc-runtime-new.h
// May be unaligned depending on class's ivars.
uint32_t unalignedInstanceSize() {
    assert(isRealized());
    // ➡️ 调用 data
    return data()->ro->instanceSize;
}

// objc-runtime-new.h
// ➡️ 返回类中的读写数据
class_rw_t *data() { 
    return bits.data();
}

// ➡️ 类中的只读数据
const class_ro_t *ro;

struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    // ➡️ 实例大小
    uint32_t instanceSize;
#ifdef __LP64__
    uint32_t reserved;
#endif

    const uint8_t * ivarLayout;
    
    const char * name;
    method_list_t * baseMethodList;
    protocol_list_t * baseProtocols;
    const ivar_list_t * ivars;

    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;

    method_list_t *baseMethods() const {
        return baseMethodList;
    }
};

// objc-os.h
// ➡️ word_align 有两个实现，unalignedInstanceSize 返回 uint32_t
// 所以这里的 word_align 为参数是 uint32_t 类型的一个
static inline uint32_t word_align(uint32_t x) {
    return (x + WORD_MASK) & ~WORD_MASK;
}

// __LP64__ 代表在 64 位时的情况
#ifdef __LP64__
#   define WORD_SHIFT 3UL
    // ➡️ WORD_MASK
#   define WORD_MASK 7UL
#   define WORD_BITS 64
#else
#   define WORD_SHIFT 2UL
#   define WORD_MASK 3UL
#   define WORD_BITS 32
#endif
```

在 `word_align` 字长对齐的方法中，`WORD_MASK` 在 64 位下为无符号长整型（Unsigned Long）的 `7`，即二进制下为 `0b0111`，`~WORD_MASK` 即 `-0b1000`。将参数即实例大小加上 `WORD_MASK` 并对 `~WORD_MASK` 做按位与操作。保证了对齐后的大小均为 8 的倍数。而在 `instanceSize` 的后续步骤中，也注释表明了「CF 要求所有对象至少 16 字节」。所以到这里，我们可以认为 `NSObject` 的对象实际分配的空间为 16 字节。


## class_getInstanceSize

`class_getInstanceSize` 是 Runtime 中的一个方法，可以获取传入实例类型的大小。

```ojbc
#import <malloc/malloc.h>

NSLog(@"%zd", class_getInstanceSize([NSObject class]));
// 8
```

为什么它的答案也是 8 呢？当我们看到其中的实现就一目了然了，`class_getInstanceSize` 本质也是调用了 `alignedInstanceSize` 方法，所以和上面的答案一致。

```objc
// runtime.h
/** 
 * Returns the size of instances of a class.
 * 
 * @param cls A class object.
 * 
 * @return The size in bytes of instances of the class \e cls, or \c 0 if \e cls is \c Nil.
 */
OBJC_EXPORT size_t
class_getInstanceSize(Class _Nullable cls) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

// objc-class.mm
size_t class_getInstanceSize(Class cls)
{
    if (!cls) return 0;
    // ➡️ 调用 alignedInstanceSize
    return cls->alignedInstanceSize();
}
```

## malloc_size

那有什么办法可以获取对象真正分配的内存空间呢？答案是 `malloc_size`。

```objc
#import <malloc/malloc.h>

NSLog(@"%zd", malloc_size((__bridge void *)[[NSObject alloc] init]));
// 16
```

因为 `malloc_size` 返回的是指针指向的内存地址大小，而 `class_getInstanceSize` 返回的则是类的实例的大小。

```objc
// malloc.h
extern size_t malloc_size(const void *ptr);
    /* Returns size of given ptr */
```

## 自定义类

定义一个 `Computer` Obj-C 类，继承自 `NSObject`，拥有两个成员变量。

```objc
@interface Computer : NSObject {
    @public
    int _memorySize;
    int _diskSize;
}
@end

@implementation Computer
@end
```

使用 clang 将其翻译为 C/C++ 代码，Obj-C 的类就变成了 C 语言中的结构体：

```cpp
struct NSObject_IMPL {
    Class isa;
};

struct Computer_IMPL {
    struct NSObject_IMPL NSObject_IVARS;
    int _memorySize;
    int _diskSize;
};
```

简单实践一下：

```objc
Computer *cpt = [[Computer alloc] init];
cpt->_memorySize = 16;
cpt->_diskSize = 512;

// 将 cpt 指向 Computer Obj-C 类的指针转换为指向 Computer_IMPL 结构体的指针
struct Computer_IMPL *cptStruct = (__bridge struct Computer_IMPL *)(cpt);
NSLog(@"cptStruct->_memorySize: %d, cptStruct->_diskSize: %d", cptStruct->_memorySize, cptStruct->_diskSize);
// cptStruct->_memorySize: 16, cptStruct->_diskSize: 512
```

## 自定义类的实例对象大小

```objc
@interface Computer : NSObject {
    @public
    int _memorySize;
    int _diskSize;
}
@end

@implementation Computer
@end

// ---
@interface Mac : Computer {
    @public
    bool _hasScreen;
}
@end

@implementation Mac
@end

// ---
@interface MacPro : Mac {
    @public
    double _cpuPerformance;
}
@end

@implementation MacPro
@end
```

定义以上几个类，`Computer` 继承自 `NSObject`，`Mac` 继承自 `Computer`，`MacPro` 继承自 `Mac`，尝试输出它们的实例以及实际分配的大小。

```objc
NSObject *myObj = [[NSObject alloc] init];
NSObject *myCpt = [[Computer alloc] init];
NSObject *myMac = [[Mac      alloc] init];
NSObject *myPro = [[MacPro   alloc] init];
    
NSLog(@"NSObject - Instance Size - %zd", class_getInstanceSize([NSObject class]));
NSLog(@"NSObject - Malloc Size   - %zd", malloc_size((__bridge const void *)(myObj)));

NSLog(@"Computer - Instance Size - %zd", class_getInstanceSize([Computer class]));
NSLog(@"Computer - Malloc Size   - %zd", malloc_size((__bridge const void *)(myCpt)));

NSLog(@"Mac      - Instance Size - %zd", class_getInstanceSize([Mac class]));
NSLog(@"Mac      - Malloc Size   - %zd", malloc_size((__bridge const void *)(myMac)));

NSLog(@"MacPro   - Instance Size - %zd", class_getInstanceSize([MacPro class]));
NSLog(@"MacPro   - Malloc Size   - %zd", malloc_size((__bridge const void *)(myPro)));

NSLog(@"bool   size - %zd", sizeof(bool));
NSLog(@"int    size - %zd", sizeof(int));
NSLog(@"double size - %zd", sizeof(double));

// NSObject - Instance Size - 8
// NSObject - Malloc Size   - 16
// Computer - Instance Size - 16
// Computer - Malloc Size   - 16
// Mac      - Instance Size - 24
// Mac      - Malloc Size   - 32
// MacPro   - Instance Size - 32
// MacPro   - Malloc Size   - 32
// bool   size - 1
// int    size - 4
// double size - 8
// Program ended with exit code: 0
```

比较让人困惑的是 `myMac` 的实例大小与实际分配大小。`Mac` 除了自己的一个成员变量，还有两个继承自父类 `Computer` 的成员变量，以及一个继承自基类 `NSObject` 的 `isa`。在 64 位操作系统上，共计占用 8+4+4+1=17 字节，经过字长对齐后即 24 字节，与 `class_getInstanceSize` 返回的结果一致。但为什么最终 `malloc_size` 却是 32 字节呢？

因为在分配内存时，除了字长对齐，还存在另外的内存对齐。其将按照 16 的倍数进行对齐。

```
// nano_zone_common.h
#define NANO_MAX_SIZE			256 /* Buckets sized {16, 32, 48, ..., 256} */
```

## calloc

在 GNU 中的 glibc，也有类似 `NANO_MAX_SIZE` 的实现 `MALLOC_ALIGNMENT`，都是为了进行内存对齐。

```c
// sysdeps/generic/malloc-alignment.h
/* MALLOC_ALIGNMENT is the minimum alignment for malloc'ed chunks.  It
   must be a power of two at least 2 * SIZE_SZ, even on machines for
   which smaller alignments would suffice. It may be defined as larger
   than this though. Note however that code and data structures are
   optimized for the case of 8-byte alignment.  */
// long double 占用 16 字节，SIZE_SZ 即 sizeof(size_t)，在 Xcode 中为 8
// 即 #define MALLOC_ALIGNMENT 16
#define MALLOC_ALIGNMENT (2 * SIZE_SZ < __alignof__ (long double) \
			  ? __alignof__ (long double) : 2 * SIZE_SZ)

// malloc/malloc-internal.h
/* The corresponding word size.  */
#define SIZE_SZ (sizeof (INTERNAL_SIZE_T))

#ifndef INTERNAL_SIZE_T
# define INTERNAL_SIZE_T size_t
#endif

// sysdeps/i386/malloc-alignment.h
#define MALLOC_ALIGNMENT 16
```

## Reference

- [将 Obj-C 代码翻译为 C++ 代码](https://github.com/kingcos/Perspective/issues/72)
- [StackOverflow - Where is __LP64__ defined for default builds of C++ applications on OSX 10.6?](https://stackoverflow.com/questions/6721037/where-is-lp64-defined-for-default-builds-of-c-applications-on-osx-10-6)
- [Wikipedia - sizeof](https://en.wikipedia.org/wiki/Sizeof)