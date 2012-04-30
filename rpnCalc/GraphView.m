//
//  GraphView.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/27/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "GraphView.h"


@implementation GraphView

@synthesize dataSource = _dataSource;

@synthesize origin = _origin;
- (CGPoint)origin {
    // TODO - set default
    return _origin;
    [self setNeedsDisplay];   
}

@synthesize scale = _scale;
- (CGFloat)scale {
    // TODO - set default
    return _scale;
    [self setNeedsDisplay];
}

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


- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}


- (void)drawRect:(CGRect)rect
{
    // TODO: Draw Axes
    
    // TODO: Draw Graph Points
}

@end
