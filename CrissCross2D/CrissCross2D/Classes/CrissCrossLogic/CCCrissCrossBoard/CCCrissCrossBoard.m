//
//  CCCrissCrossBoard.m
//  CrissCrossLogic
//
//  Created by Oliver Letterer on 08.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CCCrissCrossBoard.h"
#import "CCPlayer.h"

@interface CCCrissCrossBoard ()

- (void)_createClosedBridgesByCurrentSize;
- (void)_freeClosedBridgesByCurrentSize;

- (void)_createCapturedFieldsByCurrentSize;
- (void)_freeCapturedFieldsByCurrentSize;

- (void)_closeField:(CCField)field closedFieldHandler:(void(^)(CCField field))fieldHandler;

@end



@implementation CCCrissCrossBoard
@synthesize players=_players, currentPlayer=_currentPlayer;

#pragma mark - setters and getters

- (void)setCurrentPlayer:(CCPlayer *)currentPlayer
{
    if (currentPlayer != _currentPlayer) {
        NSAssert([_players containsObject:currentPlayer], @"you can only set currentPlayer to a player that is contained in _players");
        [self willChangeValueForKey:@"currentPlayer"];
        _currentPlayer = currentPlayer;
        [self didChangeValueForKey:@"currentPlayer"];
    }
}

#pragma mark - Initialization

- (id)initWithSize:(CCCrissCrossBoardSize)size 
{
    if ((self = [super init])) {
        // Initialization code
        _size = size;
        _players = [NSArray arrayWithObjects:[[CCPlayer alloc] init], [[CCPlayer alloc] init], nil];
        self.currentPlayer = [_players objectAtIndex:0];
        
        [self _createClosedBridgesByCurrentSize];
        [self _createCapturedFieldsByCurrentSize];
    }
    return self;
}

#pragma mark - description

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p>: \n", NSStringFromClass(self.class), self];
    
    for (int verticalIndex = 0; verticalIndex <= _size.verticalFields*2; verticalIndex++) {
        // enum all vertical indexes
        BOOL isHorizontalRow = verticalIndex % 2 == 0;
        int maxHorizontalIndex = isHorizontalRow ? _size.horizontalFields : _size.horizontalFields + 1;
        NSString *bridgeString = isHorizontalRow ? @"-" : @"|";
        
        for (int horizontalIndex = 0; horizontalIndex < maxHorizontalIndex; horizontalIndex++) {
            // enumerate each column
            if (isHorizontalRow) {
                [description appendFormat:@"*"];
            }
            
            CCBridge bridge = CCBridgeMake(verticalIndex, horizontalIndex);
            BOOL isBridgeClosed = [self isBridgeClosed:bridge];
            
            if (!isHorizontalRow) {
                if (bridge.horizontalIndex > 0) {
                    CCField field = [self fieldLeftFromBridge:bridge];
                    NSInteger playerIndex = _capturedFields[field.verticalIndex][field.horizontalIndex];
                    NSString *playerString = @" ";
                    if (playerIndex >= 0) {
                        playerString = [NSString stringWithFormat:@"%d", playerIndex];
                    }
                    [description appendFormat:playerString];
                }
            }
            
            [description appendString:isBridgeClosed ? bridgeString : @" "];
        }
        if (isHorizontalRow) {
            [description appendFormat:@"*"];
        }
        [description appendString:@"\n"];
    }
    
    return description;
}

#pragma mark - memory management

- (void)dealloc
{
    [self _freeClosedBridgesByCurrentSize];
    [self _freeCapturedFieldsByCurrentSize];
}

#pragma mark - private implementation ()

- (void)_createClosedBridgesByCurrentSize
{
    _closedBridges = calloc(_size.verticalFields*2 + 1, sizeof(BOOL *));
    for (int i = 0; i <= _size.verticalFields*2; i++) {
        _closedBridges[i] = calloc(_size.horizontalFields+1, sizeof(BOOL));
    }
}

- (void)_freeClosedBridgesByCurrentSize
{
    for (int i = 0; i <= _size.verticalFields*2; i++) {
        free(_closedBridges[i]);
    }
    free(_closedBridges);
}

- (void)_createCapturedFieldsByCurrentSize
{
    _capturedFields = calloc(_size.verticalFields, sizeof(NSInteger *));
    for (int i = 0; i < _size.verticalFields; i++) {
        _capturedFields[i] = calloc(_size.horizontalFields, sizeof(NSInteger));
        for (int j = 0; j < _size.horizontalFields; j++) {
            _capturedFields[i][j] = -1;
        }
    }
}

- (void)_freeCapturedFieldsByCurrentSize
{
    for (int i = 0; i < _size.verticalFields; i++) {
        free(_capturedFields[i]);
    }
    free(_capturedFields);
}

