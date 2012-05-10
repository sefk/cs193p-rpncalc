//
//  CalculatorAppDelegate.m
//  rpnCalc
//
//  Created by Sef Kloninger on 4/13/12.
//  Copyright (c) 2012 Peek 222. All rights reserved.
//

#import "CalculatorAppDelegate.h"

@implementation CalculatorAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register the preference defaults early.
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObject:[NSNumber numberWithInteger:20] forKey:@"scale"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    // Override point for customization after application launch.
    return YES;
}

@end
