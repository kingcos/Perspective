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

typedef int (^BlockType)(int);

@interface Foo_1 : NSObject
@property (nonatomic, strong) BlockType block;
@end

@implementation Foo_1
// 作为对象方法参数
- (void)blockAsArg_1:(int(^)(int))block {
    block(10);
}
// 使用 typedef 作为对象方法参数
- (void)blockAsArg_2:(BlockType)block {
    block(10);
}
// 作为对象方法返回值
- (int(^)(int))blockAsReturnValue_1 {
    return ^(int arg) { return arg; };
}
// 使用 typedef 作为对象方法返回值
- (BlockType)blockAsReturnValue_2 {
    return ^(int arg) { return arg; };
}
@end

// Block 作为 C 语言函数参数
void blockAsArg_1(int (^block)(int)) {
    block(10);
}
// 使用 typedef 作为 C 语言函数参数
void blockAsArg_2(BlockType block) {
    block(10);
}

// 《Objective-C 高级编程》中教授的如下方法，目前会报错，且尚未找到相应的解决方法：
// Block pointer to non-function type is invalid
// Returning 'int (^)(int)' from a function with incompatible result type 'int (int)'
// int (^blockAsReturnValue()(int)) {
//     return ^(int arg) { return arg; };
// }

BlockType blockAsReturnValue() {
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
    BlockType block4;
    BlockType block5 = ^(int arg) { return arg; };
    block5 = ^int(int arg) { return arg; };
    BlockType block6 = block5;
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

// 静态全局变量
static int staticGlobalVar = 0;
// 全局变量
int globalVar = 0;

int main_4(int argc, const char * argv[]) {
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

int main_5(int argc, const char * argv[]) {
    __block int autoVar = 0;
    __block auto NSMutableArray *autoArray = [[NSMutableArray alloc] init];
    
    // 使用 __block 修饰的自动变量，在 Block 内部确实可以修改
    ^{
        autoVar = 10;
        autoArray = [[NSMutableArray alloc] init];
    };
    
    NSLog(@"autoVar = %d", autoVar);
    
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

int main_6(int argc, const char * argv[]) {
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

int main_7(int argc, const char * argv[]) {
    auto int a = 1;
    const char *b = "kingcos.me";

    void (^block)(void) = ^() {
        NSLog(@"a == %d, b == %s", a, b);
    };

    block();
    
    return 0;
}

// ---

int main_8(int argc, const char * argv[]) {
    static int a = 1;

    void (^block)(void) = ^() {
        NSLog(@"a == %d", a);
    };
    a = 10;

    block();
    
    return 0;
}

int main(int argc, const char * argv[]) {
//    main_1(argc, argv);
//    main_2(argc, argv);
//    main_3(argc, argv);
//    main_4(argc, argv);
//    main_5(argc, argv);
//    main_6(argc, argv);
//    main_7(argc, argv);
    main_8(argc, argv);
      
    
    
    return 0;
}
