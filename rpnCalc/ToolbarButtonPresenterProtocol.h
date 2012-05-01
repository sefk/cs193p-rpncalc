//
//  ToolbarButtonPresenterProtocol.h
//  rpnCalc
//
//  Created by Sef Kloninger on 5/1/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolbarButtonPresenter <NSObject>
@property (nonatomic, strong) UIBarButtonItem * barButtonItem;
@end
