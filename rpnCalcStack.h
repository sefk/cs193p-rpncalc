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
- (void)        pushVariable:(NSString *)var;
- (double)      operate:(NSString *)operate;
- (int)         depth;
- (void)        clear;

@property (readonly) id program;

+ (NSDictionary *)  orderOfOperationsDict;

+ (double)          lookupVariable:(id)var
                    usingVariableValues:(NSDictionary *)vars;

+ (double)          runProgram:(id)program;
+ (double)          runProgram:(id)program
                    usingVariableValues:(NSDictionary *)vars;

+ (NSString *)      describeProgram:(id)program;
+ (NSSet *)         variablesUsedInProgram:(id)program;

@end
