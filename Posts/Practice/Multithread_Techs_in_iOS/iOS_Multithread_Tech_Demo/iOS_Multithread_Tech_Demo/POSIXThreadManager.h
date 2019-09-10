//
//  POSIXThreadManager.h
//  iOS_Multithread_Tech_Demo
//
//  Created by kingcos on 2019/3/8.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSIXThreadManager : NSObject

+ (void)pthread_create_demo;
+ (void)pthread_join_demo;
+ (void)thread_conflict_demo;
+ (void)semaphore_demo;

@end

NS_ASSUME_NONNULL_END
