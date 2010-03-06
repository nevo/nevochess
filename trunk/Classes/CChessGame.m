/***************************************************************************
 *  Copyright 2009-2010 Nevo Hua  <nevo.hua@playxiangqi.com>               *
 *                                                                         * 
 *  This file is part of NevoChess.                                        *
 *                                                                         *
 *  NevoChess is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                    *
 *                                                                         *
 *  NevoChess is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with NevoChess.  If not, see <http://www.gnu.org/licenses/>.     *
 ***************************************************************************/


#import "CChessGame.h"
#import "Piece.h"
#import "QuartzUtils.h"
#import "XiangQi.h"  // XQWLight Objective-C based AI

///////////////////////////////////////////////////////////////////////////////
//
//    Private methods
//
///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark The private interface of CChessGame

@interface CChessGame (PrivateMethods)

- (void) _setupPieces;
- (void) _resetPieces;
- (void) _createPiece:(NSString*)imageName row:(int)row col:(int)col color:(ColorEnum)color;
- (void) _setPiece:(Piece*)piece toRow:(int)row toCol:(int)col;
- (void) _checkAndUpdateGameStatus;

@end


///////////////////////////////////////////////////////////////////////////////
//
//    Implementation of Public methods
//
///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark The implementation of the interface of CChessGame

@implementation CChessGame

@synthesize gameResult=_gameResult;
@synthesize blackAtTopSide=_blackAtTopSide;

- (id) initWithBoard:(CALayer*)board boardType:(int)boardType
{
    if (self = [super init])
    {
        _board = [board retain];
        
        CGFloat    cellSize = 33;
        CGPoint    cellOffset = CGPointMake(2, 3);
        CGPoint    boardOffset = CGPointMake(5, 32);
        CGColorRef backgroundColor = nil;
        CGColorRef highlightColor  = kLightBlueColor;
        CGColorRef animateColor    = kLightBlueColor;
        
        switch (boardType)
        {
            case 1:  // SKELETON background.
            {
                backgroundColor = GetCGPatternNamed(@"SKELETON.png");
                break;
            }
            case 2:  // HOXChess background.
            {
                backgroundColor = GetCGPatternNamed(@"HOXChess.png");
                cellSize = 34;
                cellOffset = CGPointMake(7, 1);
                boardOffset = CGPointMake(2, 28);
                break;
            }
            case 3:  // WOOD background.
            {
                backgroundColor = GetCGPatternNamed(@"WOOD.png");
                break;
            }
            default: // The custom-drawn background.
            {
                _board.backgroundColor = GetCGPatternNamed(@"board_320x480.png");
                cellSize = 34;
                highlightColor  = kHighlightColor;
                animateColor    = kHighlightColor;
                break;
            }
        }
        
        CGSize spacing = CGSizeMake(cellSize, cellSize);
        CGPoint pos = CGPointMake(board.bounds.origin.x + boardOffset.x,
                                  board.bounds.origin.y + boardOffset.y);
        _grid = [[Grid alloc] initWithRows:10 columns:9
                                   spacing:spacing position:pos
                                cellOffset:cellOffset
                           backgroundColor:backgroundColor];
        _grid.highlightColor = highlightColor;
        _grid.animateColor = animateColor;
        
        //_grid.borderColor = kTranslucentLightGrayColor;
        //_grid.borderWidth = 2;
        
        [_grid addAllCells];
        [_board addSublayer:_grid];
        
        _pieceBox = [[NSMutableArray alloc] initWithCapacity:32];
        [self _setupPieces];
        
        [_grid cellAtRow: 3 column: 0].dotted = YES;
        [_grid cellAtRow: 6 column: 0].dotted = YES;
        [_grid cellAtRow: 2 column: 1].dotted = YES;
        [_grid cellAtRow: 7 column: 1].dotted = YES;
        [_grid cellAtRow: 3 column: 2].dotted = YES;
        [_grid cellAtRow: 6 column: 2].dotted = YES;
        [_grid cellAtRow: 3 column: 4].dotted = YES;
        [_grid cellAtRow: 6 column: 4].dotted = YES;
        [_grid cellAtRow: 3 column: 6].dotted = YES;
        [_grid cellAtRow: 6 column: 6].dotted = YES;
        [_grid cellAtRow: 2 column: 7].dotted = YES;
        [_grid cellAtRow: 7 column: 7].dotted = YES;
        [_grid cellAtRow: 3 column: 8].dotted = YES;
        [_grid cellAtRow: 6 column: 8].dotted = YES;
        
        [_grid cellAtRow: 1 column: 4].cross = YES;
        [_grid cellAtRow: 8 column: 4].cross = YES;
        
        _blackAtTopSide = YES;
        _gameResult = NC_GAME_STATUS_IN_PROGRESS;
        
        // Create a Referee to manage the Game.
        _referee = [[Referee alloc] init];
        [_referee initGame];
    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"%s: ENTER.", __FUNCTION__);
    [_grid removeAllCells];
    [_grid release];
    [_pieceBox release];
    [_referee release];
    [_board release];
    _board = nil;    
    [super dealloc];
}


