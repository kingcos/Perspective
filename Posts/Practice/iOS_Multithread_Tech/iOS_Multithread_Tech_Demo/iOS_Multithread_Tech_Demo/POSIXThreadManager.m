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

// 起始数
const int START_NUMBER = 0;
// 结束数
const int END_NUMBER = 10;
// 线程数
const int THREAD_NUMBER = 5;
// 平均每个线程的任务数
const int COUNT_PER_THREAD = (END_NUMBER - START_NUMBER) / THREAD_NUMBER;

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

// 当前数，初始为起始数
int current_count = START_NUMBER;

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
