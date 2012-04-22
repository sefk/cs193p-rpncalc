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


// TODO: move all this operator junk into its own file (and class) and provide better abstraction


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
                                  _numOne,    @"x^2",
                                  _numOne,    @"sqrt",
                                  _numOne,    @"sin",
                                  _numOne,    @"cos",
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


+ (NSDictionary *) operatorPrecedenceDict
{
    static NSNumber * _numOne;
    if (!_numOne) _numOne = [NSNumber numberWithInt:1];
    static NSNumber * _numTwo;
    if (!_numTwo) _numTwo = [NSNumber numberWithInt:2];
    static NSNumber * _numThree;
    if (!_numTwo) _numTwo = [NSNumber numberWithInt:3];
    
    static NSDictionary * _operatorPrecedenceDict;
    
    if (!_operatorPrecedenceDict) {
        _operatorPrecedenceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  // VALUE    // KEY
                                  _numOne,    @"+",    
                                  _numOne,    @"-",
                                  _numTwo,    @"/",
                                  _numTwo,    @"*",    
                                  _numThree,  @"x^2",
                                  _numThree,  @"sqrt",
                                  _numThree,  @"sin",
                                  _numThree,  @"cos",
                                  nil];
    }
    
    return _operatorPrecedenceDict;    
}


+ (int) precedenceOfOperator:(NSString *)op
{
    int result = 0;
    NSNumber * resultNum;
    
    NSDictionary * dict = [self operatorPrecedenceDict];
    resultNum = [dict objectForKey:op];
    if (resultNum) result = [resultNum intValue];
    
    return result;
}




//
// EXECUTION
//

// Accessor for the current program.  Lazy instantiation.
@synthesize programStack = _programStack;
- (NSMutableArray *) programStack 
{
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}


// Accessor for current program.  Just return a copy of what we're working on so far.
- (id) program
{
    return [self.programStack copy];
}


// TRUE if the object is an operator (plus, minus, sin)
// FALSE if an operand (variable, number)
+ (BOOL) isOperator:(id)operatorOrOperand
{
    // first, an operator must be a string.  
    if (! [operatorOrOperand isKindOfClass:[NSString class]]) return NO;
    
    // all operators are a key in the operationsDict.  Look up to see if it's there
    if (! [[[self class] orderOfOperationsDict] objectForKey:operatorOrOperand]) return NO;
    
    // must have been found in the operationsDict.  Yay.
    return YES;
}


// Return the value of the variable in the list of variables.  If not found, logs an error and returns 0.
// TODO: should replace variable-not-found with raising an exception
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


