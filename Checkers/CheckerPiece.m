//
//  CheckerPiece.m
//  Checkers
//
//  Created by Robert Dohner on 2/2/15.
//  Copyright (c) 2015 Robert Dohner. All rights reserved.
//

#import "CheckerPiece.h"

@implementation CheckerPiece

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andState:(BoardCellState)state
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        currentState = state;
        
        if (state == BoardCellStateBlackPiece)
        {
            self.image = [UIImage imageNamed:@"black.png"];
        }
        else
        {
            self.image = [UIImage imageNamed:@"red.png"];
            
            // The gesture recognizer used for moving pieces.  Since red is the only player, we only need
            // to give the red pieces the ability to move.
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pieceMoved:)];
            [panRecognizer setMinimumNumberOfTouches:1];
            [panRecognizer setMaximumNumberOfTouches:1];
            [panRecognizer setDelegate:self];
            [self addGestureRecognizer:panRecognizer];
            
            self.userInteractionEnabled = YES;
        }
    }

    return self;
}

// The UIPanGestureRecognizer selector, handles both the beginning touch and the ending touch.
- (void)pieceMoved:(id)sender
{
    // If this is the first touch, we need to get the initial position in case of an invalid move.
    if ([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan)
    {
        initialX = [[sender view] center].x;
        initialY = [[sender view] center].y;
    }
    
    // Get the translated point from the recognizer.
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    
    // Turn the translated point into a new point based off of the initial position and then center the piece at
    // that point.
    translatedPoint = CGPointMake(initialX + translatedPoint.x, initialY + translatedPoint.y);
    [[sender view] setCenter:translatedPoint];
    
    // If this is the last touch, we need to see if the move was valid.
    if ([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateEnded)
    {
        // Ensure that the piece is still on the checkboard.  There is no need to do any other checks if the piece
        // is not on the board.  If the gameBoard matrix was a 10x10 with invalid squares around it, theoretically,
        // this check wouldn't be needed.
        if ((self.frame.origin.x > 0) && (self.frame.origin.x < self.frame.size.width * 9) && (self.frame.origin.y > 0) && (self.frame.origin. y < self.frame.size.height * 9))
        {
            // Get the normalized X and Y, to make the piece settle in to its spot on the board if it is valid.
            int normalizedX = [self normalizeValue:self.frame.origin.x andIsX:YES];
            int normalizedY = [self normalizeValue:self.frame.origin.y andIsX:NO];
        
            // newTag will be -1 if the move is invalid, otherwise, the move is valid and newTag is the current
            // location tag of the piece.  Then we need to set the new tag, move the piece, and then end the turn.
            int newTag = [delegate isMoveValid:self.tag withX:normalizedX andY:normalizedY];
            if (newTag >= 0)
            {
                self.tag = newTag;
                CGRect newFrame = self.frame;
                newFrame.origin.x = normalizedX;
                newFrame.origin.y = normalizedY;
                self.frame = newFrame;
                [delegate endPlayerTurn];
                return;
            }
        }
        
        // If the movement was invalid for whatever reason, we move the piece back into its original position.
        translatedPoint = CGPointMake(initialX, initialY);
        [[sender view] setCenter:translatedPoint];
    }
}

// Function used to find the correct placement of the piece, since we don't want users placing their pieces all over the
// checkerboard.
- (int)normalizeValue:(int)currentValue andIsX:(BOOL)isX
{
    int tempValue = (int)(currentValue / self.frame.size.width);
    return isX ? ((tempValue * self.frame.size.width) + kBoardOffsetX) : ((tempValue * self.frame.size.height) + kBoardOffsetY);
}

@end
