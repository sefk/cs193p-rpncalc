//
//  rpnCalcViewController.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import "rpnCalcViewController.h"
#import "rpnCalcStack.h"
#import "rpnCalcConstants.h"

@interface rpnCalcViewController ()
@property (nonatomic) BOOL entering;
@property (nonatomic, strong) rpnCalcStack *stack;

@end


@implementation rpnCalcViewController

@synthesize entering = _entering;

@synthesize displayCurrent = _displayCurrent;
@synthesize displayLog = _displayLog;

@synthesize stack = _stack;

- (rpnCalcStack *) stack
{
    if (!_stack) _stack = [[rpnCalcStack alloc] init];
    return _stack;
}

//
// HELPER FUNCTIONS (PRIVATE)
//

- (void) addDigitToDisplayCurrent:(NSString *)digit
{
    if (self.entering) {
        self.displayCurrent.text = [self.displayCurrent.text stringByAppendingString:digit];
    } else {
        self.displayCurrent.text = digit;
    }    
}

- (void) refreshDisplayLog
{
    self.displayLog.text = [[self.stack class] describeProgram:self.stack.program];
}

- (void) pushCurrentOntoStack
{
    [self.stack pushOperand:[self.displayCurrent.text doubleValue]];
}




//
// PUBLIC FUNCTIONS
//

- (IBAction)buttonPress:(UIButton *)sender 
{
    [self addDigitToDisplayCurrent:sender.currentTitle];
    self.entering = YES;
}

- (IBAction)operationPress:(UIButton *)sender 
{    
    if (self.entering) {
        [self pushCurrentOntoStack];
        self.entering = NO;
    }

    NSString *op = sender.currentTitle;
    double result = [self.stack pushOperatorAndEvaluate:op];
                  
    [self refreshDisplayLog];
    
    NSString * resultString = [NSString stringWithFormat:@"%g", result];
    self.displayCurrent.text = resultString;
}


- (IBAction)enterPress 
{
    self.entering = NO;
    [self pushCurrentOntoStack];
    
    [self refreshDisplayLog];    
}


- (IBAction)decimalPress:(UIButton *)sender 
{
    if (self.entering && 
        [self.displayCurrent.text rangeOfString:@"."].location != NSNotFound ) {
        // already a decimal point, don't do anything
        return;
    }
    if (!self.entering) {
        [self addDigitToDisplayCurrent:@"0"];
        self.entering = YES;
    }
    [self buttonPress:sender];
}


- (IBAction)clearPress:(UIButton *)sender 
{
    self.displayCurrent.text = @"0";
    self.entering = NO;
}

- (IBAction)allClearPress:(UIButton *)sender 
{
    [self clearPress:sender];
    
    [self.stack clear];
    [self refreshDisplayLog];
}


- (IBAction)piPress:(UIButton *)sender 
{
    double result;
    
    if (self.entering) {
        self.entering = NO;
        [self pushCurrentOntoStack];
        [self.stack pushOperand:pi];
        result = [self.stack pushOperatorAndEvaluate:@"*"];
    } else {
        [self.stack pushOperand:pi];        
        result = pi;
    }
    
    NSString * resultString = [NSString stringWithFormat:@"%g", result];
    self.displayCurrent.text = resultString;
}


- (IBAction)varPress:(UIButton *)sender 
{
    double result;
    
    NSString * var = sender.currentTitle;

    if (self.entering) {
        self.entering = NO;
        [self pushCurrentOntoStack];
        [self.stack pushVariable:var];
        result = [self.stack pushOperatorAndEvaluate:@"*"];

        NSString * resultString = [NSString stringWithFormat:@"%g", result];
        self.displayCurrent.text = resultString;
    } else {
        [self.stack pushVariable:var];
        self.displayCurrent.text = var;
    }
}


- (void)viewDidUnload {
    [self setDisplayLog:nil];
    [super viewDidUnload];
}
@end
