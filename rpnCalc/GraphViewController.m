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
#import "FavoritesPopoverTableViewController.h"

@interface GraphViewController () <GraphViewDataSource, FavoritesGraphSelectionProtocol>
@property (nonatomic, weak) IBOutlet UILabel *   programDescriptionLabel;
@property (nonatomic, weak) IBOutlet UISwitch *  lineModeSwitch;
@property (nonatomic, weak) IBOutlet GraphView * graphView;
@property (nonatomic, weak) IBOutlet UIToolbar * topToolbar;
@property (nonatomic, strong) IBOutlet UIPopoverController * myPopoverController;

@property (nonatomic, strong) VariableValues * varsForEvaluation;

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


//
// Data Source Protocol
//
// we keep using this local variable for evaluation, changing the value for "X" over 
// and over again.
//

@synthesize varsForEvaluation = _varsForEvaluation;
- (VariableValues *) varsForEvaluation
{
    if (!_varsForEvaluation) _varsForEvaluation = [[VariableValues alloc] init];
    return _varsForEvaluation;
}

- (double) evaluateAtX:(double)xValue
          forGraphView:(GraphView *)sender
{
    float yValue;
    NSNumber * xNum = [[NSNumber alloc] initWithDouble:xValue];
    
    NSMutableDictionary * varDict = self.varsForEvaluation.dict;
    
    [varDict setValue:xNum forKey:@"X"];
    yValue = [CalculatorBrain runProgram:self.program usingVariableDict:varDict];
    
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


// OTHERS

- (void) saveDataToPermanentStore
{
    NSUserDefaults * defaults;
    if (self.graphView.scaleHasBeenSet || self.graphView.originHasBeenSet) {
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:self.graphView.origin.x forKey:@"origin.x"];
        [defaults setFloat:self.graphView.origin.y forKey:@"origin.y"];
        [defaults setFloat:self.graphView.scale forKey:@"scale"];
    }
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
    

//
// Split View Delegate 
// all the rigamarole in here to present a popover (whew!)
//

@synthesize myPopoverController = _myPopoverController;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void) splitViewController:(UISplitViewController *)svc
      willHideViewController:(UIViewController *)aViewController
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)pc
{
    // add button to toolbar
    barButtonItem.title = @"Calculator";
    NSMutableArray *items = [[self.topToolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.topToolbar setItems:items animated:YES];
    self.myPopoverController = pc;
} 

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove button from toolbar
    NSMutableArray *items = [[self.topToolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.topToolbar setItems:items animated:YES];
    self.myPopoverController = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    if (self.splitViewController) {
        // iPad
        return UIInterfaceOrientationIsPortrait(orientation);
    } else {
        // iPhone
        return NO;
    }
}

// Favorites Popover support

#define FAVORITES_KEY @"GraphViewController.favorites"

- (IBAction)addProgramToFavorite 
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    assert(defaults);
    NSMutableArray * programs = [[defaults arrayForKey:FAVORITES_KEY]
                                 mutableCopy];
    if (!programs) programs = [[NSMutableArray alloc] init];
    [programs addObject:self.program];
    [defaults setObject:programs forKey:FAVORITES_KEY];
    [defaults synchronize];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowFavoritesPopover"]) {
        FavoritesPopoverTableViewController * favVC = segue.destinationViewController; 
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        assert(defaults);
        favVC.programs = [defaults arrayForKey:FAVORITES_KEY];
        favVC.delegate = self;
    }
}

- (void)selectedProgram:(id)program
      byFavoritePopover:(FavoritesPopoverTableViewController *) sender
{
    self.program = program;
}


@end
