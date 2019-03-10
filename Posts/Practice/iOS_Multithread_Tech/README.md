# Practice - iOS 多线程技术

| Date | Notes | Swift | Xcode |
|:-----:|:-----:|:-----:|:-----:|
| 2019-03-08 |

## Preface

在 iOS 中的多线程（Multithreading）技术通常有以下几种方式，`pthread` 


## pthreads (POSIX Threads)

> POSIX Threads, usually referred to as pthreads, is an execution model that exists independently from a language, as well as a parallel execution model. It allows a program to control multiple different flows of work that overlap in time. Each flow of work is referred to as a thread, and creation and control over these flows is achieved by making calls to the POSIX Threads API.
>
> -- POSIX Threads, Wikipedia
>
> 译：
> 
> POSIX（Portable Operating System Interface of UNIX，可移植操作系统接口）线程，即 pthreads，是一种不依赖于编程语言的执行模型和并行（Parallel）执行模型。其允许一个程序控制多个时间重叠的不同工作流。每个工作流即为一个线程，通过调用 POSIX 线程 API 创建并控制这些流。

如上所述，pthreads，即 POSIX Threads（后简称 pthreads）是一套跨平台的多线程 API。由 C 语言编写，在 Obj-C 中，`#import "pthread.h"` 即可引入 pthreads 相关的 API。但也由于是纯 C 的 API，使用起来不够友好，也需要手动管理线程的整个生命周期。

### `pthread_create`

pthreads 使用 `int pthread_create(pthread_t _Nullable * _Nonnull __restrict, const pthread_attr_t * _Nullable __restrict, void * _Nullable (* _Nonnull)(void * _Nullable), void * _Nullable __restrict);` 来创建线程。`_Nullable` 和 `_Nonnull ` 是 Obj-C 桥接 Swift 可选（Optional）类型的标志；`__restrict` 是 C99 标准引入的关键字，类似于 `restrict`，可以用在指针声明处，用于告诉编译器只有该指针本身才能修改指向的内容，便于编译器优化。去掉这些不影响函数本身的标志，补全参数名，即 `int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void *), void *arg);`。下面将简单分析下该函数的四个参数。

其中第一个参数是 `pthread_t *thread`。关于该参数实际意义，一种指整型（Integer）四字节的线程 ID，另一种指包含值和其他的抽象结构体，这种抽象有助于在一个进程（Process）中实现扩展到数千个线程，后者也可以称为 `pthread` 的句柄（Handle）。在 Obj-C 中，`pthread_t` 属于后者，其本质是 `_opaque_pthread_t`，一个不透明类型（Opaque Type）的结构体，即一种外界只需要知道其存在，而无需关心内部实现细节的数据类型。

```c
// _pthread_t.h
typedef __darwin_pthread_t pthread_t;

// _pthread_types.h
typedef struct _opaque_pthread_t *__darwin_pthread_t;

struct _opaque_pthread_t {
	long __sig;
	struct __darwin_pthread_handler_rec  *__cleanup_stack;
	char __opaque[__PTHREAD_SIZE__];
};
```

第二个参数是 `const pthread_attr_t *attr`。`pthread_attr_t` 本质也是一个不透明类型的结构体。可以使用 `int pthread_attr_init(pthread_attr_t *);` 初始化该结构体。该参数为 `NULL` 时将使用默认属性来创建线程。

```c
// _pthread_attr_t.h
typedef __darwin_pthread_attr_t pthread_attr_t;

// _pthread_types.h
typedef struct _opaque_pthread_attr_t __darwin_pthread_attr_t;

struct _opaque_pthread_attr_t {
	long __sig;
	char __opaque[__PTHREAD_ATTR_SIZE__];
};
```

最后两个参数是 `void *(*start_routine) (void *), void *arg`。`start_routine()` 是新线程运行时所执行的函数，`arg` 是传入 `start_routine()` 的参数。当 `start_routine()` 执行终止或者线程被明确杀死，线程也将会终止。







## Reference

- [man - pthread_create](http://man7.org/linux/man-pages/man3/pthread_create.3.html)
- [IBM - Thread ID vs. Pthread Handle (pthread_t)](https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_71/apis/concep17.htm)
- [NMSU - The Pthreads Library](https://www.cs.nmsu.edu/~jcook/Tools/pthreads/library.html)
- [Translation - [译]在 Objective-C API 中指定可空性](https://github.com/kingcos/Perspective/issues/71)
- [Wikipedia - restrict](https://en.wikipedia.org/wiki/Restrict)
- []()
- []()
- []()
