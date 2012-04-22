//
//  rpnCalcStack.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import "rpnCalcStack.h"
#import "rpnCalcConstants.h"

@interface rpnCalcStack()
@property (nonatomic, strong) NSMutableArray *programStack;

@end



@implementation rpnCalcStack


//
// GLOBAL HELPERS
//

+ (NSDictionary *) orderOfOperationsDict
{
    static NSNumber * _numOne;
    if (!_numOne) _numOne = [NSNumber numberWithInt:1];
    static NSNumber * _numTwo;
    if (!_numTwo) _numTwo = [NSNumber numberWithInt:2];
    
    static NSDictionary * _orderOfOperationsDict;
    
    if (!_orderOfOperationsDict) {
        _orderOfOperationsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  // VALUE    // KEY
                                  _numTwo,    @"+",    
                                  _numTwo,    @"-",
                                  _numTwo,    @"/",
                                  _numTwo,    @"*",    
                                  _numOne,    @"sqrt",
                                  _numOne,    @"sin",
                                  _numOne,    @"cos",
                                  _numOne,    @"sqr",
                                  nil];
    }
    
    return _orderOfOperationsDict;
}


+ (int) numberOfOperandsThisOperationUses:(NSString *)op
{
    int result = 0;
    NSNumber * resultNum;
    
    NSDictionary * dict = [self orderOfOperationsDict];
    resultNum = [dict objectForKey:op];
    if (resultNum) result = [resultNum intValue];
    
    return result;
}




//
// EXECUTION
//

@synthesize programStack = _programStack;
- (NSMutableArray *) programStack 
{
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}


- (id) program
{
    return [self.programStack copy];
}


+ (BOOL) isOperator:(id)thingy
{
    // first, an operator must be a string.  
    
    if (! [thingy isKindOfClass:[NSString class]]) return NO;
    
    // all operators are a key in the operationsDict.  Look up to see if it's there
    if (! [[[self class] orderOfOperationsDict] objectForKey:thingy]) return NO;
    
    // must have been found in the operationsDict.  Yay.
    return YES;
}


+ (double) lookupVariable:(id)var 
           usingVariableValues:(NSDictionary *)vars
{
    NSNumber * numObj;
    numObj = [vars objectForKey:var];
    if (!numObj) {
        NSLog(@"stack: assuming \"%@\" is a variable, but not found\n", var);
        // result already 0, and that's OK for the var not found case
    }
    return [numObj doubleValue];
}



+ (double) popOperand:(NSMutableArray *)stack
           usingVariableValues:(NSDictionary *)vars
{
    double result = 0;
   
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];

    // OPERAND CASE
    if (! [[self class] isOperator:topOfStack]) {
        
        // for operands: numbers are values, strings are variables
        if ([topOfStack isKindOfClass:[NSNumber class]]) {
            return [topOfStack doubleValue];
        } else {
            return [[self class] lookupVariable:topOfStack usingVariableValues:vars];
        }
    } 
        
    // OPERATION CASE
    else {
        NSString * op = topOfStack;
        
        if ([@"+" isEqualToString:op]) {
            result = [self popOperand:stack usingVariableValues:vars] + 
                     [self popOperand:stack usingVariableValues:vars];
        } 
        else if ([@"-" isEqualToString:op]) {
            result = ([self popOperand:stack usingVariableValues:vars]) * (-1) + 
                      [self popOperand:stack usingVariableValues:vars];
        }
        else if ([@"*" isEqualToString:op]) {
            result = [self popOperand:stack usingVariableValues:vars] *
                        [self popOperand:stack usingVariableValues:vars];
        } 
        else if ([@"/" isEqualToString:op]) {
            double op1 = [self popOperand:stack usingVariableValues:vars];
            double op2 = [self popOperand:stack usingVariableValues:vars];
            if (op1 != 0) result = op2 / op1;    // to allow for div by zero case
        } 
        else if ([@"sqrt" isEqualToString:op]) {
            result = sqrt([self popOperand:stack usingVariableValues:vars]);
        } 
        else if ([@"sqr" isEqualToString:op]) {
            double num = [self popOperand:stack usingVariableValues:vars];
            result = num * num;
        } 
        else if ([@"sin" isEqualToString:op]) {
            double operandInRadians = [self popOperand:stack usingVariableValues:vars] * 
                    (pi/180);
            result = sin(operandInRadians);
        } 
        else if ([@"cos" isEqualToString:op]) {
            double operandInRadians = [self popOperand:stack usingVariableValues:vars] * 
                    (pi/180);
            result = cos(operandInRadians);    
        } 
        else {
            NSLog(@"stack: undefined operand \"%@\" somehow made it on the stack",
                  op);
        }
    }
    
    return result;
}



+ (double) runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperand:stack usingVariableValues:nil];

}


+ (double) runProgram:(id)program
        usingVariableValues:(NSDictionary *)vars
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperand:stack usingVariableValues:vars];    
}

- (void) pushOperand:(double)num
{
    NSNumber * numObj = [NSNumber numberWithDouble:num];
    [self.programStack addObject:numObj];
}

- (void) pushVariable:(NSString *)var
{
    [self.programStack addObject:var];
}


- (double) operate:(NSString *)op
{
    [self.programStack addObject:op];
    return [[self class] runProgram:self.program];
}

- (double) depth
{
    return [self.programStack count];
}

- (void) clear
{
    [self.programStack removeAllObjects];
}
    

//
// DESCRIBE
//

- (NSString *)description
{
    return [NSString stringWithFormat:@"stack depth = %g\nstack = %@",
            [self depth], 
            self.programStack];
}


+ (NSString *) describeProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self describeOperand:stack];
}
    
+ (NSString *) describeOperand:(NSMutableArray *)stack
{
    NSString * result;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    // OPERAND CASE
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack stringValue];
    } 
    
    // OPERATOR CASE
    NSString * operator = (NSString *)topOfStack;
    
    if ([topOfStack isKindOfClass:[NSString class]]) {
        switch ([[self class] numberOfOperandsThisOperationUses:operator]) {
            case 1: // unary op
                result = [NSString stringWithFormat:@"%@(%@)",
                         operator,
                         [self describeOperand:stack],
                         nil];
                         break;
            case 2: // binary op
                result = [NSString stringWithFormat:@"(%@%@%@)",
                          [self describeOperand:stack],
                          operator,
                          [self describeOperand:stack],
                          nil];
                 
        }
        
    }
    return result;
}



+ (NSSet *) variablesUsedInProgram:(id)program
{
    // TODO
}


@end
