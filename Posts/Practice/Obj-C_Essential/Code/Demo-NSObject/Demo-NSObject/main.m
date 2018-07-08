//
//  main.m
//  Demo-NSObject
//
//  Created by kingcos on 2018/7/9.
//  Copyright © 2018 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *object = [[NSObject alloc] init];
        // Rewrite to C++ code
        // clang -rewrite-objc main.m -o main.cpp
        
        // Rewrite to C++ code for specified SDK & architecture
        // xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-ios-arm64.cpp
    }
    return 0;
}
