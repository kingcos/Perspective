//
//  Person.h
//  Type_Introspection_and_Reflection
//
//  Created by 买明 on 2019/4/10.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Fruit class
 */
@interface Fruit : NSObject
- (void)taste;
@end

/**
 Apple class
 */
@interface Apple : Fruit
- (void)tasteApple;
@end

/**
 Orange class
 */
@interface Orange : Fruit
- (void)tasteOrange;
@end

/**
 Person class
 */
@interface Person : NSObject
- (void)eat:(id)fruit;

+ (void)introspectionDemo;
+ (void)reflectionDemo;
@end

NS_ASSUME_NONNULL_END
