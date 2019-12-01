//
//  main.m
//  Block_in_Obj-C
//
//  Created by kingcos on 2019/11/23.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

// C 语言函数
int cFunc(int arg) {
    return arg;
}

int main_1(int argc, const char * argv[]) {
    int result1 = cFunc(10);
    
    // C 语言中的函数指针也需要通过函数名得到函数地址
    int (*cFuncPtr)(int) = &cFunc;
    int result2 = (*cFuncPtr)(10);
    
    printf("result1 = %d, result2 = %d\n", result1, result2);
    
    return 0;
}

// ---

// BlockType_1 是一个参数和返回值均为 int 的 Block 类型
typedef int (^BlockType_1)(int);

@interface Foo_1 : NSObject
@property (nonatomic, strong) BlockType_1 block;
@end

@implementation Foo_1
// 作为对象方法参数
- (void)blockAsArg_1:(int(^)(int))block {
    block(10);
}
// 使用 typedef 作为对象方法参数
- (void)blockAsArg_2:(BlockType_1)block {
    block(10);
}
// 作为对象方法返回值
- (int(^)(int))blockAsReturnValue_1 {
    return ^(int arg) { return arg; };
}
// 使用 typedef 作为对象方法返回值
- (BlockType_1)blockAsReturnValue_2 {
    return ^(int arg) { return arg; };
}
@end

// Block 作为 C 语言函数参数
void blockAsArg_1(int (^block)(int)) {
    block(10);
}
// 使用 typedef 作为 C 语言函数参数
void blockAsArg_2(BlockType_1 block) {
    block(10);
}

// 《Objective-C 高级编程》中提到的，将 Block 以非 typedef 形式作为 C 语言函数的返回值类型；但目前会报错，且尚未找到相应的解决方法：
// ERROR: Block pointer to non-function type is invalid
// ERROR: Returning 'int (^)(int)' from a function with incompatible result type 'int (int)'
// int (^blockAsReturnValue()(int)) {
//     return ^(int arg) { return arg; };
// }

BlockType_1 blockAsReturnValue() {
    return ^(int arg) { return arg; };
}

int main_2(int argc, const char * argv[]) {
    // 省略返回值的 void
    ^(int arg) {
        printf("%d\n", arg);
    };

    // 完整写法
    ^void (int arg) {
        printf("%d\n", arg);
    };
    
    // 省略返回值 & 参数
    ^{ /* compound_statement_body */ };
    // 省略返回值
    ^(int arg){ /* compound_statement_body */ };
    // 省略参数
    ^int{ /* compound_statement_body */ return 0; };
    
    // 声明 Block 类型的变量
    int (^block1)(int);
    // 声明并赋值 Block（省略返回值类型）
    int(^block2)(int) = ^(int arg) { return arg; };
    block2 = ^int(int arg) { return arg; };
    // Block 类型的变量之间赋值
    int (^block3)(int) = block2;
    block1 = block2;
    
    // 使用 typedef
    BlockType_1 block4;
    BlockType_1 block5 = ^(int arg) { return arg; };
    block5 = ^int(int arg) { return arg; };
    BlockType_1 block6 = block5;
    block4 = block5;
    
    return 0;
}

// ---

int main_3(int argc, const char * argv[]) {
    void(^block)(void) = ^{
        NSLog(@"Hello, World!");
    };
    
    block();
    
    return 0;
}

// ---

@interface Foo_2 : NSObject
@property (nonatomic, copy) NSString *prop;

- (void)bar_1;
- (void)bar_2;

+ (void)bar;
@end

@implementation Foo_2
- (void)dealloc
{
    NSLog(@"dealloc");
}

- (void)bar_1 {
    void (^block_1)(void) = ^() {
        NSLog(@"self == %@", self);
    };

    block_1();
}

- (void)bar_2 {
    self.prop = @"kingcos.me";

    void (^block_2)(void) = ^() {
        // WARNING: Block implicitly retains 'self'; explicitly mention 'self' to indicate this is intended behavior
        // NSLog(@"_prop == %@.", _prop);

        NSLog(@"_prop == %@", self->_prop);
    };

    block_2();
}

