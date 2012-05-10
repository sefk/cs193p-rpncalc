//
//  FavoritesPopoverTableViewController.h
//  rpnCalc
//
//  Created by Sef Kloninger on 5/10/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesPopoverTableViewController;

@protocol FavoritesPopoverGraphSelectionProtocol <NSObject>

@optional - (void)selectedProgram:(id)program
                byFavoritePopoverTVC:(FavoritesPopoverTableViewController *) sender;

@end

@interface FavoritesPopoverTableViewController : UITableViewController

@property NSArray * programs;
@property id<FavoritesPopoverGraphSelectionProtocol> delegate;

@end
