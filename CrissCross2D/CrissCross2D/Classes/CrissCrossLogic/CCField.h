//
//  MyClass.h
//  CrissCrossLogic
//
//  Created by Oliver Letterer on 08.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    NSInteger verticalIndex;
    NSInteger horizontalIndex;
} CCField;

static inline CCField CCFieldMake(NSInteger verticalIndex, NSInteger horizontalIndex)
{
    CCField field; field.verticalIndex = verticalIndex; field.horizontalIndex = horizontalIndex; return field;
}

static inline NSString *NSStringFromCCField(CCField field)
{
    return [NSString stringWithFormat:@"{%d, %d}", field.verticalIndex, field.horizontalIndex];
}

static inline BOOL CCFieldIsEqualToField(CCField field, CCField otherField)
{
    return field.verticalIndex == otherField.verticalIndex && field.horizontalIndex == otherField.horizontalIndex;
}