+ (void)bar {
    void (^block)(void) = ^() {
        NSLog(@"self == %@", self);
    };
    
    block();
}
@end

int main_4(int argc, const char * argv[]) {
    void (^block)(void);
    
    {
        auto int autoVar = 1;
        const char *autoConstVar = "kingcos.me";
        
        block = ^() {
            NSLog(@"autoVar == %d, autoConstVar == %s", autoVar, autoConstVar);
        };
        
        autoVar = 10;
        // const char * 为常量，不可改变存储的类型
        // autoConstVar = 1.5;
    }

    // ERROR: Use of undeclared identifier 'autoVar'
    // autoVar = 10;
    
    block();
    
    // ---
    
    Foo_2 *foo = [[Foo_2 alloc] init];
    [foo bar_1];
    [foo bar_2];
    
    [Foo_2 bar];
    
    return 0;
}

// ---

int main_5(int argc, const char * argv[]) {
    void (^block)(void);
    
    {
        static int a = 1;

        block = ^() {
            NSLog(@"a == %d", a);
        };
        
        a = 10;
    }

    block();
    
    return 0;
}

// ---

// 全局变量
int globalVar_1 = 1;
// 全局静态变量
static int staticGlobalVar_1 = 2;

int main_6(int argc, const char * argv[]) {
    void (^block)(void) = ^() {
        NSLog(@"globalVar_1 == %d, staticGlobalVar_1 == %d", globalVar_1, staticGlobalVar_1);
    };

    globalVar_1 = 10;
    staticGlobalVar_1 = 20;

    block();
    
    return 0;
}

// ---

void cFunc_2(char a[10]) {
    printf("%d\n", a[0]);
}

void cFunc_3(char a[10]) {
    // C 语言不允许数组类型变量赋值给另外的数组类型变量
    // ERROR: Array initializer must be an initializer list or string literal
    // char b[10] = a;
    // printf("%d\n", b[0]);
}

int main_7(int argc, const char * argv[]) {
    const char cLocalArr[] = "kingcos.me";
    const char *cLocalString = "kingcos.me";
    
    ^{
        // Block 不会对 C 语言数组进行捕获，而可以使用指针
        // ERROR: Cannot refer to declaration with an array type inside block
        // printf("%c\n", cLocalArr[7]);
        
        printf("%c\n", cLocalString[7]);
    }();
    
    // Block 类似遵循了 C 语言的规范
    char a[10] = {2};
    
    cFunc_2(a);
    cFunc_3(a);
    
    return 0;
}

// ---

int main_8(int argc, const char * argv[]) {
    void (^block1)(void) = ^() {
        NSLog(@"Hello, world!");
    };

    int a = 1;
    void (^block2)(void) = ^() {
        NSLog(@"%d", a);
    };

    NSLog(@"%@ %@ %@", [block1 class], [block2 class], [^{
        NSLog(@"%d", a);
    } class]);

    NSLog(@"%@ %@ %@", [block1 superclass], [block2 superclass],[^{
        NSLog(@"%d", a);
    } superclass]);

    NSLog(@"%@ %@ %@", [[block1 superclass] superclass], [[block2 superclass] superclass],[[^{
        NSLog(@"%d", a);
    } superclass] superclass]);

    NSLog(@"%@ %@ %@", [[[block1 superclass] superclass] superclass], [[[block2 superclass] superclass] superclass],[[[^{
        NSLog(@"%d", a);
    } superclass] superclass] superclass]);
    
    return 0;
}

// ---

int globalVar_2 = 1;

int main_9(int argc, const char * argv[]) {
    void (^gloablBlock)(void) = ^{
        // 没有访问任何外界变量
        NSLog(@"This is a __NSGlobalBlock__.");
    };

    NSLog(@"%@", [gloablBlock class]);

    static int staticVar = 1;

    gloablBlock = ^{
        // 访问了全局变量或局部静态变量
        NSLog(@"globalVar2 == %d, staticVar == %d.", globalVar_2, staticVar);
    };

    NSLog(@"%@", [gloablBlock class]);
    
    // 该 Block 实际初始化时将：
    // impl.isa = &_NSConcreteGlobalBlock;
    
    return 0;
}

