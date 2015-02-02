//
//  CheckerBoard.m
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#import "CheckerBoard.h"
#import "CheckerPiece.h"

@implementation CheckerBoard

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    pieceWidth = (frame.size.width - 20) / 8.0;
    pieceHeight = (frame.size.height - 20) / 8.0;
    
    if (self)
    {
        [self initializeGameBoard];
    }

    // Add the background checkerboard.
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    background.image = [UIImage imageNamed:@"checkerboard.jpg"];
    background.tag = 1000;
    [self addSubview:background];
    [self sendSubviewToBack:background];
    
    canJump = NO;
    
    return self;
}

// Initializes the game board and places the pieces in the correct starting location.  This method would have to change
// to remove pieces that are still on the board if a rematch option was coded in.
- (void)initializeGameBoard
{
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            gameBoard[i][j] = BoardCellStateEmpty;
        }
    }
    
    for (int row = 0; row < 8; row++)
    {
        for (int col = row % 2; col < 8; col = col + 2)
        {
            if ((row >= 0) && (row < 3))
            {
                CheckerPiece *piece = [[CheckerPiece alloc] initWithFrame:CGRectMake(col * pieceWidth + kBoardOffsetX, row * pieceHeight + kBoardOffsetY, pieceWidth, pieceHeight) andState:BoardCellStateBlackPiece];
                piece.tag = row * 10 + col;
                piece.delegate = self;
                [self addSubview:piece];
                gameBoard[row][col] = BoardCellStateBlackPiece;
            }
            else if ((row >= 5) && (row < 8))
            {
                CheckerPiece *piece = [[CheckerPiece alloc] initWithFrame:CGRectMake(col * pieceWidth + kBoardOffsetX, row * pieceHeight + kBoardOffsetY, pieceWidth, pieceHeight) andState:BoardCellStateRedPiece];
                piece.tag = row * 10 + col;
                piece.delegate = self;
                [self addSubview:piece];
                gameBoard[row][col] = BoardCellStateRedPiece;
            }
        }
    }
    
    highestBlack = 2;
    highestRed = 5;
    
    blackCount = 12;
    redCount = 12;
}

// Checks to see if a move is valid.  Returns a -1 if the move is invalid, otherwise it returns the new tag
// for the piece.  The tag corresponds to it's location on the board.
- (int)isMoveValid:(int)tag withX:(int)newX andY:(int)newY
{
    int currentRow = tag / 10;
    int currentCol = tag % 10;
    
    int destinationRow = newY / pieceWidth;
    int destinationCol = newX / pieceHeight;
    
    int jumpOffset;
    
    // If we can jump, we need a different offset, since we our doubling our traveling distance.
    if (!canJump)
    {
        jumpOffset = 1;
    }
    else
    {
        jumpOffset = 2;
    }
    
    // The check to see if the destination is on the board and legal for a piece to move, regardless of what is there.
    if (((currentRow - jumpOffset) != destinationRow) || (((currentCol - jumpOffset) != destinationCol) && (currentCol + jumpOffset) != destinationCol))
    {
        return -1;
    }

    // Check to see if the destination is empty or a potential movement spot.
    if ((gameBoard[destinationRow][destinationCol] != BoardCellStateEmpty) && (gameBoard[destinationRow][destinationCol] != BoardCellStateCanMove))
    {
        return -1;
    }
    
    // If we jump, then we need to remove the piece that was jumped.
    if (canJump)
    {
        [self removePieceFromRow:currentRow - 1 andColumn:(currentCol > destinationCol ? currentCol - 1 : currentCol + 1)];
        blackCount--;
    }
    
    // Move the red piece on the gameboard, then send the tag so the gesture engine can moe the piece.
    gameBoard[currentRow][currentCol] = BoardCellStateEmpty;
    gameBoard[destinationRow][destinationCol] = BoardCellStateRedPiece;
    
    if (highestRed > destinationRow)
    {
        highestRed = destinationRow;
    }
    
    return destinationRow * 10 + destinationCol;
}

// When a player moves, their turn ends and the AI takes over.
- (void)endPlayerTurn
{
    [self removeAllCanMove];
    [self checkForRedWin];
    [self randomBlackMove];
    [self checkForBlackWin];
    [self findValidJumps:YES];
}

// Removes a piece, regardless of color, from the view and from the gameBoard matrix.
- (void)removePieceFromRow:(int)row andColumn:(int)col
{
    for (UIView *piece in self.subviews)
    {
        if (piece.tag == row * 10 + col)
        {
            [piece removeFromSuperview];
            gameBoard[row][col] = BoardCellStateEmpty;
        }
    }
}

// Cleans up the can move flags.
- (void)removeAllCanMove
{
    for (int row = 0; row < 8; row++)
    {
        for (int col = 0; col < 8; col++)
        {
            if (gameBoard[row][col] == BoardCellStateCanMove)
            {
                gameBoard[row][col] = BoardCellStateEmpty;
            }
        }
    }
}

