# Practice - iOS 多线程技术

| Date | Notes | Swift | Xcode |
|:-----:|:-----:|:-----:|:-----:|
| 2019-03-08 |

## Preface

在 iOS 中的多线程（Multithreading）技术通常有以下几种方式，`pthread`、`NSThread`、GCD、`NSOperation`。

## pthreads (POSIX Threads)

> POSIX Threads, usually referred to as pthreads, is an execution model that exists independently from a language, as well as a parallel execution model. It allows a program to control multiple different flows of work that overlap in time. Each flow of work is referred to as a thread, and creation and control over these flows is achieved by making calls to the POSIX Threads API.
>
> -- POSIX Threads, Wikipedia
>
> 译：
> 
> POSIX（Portable Operating System Interface of UNIX，可移植操作系统接口）线程，即 pthreads，是一种不依赖于语言的执行模型，也称作并行（Parallel）执行模型。其允许一个程序控制多个时间重叠的不同工作流。每个工作流即为一个线程，通过调用 POSIX 线程 API 创建并控制这些流。

如上所述，pthreads，即 POSIX Threads（后简称 pthreads）是一套跨平台的多线程 API。由 C 语言编写，在 Obj-C 中，`#import <pthread.h>` 即可引入 pthreads 相关的 API。但也由于是纯 C 的 API，使用起来不够友好，也需要手动管理线程的整个生命周期。

### `pthread_create`

pthreads 使用 `int pthread_create(pthread_t _Nullable * _Nonnull __restrict, const pthread_attr_t * _Nullable __restrict, void * _Nullable (* _Nonnull)(void * _Nullable), void * _Nullable __restrict);` 来创建线程。`_Nullable` 和 `_Nonnull ` 是 Obj-C 桥接 Swift 可选（Optional）类型的标志；`__restrict` 是 C99 标准引入的关键字，类似于 `restrict`，可以用在指针声明处，用于告诉编译器只有该指针本身才能修改指向的内容，便于编译器优化。去掉这些不影响函数本身的标志，补全参数名，即 `int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void *), void *arg);`。下面将简单分析下该函数的四个参数。

其中第一个参数是 `pthread_t *thread`。关于该参数实际意义，一种指整型（Integer）四字节的线程 ID，另一种指包含值和其他的抽象结构体，这种抽象有助于在一个进程（Process）中实现扩展到数千个线程，后者也可以称为 `pthread` 的句柄（Handle）。在 Obj-C 中，`pthread_t` 属于后者，其本质是 `_opaque_pthread_t`，一个不透明类型（Opaque Type）的结构体，即一种外界只需要知道其存在，而无需关心内部实现细节的数据类型。在函数中，该参数是作为指针传入的，总之我们可以简单将这个参数理解为线程的引用即可，通过它能找到线程的 ID 或者其他信息。

```c
// sys/_pthread/_pthread_t.h
typedef __darwin_pthread_t pthread_t;

// sys/_pthread/_pthread_types.h
typedef struct _opaque_pthread_t *__darwin_pthread_t;

// sys/_pthread/_pthread_types.h
struct _opaque_pthread_t {
	long __sig;
	struct __darwin_pthread_handler_rec  *__cleanup_stack;
	char __opaque[__PTHREAD_SIZE__];
};
```

第二个参数是 `const pthread_attr_t *attr`。`pthread_attr_t` 本质也是一个不透明类型的结构体。可以使用 `int pthread_attr_init(pthread_attr_t *);` 初始化该结构体。该参数为 `NULL` 时将使用默认属性来创建线程。

```c
// sys/_pthread/_pthread_attr_t.h
typedef __darwin_pthread_attr_t pthread_attr_t;

// sys/_pthread/_pthread_types.h
typedef struct _opaque_pthread_attr_t __darwin_pthread_attr_t;

// sys/_pthread/_pthread_types.h
struct _opaque_pthread_attr_t {
	long __sig;
	char __opaque[__PTHREAD_ATTR_SIZE__];
};
```

最后两个参数是 `void *(*start_routine) (void *), void *arg`。`start_routine()` 是新线程运行时所执行的函数，`arg` 是传入 `start_routine()` 的参数。当 `start_routine()` 执行终止或者线程被明确杀死，线程也将会终止。

返回值是 `int` 类型，当返回 `0` 时，创建成功，否则将返回错误码。