// ---

int main_10(int argc, const char * argv[]) {
#if !__has_feature(objc_arc)
    int c = 1;

    void (^stackBlock)(void) = ^{
        NSLog(@"c == %d.", c);
    };

    NSLog(@"%@", [stackBlock class]);
#endif
    
    // stackBlock 初始化时将：
    // impl.isa = &_NSConcreteStackBlock;
    
    return 0;
}

// ---

@interface Foo_3 : NSObject
@end

@implementation Foo_3
- (void)dealloc
{
#if !__has_feature(objc_arc)
    [super dealloc]; // MRC 下需手动调用下父类的 dealloc
#endif
    NSLog(@"dealloc");
}
@end

void (^stackBlock_1)(void);
void (^stackBlock_2)(void);

void initBlockInARC() {
#if __has_feature(objc_arc)
    // 初始化，引用计数 +1
    Foo_3 *strongF = [[Foo_3 alloc] init];

    NSLog(@"%ld", CFGetRetainCount((__bridge CFTypeRef)(strongF)));

    // 弱引用，引用计数不变 +0
    __weak Foo_3 *weakF = strongF;

    NSLog(@"%ld", CFGetRetainCount((__bridge CFTypeRef)(strongF)));

    // Block 捕获，引用计数 +1
    // __NSStackBlock__
    ^{
        NSLog(@"%@", strongF);
        NSLog(@"%@", weakF);
    };

    NSLog(@"%ld", CFGetRetainCount((__bridge CFTypeRef)(strongF)));
#endif
}

void initBlockInMRC() {
#if !__has_feature(objc_arc)
    int c = 10;

    stackBlock_1 = ^{
        NSLog(@"c == %d", c);
    };

    // 初始化，引用计数 +1
    Foo_3 *f = [[Foo_3 alloc] init];
    
    NSLog(@"%ld", [f retainCount]);

    // MRC 下 stackBlock_2 捕获 f 但不持有，引用计数 +0
    stackBlock_2 = ^{
       NSLog(@"f == %@", f);
    };

    NSLog(@"%ld", [f retainCount]);

    [f release];
#endif
}

int main_11(int argc, const char * argv[]) {
#if __has_feature(objc_arc)
    // 初始化 stackBlock
    initBlockInARC();
#else
    // 初始化 stackBlock
    initBlockInMRC();
    
    // 执行 stackBlock_1
    stackBlock_1(); // c == -272632744
    // 执行 stackBlock_2
    stackBlock_2(); // CRASH: objc[59614]: Attempt to use unknown class 0x7ffeefbff428.

    NSLog(@"stackBlock_1 is a %@.", [stackBlock_1 class]); // CRASH: EXC_BAD_ACCESS
#endif
    
    return 0;
}

// ---

@interface Foo_4 : NSObject
@end

@implementation Foo_4
- (void)dealloc
{
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
    NSLog(@"dealloc");
}
@end

typedef void(^BlockType_2)(void);

void (^mallocBlock_1)(void);
void (^mallocBlock_2)(void);

void initBlock() {
#if !__has_feature(objc_arc)
    int c = 10;

    mallocBlock_1 = [^{
        NSLog(@"c == %d", c);
    } copy];

    Foo_4 *f = [[Foo_4 alloc] init];

    mallocBlock_2 = [^{
        NSLog(@"%@", f);
    } copy];

    [f release];
#else
    int c = 10;

    mallocBlock_1 = ^{
        NSLog(@"c == %d", c);
    };

    Foo_4 *strongF = [[Foo_4 alloc] init];
    __weak Foo_4 *weakF = strongF;

    // 1⃣️ ARC 下强指针 mallocBlock_2 指向的 Block 会被自动拷贝为 __NSMallocBlock__
    mallocBlock_2 = ^{
        NSLog(@"%@", strongF);
        NSLog(@"%@", weakF);
    };

    // 使用弱引用指针指向的 Block，将仍然是 __NSStackBlock__，编译将提示以下警告
    // WARNING: Assigning block literal to a weak variable; object will be released after assignment
    __weak BlockType_2 weakStackBlock = ^{
        NSLog(@"%@", strongF);
        NSLog(@"%@", weakF);
    };

    NSLog(@"weakStackBlock is %@", weakStackBlock);

    // 3⃣️ Block 作为 Cocoa API 中方法名含有 `usingBlock` 的参数时会被自动拷贝为 __NSMallocBlock__（较难证明）
    // 4⃣️ Block 作为 GCD API 参数时会被自动拷贝为 __NSMallocBlock__（较难证明）
#endif
}

