//
//  CCCrissCrossBoard.h
//  CrissCrossLogic
//
//  Created by Oliver Letterer on 08.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CCBridge.h"
#import "CCField.h"

@class CCPlayer;

typedef struct {
    NSUInteger verticalFields;
    NSUInteger horizontalFields;
} CCCrissCrossBoardSize;

static inline CCCrissCrossBoardSize CCCrissCrossBoardSizeMake(NSUInteger verticalFields, NSUInteger horizontalFields) 
{
    CCCrissCrossBoardSize size; size.verticalFields = verticalFields; size.horizontalFields = horizontalFields; return size;
}



/**
 @class     CCCrissCrossBoard
 @abstract  class that handles the logic of playing criss cross
 */
@interface CCCrissCrossBoard : NSObject {
@private
    NSArray *_players;
    CCPlayer *_currentPlayer;
    
    CCCrissCrossBoardSize _size;
    
    /**
     @var           _closedBridges
     @abstract      stores which bridge on this board is closed and which is still open
     @discussion    '*' represents a knot between a bridge can be set. the following scheme describes the numeration the bridges
     
          0 1 2 3       these are the indexes for *-*-*-*-* rows (3 == _size.horizontalFields)
         0 1 2 3 4      these are the indexes for | | | | | rows (4 == _size.horizontalFields + 1)
     
     0   * * * * *
     1  
     2   * * * * *
     3 
     4   * * * * *
     5 
     6   * * * * *      this max row has index (_size.verticalFields*2)
     
     */
    BOOL **_closedBridges;
    
    /**
     @var           _capturedFields
     @abstract      contains the index of the player that did close the corresponding field
     @discussion    -1 means that this field has not been taken
     
     *-*-*-* *
     |1|0|0|        <-- Player 1 closed first field, Player 0 closed next two Fields
     *-*-*-* *
     
     * * * * *
     
     * * * * *
     
     * * * * *
     */
    NSInteger **_capturedFields;
}

/**
 @method    initWithSize:
 @abstract  initializes a new instance with a board size
 */
- (id)initWithSize:(CCCrissCrossBoardSize)size;

/**
 @property  players
 @abstract  stores players currently playing on this board. contains instances of CCPlayer
 */
@property (nonatomic, strong) NSArray *players;

/**
 @property  currentPlayer
 @abstract  contains the player who makes the next move
 */
@property (nonatomic, strong) CCPlayer *currentPlayer;

@end





/**
 @category  CCCrissCrossBoard (CCBridge)
 @abstract  contains methods to manage bridges
 */
@interface CCCrissCrossBoard (CCBridge)

/**
 @method    containsBridge:
 @abstract  specifies if the current board contains bridge
 @return    YES, if self contains this bridge, otherwise NO
 */
- (BOOL)containsBridge:(CCBridge)bridge;

/**
 @method        isBridgeClosed:
 @abstract      specifies if a bridge is closed.
 @discussion    self needs to contain bridge
 */
- (BOOL)isBridgeClosed:(CCBridge)bridge;

/**
 @method    closeBridge:
 @abstract  closes a bridge for the currentPlayer
 @param     fieldHandler: gets called for each field that gets closed by this bridge
 @param     noFieldsClosedHandler: gets called if no field gets closed by closing bridge
 */
- (void)closeBridge:(CCBridge)bridge 
 closedFieldHandler:(void(^)(CCField field))fieldHandler noFieldsClosedHandler:(void(^)(void))noFieldsClosedHandler;

@end





/**
 @category  CCCrissCrossBoard (CCField)
 @abstract  category that manages fields
 */
@interface CCCrissCrossBoard (CCField)

/**
 @method    containsField:
 @abstract  specifies if the current field is contain in this board
 */
- (BOOL)containsField:(CCField)field;

/**
 @method    fieldLeftFromBridge:
 @abstract  returns the field left from bridge. bridge needs to be a vertical bridge and not the most left one
 */
- (CCField)fieldLeftFromBridge:(CCBridge)bridge;

/**
 @method    fieldRightFromBridge:
 @abstract  returns the field right from bridge. bridge needs to be a vertical bridge and not the most right one
 */
- (CCField)fieldRightFromBridge:(CCBridge)bridge;

/**
 @method    fieldOnTopOfBridge:
 @abstract  returns the field above bridge. bridge needs to be a horizontal bridge and not the most top one
 */
- (CCField)fieldOnTopOfBridge:(CCBridge)bridge;

/**
 @method    fieldOnBottomOfBridge:
 @abstract  returns the field below bridge. bridge needs to be a horizontal bridge and not the most down one
 */
- (CCField)fieldOnBottomOfBridge:(CCBridge)bridge;

@end