#pragma mark -
#pragma mark Piece/Cell Public API

- (void) movePiece:(Piece*)piece toPosition:(Position)position
          animated:(BOOL)animated;
{
    int row = position.row, col = position.col;
    if (!_blackAtTopSide) {
        row = 9 - row;
        col = 8 - col;
    }
    GridCell* newCell = [_grid cellAtRow:row column:col];
    CGPoint newPosition = [newCell getMidInLayer:_board];
    piece.holder = newCell;
    [piece movePieceTo:newPosition animated:animated];
}

- (void) movePiece:(Piece*)piece toRow:(int)row toCol:(int)col
{
    if (!_blackAtTopSide) {
        row = 9 - row;
        col = 8 - col;
    }
    [self _setPiece:piece toRow:row toCol:col];
}

- (Piece*) getPieceAtRow:(int)row col:(int)col
{
    if (!_blackAtTopSide) {
        row = 9 - row;
        col = 8 - col;
    }
    GridCell* cell = [_grid cellAtRow:row column:col]; 
    CALayer* piece = [_board hitTest:[cell getMidInLayer:_board]];
    if (piece && [piece isKindOfClass:[Piece class]]) {
        return (Piece*)piece;
    }
    
    return nil;
}

- (Piece*) getPieceAtCell:(int)square
{
    return [self getPieceAtRow:ROW(square) col:COLUMN(square)];
}

- (GridCell*) getCellAtRow:(int)row col:(int)col
{
    if (!_blackAtTopSide) {
        row = 9 - row;
        col = 8 - col;
    }
    GridCell* cell = [_grid cellAtRow:row column:col];
    return cell;
}

- (GridCell*) getCellAt:(int)square
{
    return [self getCellAtRow:ROW(square) col:COLUMN(square)];
}

- (Position) getActualPositionAtCell:(GridCell*)cell
{
    int row = cell.row, col = cell.column;
    if (!self.blackAtTopSide) {
        row = 9 - row;
        col = 8 - col;
    }
    Position position = { row, col };
    return position;
}

#pragma mark -
#pragma mark Move/Game Public API

- (int) doMoveFrom:(Position)from toPosition:(Position)to
{
    int sqSrc = TOSQUARE(from.row, from.col);
    int sqDst = TOSQUARE(to.row, to.col);
    int move = MOVE(sqSrc, sqDst);
    int captured = 0;
    
    [_referee makeMove:move captured:&captured];
    [self _checkAndUpdateGameStatus];
    
    return captured;
}

- (int) generateMoveFrom:(Position)from moves:(int*)mvs
{
    int sqSrc = TOSQUARE(from.row, from.col);
    return [_referee generateMoveFrom:sqSrc moves:mvs];
}

- (BOOL) isMoveLegalFrom:(Position)from toPosition:(Position)to
{
    int sqSrc = TOSQUARE(from.row, from.col);
    int sqDst = TOSQUARE(to.row, to.col);
    int move = MOVE(sqSrc, sqDst);
    return [_referee isLegalMove:move];
}

- (ColorEnum) getNextColor
{
    return [_referee get_sdPlayer] ? NC_COLOR_BLACK : NC_COLOR_RED;
}

- (int) getMoveCount { return [_referee get_nMoveNum]; }

- (void) resetGame
{
    BOOL saved_blackAtTopSide = _blackAtTopSide;
    _blackAtTopSide = YES;
    [self _resetPieces];
    if (!saved_blackAtTopSide) {
        [self reverseView];
    }
    _blackAtTopSide = saved_blackAtTopSide;
    
    [_referee initGame];
    _gameResult = NC_GAME_STATUS_IN_PROGRESS;
}

- (void) reverseView
{
    for (Piece* piece in _pieceBox) {
        if (piece.superlayer) { // not captured?
            GridCell* holder = piece.holder;
            unsigned row = 9 - holder.row;
            unsigned column = 8 - holder.column;
            [self _setPiece:piece toRow:row toCol:column];
        }
    }
    _blackAtTopSide = !_blackAtTopSide;
}

- (void) highlightCell:(int)cell highlight:(BOOL)bHighlight
{
    [self getCellAtRow:ROW(cell) col:COLUMN(cell)].highlighted = bHighlight;
}

#pragma mark -
#pragma mark Private API


