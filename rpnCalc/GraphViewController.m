//
//  GraphViewController.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/26/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "rpnCalcBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView * graphView;
@property (nonatomic, weak) IBOutlet UILabel *programDescriptionLabel;
@end


@implementation GraphViewController

// Public Properties

@synthesize program = _program;
@synthesize programDescriptionLabel = _programDescriptionLabel;

- (void)setProgram:(id)program
{
    _program = program;
}

@synthesize graphView = _graphView;
- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;

    // TODO - gesture recognizers
    
    self.graphView.dataSource = self;
}



// Data Source Protocol

- (double) evaluateAtX:(double)xValue
          forGraphView:(GraphView *)sender
{
    float yValue;
    NSNumber * xNum = [[NSNumber alloc] initWithDouble:xValue];
    
    rpnCalcVariableValues * vars = [[rpnCalcVariableValues alloc] init];
    [vars.dict setValue:xNum forKey:@"X"];
    yValue = [rpnCalcBrain runProgram:self.program usingVariableDict:vars.dict];
    
    return yValue;
}

- (void) saveDataToPermanentStore
{
    // TODO - write scale, origin to NSUserDefaults
}



// View Bringup and Teardown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.programDescriptionLabel.text = [rpnCalcBrain describeProgram:self.program];
    [self.programDescriptionLabel setNeedsDisplay];
    
    [self.graphView setNeedsDisplay];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveDataToPermanentStore];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    self.graphView = nil;
    [self setProgramDescriptionLabel:nil];
    self.programDescriptionLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;  // all rotations OK
}

@end
