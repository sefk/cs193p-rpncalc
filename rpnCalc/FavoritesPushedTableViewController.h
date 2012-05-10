//
//  FavoritesPushedTableViewController.h
//  rpnCalc
//
//  Created by Sef Kloninger on 5/10/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesPushedTableViewController;

@protocol FavoritesPushedGraphSelectionProtocol <NSObject>

@optional - (void)selectedProgram:(id)program
                byFavoritePushedTVC:(FavoritesPushedTableViewController *) sender;

@end


@interface FavoritesPushedTableViewController : UITableViewController

@property NSArray * programs;
@property id<FavoritesPushedGraphSelectionProtocol> delegate;

@end
