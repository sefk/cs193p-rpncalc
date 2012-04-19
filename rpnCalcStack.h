//
//  rpnCalcStack.h
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rpnCalcStack : NSObject

- (void)        pushOperand:(double)num;
- (double)      operate:(NSString *)operate;
- (double)      depth;
- (void)        clear;

@property (readonly) id program;

+ (double)      runProgram:(id)program;
+ (NSString *)  describeProgram:(id)program;

@end
