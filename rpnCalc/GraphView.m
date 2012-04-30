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
        _origin.x = self.bounds.size.width / 2;
        _origin.y = self.bounds.size.height / 2;
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
        _scale = 20.0;
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


- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
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
//        CGPoint translation = [gesture translationInView:[self superview]];
        CGPoint translation = [gesture translationInView:self];
        [self adjustOrigin:translation];
        [gesture setTranslation:CGPointZero inView:self];
    }
}



- (void)drawRect:(CGRect)rect
{
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:self.origin
                         scale:self.scale];
    
    // TODO: Draw Graph Points
}

@end