```objc
#import "POSIXThreadManager.h"

#import <pthread.h>

void * run_for_pthread_create_demo(void * arg) {
    // 打印参数 & 当前线程 __opaque 属性的地址
    printf("%s (%p) is running.\n", arg, &pthread_self()->__opaque);
    exit(2);
}

@implementation POSIXThreadManager

+ (void)pthread_create_demo {
    // 声明 thread_1 & thread_2
    pthread_t thread_1, thread_2;
    
    // 创建 thread_1
    int result_1 = pthread_create(&thread_1, NULL, run_for_pthread_create_demo, "thread_1");
    
    // 打印 thread_1 创建函数返回值 & __opaque 属性的地址
    printf("result_1 - %d - %p\n", result_1, &thread_1->__opaque);
    
    // 检查线程是否创建成功
    if (result_1 != 0) {
        perror("pthread_create thread_1 error.");
        // 线程创建失败退出码为 1
        exit(1);
    }
    
    // 创建 thread_2
    int result_2 = pthread_create(&thread_2, NULL, run_for_pthread_create_demo, "thread_2");
    
    // 打印 thread_2 创建函数返回值 & __opaque 属性的地址
    printf("result_2 - %d - %p\n", result_2, &thread_2->__opaque);
    
    if (result_2 != 0) {
        perror("pthread_create thread_2 error.");
        // 线程创建失败退出码为 1
        exit(1);
    }
    
    // sleep(1);
    
    // 主线程退出码为 3
    exit(3);
}

@end
```

这段程序简单地创建了两个子线程，带上程序本身的主线程，其实一共有三个线程。当某个线程执行到 `exit()` 时，整个程序停止。尝试多运行几次就能发现，每次的输出结果都不太一样。`OUTPUT-1` 中，主线程先抢在了子线程之前输出，之后子线程输出，最后主线程结束了程序；`OUTPUT-2` 中，主线程和子线程轮流输出，最后被子线程结束了程序。`OUTPUT-3` 中，`thread_2` 还没执行完，就被主线程结束了程序，所以没有 `thread_2` 的输出。

```
// OUTPUT-1:
result_1 - 0 - 0x700002479010 // 主线程输出
result_2 - 0 - 0x7000024fc010 // 主线程输出
thread_1 (0x700002479010) is running. // thread_1 输出
thread_2 (0x7000024fc010) is running. // thread_2 输出
Program ended with exit code: 3 // 主线程结束程序

// OUTPUT-2:
result_1 - 0 - 0x70000ff41010 // 主线程输出
thread_1 (0x70000ff41010) is running. // thread_1 输出
result_2 - 0 - 0x70000ffc4010 // 主线程输出
thread_2 (0x70000ffc4010) is running. // thread_2 输出
Program ended with exit code: 2 // 子线程结束程序

// OUTPUT-3:
result_1 - 0 - 0x700005914010 // 主线程输出
result_2 - 0 - 0x700005997010 // 主线程输出
thread_1 (0x700005914010) is running. // thread_1 输出
Program ended with exit code: 3 // 主线程结束程序
```

### `pthread_join `

那如何保证主线程在子线程还没有结束的时候，不执行完呢？首先可以想到的就是让主线程休息一会儿。在 `exit(3);` 之前加一句 `sleep(1);` 让主线程休眠一秒钟，这样子线程的程序就有足够的时间执行完。但这样真的好吗？如果子线程的执行时间小于一秒，那么我们的时间就浪费了；而当大于一秒时，这个方法就没用了。这时候就需要另外一个函数，`int pthread_join(pthread_t , void * _Nullable * _Nullable)`，即 `int pthread_join(pthread_t thread, void **retval);`，其作用是阻塞当前线程运行，直到参数线程 `thread` 终止，参数 `retval` 保存了线程函数的返回值。与 `pthread_create` 一样，当返回 `0` 时，参与成功，否则将返回错误码。

