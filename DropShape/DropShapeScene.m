//
//  DropShapeScene.m
//  DropShape
//
//  Created by Michael Behan on 06/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import "DropShapeScene.h"

@implementation DropShapeScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        self.physicsWorld.gravity = CGVectorMake(0,-7);
        
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height)];
        self.physicsBody = borderBody;
        
    }
    return self;
}

@end
