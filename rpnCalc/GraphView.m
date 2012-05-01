//
//  GraphView.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/27/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView()
@end


@implementation GraphView

// Origin and Scale

@synthesize originHasBeenSet = _originHasBeenSet;
@synthesize origin = _origin;
- (CGPoint)origin
{
    if (!self.originHasBeenSet) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        _origin.x = [defaults floatForKey:@"origin.x"];
        _origin.y = [defaults floatForKey:@"origin.y"];
        if (_origin.x == 0) {
            // all hell breaks loose default case
            _origin.x = self.bounds.size.width / 2;
        }
        if (_origin.y == 0) {
            _origin.y = self.bounds.size.height / 2;
        }
        self.originHasBeenSet = YES;
    }
    return _origin;
}

- (void)setOrigin:(CGPoint)newOrigin
{
    _origin.x = newOrigin.x;
    _origin.y = newOrigin.y;
    self.originHasBeenSet = YES;
    [self setNeedsDisplay];     
}

- (void)adjustOrigin:(CGPoint)offset
{
    _origin.x += offset.x;
    _origin.y += offset.y;
    self.originHasBeenSet = YES;
    [self setNeedsDisplay];
}

@synthesize scaleHasBeenSet = _scaleHasBeenSet;
@synthesize scale = _scale;
- (CGFloat)scale {
    if (!self.scaleHasBeenSet) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        _scale = [defaults floatForKey:@"scale"];
        if (_scale == 0) {
            // all hell breaks loose default case
            _scale = 20.0;
        }
        self.scaleHasBeenSet = YES;
    }
    return _scale;
}
- (void)setScale:(CGFloat)newScale
{
    _scale = newScale;
    self.scaleHasBeenSet = YES;
    [self setNeedsDisplay];
}


@synthesize dataSource = _dataSource;


- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


// Gestures

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        [self adjustOrigin:translation];
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture 
{     
    if (gesture.state == UIGestureRecognizerStateEnded) {  
        CGPoint tapLocation = [gesture locationInView:self];
        self.origin = tapLocation;
    } 
}


const CGFloat darkRedColorValues[] = {1.0, 0.2, 0.2, 1.0};


#define DOT_RADIUS 1.0

- (void)drawDotAtPoint:(CGPoint)p inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextSetFillColor(context, darkRedColorValues);
    CGContextSetStrokeColor(context, darkRedColorValues);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, DOT_RADIUS, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}


- (void)drawLineBetweenPointA:(CGPoint)a andB:(CGPoint)b inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextSetStrokeColor(context, darkRedColorValues);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, a.x, a.y);
    CGContextAddLineToPoint(context, b.x, b.y);
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}


// For every pixel on the screen, figure out it's "value", evaluate it, and then
// convert that value back to the coordinate system
//
// The arithmetic here is counter-intuitive since the X coordinates increase from
// left to right, while the Y coordinates decrease from top to bottom.
// 
// We loop over the X values of the currentPoint (x,y struct) and store the 
// pixel value we get back in the Y value of currentPoint.

- (void) plotGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGPoint currentPoint;   // current loop and result
    CGPoint priorPoint;     // prior point for drawing a line
    BOOL validPriorPoint;   // was a prior point set

	for (currentPoint.x = 0; currentPoint.x < self.bounds.size.width; currentPoint.x++) {
        CGContextBeginPath(context);
        double xValue = (currentPoint.x - self.origin.x) / self.scale;
        double yValue = [self.dataSource evaluateAtX:xValue forGraphView:self];
        currentPoint.y = self.origin.y - (yValue * self.scale);
        
        if ([self.dataSource drawLinesForGraphView:self]) {
            if (validPriorPoint) {
                [self drawLineBetweenPointA:priorPoint andB:currentPoint inContext:context];
            } // else don't draw just yet, miss a point
        } else {
            [self drawDotAtPoint:currentPoint inContext:context];
        }
        priorPoint = currentPoint;
        validPriorPoint = YES;        
    }
}


- (void)drawRect:(CGRect)rect
{
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:self.origin
                         scale:self.scale];

    if ([self.dataSource validProgram]) {
        [self plotGraph];
    }
}

@end
