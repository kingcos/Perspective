//
//  main.m
//  NSObject-Inheritance
//
//  Created by kingcos on 2018/7/11.
//  Copyright © 2018 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

// Person
@interface Person : NSObject {
    int _age;
}
@end

@implementation Person

@end

// Student
@interface Student : Person {
    int _no;
}
@end

@implementation Student

@end

// Man
@interface Man : NSObject {
    int _age;
}

// @property (nonatomic, assign) int height; => int _height;
@property (nonatomic, assign) int height;

@end

@implementation Man

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *person = [[Person alloc] init];
        Student *student = [[Student alloc] init];
        
        // 16 bits（内存对齐后的大小）
        NSLog(@"%zd", class_getInstanceSize([Person class]));
        // 16 bits
        NSLog(@"%zd", malloc_size((__bridge const void *)(person)));
        
        // 16 bits
        NSLog(@"%zd", class_getInstanceSize([Student class]));
        // 16 bits
        NSLog(@"%zd", malloc_size((__bridge const void *)(student)));
        
        Man *man = [[Man alloc] init];
        // getter & setter 等方法并不存在对象中
        [man setHeight:185];
        
        // 16 bits
        NSLog(@"%zd", class_getInstanceSize([Man class]));
        // 16 bits
        NSLog(@"%zd", malloc_size((__bridge const void *)(man)));
    }
    return 0;
}
