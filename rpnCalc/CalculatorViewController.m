//
//  CalculatorViewController.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "VariableValues.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL entering;
@property (nonatomic, strong) CalculatorBrain * brain;
@property (nonatomic, strong) VariableValues *  variableValues;
@end


@implementation CalculatorViewController

@synthesize entering = _entering;

@synthesize displayCurrent = _displayCurrent;
@synthesize displayLog = _displayLog;

@synthesize brain = _brain;

- (CalculatorBrain *) brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}


@synthesize variableValues = _variableValues;

- (VariableValues *) variableValues
{
    if (!_variableValues) {
        _variableValues = [[VariableValues alloc] init];
    }
    return _variableValues;
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
    self.displayLog.text = [[self.brain class] describeProgram:self.brain.program];
}

- (void) pushCurrentOntoStack
{
    [self.brain pushOperand:[self.displayCurrent.text doubleValue]];
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
    double result = [self.brain pushOperatorAndEvaluate:op
                                      usingVariableDict:self.variableValues.dict];
                  
    [self refreshDisplayLog];
    
    NSString * resultString = [NSString stringWithFormat:@"%g", result];
    self.displayCurrent.text = resultString;
}


- (IBAction)enterPress 
{
    if (self.entering) {
        self.entering = NO;
        [self pushCurrentOntoStack];
    }
    
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
    
    [self.brain clear];
    [self refreshDisplayLog];

    // iPad -- clear out the graph by setting the program to nil
    id detailController = [self.splitViewController.viewControllers lastObject];
    if ([detailController isKindOfClass:[GraphViewController class]])
        // (and not nil of course...)
    {
        GraphViewController * detailGraphViewController = detailController;
        [detailGraphViewController setProgram:nil];
    }
}


- (IBAction)varPress:(UIButton *)sender 
{
    double result;
    
    NSString * var = sender.currentTitle;

    if (self.entering) {
        self.entering = NO;
        [self pushCurrentOntoStack];
        [self.brain pushVariable:var];
        result = [self.brain pushOperatorAndEvaluate:@"*"
                                   usingVariableDict:self.variableValues.dict];
        
        [self refreshDisplayLog];

        NSString * resultString = [NSString stringWithFormat:@"%g", result];
        self.displayCurrent.text = resultString;
    } else {
        [self.brain pushVariable:var];
        self.displayCurrent.text = var;
    }
}



//
// iPad:   Send program to graph pane
// iPhone: Bring up Graph by Segue
//

- (IBAction)graphPress 
{  
    id detailController = [self.splitViewController.viewControllers lastObject];
    if ([detailController isKindOfClass:[GraphViewController class]])    
        // (and not nil of course...)
    {
        // iPad -- update program in graph in right (detail) pane
        GraphViewController * detailGraphViewController = detailController;
        [detailGraphViewController setProgram:self.brain.program];
    } else {
        // iPhone -- segue to Graph
        if ([self.brain.program count] > 0) {
            [self performSegueWithIdentifier:@"ShowGraph" sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

- (void)viewDidUnload {
    [self setDisplayLog:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (self.splitViewController) {
        // iPad
        return YES;
    } else {
        // iPhone
        return UIInterfaceOrientationIsPortrait(orientation);
    }
}


@end