BlockType_2 returnMallocBlock() {
    auto int autoVar = 10;

#if !__has_feature(objc_arc)
    // MRC 下如果直接返回 Block，将报错「Returning block that lives on the local stack」
    // 即编译器已经发现返回的 Block 是在栈上，一旦函数体走完，Block 就会被销毁，因此在 MRC 下需要手动 copy：
    return [^{
        NSLog(@"%d", autoVar);
    } copy];
#else
    // 2⃣️ ARC 下 Block 作为函数返回值会被自动拷贝为 __NSMallocBlock__
    return ^{
        NSLog(@"%d", autoVar);
    };
#endif
}

int main_12(int argc, const char * argv[]) {
    initBlock();

    NSLog(@"mallocBlock_1 is %@", [mallocBlock_1 class]);
    NSLog(@"mallocBlock_2 is %@", [mallocBlock_2 class]);
    NSLog(@"returnMallocBlock() is %@", [returnMallocBlock() class]);

    mallocBlock_1();
    mallocBlock_2();

#if !__has_feature(objc_arc)
    [mallocBlock_1 release];
    [mallocBlock_2 release];
#endif
    
    return 0;
}

// ---

@interface Foo_5 : NSObject
#if !__has_feature(objc_arc)
// MRC
@property (nonatomic, copy) void (^block_1)(void);
#else
// ARC
@property (nonatomic, copy) void (^block_2)(void);
@property (nonatomic, strong) void (^block_3)(void);
#endif
@end

@implementation Foo_5
@end

// ---

#if __has_feature(objc_arc)
typedef int(^BlockType_3)(int);

BlockType_3 returnSomeBlock(int arg) {
    return ^(int param){ return arg * param; };
}
#endif

int main_13(int argc, const char * argv[]) {
#if __has_feature(objc_arc)
    NSLog(@"%@", returnSomeBlock(10));
#endif
    
    return 0;
}

// ---

typedef void(^BlockType_4)(void);

NSArray *returnBlocksArray_1() {
    int autoVar = 1;
    
    return [[NSArray alloc] initWithObjects:
            ^{ NSLog(@"%d", autoVar); },
            ^{ NSLog(@"%d", autoVar); },
            nil];
}

NSArray *returnBlocksArray_2() {
    int autoVar = 10;
    
    return [[NSArray alloc] initWithObjects:
            [^{ NSLog(@"%d", autoVar); } copy],
            [^{ NSLog(@"%d", autoVar); } copy],
            nil];
}

NSArray *returnBlocksArray_3() {
    int autoVar = 100;
    
    BlockType_4 block = ^{ NSLog(@"%d", autoVar); };
    
    return [[NSArray alloc] initWithObjects:
            block,
            block,
            nil];
}

int main_14(int argc, const char * argv[]) {
    NSArray *arr_1 = returnBlocksArray_1();
    BlockType_4 block_1 = (BlockType_4)[arr_1 objectAtIndex:0];
    block_1();
    // CRASH: EXC_BAD_ACCESS
    // block_1 = (BlockType_4)[arr_1 objectAtIndex:1];
    
    // ---
    
    NSArray *arr_2 = returnBlocksArray_2();
    BlockType_4 block_2 = (BlockType_4)[arr_2 objectAtIndex:0];
    block_2();
    block_2 = (BlockType_4)[arr_2 objectAtIndex:1];
    block_2();

    NSArray *arr_3 = returnBlocksArray_3();
    BlockType_4 block_3 = (BlockType_4)[arr_3 objectAtIndex:0];
    block_3();
    block_3 = (BlockType_4)[arr_3 objectAtIndex:1];
    block_3();
    
    // ---
    
    int autoVar = 0;
    BlockType_4 block_4 = ^{ NSLog(@"%d", autoVar); };
    block_4 = [[[block_4 copy] copy] copy];
    
    NSLog(@"%ld", CFGetRetainCount((__bridge CFTypeRef)(block_4)));
    
    return 0;
}

