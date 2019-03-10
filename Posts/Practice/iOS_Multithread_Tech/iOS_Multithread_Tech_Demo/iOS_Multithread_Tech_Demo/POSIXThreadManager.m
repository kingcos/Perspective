//
//  POSIXThreadManager.m
//  iOS_Multithread_Tech_Demo
//
//  Created by kingcos on 2019/3/8.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import "POSIXThreadManager.h"

#import "pthread.h"

void * run_for_pthread_create_demo(void * arg) {
    // 打印参数 & 当前线程 __opaque 属性的地址
    printf("%s (%p) is running.\n", arg, &pthread_self()->__opaque);
    exit(2);
}

void * run_for_pthread_join_demo(void * arg) {
    // 返回参数
    //    return arg;
    pthread_exit(arg);
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
