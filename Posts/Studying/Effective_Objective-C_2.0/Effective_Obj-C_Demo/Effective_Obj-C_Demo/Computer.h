//
//  Computer.h
//  Effective_Obj-C_Demo
//
//  Created by 买明 on 2019/3/19.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Computer : NSObject
@property (copy) NSString *name;

- (void)run;
- (void)run:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