```objc
#import "POSIXThreadManager.h"

#import <pthread.h>

void * run_for_pthread_join_demo(void * arg) {
    // 返回参数
    // return arg;
    pthread_exit(arg);
}

@implementation POSIXThreadManager

+ (void)pthread_join_demo {
    // 声明 thread_1 & thread_2
    pthread_t thread_1, thread_2;
    
    // 创建 thread_1
    int result_1 = pthread_create(&thread_1, NULL, run_for_pthread_join_demo, "thread_1");
    
    // 打印 thread_1 创建函数返回值 & __opaque 属性的地址
    printf("result_1 - %d - %p\n", result_1, &thread_1->__opaque);
    
    // 检查线程是否创建成功
    if (result_1 != 0) {
        perror("pthread_create thread_1 error.");
        // 线程创建失败退出码为 1
        exit(1);
    }
    
    // 创建 thread_2
    int result_2 = pthread_create(&thread_2, NULL, run_for_pthread_join_demo, "thread_2");
    
    // 打印 thread_2 创建函数返回值 & __opaque 属性的地址
    printf("result_2 - %d - %p\n", result_2, &thread_2->__opaque);
    
    if (result_2 != 0) {
        perror("pthread_create thread_2 error.");
        // 线程创建失败退出码为 1
        exit(1);
    }
    
    void * result;
    if (pthread_join(thread_1, &result) != 0) {
        perror("pthread_join thread_1 error.");
    }
    printf("%s\n", result);
    
    if (pthread_join(thread_2, &result) != 0) {
        perror("pthread_join thread_2 error.");
    }
    printf("%s\n", result);
    
    // 主线程退出码为 3
    exit(3);
}

@end
```

这样主线程就能等待子线程全部执行完毕后再接着执行了，而且通过第二个参数也可以使我们在线程间进行数据传输。

```
// OUTPUT:
result_1 - 0 - 0x70000c9e5010 // 主线程输出
result_2 - 0 - 0x70000ca68010 // 主线程输出
thread_1 // 主线程拿到了子线程调用函数的返回值并输出
thread_2 // 主线程拿到了子线程调用函数的返回值并输出
Program ended with exit code: 3 // 主线程结束程序
```

### 互斥锁（Mutex）

多线程的并行计算加快了速度，但这使得多个线程的管理变得复杂。其中一个问题便是，如果两个线程同时对同一个资源操作，情况将变得不可控。举个例子，从 0 开始数数，数到 10 为止，如果有 5 个线程，则平均每个线程只需要数 2 个即可完成。

```objc
#import "POSIXThreadManager.h"

#import <pthread.h>

// 起始数
const int START_NUMBER = 0;
// 结束数
const int END_NUMBER = 10;
// 线程数
const int THREAD_NUMBER = 5;
// 平均每个线程的任务数
const int COUNT_PER_THREAD = (END_NUMBER - START_NUMBER) / THREAD_NUMBER;

// 当前数，初始为起始数
int current_count = START_NUMBER;

void * run_for_thread_conflict_demo(void * arg) {
    for (int i = 0; i < COUNT_PER_THREAD; i++) {
        // 人为休息线程 1 秒
        sleep(1);
        current_count += 1;
        printf("Now - %d\n", current_count);
    }
    return NULL;
}

@implementation POSIXThreadManager

+ (void)thread_conflict_demo {
    // 线程数组
    pthread_t thread[THREAD_NUMBER];
    void * result;
    
    printf("Start number: %d\nEnd number: %d\nThread number: %d\n", START_NUMBER, END_NUMBER, THREAD_NUMBER);
    
    for (int i = 0; i < THREAD_NUMBER; i++) {
        // 循环创建线程
        if (pthread_create(&thread[i], NULL, run_for_thread_conflict_demo, NULL) != 0) {
            printf("pthread_create thread_%d error.", i);
            exit(1);
        }
    }
    
    for (int i = 0; i < THREAD_NUMBER; i++) {
        // 循环 Join 线程，防止主线程提前结束
        pthread_join(thread[i], &result);
    }
    
    // 打印最终的数
    printf("Result count - %d\n", current_count);
}

@end

// OUTPUT:
// Start number: 0
// End number: 10
// Thread number: 5
// Now - 1
// Now - 5
// Now - 4
// Now - 2
// Now - 3
// Now - 6
// Now - 6
// Now - 7
// Now - 8
// Now - 9
// Result count - 9
// Program ended with exit code: 0
```

