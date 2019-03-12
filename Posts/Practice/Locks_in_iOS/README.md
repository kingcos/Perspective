# Practice - iOS 中的锁（Lock）

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019-03-08 | 首次提交 |  |

锁（Lock）是什么？正如 Wikipedia 所说：

> In computer science, a lock or mutex (from mutual exclusion) is a synchronization mechanism for enforcing limits on access to a resource in an environment where there are many threads of execution. A lock is designed to enforce a mutual exclusion concurrency control policy.
> 
> -- Lock (computer science), Wikipedia
> 
> 译：
> 在计算机科学中，锁或互斥（mutex，来源于 mutual exclusion，相互排斥）是一种同步机制，用于在多线程执行的环境中强制限制访问资源的访问。锁被设计为强制互斥的并发控制策略。
> 
> -- 锁（计算机科学）

在计算机中，一块资源（Resource），或者简单地拿一个变量（Variable）来举例，当它加载到内存之后，可能会有许多线程（Thread）去同时访问其所在的内存地址。为了保护这块资源在同一时间只能被有限个线程访问，就可以加上锁，在需要访问的线程访问完毕后，再进行解锁，即可以保证在程序执行时，其是线程安全的。iOS 也是支持多线程的操作系统，锁自然也存在于 iOS 中，那么这篇就简单谈谈 iOS 中锁的概念，以及相关的 API。

## NSLock

NSLock 是






## Reference

- [Wikipedia - Lock (computer science)](https://en.wikipedia.org/wiki/Lock_(computer_science))