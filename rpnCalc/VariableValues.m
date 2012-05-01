//
//  VariableValues.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/26/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "VariableValues.h"

@implementation VariableValues

@synthesize dict = _dict;

- (NSMutableDictionary *) dict
{
    if (!_dict) {
        _dict = [[NSMutableDictionary alloc] init];
        
        // everything starts out with one "variable", pi
        NSNumber * numPi = [NSNumber numberWithDouble:M_PI];
        [_dict setObject:numPi forKey:@"pi"];
    }
    return _dict;
}

@end
