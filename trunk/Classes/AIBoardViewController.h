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

#import "BoardViewController.h"
#import "AIRobot.h";

@interface AIBoardViewController : BoardViewController<AIRobotDelegate, UIActionSheetDelegate>
{
    NSTimer*     _idleTimer;
    AIRobot*     _aiRobot;

    UIBarButtonItem*         _actionButton;
    UIActivityIndicatorView* _aiThinkingActivity;
    UIBarButtonItem*         _aiThinkingButton;

    UIBarButtonItem*         _reverseRoleButton;
}

@property (nonatomic, retain) NSTimer* _idleTimer;

- (IBAction)homePressed:(id)sender;
- (IBAction)resetPressed:(id)sender;

- (void) handleNewMove:(NSNumber *)pMove;
- (void) onLocalMoveMade:(int)move gameResult:(int)nGameResult;
- (void) saveGame;

@end