结果怎么会是 9，是不是谁少数了 1 个呢？数一下输出语句可以发现并没有少数，而却有两个 `6`。其实问题就在于 `sleep(1);`，在一个线程休息的时候可能被另外一个线程抢先访问了同样的资源，而导致出错重复数数，虽然次数都是一定的，但最终的结果却少了。当然，因为这个示例程序是个很简单的 Demo，我们加入了人为的休息 `sleep()` 函数，然而其实每条程序语句的执行都是需要时间的，仍然有可能和其他线程同时访问一块资源。解决这一问题的方法就是加锁（Lock）。计算机科学中的锁不止互斥锁一种，限于主题，我将之后一篇文章中专门讲述锁相关的概念。最基本的锁就是互斥锁，即在不希望被同时多个线程访问的代码前加锁，执行完后再解锁，他们的执行是互斥的。

```objc
// 创建互斥锁
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void * run_for_thread_conflict_demo(void * arg) {
    for (int i = 0; i < COUNT_PER_THREAD; i++) {
        // 人为休息线程 1 秒
        sleep(1);
        
        // 加锁
        pthread_mutex_lock(&mutex);
        
        current_count += 1;
        printf("Now - %d\n", current_count);
        
        // 解锁
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

// Start number: 0
// End number: 10
// Thread number: 5
// Now - 1
// Now - 2
// Now - 3
// Now - 4
// Now - 5
// Now - 6
// Now - 7
// Now - 8
// Now - 9
// Now - 10
// Result count - 10
// Program ended with exit code: 0
```

### 信号量（Semaphore）

