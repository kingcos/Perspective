//
//  main.m
//  NSObject-Subclass
//
//  Created by kingcos on 2018/7/11.
//  Copyright © 2018 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

@interface Student : NSObject {
    @public
    int _no;
    int _age;
}
@end

@implementation Student

@end

struct NSObject_IMPL {
    Class isa;
};

struct Student_IMPL {
    // NSObject_IVARS == Class isa;
    struct NSObject_IMPL NSObject_IVARS;
    int _no;
    int _age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *student = [[Student alloc] init];
        
        student -> _no = 1;
        student -> _age = 22;
        
        struct Student_IMPL *student_impl = (__bridge struct Student_IMPL *)(student);
        // no: 1, age: 22
        NSLog(@"no: %d, age: %d", student_impl -> _no, student_impl -> _age);
        
        // 16 bits
        NSLog(@"%zd", class_getInstanceSize([Student class]));
        // 16 bits
        NSLog(@"%zd", malloc_size((__bridge const void *)(student)));
    }
    return 0;
}
