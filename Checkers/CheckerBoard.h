//
//  CheckerBoard.h
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardCellState.h"
#import "WinConditionDelegate.h"

// The delegate that the piece calls when a move has been completed.
@protocol CheckerBoardDelegate <NSObject>

- (int)isMoveValid:(int)tag withX:(int)newX andY:(int)newY;
- (void)endPlayerTurn;

@end

@interface CheckerBoard : UIView <CheckerBoardDelegate>
{
    float pieceWidth;
    float pieceHeight;
    
    // Variables used to limit the number of searches for jumps.
    int highestRed;
    int highestBlack;
    
    BOOL canJump;
    
    // The gameboard matrix.  Originally, I wasn't going to have one, but I realized it was going to make things
    // much easier.  Since I changed course midstream, I forgot to make the matrix bgger than the actual board.
    // This would remove some excessive code and improve performance if it was a 10x10 matrix with invalid squares
    // surrounding the board.
    int gameBoard[8][8];
    
    // Variables used for win condition.
    int redCount;
    int blackCount;
}

@property (nonatomic, weak) id <WinConditionDelegate> delegate;

@end

