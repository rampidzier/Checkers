//
//  CheckerPiece.h
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckerBoard.h"
#import "BoardCellState.h"

@interface CheckerPiece : UIImageView <UIGestureRecognizerDelegate>
{
    BoardCellState currentState;
    
    // Used to return the piece to it's orignal spot if the move is invalid.
    int initialX;
    int initialY;
}

@property (nonatomic, weak) id <CheckerBoardDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andState:(BoardCellState)state;

@end
