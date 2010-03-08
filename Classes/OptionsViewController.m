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

#import "OptionsViewController.h"
#import "AboutViewController.h"
#import "AudioHelper.h"

enum ViewTagEnum
{
    VIEW_TAG_BOARD_STYLE  = 1,  // The tags must be non-zero.
    VIEW_TAG_PIECE_STYLE,
    VIEW_TAG_AI_TYPE,
    VIEW_TAG_AI_LEVEL
};

@implementation OptionsViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", @"");

    _soundSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound_on"];

    // --- Piece Type.
    _pieceChoices = [[NSArray alloc] initWithObjects:
                                        NSLocalizedString(@"Default", @""),
                                        NSLocalizedString(@"Western", @""),
                                        @"HOXChess",
                                        @"iXiangQi",
                                        nil];
    _pieceType = [[NSUserDefaults standardUserDefaults] integerForKey:@"piece_type"];
    if (_pieceType >= [_pieceChoices count]) { _pieceType = 0; }

    // --- Board Type.
    _boardChoices = [[NSArray alloc] initWithObjects:
                                        NSLocalizedString(@"Default", @""),
                                        NSLocalizedString(@"Skeleton", @""),
                                        NSLocalizedString(@"HOXChess", @""),
                                        NSLocalizedString(@"Wood", @""),
                                        nil];
    _boardType = [[NSUserDefaults standardUserDefaults] integerForKey:@"board_type"];
    if (_boardType >= [_boardChoices count]) { _boardType = 0; }

    // --- AI Level
    _aiLevelChoices = [[NSArray alloc] initWithObjects:
                                        NSLocalizedString(@"Easy", @""),
                                        NSLocalizedString(@"Normal", @""),
                                        NSLocalizedString(@"Hard", @""),
                                        NSLocalizedString(@"Master", @""),
                                        nil];
    _aiLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"ai_level"];
    if (_aiLevel >= [_aiLevelChoices count]) { _aiLevel = 0; }

    // --- AI Type
    _aiTypeChoices = [[NSArray alloc] initWithObjects:
                                        @"XQWLight",
                                        @"HaQiKiD",
#ifdef ENABLE_XQWLIGHT_OBJC
                                        @"XQWLightObjc",
#endif
                                        nil];
    NSString* aiStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"ai_type"];
    _aiType = [_aiTypeChoices indexOfObject:aiStr];
    if (_aiType == NSNotFound) { _aiType = 0; }

    // --- Network
    _username = [[NSUserDefaults standardUserDefaults] stringForKey:@"network_username"];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) {
        case 0: return 3;
        case 1: return 2;
        case 2: return 1;
        case 3: return 1;
    }
    return 0;
}

