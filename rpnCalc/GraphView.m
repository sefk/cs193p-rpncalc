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
@property (nonatomic) BOOL originHasBeenSet;
@property (nonatomic) BOOL scaleHasBeenSet;
@end


@implementation GraphView

// Origin and Scale

@synthesize originHasBeenSet = _originHasBeenSet;
@synthesize origin = _origin;
- (CGPoint)origin
{
    if (!self.originHasBeenSet) {
        _origin.x = 10;
        _origin.y = 10;
    }
    return _origin;
    [self setNeedsDisplay];   
}
- (void)setOrigin:(CGPoint)newOrigin
{
    _origin.x = newOrigin.x;
    _origin.y = newOrigin.y;
    self.originHasBeenSet = YES;
    
}

@synthesize scaleHasBeenSet = _scaleHasBeenSet;
@synthesize scale = _scale;
- (CGFloat)scale {
    if (!self.scaleHasBeenSet) {
        _scale = 1.0;
    }
    return _scale;
    [self setNeedsDisplay];
}
- (void)setScale:(CGFloat)newScale
{
    _scale = newScale;
    self.originHasBeenSet = YES;
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
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:self.origin
                         scale:self.scale];
    
    // TODO: Draw Graph Points
}

@end
