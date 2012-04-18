//
//  rpnCalcViewController.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import "rpnCalcViewController.h"
#import "rpnCalcStack.h"


@interface rpnCalcViewController ()
@property (nonatomic) BOOL entering;
@property (nonatomic, strong) rpnCalcStack *stack;

- (void)addDigitToDisplay:(NSString *)digit;

@end


@implementation rpnCalcViewController

@synthesize entering = _entering;

@synthesize display = _display;
@synthesize dispStack = _dispStack;

@synthesize stack = _stack;

- (rpnCalcStack *) stack
{
    if (!_stack) _stack = [[rpnCalcStack alloc] init];
    return _stack;
}

//
// HELPER FUNCTIONS (PRIVATE)
//

- (void)addDigitToDisplay:(NSString *)digit
{
    if (self.entering) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.entering = YES;
    }    
}

- (void)addItemToDispStack:(NSString *)item
{
    self.dispStack.text = [self.dispStack.text stringByAppendingFormat:@" %@", item];
}

//
// PUBLIC FUNCTIONS
//

- (IBAction)buttonPress:(UIButton *)sender 
{
    [self addDigitToDisplay:sender.currentTitle];
}

- (IBAction)operationPress:(UIButton *)sender 
{
    // push on to stack whether or not they are entering a number.  This enables the
    // behavior "5 <enter> <plus>" = 10
    [self enterPress];
    self.entering = NO;
    
    // [stack op] is expecting the operands on the stack
    NSString *op = sender.currentTitle;
    double result = [self.stack operate:op];
    
    [self addItemToDispStack:op];    

    NSString * resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
}


- (IBAction)enterPress 
{
    [self.stack push:[self.display.text doubleValue]];
    [self addItemToDispStack:self.display.text];
    
    self.entering = NO;
}

- (IBAction)decimalPress:(UIButton *)sender 
{
    if (self.entering && 
        [self.display.text rangeOfString:@"."].location != NSNotFound ) {
        // already a decimal point, don't do anything
        return;
    }
    if (!self.entering) {
        [self addDigitToDisplay:@"0"];
    }
    [self buttonPress:sender];
}


- (IBAction)clearPress:(UIButton *)sender 
{
    self.display.text = @"0";
    self.entering = NO;
}


- (IBAction)allClearPress:(UIButton *)sender 
{
    [self clearPress:sender];
    
    [self.stack clear];
    self.dispStack.text = @"";
}

- (IBAction)piPress:(UIButton *)sender 
{
    double result;
    
    if (self.entering) {
        [self enterPress];
        [self.stack push:pi];
        result = [self.stack operate:@"*"];
    } else {
        [self.stack push:pi];        
        result = pi;
    }
    
    NSString * resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
}


- (void)viewDidUnload {
    [self setDispStack:nil];
    [super viewDidUnload];
}
@end
