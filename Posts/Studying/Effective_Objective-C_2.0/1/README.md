# Studying - Effective Objective-C 2.0

## 1 - 熟悉 Objective-C

### 1. 了解 Objective-C 的起源

- Obj-C 使用「消息结构」（Messaging Structure）而非「函数调用」（Function Calling）
- 使用消息结构的语言，其运行时所应执行的代码由运行环境决定；而函数调用的语言，则由编译器决定
- 多态
  - 函数调用的语言要按照「虚方法表」（Virtual Method Table），虚方法表是编程语言为实现「动态派发」（Dynamic Dispatch）或运行时「方法绑定」（Method Binding）而采用的一种机制
  - 消息结构的语言不论是否多态，总是在运行时才会去查找要执行的方法
- 使用 Obj-C 的面向对象特性所需的全部数据结构及函数都在「运行期组件」（Runtime Component）里面
- 运行期组件本质上就是一种与开发者所编代码想链接的「动态库」（Dynamic Library），其代码能把开发者编写的所有程序粘合起来；只需更新运行期组件，即可提升应用程序性能（而不需要重新编译代码）
- Obj-C 是 C 的「超集」（Superset）

```objc
// str：指向 NSString 的指针
NSString *str = @"github.com/kingcos";

// ERROR:
// 不能在「栈」（Stack）上分配 Obj-C 对象
// Interface type cannot be statically allocated
// NSString str = @"github.com/kingcos";
```

- 对象所占内存总是分配在「堆空间」（Heap Space）上

```objc
// str1 & str2 指向同一地址
NSString *str1 = @"maimieng.com";
NSString *str2 = str1;
```

- `str1` & `str2` 两个变量都是 `NSString *` 类型，这说明当前栈帧（Stack Frame）里分配了两块内存，每块内存的大小都能容下一枚指针（32 位 4 字节，64 位 8 字节）；这两块内存里的值都一样，存储了 NSString 实例的内存地址


### 2. 在类的头文件中尽量少引入其他头文件
### 3. 多要字面量语法，少用与之等效的方法
### 4. 多用类型常量，少用 #define 预处理指令
### 5. 用枚举表示状态、选项和状态码