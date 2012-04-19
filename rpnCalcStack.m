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


+ (double) popOperand:(NSMutableArray *)stack
{
    double result = 0;
   
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];

    // OPERAND CASE
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } 
        
    // OPERATION CASE
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString * op = topOfStack;
        
        if ([@"+" isEqualToString:op]) {
            result = [self popOperand:stack] + [self popOperand:stack];
        } 
        else if ([@"-" isEqualToString:op]) {
            result = (-1 * [self popOperand:stack]) + [self popOperand:stack];
        }
        else if ([@"*" isEqualToString:op]) {
            result = [self popOperand:stack] * [self popOperand:stack];
        } 
        else if ([@"/" isEqualToString:op]) {
            double op1 = [self popOperand:stack];
            double op2 = [self popOperand:stack];
            if (op1 != 0) result = op2 / op1;    // to allow for div by zero case
        } 
        else if ([@"sqrt" isEqualToString:op]) {
            result = sqrt([self popOperand:stack]);
        } 
        else if ([@"x**2" isEqualToString:op]) {
            double num = [self popOperand:stack];
            result = num * num;
        } 
        else if ([@"sin" isEqualToString:op]) {
            double operandInRadians = [self popOperand:stack] * (pi/180);
            result = sin(operandInRadians);
        } 
        else if ([@"cos" isEqualToString:op]) {
            double operandInRadians = [self popOperand:stack] * (pi/180);
            result = cos(operandInRadians);    
        } 
        else {
            NSLog(@"stack: unrecognized operand: \"%@\"", op);
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
    return [self popOperand:stack];

}


- (void) pushOperand:(double)num
{
    NSNumber * numObj = [NSNumber numberWithDouble:num];
    [self.programStack addObject:numObj];
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
    

- (NSString *)description
{
    return [NSString stringWithFormat:@"stack depth = %g\nstack = %@",
            [self depth], 
            self.programStack];
}


+ (NSString *) describeProgram:(id)program
{
    // TODO
}



@end
