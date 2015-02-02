//
//  WinConditionDelegate.h
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#ifndef Checkers_WinConditionDelegate_h
#define Checkers_WinConditionDelegate_h

// The delegate that is called to signal a winner.
@protocol WinConditionDelegate <NSObject>

- (void)displayMessage:(NSString *)message;

@end

#endif
