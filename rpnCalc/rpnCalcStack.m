//
//  rpnCalcStack.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import "rpnCalcStack.h"
#import "rpnCalcConstants.h"
#import "rpnCalcOperator.h"

@interface rpnCalcStack()
@property (nonatomic, strong) NSMutableArray *programStack;

@end



@implementation rpnCalcStack


// TODO: move all this operator junk into its own file (and class) and provide better abstraction

// TODO: treat PI as a symbol instead of just a real value


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
    if (! [[[rpnCalcOperator class] setWithAllOperatorStrings] containsObject:operatorOrOperand]) return NO;
    
    // must have been found in the operationsDict.  Yay.
    return YES;
}


+ (BOOL) isVariable:(id)numOrVar
{
    return [numOrVar isKindOfClass:[NSString class]];
}


// Return the value of the variable in the list of variables.  If not found, logs an error and returns 0.
// TODO: should replace variable-not-found with raising an exception
+ (NSNumber *) lookupVariable:(id)var 
           usingVariableValues:(NSDictionary *)vars
{
    NSNumber * numObj;
    numObj = [vars objectForKey:var];
    if (!numObj) {
        NSLog(@"stack: assuming \"%@\" is a variable, but not found\n", var);
        // result already 0, and that's OK for the var not found case
    }
    return numObj;
}


// For the program stack, take off the top item and evaluate. 
// Operand:  return its value, either number itself or value of its variable
// Operator: pop what it needs off the stack, evaluate the operator, and return that
+ (NSNumber *) popAndEvaluate:(NSMutableArray *)stack
          usingVariableValues:(NSDictionary *)vars
{
    NSNumber * result;
   
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    } else {
        NSLog(@"stack: evaluating empty stack, assume 0");
        // when there's something missing on the stack, assume zero (which it is by default)
        return result;
    }
    
    // OPERATOR CASE    
    if ([[self class] isOperator:topOfStack]) {
        
        NSNumber * operand1num, * operand2num;
        
        NSString * operatorString = topOfStack;    // a bit redundant but more readable        
        rpnCalcOperator * myCalcOperator = [rpnCalcOperator operatorFromOpname:operatorString];
        int expectedOperands = myCalcOperator.needsOperands;        
        
        // don't need to check if we have enough operands here.  If there are 
        // two few, we assume zero and run with it

        switch (expectedOperands) {
            case 1: // unary op
                operand1num = [[self class] popAndEvaluate:stack
                                       usingVariableValues:vars];
                result = [myCalcOperator evaluateOperand:operand1num]; 
                break;
            case 2: // binary op
                operand1num = [[self class] popAndEvaluate:stack
                                       usingVariableValues:vars];
                operand2num = [[self class] popAndEvaluate:stack
                                       usingVariableValues:vars];
                result = [myCalcOperator evaluateOperand:operand2num
                                             withOperand:operand1num];
                break;
            default:
                NSLog(@"stack: evaluating operator \"%@\", didn't expect %d operands", operatorString, expectedOperands);
        }
    }
    
    // OPERAND CASE
    else {
        if ([[self class] isVariable:topOfStack]) {
            result = [[self class] lookupVariable:topOfStack usingVariableValues:vars];
        } else {
            result = topOfStack;
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
    return [[self popAndEvaluate:stack usingVariableValues:nil] doubleValue];

}


+ (double) runProgram:(id)program
        usingVariableValues:(NSDictionary *)vars
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [[self popAndEvaluate:stack usingVariableValues:vars] doubleValue];    
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

- (double) pushOperatorAndEvaluate:(NSString *)op
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
    NSLog(@"--- ALL CLEAR --- ");
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
            NSString * newTerm = [[self class] describeOperand:stack inTheContextOfOperator:nil];
            if ([result length]) {
                newTerm = [newTerm stringByAppendingString:@", "];
            }
            result = [newTerm stringByAppendingString:result];
        }
    }
    return result;
}

    
+ (NSString *) describeOperand:(NSMutableArray *)stack 
        inTheContextOfOperator:(rpnCalcOperator *)callerCalcOperator
{
    NSString * result;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    } else {
        NSLog(@"stack: describing empty stack, assuming \"0\"");
        result = @"0";  // when there's something missing on the stack, assume zero
        return result;
    }
    
    // OPERATOR CASE    
    if ([[self class] isOperator:topOfStack]) {

        NSString * operand1Str, * operand2Str;

        NSString * operatorString = topOfStack;    // a bit redundant but more readable        
        rpnCalcOperator * myCalcOperator = [rpnCalcOperator operatorFromOpname:operatorString];
        int expectedOperands = myCalcOperator.needsOperands;
        
        // don't need to check if we have enough operands here.  If there are 
        // two few, we assume zero and run with it.
        
        switch (expectedOperands) {
            case 1: // Unary
                operand1Str = [[self class] describeOperand:stack 
                                     inTheContextOfOperator:myCalcOperator];
                result = [     myCalcOperator formatOperand:operand1Str
                                       withinParentOperator:callerCalcOperator];
                break;
            case 2: // Binary
                operand1Str = [[self class] describeOperand:stack
                                     inTheContextOfOperator:myCalcOperator];
                operand2Str = [[self class] describeOperand:stack 
                                     inTheContextOfOperator:myCalcOperator];
                result =      [myCalcOperator formatOperand:operand2Str
                                                withOperand:operand1Str
                                       withinParentOperator:callerCalcOperator];
                break;
            default:
                NSLog(@"stack: for operator \"%@\", didn't expect %d operands", operatorString, expectedOperands);
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
