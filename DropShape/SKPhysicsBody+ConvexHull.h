//
//  SKPhysicsBody+ConvexHull.h
//  DropShape
//
//  Created by Michael Behan on 09/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKPhysicsBody (ConvexHull)

+ (SKPhysicsBody *)bodyWithConvexHullFromPath:(UIBezierPath *)path;

@end
