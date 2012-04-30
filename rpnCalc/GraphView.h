//
//  GraphView.h
//  rpnCalc
//
//  Created by Sef Kloninger on 4/27/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;   


@protocol GraphViewDataSource
- (double) evaluateAtX:(double)xValue forGraphView:(GraphView *)sender;
- (BOOL) drawLinesForGraphView:(GraphView *)sender;
@end


@interface GraphView : UIView

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat scale;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void)pinch:    (UIPinchGestureRecognizer *)gesture;
- (void)pan:      (UIPinchGestureRecognizer *)gesture;
- (void)doubleTap:(UIPinchGestureRecognizer *)gesture;

@end
