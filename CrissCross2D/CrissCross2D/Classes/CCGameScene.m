//
//  CCGameScene.m
//  CrissCross2D
//
//  Created by Oliver Letterer on 09.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CCGameScene.h"


@implementation CCGameScene

- (id)init 
{
    if (self = [super init]) {
        _rootLayer = [CCLayer node];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[_rootLayer addChild: label];
        
        [self addChild:_rootLayer];
    }
    return self;
}


@end
