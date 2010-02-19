/*

File: Piece.h

Abstract: A playing piece. A concrete subclass of Bit that displays an image..

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright © 2007 Apple Inc. All Rights Reserved.

*/

#import <QuartzCore/QuartzCore.h>
#import "Enums.h"

@class GridCell;

/** Standard Z positions */
enum {
    kBoardZ = 1,
    kCardZ  = 2,
    kPieceZ = 3,
    
    kPickedUpZ = 100
};


/** A moveable item in a card/board game.
 Abstract superclass of Card and Piece. */
@interface Bit : CALayer
{
    int         _restingZ;  // Original z position, saved while pickedUp
    GridCell*   holder;
}

/** Conveniences for getting/setting the layer's scale and rotation */
@property CGFloat scale;
@property int rotation;         // in degrees! Positive = clockwise

/** "Picking up" a Bit makes it larger, translucent, and in front of everything else */
@property BOOL pickedUp;

/** Current holder (or nil) */
@property (nonatomic, retain) GridCell *holder;

/** Removes this Bit while running a explosion/fade-out animation */
- (void) destroy;

@end


/** A playing piece. A concrete subclass of Bit that displays an image. */
@interface Piece : Bit
{
    ColorEnum  _color;
    NSString*  _imageName;
}

/** Initialize a Piece from an image file.
    imageName can be a resource name from the app bundle, or an absolute path.
    If scale is 0.0, the image's natural size will be used.
    If 0.0 < scale < 4.0, the image will be scaled by that factor.
    If scale >= 4.0, it will be used as the size to scale the maximum dimension to. */
- (id) initWithImageNamed:(NSString*)imageName scale:(CGFloat)scale;

- (void) setImage:(CGImageRef)image scale:(CGFloat)scale;
- (void) setImage:(CGImageRef)image;
- (void) setImageNamed:(NSString*)name;

@property (nonatomic)         ColorEnum color;
@property (nonatomic, retain) NSString* _imageName;

@end