- (void)_closeField:(CCField)field closedFieldHandler:(void(^)(CCField field))fieldHandler
{
    NSAssert([self containsField:field], @"%@ needs to contain field %@", self, NSStringFromCCField(field));
    NSInteger playerIndex = [_players indexOfObject:self.currentPlayer];
    
    _capturedFields[field.verticalIndex][field.horizontalIndex] = playerIndex;
    if (fieldHandler) {
        fieldHandler(field);
    }
}

@end

@implementation CCCrissCrossBoard (CCBridge)

- (BOOL)containsBridge:(CCBridge)bridge
{
    BOOL isHorizontalRow = bridge.verticalIndex % 2 == 0;
    int maxHorizontalIndex = isHorizontalRow ? _size.horizontalFields : _size.horizontalFields + 1;
    return bridge.horizontalIndex < maxHorizontalIndex && bridge.verticalIndex < _size.verticalFields*2+1 && bridge.horizontalIndex >= 0 && bridge.verticalIndex >= 0;
}

- (BOOL)isBridgeClosed:(CCBridge)bridge
{
    NSAssert([self containsBridge:bridge], @"%@ needs to contain bridge: %@", self, NSStringFromCCBridge(bridge));
    return _closedBridges[bridge.verticalIndex][bridge.horizontalIndex];
}

- (void)closeBridge:(CCBridge)bridge 
 closedFieldHandler:(void(^)(CCField field))fieldHandler noFieldsClosedHandler:(void(^)(void))noFieldsClosedHandler
{
    NSAssert(![self isBridgeClosed:bridge], @"%@ needs to be able to close bridge: %@", self, NSStringFromCCBridge(bridge));
    _closedBridges[bridge.verticalIndex][bridge.horizontalIndex] = YES;
    
    /**
     - check if a field was closed
     - if a field was closed, current player does not change, points for currentplayer need to increase, inform delegate
     - if no field was closed, currentPlayer needs to change
     */
    
    BOOL didNotCloseAnyField = YES;
    BOOL isHorizontalBridge = bridge.verticalIndex % 2 == 0;
    if (isHorizontalBridge) {
        /**
         this is a horizontal bridge *-*. we need to check the fields above and below this bridge
         */
        
        // first check the top field
        CCBridge topFieldLeftBridge    = CCBridgeMake(bridge.verticalIndex - 1, bridge.horizontalIndex);
        CCBridge topFieldTopBridge     = CCBridgeMake(bridge.verticalIndex - 2, bridge.horizontalIndex);
        CCBridge topFieldRightBridge   = CCBridgeMake(bridge.verticalIndex - 1, bridge.horizontalIndex + 1);
        CCBridge topFieldBottomBridge  = bridge;
        
        if ([self containsBridge:topFieldLeftBridge] && [self containsBridge:topFieldTopBridge] && [self containsBridge:topFieldRightBridge] && [self containsBridge:topFieldBottomBridge]) {
            // there exists a left field from bridge
            
            if ([self isBridgeClosed:topFieldLeftBridge] && [self isBridgeClosed:topFieldTopBridge] && [self isBridgeClosed:topFieldRightBridge] && [self isBridgeClosed:topFieldBottomBridge]) {
                // this field is closed
                CCField field = [self fieldOnTopOfBridge:bridge];
                [self _closeField:field closedFieldHandler:fieldHandler];
                didNotCloseAnyField = NO;
            }
        }
        
        // now check the right field
        CCBridge bottomFieldRightBridge   = CCBridgeMake(bridge.verticalIndex + 1, bridge.horizontalIndex + 1);
        CCBridge bottomFieldTopBridge     = bridge;
        CCBridge bottomFieldLeftBridge    = CCBridgeMake(bridge.verticalIndex + 1, bridge.horizontalIndex);
        CCBridge bottomFieldBottomBridge  = CCBridgeMake(bridge.verticalIndex + 2, bridge.horizontalIndex);
        
        if ([self containsBridge:bottomFieldRightBridge] && [self containsBridge:bottomFieldTopBridge] && [self containsBridge:bottomFieldLeftBridge] && [self containsBridge:bottomFieldBottomBridge]) {
            // there exists a left field from bridge
            
            if ([self isBridgeClosed:bottomFieldRightBridge] && [self isBridgeClosed:bottomFieldTopBridge] && [self isBridgeClosed:bottomFieldLeftBridge] && [self isBridgeClosed:bottomFieldBottomBridge]) {
                // this field is closed
                CCField field = [self fieldOnBottomOfBridge:bridge];
                [self _closeField:field closedFieldHandler:fieldHandler];
                didNotCloseAnyField = NO;
            }
        }
        
    } else {
        /**
         
         *
         |
         *
         
         this is a vertical bridge. we need to check the fields left and right from this bridge
         */
        
        // first check the left field
        CCBridge leftFieldLeftBridge    = CCBridgeMake(bridge.verticalIndex, bridge.horizontalIndex - 1);
        CCBridge leftFieldTopBridge     = CCBridgeMake(bridge.verticalIndex - 1, bridge.horizontalIndex - 1);
        CCBridge leftFieldRightBridge   = bridge;
        CCBridge leftFieldBottomBridge  = CCBridgeMake(bridge.verticalIndex + 1, bridge.horizontalIndex - 1);
        
        if ([self containsBridge:leftFieldLeftBridge] && [self containsBridge:leftFieldTopBridge] && [self containsBridge:leftFieldRightBridge] && [self containsBridge:leftFieldBottomBridge]) {
            // there exists a left field from bridge
            
            if ([self isBridgeClosed:leftFieldLeftBridge] && [self isBridgeClosed:leftFieldTopBridge] && [self isBridgeClosed:leftFieldRightBridge] && [self isBridgeClosed:leftFieldBottomBridge]) {
                // this field is closed
                CCField field = [self fieldLeftFromBridge:bridge];
                [self _closeField:field closedFieldHandler:fieldHandler];
                didNotCloseAnyField = NO;
            }
        }
        
        // now check the right field
        CCBridge rightFieldRightBridge   = CCBridgeMake(bridge.verticalIndex, bridge.horizontalIndex + 1);
        CCBridge rightFieldTopBridge     = CCBridgeMake(bridge.verticalIndex - 1, bridge.horizontalIndex);
        CCBridge rightFieldLeftBridge    = bridge;
        CCBridge rightFieldBottomBridge  = CCBridgeMake(bridge.verticalIndex + 1, bridge.horizontalIndex);
        
        if ([self containsBridge:rightFieldRightBridge] && [self containsBridge:rightFieldTopBridge] && [self containsBridge:rightFieldLeftBridge] && [self containsBridge:rightFieldBottomBridge]) {
            // there exists a left field from bridge
            
            if ([self isBridgeClosed:rightFieldRightBridge] && [self isBridgeClosed:rightFieldTopBridge] && [self isBridgeClosed:rightFieldLeftBridge] && [self isBridgeClosed:rightFieldBottomBridge]) {
                // this field is closed
                CCField field = [self fieldRightFromBridge:bridge];
                [self _closeField:field closedFieldHandler:fieldHandler];
                didNotCloseAnyField = NO;
            }
        }
    }
    
    if (didNotCloseAnyField && noFieldsClosedHandler) {
        noFieldsClosedHandler();
    }
}