// ---

@interface Foo_6 : NSObject
@end

@implementation Foo_6
- (void)dealloc
{
    NSLog(@"dealloc");
}
@end

int main_15(int argc, const char * argv[]) {
    Foo_6 *strongF = [[Foo_6 alloc] init];

    __weak Foo_6 *weakF = strongF;
    
    void(^someBlcok)(void) = ^{
        NSLog(@"%@", strongF);
        NSLog(@"%@", weakF);
    };
    
    someBlcok();
    
    return 0;
}


// ---

// 静态全局变量
static int staticGlobalVar = 0;
// 全局变量
int globalVar = 0;

int main_16(int argc, const char * argv[]) {
    // 自动变量
    int autoVar = 0;
    // 静态变量
    static int staticVar = 0;

    auto NSMutableArray *autoArray = [[NSMutableArray alloc] init];

    ^{
        // ERROR: Variable is not assignable (missing __block type specifier)
        // autoVar = 10;

        staticVar = 10;
        staticGlobalVar = 10;
        globalVar = 10;

        [autoArray addObject:@"kingcos.me"];

        // ERROR: Variable is not assignable (missing __block type specifier)
        // autoArray = [[NSMutableArray alloc] init];
    }();

    return 0;
}

// ---

int main_17(int argc, const char * argv[]) {
    void(^block1)(void);
    void(^block2)(void);

    {
        __block int autoVar = 1;
        __block auto NSMutableArray *autoArray = [[NSMutableArray alloc] init];

        NSLog(@"autoVar = %d", autoVar);

        block1 = ^{
            autoVar = 10;
            autoArray = [[NSMutableArray alloc] init];

            NSLog(@"autoVar = %d", autoVar);
        };

        block2 = ^{
            autoVar = 20;

            NSLog(@"autoVar = %d", autoVar);
        };

        NSLog(@"autoVar = %d", autoVar);
    }

    block1();
    block2();

    return 0;
}

// ---

int main_18(int argc, const char * argv[]) {
    void(^block1)(void);
    void(^block2)(void);
    
    {
        // 声明 __block 变量 blockVar
        __block int blockVar = 10;
        
        // blockVar 默认在栈上
        NSLog(@"1 - %p", &blockVar); // 1 - 0x7ffeefbff3d8
        
        // 栈上的 Block 捕获，Block 本身在栈上
        NSLog(@"2 - %p", ^{
            NSLog(@"%p", &blockVar);
        }); // 2 - 0x7ffeefbff388
        
        // 栈上的 Block 捕获对 blockVar 无影响
        NSLog(@"3 - %p", &blockVar); // 3 - 0x7ffeefbff3d8
        
        // 栈上的 Block 捕获并执行
        ^{
            // 捕获的 blockVar 仍在栈上
            NSLog(@"4 - %p", &blockVar); // 4 - 0x7ffeefbff3d8
        }();
        
        // 栈上的 Block 执行对 blockVar 无影响
        NSLog(@"5 - %p", &blockVar);
        
        // 栈上的 Block 被强指针引用，将拷贝至堆上
        block1 = ^{
            // 捕获的 blockVar 也在堆上
            NSLog(@"6 - %p", &blockVar); // 6 - 0x100500eb8
        };
        
        // 此时 blockVar 已被拷贝至堆上
        NSLog(@"7 - %p", &blockVar); // 7 - 0x100500eb8
        
        // block1 在堆上
        NSLog(@"8 - %p", block1); // 8 - 0x100500bb0
        
        // 另一个栈上的 Block 捕获并执行
        ^{
            // 捕获的 blockVar 也在堆上
            NSLog(@"9 - %p", &blockVar); // 9 - 0x100500eb8
        }();
        
        // blockVar 再次被栈上 Block 捕获，此时仍在堆上
        NSLog(@"10 - %p", &blockVar); // 10 - 0x100500eb8
        
        block1();
        
        // blockVar 此时仍在堆上
        NSLog(@"11 - %p", &blockVar); // 11 - 0x100701f18
        
        // 第二个栈上的 Block 被强指针引用，拷贝至堆上
        block2 = ^{
            // 捕获的 blockVar 也在堆上
            NSLog(@"12 - %p", &blockVar); // 12 - 0x100701f18
        };
        
        // blockVar 再次被堆上 Block 捕获，此时仍在堆上
        NSLog(@"13 - %p", &blockVar); // 13 - 0x100701f18
    }
    
    NSLog(@"14 - %p", block1); // 14 - 0x100500bb0
    NSLog(@"15 - %p", block2); // 15 - 0x100500940
    
    block1();
    block2();
    
    return 0;
}