// For the program stack, take off the top item and evaluate. 
// Operand:  return its value, either number itself or value of its variable
// Operator: pop what it needs off the stack, evaluate the operator, and return that
+ (double) popAndEvaluate:(NSMutableArray *)stack
           usingVariableValues:(NSDictionary *)vars
{
    double result = 0;
   
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    } else {
        NSLog(@"stack: nothing found on stack to evaluate");
        return result;
    }

    // OPERATOR CASE
    if ([[self class] isOperator:topOfStack]) {
        NSString * op = topOfStack;
        
        if ([@"+" isEqualToString:op]) {
            result = [self popAndEvaluate:stack usingVariableValues:vars] + 
            [self popAndEvaluate:stack usingVariableValues:vars];
        } 
        else if ([@"-" isEqualToString:op]) {
            result = ([self popAndEvaluate:stack usingVariableValues:vars]) * (-1) + 
            [self popAndEvaluate:stack usingVariableValues:vars];
        }
        else if ([@"*" isEqualToString:op]) {
            result = [self popAndEvaluate:stack usingVariableValues:vars] *
            [self popAndEvaluate:stack usingVariableValues:vars];
        } 
        else if ([@"/" isEqualToString:op]) {
            double op1 = [self popAndEvaluate:stack usingVariableValues:vars];
            double op2 = [self popAndEvaluate:stack usingVariableValues:vars];
            if (op1 != 0) result = op2 / op1;    // to allow for div by zero case
        } 
        else if ([@"sqrt" isEqualToString:op]) {
            result = sqrt([self popAndEvaluate:stack usingVariableValues:vars]);
        } 
        else if ([@"x^2" isEqualToString:op]) {
            double num = [self popAndEvaluate:stack usingVariableValues:vars];
            result = num * num;
        } 
        else if ([@"sin" isEqualToString:op]) {
            double operandInRadians = 
            [self popAndEvaluate:stack usingVariableValues:vars] * (pi/180);
            result = sin(operandInRadians);
        } 
        else if ([@"cos" isEqualToString:op]) {
            double operandInRadians = 
            [self popAndEvaluate:stack usingVariableValues:vars] * (pi/180);
            result = cos(operandInRadians);    
        } 
        else {
            NSLog(@"stack: undefined operand \"%@\" somehow made it on the stack", op);
        }
    } 
        
    // OPERAND CASE
    else {
        // for operands, numbers are values, strings are variables
        if ([topOfStack isKindOfClass:[NSNumber class]]) {
            result = [topOfStack doubleValue];
        } else {
            result = [[self class] lookupVariable:topOfStack usingVariableValues:vars];
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
    return [self popAndEvaluate:stack usingVariableValues:nil];

}


+ (double) runProgram:(id)program
        usingVariableValues:(NSDictionary *)vars
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popAndEvaluate:stack usingVariableValues:vars];    
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

- (int) depth
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
    NSString * result = [NSString stringWithString:@""];

    NSMutableArray *stack;    

    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];

        while ([stack count]) {
            NSString * newTerm = [[self class]describeOperand:stack inTheContextOfOperatorLevel:0];
            if ([result length]) {
                newTerm = [newTerm stringByAppendingString:@", "];
            }
            result = [newTerm stringByAppendingString:result];
        }
    }
    return result;
}

    
+ (NSString *) describeOperand:(NSMutableArray *)stack inTheContextOfOperatorLevel:(int)predenceOfCaller
{
    NSString * result;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    // OPERATOR CASE    
    if ([[self class] isOperator:topOfStack]) {
        
        NSString * operator = topOfStack;    // a bit redundant but more readable
        NSString * op1, * op2;
        
        int expectedOperands = [[self class] numberOfOperandsThisOperationUses:operator];
        int myPrecedenceLevel = [[self class] precedenceOfOperator:operator];
        
        switch (expectedOperands) {
            case 1: // unary op
                op1 = [[self class] describeOperand:stack inTheContextOfOperatorLevel:myPrecedenceLevel];
                if ([operator isEqualToString:@"x^2"]) {
                    result = [NSString stringWithFormat:@"(%@)^2", op1];
                } else {
                    result = [NSString stringWithFormat:@"%@(%@)", operator, op1];
                }
                break;
            case 2: // binary op
                op2 = [[self class] describeOperand:stack inTheContextOfOperatorLevel:myPrecedenceLevel];
                op1 = [[self class] describeOperand:stack inTheContextOfOperatorLevel:myPrecedenceLevel];
                if (myPrecedenceLevel < predenceOfCaller) {
                    result = [NSString stringWithFormat:@"(%@ %@ %@)", op1, operator, op2];
                } else {
                    result = [NSString stringWithFormat:@"%@ %@ %@", op1, operator, op2];
                }

                break;
            default:
                NSLog(@"stack: for operator \"%@\", didn't expect %d operands", 
                      operator, expectedOperands);
        }
        
    }
        
    // OPERAND CASE
    else {   
        if ([topOfStack isKindOfClass:[NSString class]]) {
            // variable, just return it
            result = topOfStack;
        } else {
            // number, need to flatten
            result = [topOfStack stringValue];
        }        
    }
    
    return result;
}



+ (NSSet *) variablesUsedInProgram:(id)program
{
    // TODO
}


@end
