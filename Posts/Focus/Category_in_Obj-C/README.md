# Focus - iOS 中的 Category

| Date | Notes | Source Code | Demo |
|:-----:|:-----:|:-----:|:-----:|
| 2019-04-13 | 首次提交 |  | [Category_in_Obj-C](Category_in_Obj-C/) |

## Preface

![](1.png)

在 Obj-C 中，我们经常会使用 Category（中文常译作分类，但为表述清晰，下文仍将使用 Category）来对一个类进行扩展，使得类可以具备更多的功能；也会对一个类进行拆分，使得其结构更加清晰条理。本文将由浅入深，谈谈 iOS 中的 Category。

## `struct _category_t`

```objc
// Person+Life.h
/**
 LifeProtocol
 */
@protocol LifeProtocol <NSObject>
- (void)eat;
@end

/**
 Person+Life
 */
@interface Person (Life) <LifeProtocol>

@property (nonatomic, copy) NSString *name;

// Instance method
- (void)run;

// Class method
+ (void)foo;

// Protocol method
- (void)eat;

@end
```

以 Person 类为例，创建一个 `Life` 的 Category，并在其中遵守协议、声明属性、定义并实现实例方法和类方法。为了便于分析，我们使用 `clang` 将 Person+Life.m 翻译为 C++ 代码（Person+Life.cpp），关于翻译 Obj-C 代码的细节可以参考文末的「将 Obj-C 代码翻译为 C++ 代码」一文。

```cpp
// Person+Life.cpp
struct _category_t {
	const char *name;                               // 类名
	struct _class_t *cls;                           // 类指针
	const struct _method_list_t *instance_methods;  // 实例方法列表指针
	const struct _method_list_t *class_methods;     // 类方法列表指针
	const struct _protocol_list_t *protocols;       // 协议列表指针
	const struct _prop_list_t *properties;          // 属性列表指针
};

static struct _category_t _OBJC_$_CATEGORY_Person_$_Life __attribute__ ((used, section ("__DATA,__objc_const"))) = 
{
	"Person",
	0, // &OBJC_CLASS_$_Person,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Life,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Life,
	(const struct _protocol_list_t *)&_OBJC_CATEGORY_PROTOCOLS_$_Person_$_Life,
	(const struct _prop_list_t *)&_OBJC_$_PROP_LIST_Person_$_Life,
};

// 实例方法列表
static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[2];
} _OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Life __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	2,
	{{(struct objc_selector *)"run", "v16@0:8", (void *)_I_Person_Life_run},
	{(struct objc_selector *)"eat", "v16@0:8", (void *)_I_Person_Life_eat}}
};

// 类方法列表
static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[1];
} _OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Life __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	1,
	{{(struct objc_selector *)"foo", "v16@0:8", (void *)_C_Person_Life_foo}}
};

// 协议列表
static struct /*_protocol_list_t*/ {
	long protocol_count;  // Note, this is 32/64 bit
	struct _protocol_t *super_protocols[1];
} _OBJC_CATEGORY_PROTOCOLS_$_Person_$_Life __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	1,
	&_OBJC_PROTOCOL_LifeProtocol
};

// 属性列表
static struct /*_prop_list_t*/ {
	unsigned int entsize;  // sizeof(struct _prop_t)
	unsigned int count_of_properties;
	struct _prop_t prop_list[1];
} _OBJC_$_PROP_LIST_Person_$_Life __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_prop_t),
	1,
	{{"name","T@\"NSString\",C,N"}}
};
```

在翻译后的 C++ 源代码中，我们可以发现一个名称和 Category 相关的结构体定义：`struct _category_t`，该结构体其实就表示了 Obj-C 中 Category 的实际结构；`_OBJC_$_CATEGORY_Person_$_Life` 静态变量则是具体的 Person+Life Category。



## Reference

- [将 Obj-C 代码翻译为 C++ 代码](https://github.com/kingcos/Perspective/issues/72)