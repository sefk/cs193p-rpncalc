//
//  rpnCalcStack.h
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rpnCalcStack : NSObject

- (void) push:(double)num;
- (double) peek;
- (double) pop;
- (double) depth;
- (void) clear;
- (double) operate:(NSString *)operate;

@end
