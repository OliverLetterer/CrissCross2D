//
//  CCPlayer.h
//  CrissCrossLogic
//
//  Created by Oliver Letterer on 08.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCPlayer : NSObject {
@private
    NSInteger _points;
    NSString *_name;
}

/**
 @property  points
 @abstract  stores the number of points this player currently has
 */
@property (nonatomic, assign) NSInteger points;

/**
 @property  name
 @abstract  stores the name of the player
 */
@property (nonatomic, strong) NSString *name;



@end
