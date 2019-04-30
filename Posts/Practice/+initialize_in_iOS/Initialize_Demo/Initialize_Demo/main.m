//
//  main.m
//  Initialize_Demo
//
//  Created by kingcos on 2019/4/22.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

#import "Person.h"
#import "Student.h"
#import "Programmer.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"---");
        Student *stu = [Student alloc];
        NSLog(@"---");
        stu = [stu init];
        
        NSLog(@"---");
        [Programmer load];
    }
    return 0;
}