- (UIImage*) _getImageNamed:(NSString*)name
{
    NSString* imageName = [[NSBundle mainBundle] pathForResource:name
                                                          ofType:@"png"
                                                     inDirectory:nil];
    UIImage* theImage = [UIImage imageWithContentsOfFile:imageName];
    return theImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell* cell = nil;
    UILabel*         theLabel = nil;
    UILabel*         theValue = nil;
    UIFont*          defaultFont = [UIFont boldSystemFontOfSize:17.0];
    
    switch (indexPath.section)
    {
        case 0: // ----- General
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell = _soundCell;
                    theLabel = (UILabel *)[cell viewWithTag:1];
                    theLabel.font = defaultFont;
                    theLabel.text  = NSLocalizedString(@"Sound", @"");
                    break;
                }
                case 1:   // - Board
                {
                    cell = _boardCell;
                    theLabel = (UILabel *)[cell viewWithTag:1];
                    theLabel.font = defaultFont;
                    theLabel.text  = NSLocalizedString(@"Board", @"");
                    theValue = (UILabel *)[cell viewWithTag:2];
                    theValue.text = [_boardChoices objectAtIndex:_boardType];
                    break;
                }
                case 2:  // - Piece
                {
                    cell = _pieceCell;
                    theLabel = (UILabel *)[cell viewWithTag:1];
                    theLabel.font = defaultFont;
                    theLabel.text  = NSLocalizedString(@"Piece", @"");
                    theValue = (UILabel *)[cell viewWithTag:2];
                    theValue.text = [_pieceChoices objectAtIndex:_pieceType];
                    break;
                }
            }
            break;
        }
        case 1:  // ----- AI
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell = _aiTypeCell;
                    theLabel = (UILabel *)[cell viewWithTag:1];
                    theLabel.font = defaultFont;
                    theLabel.text  = NSLocalizedString(@"AI Type", @"");
                    theValue = (UILabel *)[cell viewWithTag:2];
                    theValue.text = [_aiTypeChoices objectAtIndex:_aiType];
                    break;
                }
                case 1:
                {
                    cell = _aiLevelCell;
                    theLabel = (UILabel *)[cell viewWithTag:1];
                    theLabel.font = defaultFont;
                    theLabel.text  = NSLocalizedString(@"AI Level", @"");
                    theValue = (UILabel *)[cell viewWithTag:2];
                    theValue.text = [_aiLevelChoices objectAtIndex:_aiLevel];
                    break;
                }

            }
            break;
        }
        case 2: // ----- Network
        {            
            cell = _networkCell;
            theLabel = (UILabel *)[cell viewWithTag:1];
            theLabel.font = defaultFont;
            theLabel.text  = NSLocalizedString(@"Network", @"");
            theValue = (UILabel *)[cell viewWithTag:2];
            theValue.text = _username;
            break;
        }
        case 3: // ----- About
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"about_cell"];
            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"about_cell"] autorelease];
                cell.textLabel.font = defaultFont;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = NSLocalizedString(@"About", @"");
            cell.imageView.image = [self _getImageNamed:@"help"];
            break;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewController* subController = nil;

    switch (indexPath.section)
    {
        case 0: // ----- General
        {
            switch (indexPath.row)
            {
                case 1:  // - Board
                {
                    NSArray* boards = [NSArray arrayWithObjects:@"board_60px",
                                        @"SKELETON_60px", @"HOXChess_60px", @"WOOD_60px", nil];
                    NSMutableArray* imageNames = [[NSMutableArray alloc] initWithCapacity:[boards count]];
                    for (NSString* name in boards)
                    {
                        NSString* path = [[NSBundle mainBundle] pathForResource:name
                                                                         ofType:@"png"
                                                                    inDirectory:nil];
                        [imageNames addObject:path];
                    }

                    SingleSelectionController* controller =
                        [[SingleSelectionController alloc] initWithChoices:_boardChoices
                                                                imageNames:imageNames
                                                                  delegate:self];
                    [imageNames release];
                    [controller setRowHeight:80];
                    subController = controller;
                    controller.title = ((UILabel*)[_boardCell viewWithTag:1]).text;
                    controller.selectionIndex = _boardType;
                    controller.tag = VIEW_TAG_BOARD_STYLE;
                    break;
                }
                case 2:  // - Piece
                {
                    NSArray* piecePaths = [NSArray arrayWithObjects:@"pieces/xqwizard_31x31",
                                           @"pieces/alfaerie_31x31", @"pieces/HOXChess", @"pieces/iXiangQi",
                                           nil];
                    NSMutableArray* imageNames = [[NSMutableArray alloc] initWithCapacity:[piecePaths count]];
                    for (NSString* subPath in piecePaths)
                    {
                        NSString* path = [[NSBundle mainBundle] pathForResource:@"rking"
                                                                         ofType:@"png"
                                                                    inDirectory:subPath];
                        [imageNames addObject:path];
                    }
                    
                    SingleSelectionController* controller =
                    [[SingleSelectionController alloc] initWithChoices:_pieceChoices
                                                            imageNames:imageNames
                                                              delegate:self];
                    [imageNames release];
                    [controller setRowHeight:50];
                    subController = controller;
                    controller.title = ((UILabel*)[_pieceCell viewWithTag:1]).text;
                    controller.selectionIndex = _pieceType;
                    controller.tag = VIEW_TAG_PIECE_STYLE;
                    break;
                }
            }
            break;
        }
        case 1: // ----- AI
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SingleSelectionController* controller =
                        [[SingleSelectionController alloc] initWithChoices:_aiTypeChoices
                                                                imageNames:nil
                                                                  delegate:self];
                    subController = controller;
                    controller.title = ((UILabel*)[_aiTypeCell viewWithTag:1]).text;
                    controller.selectionIndex = _aiType;
                    controller.tag = VIEW_TAG_AI_TYPE;
                    break;
                }
                case 1:
                {
                    SingleSelectionController* controller =
                    [[SingleSelectionController alloc] initWithChoices:_aiLevelChoices
                                                            imageNames:nil
                                                              delegate:self];
                    subController = controller;
                    controller.title = ((UILabel*)[_aiLevelCell viewWithTag:1]).text;
                    controller.selectionIndex = _aiLevel;
                    controller.tag = VIEW_TAG_AI_LEVEL;
                    break;
                }
            }
            break;
        }
        case 2: // ----- Network
        {
            subController = [[NetworkSettingController alloc] initWithNibName:@"NetworkSettingView" bundle:nil];
            ((NetworkSettingController*)subController).delegate = self;
            break;
        }
        case 3: // ----- About
        {
            subController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            break;
        }
    }

    if (subController) {
        [self.navigationController pushViewController:subController animated:YES];
        [subController release];
    }
}

