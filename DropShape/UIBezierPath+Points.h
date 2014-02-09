//
//  UIBezierPath+Points.h
//  Curious About Letters
//
//  Created by Michael Behan on 13/09/2013.
//  Copyright (c) 2013 Michael Behan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface UIBezierPath (Points)
@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) NSArray *bezierElements;
@property (nonatomic, readonly) CGFloat length;

- (NSArray *) pointPercentArray;
- (CGPoint) pointAtPercent: (CGFloat) percent withSlope: (CGPoint *) slope;
+ (UIBezierPath *) pathWithPoints: (NSArray *) points;
+ (UIBezierPath *) pathWithElements: (NSArray *) elements;

- (CGPathRef) physicsBodyPolyForNode:(SKNode *)node inScene:(SKScene *)scene;
@end