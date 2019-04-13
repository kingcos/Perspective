//
//  Person+Life.h
//  Category_in_Obj-C
//
//  Created by kingcos on 2019/4/13.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

/**
 LifeProtocol
 */
@protocol LifeProtocol <NSObject>
- (void)eat;
@end

/**
 Person+Life
 */
@interface Person (Life) <LifeProtocol>

@property (nonatomic, copy) NSString *name;

// Instance method
- (void)run;

// Class method
+ (void)foo;

// Protocol method
- (void)eat;

@end

NS_ASSUME_NONNULL_END