- (void) _createPiece:(NSString*)imageName row:(int)row col:(int)col color:(ColorEnum)color
{
    imageName = [[NSBundle mainBundle] pathForResource:imageName ofType:nil
                                           inDirectory:_pieceFolder];
    GridCell* cell = [_grid cellAtRow:row column:col]; 
    Piece* piece = [[Piece alloc] initWithColor:color imageName:imageName
                                          scale:_grid.spacing.width];
    piece.holder = cell;
    [_board addSublayer:piece];
    piece.position = [cell getMidInLayer:_board];
    [_pieceBox addObject:piece];
    [piece release];
}

- (void) _setPiece:(Piece*)piece toRow:(int)row toCol:(int)col
{
    GridCell* cell = [_grid cellAtRow:row column:col]; 
    piece.position = [cell getMidInLayer:_board];
    piece.holder = cell;
    if (!piece.superlayer) {
        [piece putbackInLayer:_board]; // Restore the captured piece.
    }
}

- (void) _checkAndUpdateGameStatus
{
    BOOL redMoved = (self.nextColor == NC_COLOR_BLACK); // Red just moved?
    int nRepVal = 0;

    if ( [_referee isMate] ) {
        _gameResult = (redMoved ? NC_GAME_STATUS_RED_WIN : NC_GAME_STATUS_BLACK_WIN);
    }
    else if ([_referee repStatus:3 repValue:&nRepVal] > 0) // Check repeat status
    {
        if (redMoved) {
            _gameResult = nRepVal < -WIN_VALUE ? NC_GAME_STATUS_RED_WIN 
                : (nRepVal > WIN_VALUE ? NC_GAME_STATUS_BLACK_WIN : NC_GAME_STATUS_DRAWN);
        } else {
            _gameResult = nRepVal > WIN_VALUE ? NC_GAME_STATUS_RED_WIN 
                : (nRepVal < -WIN_VALUE ? NC_GAME_STATUS_BLACK_WIN : NC_GAME_STATUS_DRAWN);
        }
    }
    else if ([_referee get_nMoveNum] > NC_MAX_MOVES_PER_GAME) {
        _gameResult = NC_GAME_STATUS_TOO_MANY_MOVES;
    }
}

- (void) _resetPieces
{
    // reset the pieces in pieceBox by the order they are created
    // chariot
    [self movePiece:[_pieceBox objectAtIndex:0] toRow:0 toCol:0];
    [self movePiece:[_pieceBox objectAtIndex:1] toRow:0 toCol:8];
    [self movePiece:[_pieceBox objectAtIndex:2] toRow:9 toCol:0];
    [self movePiece:[_pieceBox objectAtIndex:3] toRow:9 toCol:8];
    
    // horse
    [self movePiece:[_pieceBox objectAtIndex:4] toRow:0 toCol:1];
    [self movePiece:[_pieceBox objectAtIndex:5] toRow:0 toCol:7];
    [self movePiece:[_pieceBox objectAtIndex:6] toRow:9 toCol:1];
    [self movePiece:[_pieceBox objectAtIndex:7] toRow:9 toCol:7];
    
    // elephant
    [self movePiece:[_pieceBox objectAtIndex:8] toRow:0 toCol:2];
    [self movePiece:[_pieceBox objectAtIndex:9] toRow:0 toCol:6];
    [self movePiece:[_pieceBox objectAtIndex:10] toRow:9 toCol:2];
    [self movePiece:[_pieceBox objectAtIndex:11] toRow:9 toCol:6];
    
    // advisor
    [self movePiece:[_pieceBox objectAtIndex:12] toRow:0 toCol:3];
    [self movePiece:[_pieceBox objectAtIndex:13] toRow:0 toCol:5];
    [self movePiece:[_pieceBox objectAtIndex:14] toRow:9 toCol:3];
    [self movePiece:[_pieceBox objectAtIndex:15] toRow:9 toCol:5];
    
    // king
    [self movePiece:[_pieceBox objectAtIndex:16] toRow:0 toCol:4];
    [self movePiece:[_pieceBox objectAtIndex:17] toRow:9 toCol:4];
    
    // cannon
    [self movePiece:[_pieceBox objectAtIndex:18] toRow:2 toCol:1];
    [self movePiece:[_pieceBox objectAtIndex:19] toRow:2 toCol:7];
    [self movePiece:[_pieceBox objectAtIndex:20] toRow:7 toCol:1];
    [self movePiece:[_pieceBox objectAtIndex:21] toRow:7 toCol:7];
    
    // pawn
    [self movePiece:[_pieceBox objectAtIndex:22] toRow:3 toCol:0];
    [self movePiece:[_pieceBox objectAtIndex:23] toRow:3 toCol:2];
    [self movePiece:[_pieceBox objectAtIndex:24] toRow:3 toCol:4];
    [self movePiece:[_pieceBox objectAtIndex:25] toRow:3 toCol:6];
    [self movePiece:[_pieceBox objectAtIndex:26] toRow:3 toCol:8];
    [self movePiece:[_pieceBox objectAtIndex:27] toRow:6 toCol:0];
    [self movePiece:[_pieceBox objectAtIndex:28] toRow:6 toCol:2];
    [self movePiece:[_pieceBox objectAtIndex:29] toRow:6 toCol:4];
    [self movePiece:[_pieceBox objectAtIndex:30] toRow:6 toCol:6];
    [self movePiece:[_pieceBox objectAtIndex:31] toRow:6 toCol:8];
}

