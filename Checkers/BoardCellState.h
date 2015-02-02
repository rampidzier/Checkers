//
//  BoardCellState.h
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#ifndef Checkers_BoardCellState_h
#define Checkers_BoardCellState_h

typedef NS_ENUM(NSUInteger, BoardCellState)
{
    BoardCellStateEmpty = 0,            // Empty space.
    BoardCellStateBlackPiece = 1,       // Black piece.
    BoardCellStateRedPiece = 2,         // Red piece.
    BoardCellStateCanMove = 3           // Can move flag, used for player jumps.
};

// Board offsets used because the checkerboard I found has white space around the board.  These are used to ensure
// the pieces are in their proper place.
static const int kBoardOffsetX = 11;
static const int kBoardOffsetY = 7;

#endif
