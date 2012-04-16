//
//  rpnCalcStack.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import "rpnCalcStack.h"

@interface rpnCalcStack()
@property (nonatomic, strong) NSMutableArray *myStack;
@end



@implementation rpnCalcStack

@synthesize myStack = _myStack;

- (NSMutableArray *) myStack {
    if (!_myStack) _myStack = [[NSMutableArray alloc] init];
    return _myStack;
}

- (void) push:(double)num
{
    NSNumber * numObj = [NSNumber numberWithDouble:num];
    [self.myStack addObject:numObj];
}

- (double) pop
{
    if ([self.myStack count] < 1) {
        NSLog(@"stack: stack empty");
        return 0;
    }
    double num = [self peek];
    [self.myStack removeLastObject];
    return num;
}

- (double) peek
{
    if ([self.myStack count] < 1) {
        NSLog(@"stack: peeked at empty stack");
        return 0;
    }
    return [[self.myStack lastObject] doubleValue];
}

- (double) depth
{
    return [self.myStack count];
}

- (void) clear
{
    [self.myStack removeAllObjects];
}
    

// TODO: replace this clunky error checking with exceptions.

- (double) operate:(NSString *)op
{
    double result;
        
    // One Operand Ops 

    if (self.myStack.count < 1) {
        NSLog(@"stack: operation \"%@\" requires at least one items on the stack", op);
        return 0;
    }

    if ([op isEqualToString:@"sqrt"]) {
        result = sqrt([self pop]);
    } else if ([op isEqualToString:@"x**2"]) {
        double num = [self pop];
        result = num * num;
    } else {
    
        
        // Two Operand Ops

        if (self.myStack.count < 2) {
            NSLog(@"stack: operation \"%@\" requires at least two items on the stack", op);
            return 0;
        }
    
        if ([op isEqualToString:@"+"]) {
            result = [self pop] + [self pop];
        } else if ([op isEqualToString:@"-"]) {
            result = (-1 * [self pop]) + [self pop];
        } else if ([op isEqualToString:@"/"]) {
            result = (1/[self pop]) * [self pop];
        } else if ([op isEqualToString:@"*"]) {
            result = [self pop] * [self pop];
        } else {
            NSLog(@"stack: invalid operand: \"%@\"", op);
            return 0;
        }
    }
   
    [self push:result];
    return result;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"stack depth = %g\nstack = %@",
            [self depth], 
            self.myStack];
            }



@end
