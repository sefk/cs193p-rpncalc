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
@property (nonatomic, weak) IBOutlet UILabel *   programDescriptionLabel;
@property (nonatomic, weak) IBOutlet UISwitch *  lineModeSwitch;
@property (nonatomic, weak) IBOutlet GraphView * graphView;
@end


@implementation GraphViewController

// Public Properties

@synthesize program = _program;


// Private Properties

@synthesize programDescriptionLabel = _programDescriptionLabel;

@synthesize lineModeSwitch = _lineModeSwitch;

- (IBAction)lineModeSwitchAction {
    [self.graphView setNeedsDisplay];
}


@synthesize graphView = _graphView;
- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;

    // Pinching changes the scale
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];

    // Panning moves the origin
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
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


- (BOOL) drawLinesForGraphView:(GraphView *)sender
{
    return self.lineModeSwitch.on;
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
    self.programDescriptionLabel = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;  // all rotations OK
}

@end