信号量的概念很难从字面直接理解，常用的比喻是信号灯：一段马路（即资源）对车辆（即线程）的承载量是有限的，当承载量达到限度时，红灯会亮起阻止进入；当承载量未达到时，绿灯会亮起允许进入。关于互斥锁和信号量的区别，简而言之，互斥锁通常处理多个线程对一个资源的争夺，意味着总是按顺序获取和释放。而信号量则应当用在一个任务到另一个任务的信号，其中的任务要么发送信号要么等待信号。我在 [WWDCHelper](https://github.com/kingcos/WWDCHelper) 中也用到了信号量，函数返回的数据需要等待下载任务完成后才可以得到，所以当下载任务完成后发送信号，等待的信号收到后便继续前行。

我们创建两个线程，线程 2 中人为等待 1 秒代表处理任务，任务完成后发送信号，线程 1 中等待信号，等信号发出再执行自己的任务：

```objc
#import "POSIXThreadManager.h"

#import <pthread.h>
#import <sys/semaphore.h>

// 声明信号量
sem_t * semaphore;

void * run_for_semaphore_demo_1(void * arg) {
    // 等待信号
    if (sem_wait(semaphore) != 0) {
        perror("sem_wait error.");
        exit(1);
    }
    
    printf("Running - %s.\n", arg);
    
    pthread_exit(NULL);
}

void * run_for_semaphore_demo_2(void * arg) {
    printf("Running - %s.\n", arg);
    
    sleep(1);
    // 发送信号
    if (sem_post(semaphore) != 0) {
        perror("sem_post error.");
        exit(1);
    }
    
    pthread_exit(NULL);
}

@implementation POSIXThreadManager

+ (void)semaphore_demo {
    // sem_init 初始化匿名信号量在 macOS 中已被废弃
    // semaphore = sem_init(&semaphore, 0, 0);
    semaphore = sem_open("sem", 0, 0);
    
    pthread_t thread_1, thread_2;
    void * result;
    
    if (pthread_create(&thread_1, NULL, run_for_semaphore_demo_1, "Thread 1") != 0) {
        perror("pthread_create thread_1 error.");
        exit(1);
    }
    
    if (pthread_create(&thread_2, NULL, run_for_semaphore_demo_2, "Thread 2") != 0) {
        perror("pthread_create thread_2 error.");
        exit(1);
    }
    
    pthread_join(thread_1, &result);
    pthread_join(thread_2, &result);
}

@end
```

### One more thing...

上面我们在 Objective-C 中简单尝试了 pthreads 几个 API，那么它们能用 Swift 实现吗？答案是肯定的，但因为 Swift 没有指针的概念，存在了许多 `Unsafe` 开头的指针类型，告知我们其中可能存在隐患。

```swift
import Foundation

class PThreadsManager {
    class func tryCreate() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_create(&thread_1, nil, runForCreate, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }
        
        if pthread_create(&thread_2, nil, runForCreate, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }
        
        sleep(1)
        exit(3)
    }
    
    class func tryJoin() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_create(&thread_1, nil, runForJoin, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }
        
        if pthread_create(&thread_2, nil, runForJoin, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }
        
        if pthread_join(thread_1!, nil) != 0 {
            print("pthread_join thread_1 error.")
            exit(1)
        }
        
        if pthread_join(thread_2!, nil) != 0 {
            print("pthread_join thread_2 error.")
            exit(1)
        }
    }
    
    class func tryMutex() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_mutex_init(&mutex, nil) != 0 {
            print("pthread_mutex_init error.")
        }
        
        if pthread_create(&thread_1, nil, runForMutex, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }

        if pthread_create(&thread_2, nil, runForMutex, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }

        if pthread_join(thread_1!, nil) != 0 {
            print("pthread_join thread_1 error.")
            exit(1)
        }

        if pthread_join(thread_2!, nil) != 0 {
            print("pthread_join thread_2 error.")
            exit(1)
        }

        print("Result count \(current_count)")
    }
    
    class func trySemaphore() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_create(&thread_1, nil, runForSemaphore1, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }
        
        if pthread_create(&thread_2, nil, runForSemaphore2, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }
        
        if pthread_join(thread_1!, nil) != 0 {
            print("pthread_join thread_1 error.")
            exit(1)
        }
        
        if pthread_join(thread_2!, nil) != 0 {
            print("pthread_join thread_2 error.")
            exit(1)
        }
    }
}

let START_NUMBER = 0
let END_NUMBER = 10
let THREAD_NUMBER = 2
let COUNT_PER_THREAD = (END_NUMBER - START_NUMBER) / THREAD_NUMBER

var current_count = START_NUMBER
var mutex = pthread_mutex_t()

var sem: [CChar] = "sem".cString(using: String.Encoding.utf8)!
var semaphore = sem_open(&sem, 0, 0, 0)

func runForCreate(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    print("\(decode(context) as String) is running.")
    exit(2)
}

func runForJoin(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    print("\(decode(context) as String) is running.")
    exit(2)
}

func runForMutex(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    for _ in 0..<COUNT_PER_THREAD {
        sleep(1)
        pthread_mutex_lock(&mutex)

        current_count += 1
        print("Now - \(current_count)")
        
        pthread_mutex_unlock(&mutex)
    }
    pthread_exit(nil)
}

func runForSemaphore1(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    if sem_wait(semaphore) != 0 {
        perror("sem_wait error.")
        exit(1)
    }
    print("runForSemaphore1")
    pthread_exit(nil)
}

func runForSemaphore2(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    sleep(1)
    
    if sem_post(semaphore) != 0 {
        print("sem_post error.")
        exit(1)
    }
    
    print("runForSemaphore2")
    pthread_exit(nil)
}

class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

private func decode<T>(_ memory: UnsafeMutableRawPointer) -> T {
    let unmanaged = Unmanaged<Box<T>>.fromOpaque(memory)
    defer { unmanaged.release() }
    return unmanaged.takeUnretainedValue().value
}

private func encode<T>(_ t: T) -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(Box(t)).toOpaque()
}
```

## `NSThread`










## Reference

- [man - pthread_create](http://man7.org/linux/man-pages/man3/pthread_create.3.html)
- [IBM - Thread ID vs. Pthread Handle (pthread_t)](https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_71/apis/concep17.htm)
- [NMSU - The Pthreads Library](https://www.cs.nmsu.edu/~jcook/Tools/pthreads/library.html)
- [Translation - [译]在 Objective-C API 中指定可空性](https://github.com/kingcos/Perspective/issues/71)
- [Wikipedia - restrict](https://en.wikipedia.org/wiki/Restrict)
- [StackOverflow - What is a semaphore?](https://stackoverflow.com/questions/34519/what-is-a-semaphore)
- [Michael Barr - Mutexes and Semaphores Demystified](https://barrgroup.com/Embedded-Systems/How-To/RTOS-Mutex-Semaphore)
- [Stanford - Thread and Semaphore Examples](https://see.stanford.edu/materials/icsppcs107/23-Concurrency-Examples.pdf)
- [WWDCHelper](https://github.com/kingcos/WWDCHelper)
- [StackOverflow - sem_init on OS X](https://stackoverflow.com/questions/1413785/sem-init-on-os-x)
- [GitHub - ZewoGraveyard/POSIX](https://github.com/ZewoGraveyard/POSIX)