// The "AI" of the game.  If there is a jump, the AI takes the first jump it finds.  If there is no jumps, then it
// will legally move randomly to an empty space.
- (void)randomBlackMove
{
    BOOL moveIsValid = NO;
    
    // If there is a jump, the findValidJumps will make the jump and set a flag so the random jump doesn't happen.
    // Yes, I probably should extract the AI jump from the find jump class.
    [self findValidJumps:NO];
    
    if (!canJump && blackCount != 0)
    {
        int randomRow;
        int randomCol;
        do
        {
            // We don't need all 8 rows for the random move because a piece all the way at the bottom of the
            // checkerboard cannot move anyways.
            randomRow = abs((int)arc4random() % 7);
            randomCol = abs((int)arc4random() % 8);
            
            // Checks to see if the piece we found is a black piece.  If it is, then it checks to see if the
            // piece can move.  If it cannot, we will roll a new piece.
            if (gameBoard[randomRow][randomCol] == BoardCellStateBlackPiece)
            {
                if ((randomCol != 7) && gameBoard[randomRow + 1][randomCol + 1] == BoardCellStateEmpty)
                {
                    moveIsValid = YES;
                    [self moveBlackPieceAtRow:randomRow andColumn:randomCol withColumnOffset:1 andFromJump:NO];
                }
                else if ((randomCol != 0) && gameBoard[randomRow + 1][randomCol - 1] == BoardCellStateEmpty)
                {
                    moveIsValid = YES;
                    [self moveBlackPieceAtRow:randomRow andColumn:randomCol withColumnOffset:-1 andFromJump:NO];
                }
            }
        } while (!moveIsValid);
    }
}

// Moves a black piece to a new position, taking into account jump offsets.
- (void)moveBlackPieceAtRow:(int)row andColumn:(int)col withColumnOffset:(int)colOffset andFromJump:(BOOL)isJump
{
    int jumpOffset = isJump ? 2 : 1;
    
    gameBoard[row][col] = BoardCellStateEmpty;
    gameBoard[row + jumpOffset][col + colOffset] = BoardCellStateBlackPiece;
    
    for (UIView *piece in self.subviews)
    {
        // Uses the tag to figure out if the piece is the correct piece, then moves the piece and sets the new tag.
        if (piece.tag == row * 10 + col)
        {
            CGRect tempFrame = piece.frame;
            tempFrame.origin.x = (col + colOffset) * pieceWidth + kBoardOffsetX;
            tempFrame.origin.y = (row + jumpOffset) * pieceHeight + kBoardOffsetY;
            piece.frame = tempFrame;
            piece.tag = (row + jumpOffset) * 10 + (col + colOffset);
            
            if (row + jumpOffset > highestBlack)
            {
                highestBlack = row + jumpOffset;
            }
            
            return;
        }
    }
}

// Debug function to print the matrix gameBoard to the console, if it is needed.
- (void)printBoard
{
    for (int i = 0; i < 8; i++)
    {
        NSString *tempString = @"";
        for (int j = 0; j < 8; j++)
        {
            tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%i ", gameBoard[i][j]]];
        }
        
        NSLog(@"%@", tempString);
    }
    NSLog(@" ");
}

// Finds all valid jumps for red, or finds the first jump for black.
- (void)findValidJumps:(BOOL)isRed
{
    canJump = NO;
    int rowOffset = isRed ? -1 : 1;
    BoardCellState friendPiece = isRed ? BoardCellStateRedPiece : BoardCellStateBlackPiece;
    
    // We don't need to search the entire board, since if a black piece isn't near the bottom red pieces or vice versa,
    // checking for a bottom or top row is just wasting performance.
    for (int row = MIN(highestBlack, highestRed - 1); row <= MAX(highestBlack + 1, highestRed); row++)
    {
        for (int col = 0; col < 8; col++)
        {
            if (gameBoard[row][col] == friendPiece)
            {
                BOOL rowCheck = isRed ? (row >= 2) : (row <= 5);
                BoardCellState enemyPiece = isRed ? BoardCellStateBlackPiece : BoardCellStateRedPiece;

                // This is where a 10x10 matrix would make things look nicer, since we wouldn't have to do a row or column
                // check.  We would only have to do a piece check, since an invalid space wouldn't fall into the if
                // statement.
                if ((col >= 2) && rowCheck && ((gameBoard[row + rowOffset][col - 1] == enemyPiece) && (gameBoard[row + (rowOffset * 2)][col - 2] == BoardCellStateEmpty)))
                {
                    canJump = YES;
                    
                    // If the turn is red, we are finding all the spaces that can be a jump.  If the turn is
                    // black, then we simply want the first jump and take it.
                    if (isRed)
                    {
                        gameBoard[row + (rowOffset * 2)][col - 2] = BoardCellStateCanMove;
                    }
                    else
                    {
                        [self jumpRedPieceAtRow:row andColumn:col withOffset: -1];
                        return;
                    }
                }

                if ((col <= 5) && rowCheck && ((gameBoard[row + rowOffset][col + 1] == enemyPiece) && (gameBoard[row + (rowOffset * 2)][col + 2] == BoardCellStateEmpty)))
                {
                    canJump = YES;
                    
                    if (isRed)
                    {
                        gameBoard[row + (rowOffset * 2)][col + 2] = BoardCellStateCanMove;
                    }
                    else
                    {
                        [self jumpRedPieceAtRow:row andColumn:col withOffset: 1];
                        return;
                    }
                }
            }
        }
    }
}

// The black jump, which removes a red piece from the board and moves the black piece in the correct position.
- (void)jumpRedPieceAtRow:(int)row andColumn:(int)col withOffset:(int)offset
{
    gameBoard[row + 1][col + offset] = BoardCellStateEmpty;
    [self removePieceFromRow:row + 1 andColumn:col + offset];
    redCount--;
    
    [self moveBlackPieceAtRow:row andColumn:col withColumnOffset:offset * 2 andFromJump:YES];
}

- (void)checkForRedWin
{
    if (blackCount == 0)
    {
        [delegate displayMessage:@"Red Wins"];
    }
}

- (void)checkForBlackWin
{
    if (redCount == 0)
    {
        [delegate displayMessage:@"Black Wins"];
    }
}

@end
