//
//  GraphViewController.h
//  rpnCalc
//
//  Created by Sef Kloninger on 4/26/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "ToolbarButtonPresenterProtocol.h"

@interface GraphViewController : UIViewController <ToolbarButtonPresenter>

@property (nonatomic, strong) id program;

@end
