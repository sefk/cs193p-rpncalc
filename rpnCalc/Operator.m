//
//  Operator.m
//  
//  Meat of operation handling.
//
//  Created by Sef Kloninger on 4/22/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "Operator.h"

@implementation Operator

//
// Setup Stuff
//

@synthesize name =                 _name;
@synthesize needsOperands =        _needsOperands;
@synthesize precedence =           _precedence;
@synthesize executionSelectorStr = _executionSelectorStr;
@synthesize formatSelectorStr =    _formatSelectorStr;
@synthesize forcesParentheses =    _forcesParentheses;   // default NO

- (int) needsOperands
{
    return _needsOperands;
}
- (void) setNeedsOperands:(int)num
{
    _needsOperands = num;
}

- (int) precedence
{
    return _precedence;
}
- (void) setPrecedence:(int)p
{
    _precedence = p;
}


//
// Class Method -- Creation.  
//
// Return an operator class set up with all you need for that 
// particular operator.  Lots of static construction junk in here.
//

+ (NSMutableDictionary *)operatorCache
{
    static NSMutableDictionary * _operatorCacheDict = nil;
    
    if (!_operatorCacheDict) {
        _operatorCacheDict = [[NSMutableDictionary alloc] init];
    }
    return _operatorCacheDict;
}

+ (Operator *) operatorFromOpname:(NSString *)opname
{
    Operator * result;
    
    id cachedOperator = [[self operatorCache] objectForKey:opname];
    if (cachedOperator) {
        result = cachedOperator;
    } else {
        result = [[Operator alloc] initWithName:opname];   // expensive construction
        [[self operatorCache] setObject:result forKey:opname];  // cache
    }

    return result;
}



// Instance Initialization


- (id) initWithName:(NSString *)opname
{
    self = [super init];
    self.name = opname;
    
    // Arithmetic (plus, minus)
    
    if ([opname isEqualToString:@"+"]) {
        self.needsOperands = 2;         
        self.precedence = 1;
        self.executionSelectorStr = @"add:to:";
        self.formatSelectorStr = @"formatAdd:to:";
    } 
    else if ([opname isEqualToString:@"-"]) {
        self.needsOperands = 2;         
        self.precedence = 1;
        self.executionSelectorStr = @"sub:by:";
        self.formatSelectorStr = @"formatSub:by:";
    }
    else if ([opname isEqualToString:@"*"]) {
        self.needsOperands = 2;         
        self.precedence = 2;
        self.executionSelectorStr = @"mult:by:";
        self.formatSelectorStr = @"formatMult:by:";
   }
    else if ([opname isEqualToString:@"/"]) {
        self.needsOperands = 2;         
        self.precedence = 2;
        self.executionSelectorStr = @"div:by:";
        self.formatSelectorStr = @"formatDiv:by:";
    }
    
    // Higher Functions (sin, cos)
    
    else if ([opname isEqualToString:@"x^2"]) {
        self.needsOperands = 1;         
        self.precedence = 3;
        self.executionSelectorStr = @"square:";
        self.formatSelectorStr = @"formatSquare:";
    }
    else if ([opname isEqualToString:@"sqrt"]) {
        self.needsOperands = 1;         
        self.precedence = 3;
        self.executionSelectorStr = @"squareroot:";
        self.formatSelectorStr = @"formatSquareroot:";
        self.forcesParentheses = YES;
    }
    else if ([opname isEqualToString:@"sin"]) {
        self.needsOperands = 1;         
        self.precedence = 3;
        self.executionSelectorStr = @"sine:";
        self.formatSelectorStr = @"formatSine:";
        self.forcesParentheses = YES;
    }
    else if ([opname isEqualToString:@"cos"]) {
        self.needsOperands = 1;         
        self.precedence = 3;
        self.executionSelectorStr = @"cosine:";
        self.formatSelectorStr = @"formatCosine:";
        self.forcesParentheses = YES;
    }
    
    return self;
}


//
// Evaluating
//

- (NSNumber *) evaluateOperand:(NSNumber *)operand
{
    NSNumber * result;
    
    SEL executionSelector = NSSelectorFromString(self.executionSelectorStr);
    result = [self performSelector:executionSelector
                        withObject:operand];
    return result;
}

- (NSNumber *) evaluateOperand:(NSNumber *)operand1
                   withOperand:(NSNumber *)operand2
{
    NSNumber * result;
    
    SEL executionSelector = NSSelectorFromString(self.executionSelectorStr);
    result = [self performSelector:executionSelector 
                        withObject:operand1
                        withObject:operand2];
    return result;
}


// 
// Formatting
//

