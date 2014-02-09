//
//  SKPhysicsBody+ConvexHull.m
//  DropShape
//
//  Created by Michael Behan on 09/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import "SKPhysicsBody+ConvexHull.h"
#import "UIBezierPath+Points.h"
#import "UIBezierPath+Thinning.h"

@implementation SKPhysicsBody (ConvexHull)

+ (SKPhysicsBody *)bodyWithConvexHullFromPath:(UIBezierPath *)path
{
    NSArray *sortedPoints = [path.points sortedArrayUsingComparator:^(id b, id a){
        
        CGPoint pointA = [a CGPointValue];
        CGPoint pointB = [b CGPointValue];
        
        if(pointA.x == pointB.x && pointA.y == pointB.y)
        {
            return (NSComparisonResult)NSOrderedSame;
        }
        else if (pointA.x != pointB.x)
        {
            if(pointA.x > pointB.x)
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        else
        {
            if(pointA.y > pointB.y)
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        
    }];
    
    NSArray *convexHull = chainHull_2D(sortedPoints);
    
    
    UIBezierPath *hullPath = [UIBezierPath pathWithPoints:convexHull];
    
    UIBezierPath *reducedHullPath = hullPath;
    
    float tolerance = 0.0;
    while ([reducedHullPath.points count] > 11) {
        tolerance += 0.1;
        reducedHullPath = thinPath(reducedHullPath, tolerance);
        
        NSLog(@"POINTS %lu",(unsigned long)[reducedHullPath.points count]);
    }
    
    NSArray *reducedHullPoints = reducedHullPath.points;
    CGMutablePathRef returnPath = CGPathCreateMutable();
    
    CGRect pathBounds = CGPathGetPathBoundingBox(reducedHullPath.CGPath);
    
    
    CGPoint point = [reducedHullPoints[0] CGPointValue];
    CGPathMoveToPoint(returnPath, NULL, point.x- pathBounds.origin.x - (pathBounds.size.width / 2.0), -1 *(((point.y - pathBounds.origin.y) - (pathBounds.size.height / 2.0))));
    
    for(int i = 1; i < [reducedHullPoints count]; i++)
    {
        CGPoint point = [reducedHullPoints[i] CGPointValue];
        CGPathAddLineToPoint(returnPath, NULL, point. x- pathBounds.origin.x - (pathBounds.size.width / 2.0), -1 *( ((point.y - pathBounds.origin.y) - (pathBounds.size.height / 2.0))));
    }
    
    return [SKPhysicsBody bodyWithPolygonFromPath:returnPath];
}

// Assume that a class is already given for the object:
//    Point with coordinates {float x, y;}
//===================================================================


// isLeft(): tests if a point is Left|On|Right of an infinite line.
//    Input:  three points P0, P1, and P2
//    Return: >0 for P2 left of the line through P0 and P1
//            =0 for P2 on the line
//            <0 for P2 right of the line
//    See: Algorithm 1 on Area of Triangles
float isLeft( CGPoint P0, CGPoint P1, CGPoint P2 )
{
    return (P1.x - P0.x)*(P2.y - P0.y) - (P2.x - P0.x)*(P1.y - P0.y);
}
//===================================================================


// chainHull_2D(): Andrew's monotone chain 2D convex hull algorithm
//     Input:  P[] = an array of 2D points
//                  presorted by increasing x and y-coordinates
//             n =  the number of points in P[]
//     Output: H[] = an array of the convex hull vertices (max is n)
//     Return: the number of points in H[]
NSArray * chainHull_2D(NSArray *P)
{
    int n = (int) [P count];
    
    NSMutableArray *H = [[NSMutableArray alloc] init];
    // the output array H[] will be used as the stack
    int    bot=0, top=(-1);   // indices for bottom and top of the stack
    int    i;                 // array scan index
    
    // Get the indices of points with min x-coord and min|max y-coord
    int minmin = 0, minmax;
    float xmin = [P[0] CGPointValue].x;
    for (i=1; i<n; i++)
        if ([P[i] CGPointValue].x != xmin) break;
    minmax = i-1;
    if (minmax == n-1) {       // degenerate case: all x-coords == xmin
        H[++top] = P[minmin];
        if ([P[minmax] CGPointValue].y != [P[minmin] CGPointValue].y) // a  nontrivial segment
            H[++top] =  P[minmax];
        H[++top] = P[minmin];            // add polygon endpoint
        return H;
    }
    
    // Get the indices of points with max x-coord and min|max y-coord
    int maxmin, maxmax = n-1;
    float xmax = [P[n-1] CGPointValue].x;
    for (i=n-2; i>=0; i--)
        if ([P[i] CGPointValue].x != xmax) break;
    maxmin = i+1;
    
    // Compute the lower hull on the stack H
    H[++top] = P[minmin];      // push  minmin point onto stack
    i = minmax;
    while (++i <= maxmin)
    {
        // the lower line joins P[minmin]  with P[maxmin]
        if (isLeft( [P[minmin] CGPointValue], [P[maxmin] CGPointValue], [P[i] CGPointValue])  >= 0 && i < maxmin)
            continue;           // ignore P[i] above or on the lower line
        
        while (top > 0)         // there are at least 2 points on the stack
        {
            // test if  P[i] is left of the line at the stack top
            if (isLeft(  [H[top-1] CGPointValue], [H[top] CGPointValue], [P[i] CGPointValue]) > 0)
                break;         // P[i] is a new hull  vertex
            else
                top--;         // pop top point off  stack
        }
        H[++top] = P[i];        // push P[i] onto stack
    }
    
    // Next, compute the upper hull on the stack H above  the bottom hull
    if (maxmax != maxmin)      // if  distinct xmax points
        H[++top] = P[maxmax];  // push maxmax point onto stack
    bot = top;                  // the bottom point of the upper hull stack
    i = maxmin;
    while (--i >= minmax)
    {
        // the upper line joins P[maxmax]  with P[minmax]
        if (isLeft( [P[maxmax] CGPointValue], [P[minmax] CGPointValue], [P[i] CGPointValue])  >= 0 && i > minmax)
            continue;           // ignore P[i] below or on the upper line
        
        while (top > bot)     // at least 2 points on the upper stack
        {
            // test if  P[i] is left of the line at the stack top
            if (isLeft(  [H[top-1] CGPointValue], [H[top] CGPointValue], [P[i] CGPointValue]) > 0)
                break;         // P[i] is a new hull  vertex
            else
                top--;         // pop top point off  stack
        }
        H[++top] = P[i];        // push P[i] onto stack
    }
    if (minmax != minmin)
        H[++top] = P[minmin];  // push  joining endpoint onto stack
    
    return H;
}


@end
