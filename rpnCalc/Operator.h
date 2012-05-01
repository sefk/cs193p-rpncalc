//
//  Operator.h
//  
//  Handle all the low level grungy stuff for particular operations.  
//
//  For example, here is the logic that  "cos" takes one parameter, is evaluated by 
//  the cos() math function, and always needs parenthesis around the term it's 
//  operating on when printing out.
//
//  Created by Sef Kloninger on 4/22/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Operator : NSObject

@property (nonatomic, strong) NSString *  name;
@property (nonatomic)         int         needsOperands;
@property (nonatomic)         int         precedence;
@property (nonatomic)         NSString *  executionSelectorStr;
@property (nonatomic)         NSString *  formatSelectorStr;
@property (nonatomic)         BOOL        forcesParentheses;

// WORKERS

- (NSNumber *) evaluateOperand:(NSNumber *)operand;

- (NSNumber *) evaluateOperand:(NSNumber *)operand1
                   withOperand:(NSNumber *)operand2;

// When printing we need to know what the parent operator is
// to decide whether we need parenthesis or not.

- (NSString *) formatOperand:(NSString *)operandStr
        withinParentOperator:(Operator *)parent;

- (NSString *) formatOperand:(NSString *)operand1Str
                 withOperand:(NSString *)operand2Str
         withinParentOperator:(Operator *)parent;

// CLASS METHODS

+ (Operator *) operatorFromOpname:(NSString *)opname;

+ (NSSet *) setWithAllOperatorStrings;


@end