// ---

@interface Foo_7 : NSObject
@property (nonatomic, assign) int bar;
@end

@implementation Foo_7
@end

int main_19(int argc, const char * argv[]) {
    __block Foo_7 *strongF = [[Foo_7 alloc] init];
    strongF.bar = 10;

    __block __weak Foo_7 *weakF = strongF;

    void(^block)(void) = ^{
        NSLog(@"%lu", (unsigned long)weakF.bar);
        NSLog(@"%lu", (unsigned long)strongF.bar);
        
        strongF = [Foo_7 new];
        strongF.bar = 100;
        NSLog(@"%lu", (unsigned long)strongF.bar);
    };

    block();
    
    // ---
    
    block = ^{
        NSLog(@"%lu", (unsigned long)weakF.bar);
    };
    
    block();
    
    __weak Foo_7 *weakF_2 = strongF;
    
    block = ^{
        NSLog(@"%lu", (unsigned long)weakF_2.bar);
    };
    
    block();
    
    return 0;
}

// ---

int main_20(int argc, const char * argv[]) {
    void(^block_1)(void);
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        // 弱引用
        __weak NSMutableArray *weakArr = arr;
        
        block_1 = ^(){
            NSLog(@"%@", weakArr);
        };
        
        block_1();
    }
    
    block_1();
    
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        // __block 下弱引用
        __block __weak NSMutableArray * weakArr = arr;
        
        block_1 = ^(){
            NSLog(@"%@", weakArr);
        };
        
        block_1();
    }
    
    block_1();
    
    return 0;
}

// ---

@interface Foo_8 : NSObject
@end

@implementation Foo_8
- (void)dealloc
{
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
    NSLog(@"dealloc");
}
@end

int main_21(int argc, const char * argv[]) {
#if !__has_feature(objc_arc)
    __block Foo_8 *f = [[Foo_8 alloc] init];

    void(^block)(void) = [^{
        // CRASH: EXC_BAD_INSTRUCTION
        NSLog(@"%@", f);
        
        f = [Foo_8 new];
        
        NSLog(@"%@", f);
    } copy];

    // 正常来说，Block 如果对 f 进行了强引用，引用计数加一，即使调用一次 release 也不应当 dealloc
    // [f release]; // dealloc

    block();

    [block release];
#endif
    return 0;
}

// ---

typedef void(^BlockType_5)(void);

@interface Foo_9 : NSObject
@property (nonatomic, assign) NSUInteger bar;
@property (nonatomic, copy) BlockType_5 block;
@end

@implementation Foo_9
- (void)dealloc
{
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
    NSLog(@"dealloc");
}

#if __has_feature(objc_arc)
- (void)foo_1 {
    // Block 捕获了 self，其强引用了 Block，导致双方都无法释放
    self.block = ^{
        // WARNING: Capturing 'self' strongly in this block is likely to lead to a retain cycle
        NSLog(@"%lu", (unsigned long)self.bar);
        // WARNING: Block implicitly retains 'self'; explicitly mention 'self' to indicate this is intended behavior
        NSLog(@"%lu", (unsigned long)_bar); // self->_bar
    };
}

