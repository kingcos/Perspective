//
//  main.m
//  Demo-NSObject
//
//  Created by kingcos on 2018/7/9.
//  Copyright © 2018 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

struct NSObject_IMPL {
    Class isa;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *object = [[NSObject alloc] init];
        
        // 8 bits (实际使用到的 8 bytes 内存)
        NSLog(@"%zd", class_getInstanceSize([NSObject class]));
        
        // 16 bits (CF 规定小于 16 bytes 一律按照 16 bytes 分配)
        // __bridge: 将 Obj-C 指针桥接为 C++ 指针
        NSLog(@"%zd", malloc_size((__bridge const void *)(object)));
    }
    return 0;
}