@end



@implementation CCCrissCrossBoard (CCField)

- (BOOL)containsField:(CCField)field
{
    return field.verticalIndex < _size.verticalFields && field.horizontalIndex < _size.horizontalFields && field.verticalIndex >= 0 && field.horizontalIndex >= 0;
}

- (CCField)fieldLeftFromBridge:(CCBridge)bridge
{
    NSAssert([self containsBridge:bridge], @"%@ needs to contain bridge: %@", self, NSStringFromCCBridge(bridge));
    NSAssert(bridge.verticalIndex % 2 == 1, @"this bridge %@ needs to be a vertical bridge", NSStringFromCCBridge(bridge));
    NSAssert(bridge.horizontalIndex > 0, @"most left bridge %@ does not have a left field", NSStringFromCCBridge(bridge));
    
    return CCFieldMake(bridge.verticalIndex / 2, bridge.horizontalIndex - 1);
}

- (CCField)fieldRightFromBridge:(CCBridge)bridge
{
    NSAssert([self containsBridge:bridge], @"%@ needs to contain bridge: %@", self, NSStringFromCCBridge(bridge));
    NSAssert(bridge.verticalIndex % 2 == 1, @"this bridge %@ needs to be a vertical bridge", NSStringFromCCBridge(bridge));
    NSAssert(bridge.horizontalIndex < _size.horizontalFields, @"most right bridge %@ does not have a right field", NSStringFromCCBridge(bridge));
    
    return CCFieldMake(bridge.verticalIndex / 2, bridge.horizontalIndex);
}

- (CCField)fieldOnTopOfBridge:(CCBridge)bridge
{
    NSAssert([self containsBridge:bridge], @"%@ needs to contain bridge: %@", self, NSStringFromCCBridge(bridge));
    NSAssert(bridge.verticalIndex % 2 == 0, @"this bridge %@ needs to be a horizontal bridge", NSStringFromCCBridge(bridge));
    NSAssert(bridge.verticalIndex > 0, @"most top bridge %@ does not have a top field", NSStringFromCCBridge(bridge));
    
    return CCFieldMake(bridge.verticalIndex / 2 - 1, bridge.horizontalIndex);
}

- (CCField)fieldOnBottomOfBridge:(CCBridge)bridge
{
    NSAssert([self containsBridge:bridge], @"%@ needs to contain bridge: %@", self, NSStringFromCCBridge(bridge));
    NSAssert(bridge.verticalIndex % 2 == 0, @"this bridge %@ needs to be a horizontal bridge", NSStringFromCCBridge(bridge));
    NSAssert(bridge.verticalIndex < _size.horizontalFields*2+1, @"most bottom bridge %@ does not have a bottom field", NSStringFromCCBridge(bridge));
    
    return CCFieldMake(bridge.verticalIndex / 2 - 1, bridge.horizontalIndex);
}

@end
