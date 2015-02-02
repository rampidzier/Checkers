//
//  ViewController.h
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckerBoard.h"
#import "WinConditionDelegate.h"

@interface ViewController : UIViewController <WinConditionDelegate>
{
    CheckerBoard *gameBoard;
}


@end