- (void) _setupPieces
{
    _pieceFolder = nil;
    NSInteger pieceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"piece_type"];
    switch (pieceType) {
        case 0: _pieceFolder = @"pieces/xqwizard_31x31"; break;
        case 1: _pieceFolder = @"pieces/alfaerie_31x31"; break;
        case 2: _pieceFolder = @"pieces/HOXChess"; break;
        default: _pieceFolder = @"pieces/iXiangQi"; break;
    }

    // chariot      
    [self _createPiece:@"bchariot.png" row:0 col:0 color:NC_COLOR_BLACK];
    [self _createPiece:@"bchariot.png" row:0 col:8 color:NC_COLOR_BLACK];         
    [self _createPiece:@"rchariot.png" row:9 col:0 color:NC_COLOR_RED];     
    [self _createPiece:@"rchariot.png" row:9 col:8 color:NC_COLOR_RED];  

    // horse    
    [self _createPiece:@"bhorse.png" row:0 col:1 color:NC_COLOR_BLACK];        
    [self _createPiece:@"bhorse.png" row:0 col:7 color:NC_COLOR_BLACK];         
    [self _createPiece:@"rhorse.png" row:9 col:1 color:NC_COLOR_RED];      
    [self _createPiece:@"rhorse.png" row:9 col:7 color:NC_COLOR_RED];
    
    // elephant      
    [self _createPiece:@"belephant.png" row:0 col:2 color:NC_COLOR_BLACK];        
    [self _createPiece:@"belephant.png" row:0 col:6 color:NC_COLOR_BLACK];        
    [self _createPiece:@"relephant.png" row:9 col:2 color:NC_COLOR_RED];     
    [self _createPiece:@"relephant.png" row:9 col:6 color:NC_COLOR_RED]; 
    
    // advisor      
    [self _createPiece:@"badvisor.png" row:0 col:3 color:NC_COLOR_BLACK];         
    [self _createPiece:@"badvisor.png" row:0 col:5 color:NC_COLOR_BLACK];         
    [self _createPiece:@"radvisor.png" row:9 col:3 color:NC_COLOR_RED];        
    [self _createPiece:@"radvisor.png" row:9 col:5 color:NC_COLOR_RED];
    
    // king       
    [self _createPiece:@"bking.png" row:0 col:4 color:NC_COLOR_BLACK];       
    [self _createPiece:@"rking.png" row:9 col:4 color:NC_COLOR_RED];
    
    // cannon     
    [self _createPiece:@"bcannon.png" row:2 col:1 color:NC_COLOR_BLACK];       
    [self _createPiece:@"bcannon.png" row:2 col:7 color:NC_COLOR_BLACK];          
    [self _createPiece:@"rcannon.png" row:7 col:1 color:NC_COLOR_RED];        
    [self _createPiece:@"rcannon.png" row:7 col:7 color:NC_COLOR_RED];

    // pawn       
    [self _createPiece:@"bpawn.png" row:3 col:0 color:NC_COLOR_BLACK];         
    [self _createPiece:@"bpawn.png" row:3 col:2 color:NC_COLOR_BLACK];         
    [self _createPiece:@"bpawn.png" row:3 col:4 color:NC_COLOR_BLACK];        
    [self _createPiece:@"bpawn.png" row:3 col:6 color:NC_COLOR_BLACK];      
    [self _createPiece:@"bpawn.png" row:3 col:8 color:NC_COLOR_BLACK];     
    [self _createPiece:@"rpawn.png" row:6 col:0 color:NC_COLOR_RED];      
    [self _createPiece:@"rpawn.png" row:6 col:2 color:NC_COLOR_RED];         
    [self _createPiece:@"rpawn.png" row:6 col:4 color:NC_COLOR_RED];       
    [self _createPiece:@"rpawn.png" row:6 col:6 color:NC_COLOR_RED];      
    [self _createPiece:@"rpawn.png" row:6 col:8 color:NC_COLOR_RED];
}

@end
