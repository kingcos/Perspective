//
//  main.m
//  Effective_Obj-C_Demo
//
//  Created by kingcos on 2019/3/18.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

#import "objc-header.h"

#import "Computer.h"
#import "Mac.h"

@interface Person : NSObject {
    int _age;
}

@property (readonly) int height;
- (void)test;
@end

@implementation Person
@synthesize height = ___height;
//@dynamic height;
- (void)test {
//    self->_height
//    self->_age
//    self->___height
//    self.height = 123;
//    self.height = 10;
    self->___height = 10;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        NSLog(@"Hello, World!");
//        // str1 & str2 指向同一地址；在当前栈帧（Stack Frame）里分配了两块内存，每块内存的大小都能容下一枚指针（32 位 4 字节，64 位 8 字节）
//////        NSString *str1 = @"maimieng.com";
//////        NSString *str2 = str1;
//        Person *person = [[Person alloc] init];
////        person.height
//        [person test];
////        person.height = 10;
//
//
////        objc_getClass(<#const char * _Nonnull name#>)
//
//        NSObject *obj = [[NSObject alloc] init];
//        object_getClass(obj);
        Mac *mac = [[Mac alloc] init];
        
    }
    return 0;
}

