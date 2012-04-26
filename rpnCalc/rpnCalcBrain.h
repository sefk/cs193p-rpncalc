//
//  rpnCalcBrain.h
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rpnCalcVariableValues.h"


@interface rpnCalcBrain : NSObject

- (void)        pushOperand:(double)num;
- (void)        pushVariable:(NSString *)var;
- (double)      pushOperatorAndEvaluate:(NSString *)operate
                      usingVariableDict:(NSMutableDictionary *)vars;
- (int)         depth;
- (void)        clear;

@property (readonly) id program;

+ (NSNumber *)      lookupVariable:(NSString *)var
                    usingVariableDict:(NSMutableDictionary *)vars;

+ (double)          runProgram:(id)program
                    usingVariableDict:(NSMutableDictionary *)vars;

+ (NSString *)      describeProgram:(id)program;

//+ (NSSet *)         variablesUsedInProgram:(id)program;

@end
