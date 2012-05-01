//
//  GraphViewController.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/26/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "VariableValues.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet UILabel *   programDescriptionLabel;
@property (nonatomic, weak) IBOutlet UISwitch *  lineModeSwitch;
@property (nonatomic, weak) IBOutlet GraphView * graphView;
@property (nonatomic, weak) IBOutlet UIToolbar * topToolbar;
@end


@implementation GraphViewController

// Public Properties

@synthesize program = _program;

- (void)setProgram:(id)program
{
    _program = program;
    [self.graphView setNeedsDisplay];
    
    [self showProgramDescription:[CalculatorBrain describeProgram:self.program]];
    [self.programDescriptionLabel setNeedsDisplay];

}


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
    
    // Double-tap sets a new origin
    UITapGestureRecognizer * gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(doubleTap:)];
    gestureRec.numberOfTapsRequired = 2;
    [self.graphView addGestureRecognizer:gestureRec];
    
    self.graphView.dataSource = self;
}

@synthesize topToolbar = _topToolbar;


// Data Source Protocol

- (double) evaluateAtX:(double)xValue
          forGraphView:(GraphView *)sender
{
    float yValue;
    NSNumber * xNum = [[NSNumber alloc] initWithDouble:xValue];
    
    VariableValues * vars = [[VariableValues alloc] init];
    [vars.dict setValue:xNum forKey:@"X"];
    yValue = [CalculatorBrain runProgram:self.program usingVariableDict:vars.dict];
    
    return yValue;
}

- (BOOL) drawLinesForGraphView:(GraphView *)sender
{
    return self.lineModeSwitch.on;
}

- (BOOL) validProgram
{
    return (self.program != nil);
}


// Toolbar Button Protocol

@synthesize barButtonItem = _barButtonItem;

- (void) setBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (_barButtonItem != barButtonItem) {
        NSMutableArray * newItems = [self.topToolbar.items mutableCopy];
        if (_barButtonItem) [newItems removeObject:_barButtonItem];
        if (barButtonItem)  [newItems insertObject:barButtonItem atIndex:0];  //left
        self.topToolbar.items = newItems;
        _barButtonItem = barButtonItem;
    }
    
}


// OTHERS

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


- (void)showProgramDescription:(NSString *)programDesc
{
    BOOL changed;
    if (self.topToolbar) {
        // iPad
        NSMutableArray * items = [[self.topToolbar items] mutableCopy];
        for (int i = 0; i < items.count; i++) {
            UIBarButtonItem * b = [items objectAtIndex:i];
            if (b.style == UIBarButtonItemStylePlain) {
                [b setTitle:programDesc];
                changed = YES;
            }
        }
        if (changed) [self.topToolbar setItems:items];
    }
    else {
        // iPhone
        self.programDescriptionLabel.text = programDesc;
        [self.programDescriptionLabel setNeedsDisplay];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showProgramDescription:[CalculatorBrain describeProgram:self.program]];
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
