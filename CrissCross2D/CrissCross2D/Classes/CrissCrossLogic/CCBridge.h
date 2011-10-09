//
//  CCBride.h
//  CrissCrossLogic
//
//  Created by Oliver Letterer on 08.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @struct    CCBride
 @abstract  represents a bridge between two knots
 */
typedef struct {
    NSInteger verticalIndex;
    NSInteger horizontalIndex;
} CCBridge;

static inline CCBridge CCBridgeMake(NSInteger verticalIndex, NSInteger horizontalIndex)
{
    CCBridge bridge; bridge.verticalIndex = verticalIndex; bridge.horizontalIndex = horizontalIndex; return bridge;
}

static inline NSString *NSStringFromCCBridge(CCBridge bridge)
{
    return [NSString stringWithFormat:@"{%d, %d}", bridge.verticalIndex, bridge.horizontalIndex];
}
