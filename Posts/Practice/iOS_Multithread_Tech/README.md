# Practice - iOS 多线程技术

| Date | Notes | Swift | Xcode |
|:-----:|:-----:|:-----:|:-----:|
| 2019-03-08 |

## Preface

在 iOS 中的多线程（Multithreading）技术通常有以下几种方式，`pthread` 


# pthreads (POSIX Threads)

> POSIX Threads, usually referred to as pthreads, is an execution model that exists independently from a language, as well as a parallel execution model. It allows a program to control multiple different flows of work that overlap in time. Each flow of work is referred to as a thread, and creation and control over these flows is achieved by making calls to the POSIX Threads API.
>
> -- POSIX Threads, Wikipedia
>
> 译：
> 
> POSIX（Portable Operating System Interface of UNIX，可移植操作系统接口）线程，即 pthreads，是一种不依赖于编程语言的执行模型和并行（Parallel）执行模型。其允许一个程序控制多个时间重叠的不同工作流。每个工作流即为一个线程，通过调用 POSIX 线程 API 创建并控制这些流。

如上所述，pthreads（即 POSIX Threads，后简称 pthreads）是一套跨平台的多线程 API。其由 C 语言编写，在 Obj-C 中也能够直接使用，但也由于是纯 C 的 API，使用起来不够友好，也需要我们管理线程的整个生命周期。

在 Obj-C 中，`#import "pthread.h"` 即可引入 pthreads 相关的 API。pthreads 使用 `int pthread_create(pthread_t _Nullable * _Nonnull __restrict, const pthread_attr_t * _Nullable __restrict, void * _Nullable (* _Nonnull)(void * _Nullable), void * _Nullable __restrict);` 函数来创建线程。但这个函数接口没有暴露参数名，不易理解，另外一个更容易理解的版本是 `int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void *), void *arg);`。其中第一个参数是 `pthread_t *thread `，关于 `pthread_t` 到底是什么，我查阅了很多资料，目前看来有两种实现，一种指整型（Integer）四字节的线程 ID，另一种指包含值和其他的抽象结构体（参考 [IBM - Thread ID vs. Pthread Handle (pthread_t)](https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_71/apis/concep17.htm)，这种抽象有助于在一个进程（Process）中实现扩展到数千个线程），后者也可以称为 `pthread` 的句柄（Handle）。在 iOS/macOS 中，我们可以顺着找到 `pthread_t` 的源头，即是后者，`pthread_t` 是一个不透明类型（Opaque Type，不透明类型在计算机科学中通俗的理解是一种外界只需要知道其存在，而无需关心内部实现细节的数据类型，常为结构体）的结构体。

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

第二个参数是 `const pthread_attr_t *attr`，`pthread_attr_t` 也是一个不透明类型的结构体。其内容决定了新线程创建时的属性。可以使用 `int pthread_attr_init(pthread_attr_t *);` 初始化该结构体。我们之后将传入 `NULL` 即使用默认属性来创建线程。

```objc
// _pthread_attr_t.h
typedef __darwin_pthread_attr_t pthread_attr_t;

// _pthread_types.h
typedef struct _opaque_pthread_attr_t __darwin_pthread_attr_t;

struct _opaque_pthread_attr_t {
	long __sig;
	char __opaque[__PTHREAD_ATTR_SIZE__];
};
```

最后两个参数 `void *(*start_routine) (void *), void *arg` 比较好理解，`start_routine()` 是新线程运行时所执行的函数，`arg` 是传入 `start_routine()` 的参数。当 `start_routine()` 执行终止或者线程被明确杀死，线程也将会终止。



## Tips

### __restrict




## Reference

- [man - pthread_create](http://man7.org/linux/man-pages/man3/pthread_create.3.html)
- [IBM - Thread ID vs. Pthread Handle (pthread_t)](https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_71/apis/concep17.htm)
- [NMSU - The Pthreads Library](https://www.cs.nmsu.edu/~jcook/Tools/pthreads/library.html)
- []()
- []()
- []()
- []()
- []()