- (void)dealloc 
{
    [_pieceChoices release];
    [_boardChoices release];
    [_aiLevelChoices release];
    [_aiTypeChoices release];
    [super dealloc];
}

#pragma mark -
#pragma mark SingleSelectionDelegate methods

- (void) didSelect:(SingleSelectionController*)controller rowAtIndex:(NSUInteger)index
{
    switch (controller.tag)
    {
        case VIEW_TAG_BOARD_STYLE:
        {
            if (_boardType != index)
            {
                _boardType = index;
                UILabel* theValue = (UILabel *)[_boardCell viewWithTag:2];
                theValue.text = [_boardChoices objectAtIndex:_boardType];
                [[NSUserDefaults standardUserDefaults] setInteger:_boardType forKey:@"board_type"];
            }
            break;
        }
        case VIEW_TAG_PIECE_STYLE:
        {
            if (_pieceType != index)
            {
                _pieceType = index;
                UILabel* theValue = (UILabel *)[_pieceCell viewWithTag:2];
                theValue.text = [_pieceChoices objectAtIndex:_pieceType];
                [[NSUserDefaults standardUserDefaults] setInteger:_pieceType forKey:@"piece_type"];
            }
            break;
        }
        case VIEW_TAG_AI_TYPE:
        {
            if (_aiType != index)
            {
                _aiType = index;
                UILabel* theValue = (UILabel *)[_aiTypeCell viewWithTag:2];
                theValue.text = [_aiTypeChoices objectAtIndex:_aiType];
                [[NSUserDefaults standardUserDefaults] setObject:[_aiTypeChoices objectAtIndex:_aiType] forKey:@"ai_type"];
            }
            break;
        }
        case VIEW_TAG_AI_LEVEL:
        {
            if (_aiLevel != index)
            {
                _aiLevel = index;
                UILabel* theValue = (UILabel *)[_aiLevelCell viewWithTag:2];
                theValue.text = [_aiLevelChoices objectAtIndex:_aiLevel];
                [[NSUserDefaults standardUserDefaults] setInteger:_aiLevel forKey:@"ai_level"];
            }
            break;
        }
    }
}

#pragma mark -
#pragma mark SingleSelectionDelegate methods

- (void) didChangeUsername:(NetworkSettingController*)controller username:(NSString*)username
{
    UILabel* theValue = (UILabel *)[_networkCell viewWithTag:2];
    theValue.text = username;
}

#pragma mark Event handlers

- (IBAction) autoConnectValueChanged:(id)sender
{    
    [[NSUserDefaults standardUserDefaults] setBool:_soundSwitch.on forKey:@"sound_on"];
    [AudioHelper sharedInstance].enabled = _soundSwitch.on;
}

@end

