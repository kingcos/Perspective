//
//  main.m
//  NSObject-Subclass
//
//  Created by kingcos on 2018/7/11.
//  Copyright © 2018 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject {
    @public
    int _no;
    int _age;
}
@end

@implementation Student

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *student = [[Student alloc] init];
    }
    return 0;
}