- (NSString *) formatOperand:(NSString *)operandStr
        withinParentOperator:(Operator *)parent
{
    NSString * resultStr;
    
    if (self.forcesParentheses && [operandStr characterAtIndex:0] != '(') {
        NSString * operandStrWithParens = [NSString stringWithFormat:@"(%@)", operandStr];
        operandStr = operandStrWithParens;
    }
    
    SEL formatSelector = NSSelectorFromString(self.formatSelectorStr);
    resultStr = [self performSelector:formatSelector
                           withObject:operandStr];

    if (parent.precedence > self.precedence) {
        NSString * resultStrWithParens = [NSString stringWithFormat:@"(%@)", resultStr];
        resultStr = resultStrWithParens;
    }
    
    return resultStr;
}


- (NSString *) formatOperand:(id)operand1
                 withOperand:(id)operand2
         withinParentOperator:(Operator *)parent
{
    NSString * resultStr;
    
    // TODO: if there was a binary operation that forced parentheses, then we would have to handle
    // that case, but not sure what that would format like
    
    SEL formatSelector = NSSelectorFromString(self.formatSelectorStr);
    resultStr = [self performSelector:formatSelector
                           withObject:operand1
                           withObject:operand2];
    
    if (parent.precedence > self.precedence) {
        NSString * resultStrWithParens = [NSString stringWithFormat:@"(%@)", resultStr];
        resultStr = resultStrWithParens;
    }
    
    return resultStr;
}

//
// CLASS METHODS
//

+ (NSSet *) setWithAllOperatorStrings
{
    // TODO: there has to be a better way to do this, but would mean non-lazy instantiation of all
    // the 
    return [NSSet setWithObjects:@"+",
                                 @"-",
                                 @"*",
                                 @"/",
                                 @"x^2",
                                 @"sqrt",
                                 @"sin",
                                 @"cos", 
            nil];
}

   



// 
// Helper Functions -- glue junk
//

// plus

- (NSNumber *) add:(NSNumber *)a
                to:(NSNumber *)b
{
    double aVal = [a doubleValue];
    double bVal = [b doubleValue];
    return [NSNumber numberWithDouble:(aVal + bVal)];
}

- (NSString *) formatAdd:(NSString *)a
                      to:(NSString *)b
{
    return [NSString stringWithFormat:@"%@ + %@", a, b];
}


// minus

- (NSNumber *) sub:(NSNumber *)a
                by:(NSNumber *)b
{
    double aVal = [a doubleValue];
    double bVal = [b doubleValue];
    return [NSNumber numberWithDouble:(aVal - bVal)];
}

- (NSString *) formatSub:(NSString *)a
                      by:(NSString *)b
{
    return [NSString stringWithFormat:@"%@ - %@", a, b];
}


// multiply

- (NSNumber *) mult:(NSNumber *)a
                 by:(NSNumber *)b
{
    double aVal = [a doubleValue];
    double bVal = [b doubleValue];
    return [NSNumber numberWithDouble:(aVal * bVal)];
}

- (NSString *) formatMult:(NSString *)a
                       by:(NSString *)b
{
    return [NSString stringWithFormat:@"%@ * %@", a, b];
}


// divide

- (NSNumber *) div:(NSNumber *)a
                by:(NSNumber *)b
{
    double aVal = [a doubleValue];
    double bVal = [b doubleValue];
    double result;

    // Need to handle the div by zero case, may as well do here at the lowest level
    if (bVal == 0) {
        result = 0;
    } else {
        result = aVal / bVal;
    }

    return [NSNumber numberWithDouble:result];
}

- (NSString *) formatDiv:(NSString *)a
                      by:(NSString *)b
{
    return [NSString stringWithFormat:@"%@ / %@", a, b];
}


// square

- (NSNumber *) square:(NSNumber *)a
{
    double aVal = [a doubleValue];
    return [NSNumber numberWithDouble:(aVal * aVal)];
}

- (NSString *) formatSquare:(NSString *)a
{
    return [NSString stringWithFormat:@"%@^2", a];
}


// square root

- (NSNumber *) squareroot:(NSNumber *)a
{
    double aVal = [a doubleValue];
    return [NSNumber numberWithDouble:sqrt(aVal)];
}

- (NSString *) formatSquareroot:(NSString *)a
{
    return [NSString stringWithFormat:@"sqrt%@", a];
}


// sine

- (NSNumber *) sine:(NSNumber *)a
{
    double aVal = [a doubleValue];
    return [NSNumber numberWithDouble:sin(aVal)];
}

- (NSString *) formatSine:(NSString *)a
{
    return [NSString stringWithFormat:@"sin%@", a];
}


// cosine

- (NSNumber *) cosine:(NSNumber *)a
{
    double aVal = [a doubleValue];
    return [NSNumber numberWithDouble:cos(aVal)];
}

- (NSString *) formatCosine:(NSString *)a
{
    return [NSString stringWithFormat:@"cos%@", a];
}



@end