- (void)foo_2 {
    __weak typeof(self) weakSelf = self;
    self.block = ^{
        NSLog(@"%lu", (unsigned long)weakSelf.bar);

        // 需要 __strong 避免编译器报错（也保证在下面使用时 self 没有被释放）
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"%lu", (unsigned long)strongSelf->_bar);
    };
}
#endif
@end

int main_22(int argc, const char * argv[]) {
#if __has_feature(objc_arc)
    Foo_9 *f = [[Foo_9 alloc] init];
    f.bar = 20;

    f.block = ^{
        // Block 捕获了 f，其强引用了 Block，导致双方都无法释放
        // WARNING: Capturing 'f' strongly in this block is likely to lead to a retain cycle
        NSLog(@"%lu", (unsigned long)f.bar);
    };

    f.block();
    [f foo_1];

    // Never call dealloc
#endif
    return 0;
}

int main_23(int argc, const char * argv[]) {
#if __has_feature(objc_arc)
    Foo_9 *f = [[Foo_9 alloc] init];
    f.bar = 30;

    // 也可使用 typeof() 简化类型声明
    // __weak typeof(f) weakF = f;
    __weak Foo_9 *weakF = f;

    // __unsafe_unretained Foo_9 *unsafeUnretainedF = f;
    __unsafe_unretained typeof(f) unsafeUnretainedF = f;

    f.block = ^{
        NSLog(@"%lu", (unsigned long)weakF.bar);
        NSLog(@"%lu", (unsigned long)unsafeUnretainedF.bar);
    };

    f.block();
    [f foo_2];
#endif

    return 0;
}

int main_24(int argc, const char * argv[]) {
#if __has_feature(objc_arc)
    __block Foo_9 *f = [[Foo_9 alloc] init];
    f.bar = 30;

    f.block = ^{
        NSLog(@"%@", f);

        f = nil; // 将 __Block_byref 中的 f 置为 nil，打破循环
    };

    f.block();

    // CRASH: EXC_BAD_ACCESS
    // f.block();
#endif
    
    return 0;
}

int main_25(int argc, const char * argv[]) {
#if !__has_feature(objc_arc)
    Foo_9 *f = [[Foo_9 alloc] init];

    f.block = [^{
        NSLog(@"%@", f);
    } copy];

    f.block();

    [f release]; // Never call dealloc
#endif
    
    return 0;
}

int main_26(int argc, const char * argv[]) {
#if !__has_feature(objc_arc)
    __unsafe_unretained Foo_9 *f = [[Foo_9 alloc] init];

    f.block = [^{
        NSLog(@"%@", f);
    } copy];

    f.block();

    [f release];
#endif
    
    return 0;
}

int main_27(int argc, const char * argv[]) {
#if !__has_feature(objc_arc)
    __block Foo_9 *f = [[Foo_9 alloc] init];

    f.block = [^{
        NSLog(@"%@", f);
    } copy];

    f.block();

    [f release];
#endif
    
    return 0;
}

// ---

int main(int argc, const char * argv[]) {
//    main_1(argc, argv);
//    main_2(argc, argv);
//    main_3(argc, argv);
//    main_4(argc, argv);
//    main_5(argc, argv);
//    main_6(argc, argv);
//    main_7(argc, argv);
//    main_8(argc, argv);
//    main_9(argc, argv);
//    main_10(argc, argv);
//    main_11(argc, argv);
//    main_12(argc, argv);
//    main_13(argc, argv);
//    main_14(argc, argv);
//    main_15(argc, argv);
//    main_16(argc, argv);
//    main_17(argc, argv);
//    main_18(argc, argv);
//    main_19(argc, argv);
//    main_20(argc, argv);
//    main_21(argc, argv);
//    main_22(argc, argv);
//    main_23(argc, argv);
//    main_24(argc, argv);
//    main_25(argc, argv);
//    main_26(argc, argv);
//    main_27(argc, argv);
    
    // xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main.cpp -fobjc-arc -fobjc-runtime=ios-13.0.0
    return 0;
}
