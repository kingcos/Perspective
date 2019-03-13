# Practice - iOS 中的 NSObject

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019-03-13 | 首次提交 | [objc4-750](https://opensource.apple.com/tarballs/objc4/objc4-750.tar.gz)、[libmalloc-166.220.1](https://opensource.apple.com/tarballs/libmalloc/libmalloc-166.220.1.tar.gz) |

## What

`clang -rewrite-objc main.m -o main.cpp`

`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main.cpp -framework UIKit`

```cpp
// NSObject Obj-C -> C
struct NSObject_IMPL {
	Class isa;
};
```


##

### class_getInstanceSize

```objc
#import <objc/runtime.h>

NSLog(@"%zd", class_getInstanceSize([NSObject class]));
```

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
    return cls->alignedInstanceSize();
}

// objc-runtime-new.h
// Class's ivar size rounded up to a pointer-size boundary.
uint32_t alignedInstanceSize() {
    return word_align(unalignedInstanceSize());
}

// objc-runtime-new.h
// May be unaligned depending on class's ivars.
uint32_t unalignedInstanceSize() {
    assert(isRealized());
    return data()->ro->instanceSize;
}

// objc-os.h
#ifdef __LP64__
#   define WORD_SHIFT 3UL
#   define WORD_MASK 7UL
#   define WORD_BITS 64
#else
#   define WORD_SHIFT 2UL
#   define WORD_MASK 3UL
#   define WORD_BITS 32
#endif

static inline uint32_t word_align(uint32_t x) {
    return (x + WORD_MASK) & ~WORD_MASK;
}
```


### malloc_size

```objc
#import <malloc/malloc.h>

NSLog(@"%zd", malloc_size((__bridge void *)[[NSObject alloc] init]));
```

```objc
// malloc.h
extern size_t malloc_size(const void *ptr);
    /* Returns size of given ptr */

// malloc.c
size_t
malloc_size(const void *ptr)
{
	size_t size = 0;

	if (!ptr) {
		return size;
	}

	(void)find_registered_zone(ptr, &size);
	return size;
}
```



##

```ojbc
// [[NSObejct alloc] init];
// NSObject.mm
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

// [NSObject new];
+ (id)new {
    return [callAlloc(self, false/*checkNil*/) init];
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
    size_t size = alignedInstanceSize() + extraBytes;
    // CF requires all objects be at least 16 bytes.
    if (size < 16) size = 16;
    return size;
}
```
## 

## Tips

### 大端与小端


### __bridge





### 内存对齐



### LLDB













## Reference
