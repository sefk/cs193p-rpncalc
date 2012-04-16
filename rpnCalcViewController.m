//
//  rpnCalcViewController.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "rpnCalcViewController.h"
#import "rpnCalcStack.h"

@interface rpnCalcViewController ()
@property (nonatomic) BOOL entering;
@property (nonatomic, strong) rpnCalcStack *stack;

- (void)addCharToDisplay:(NSString *)digit;

@end



@implementation rpnCalcViewController
@synthesize display = _display;
@synthesize entering = _entering;




@synthesize stack = _stack;

- (rpnCalcStack *) stack
{
    if (!_stack) _stack = [[rpnCalcStack alloc] init];
    return _stack;
}

//
// HELPER FUNCTIONS (PRIVATE)
//

- (void)addCharToDisplay:(NSString *)digit
{
    if (self.entering) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.entering = YES;
    }    
}


//
// PUBLIC FUNCTIONS
//

- (IBAction)buttonPress:(UIButton *)sender {
    [self addCharToDisplay:sender.currentTitle];
}

- (IBAction)operationPress:(UIButton *)sender {
    // if they are in the middle of entering a number, and haven't
    // pushed enter yet, then do it for them
    if (self.entering) [self enterPress];
    
    NSString *op = sender.currentTitle;
    double result = [self.stack operate:op];
    NSString * resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
    self.entering = NO;
}


- (IBAction)enterPress {
    [self.stack push:[self.display.text doubleValue]];
    self.display.text = @"0";
    self.entering = NO;
}

- (IBAction)decimalPress:(UIButton *)sender {
    if (self.entering && 
        [self.display.text rangeOfString:@"."].location != NSNotFound ) {
        // already a decimal point, dont do anything
        return;
    }
    if (!self.entering) {
        [self addCharToDisplay:@"0"];
    }
    [self buttonPress:sender];
}


- (IBAction)clearPress:(UIButton *)sender {
    self.display.text = @"0";
    self.entering = NO;
}


- (IBAction)allClearPress:(UIButton *)sender {
    [self clearPress:sender];
    [self.stack clear];
}



@end
