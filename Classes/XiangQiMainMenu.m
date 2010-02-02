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

#import "XiangQiMainMenu.h"
#import "ChessBoardViewController.h"
#import "NetworkBoardViewController.h"
#import "AboutViewController.h"
#import "OptionsViewController.h"

@implementation XiangQiMainMenu

@synthesize new_game;
@synthesize setting;
@synthesize about;
@synthesize bg_view;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Home", @"");
    [new_game setTitle:NSLocalizedString(@"Home_Play", @"") forState:UIControlStateNormal];
    [about setTitle:NSLocalizedString(@"Home_About", @"") forState:UIControlStateNormal];
    [setting setTitle:NSLocalizedString(@"Home_Settings", @"") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [new_game release];
    [setting release];
    [about release];
    [bg_view release];
    [super dealloc];
}

- (IBAction)newGamePressed:(id)sender
{
    ChessBoardViewController *chessboard = [[ChessBoardViewController alloc] initWithNibName:@"ChessBoardViewController" bundle:nil];
    [self.navigationController pushViewController:chessboard animated:YES];
    [chessboard release];
}

- (IBAction)networkGamePressed:(id)sender
{
    NetworkBoardViewController *chessboard = [[NetworkBoardViewController alloc] initWithNibName:@"ChessBoardViewController" bundle:nil];
    [self.navigationController pushViewController:chessboard animated:YES];
    [chessboard release];
}

- (IBAction)aboutPressed:(id)sender
{
    AboutViewController *aboutController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:aboutController animated:YES];
    [aboutController release];      
}

- (IBAction)settingPressed:(id)sender
{
    OptionsViewController *optionController = [[OptionsViewController alloc] initWithNibName:@"OptionsView" bundle:nil];
    [self.navigationController pushViewController:optionController animated:YES];
    [optionController release];
    
}


@end
