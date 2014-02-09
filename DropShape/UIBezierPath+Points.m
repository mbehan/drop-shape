//
//  UIBezierPath+Points.m
//  Curious About Letters
//
//  Created by Michael Behan on 13/09/2013.
//  Copyright (c) 2013 Michael Behan. All rights reserved.
//

#import "UIBezierPath+Points.h"
#import "UIBezierPath-Thinning.h"

#define POINTSTRING(_CGPOINT_) (NSStringFromCGPoint(_CGPOINT_))
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

// Return distance between two points
static float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
    
	return sqrt(dx*dx + dy*dy);
}

@implementation UIBezierPath (Points)

- (CGPathRef) physicsBodyPolyForNode:(SKNode *)node inScene:(SKScene *)scene
{
    NSArray *sortedPoints = [self.points sortedArrayUsingComparator:^(id b, id a){
        
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
    
    NSArray *convexHull = [self chainHull_2D:sortedPoints];
    
    
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
    
    return returnPath;
}

-(CGPoint) centroidOfPoints:(NSArray *)points
{
    CGPoint centroid = CGPointZero;
    for (NSValue *pointVal in points) {
        centroid.x += [pointVal CGPointValue].x;
        centroid.y += [pointVal CGPointValue].y;
    }
    centroid.x /= ([points count] * 1.0);
    centroid.y /= ([points count] * 1.0);
    return centroid;
}

/*-(float) polygonAreaFromArrayOfPoints:(NSArray *)points
{
    NSMutableArray *X = [[NSMutableArray alloc] init];
    NSMutableArray *Y = [[NSMutableArray alloc] init];
    
    for(NSValue *pointVal in points)
    {
        [X addObject:[NSNumber numberWithFloat:[pointVal CGPointValue].x]];
        [Y addObject:[NSNumber numberWithFloat:[pointVal CGPointValue].y]];
    }
    
    int numPoints = (int)[points count];
    
    float area = 0;         // Accumulates area in the loop
    int j = numPoints-1;  // The last vertex is the 'previous' one to the first
    
    for (int i=0; i<numPoints; i++)
    { area = area +  ([X[j] floatValue]+[X[i] floatValue]) * ([Y[j] floatValue]-[Y[i] floatValue]);
        j = i;  //j is previous vertex to i
    }
    return area/2;
}*/

void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    if (type != kCGPathElementCloseSubpath)
    {
        if ((type == kCGPathElementAddLineToPoint) ||
            (type == kCGPathElementMoveToPoint)){
            [bezierPoints addObject:VALUE(0)];
        }
        else if (type == kCGPathElementAddQuadCurveToPoint)
        {
            [bezierPoints addObject:VALUE(0)];
            [bezierPoints addObject:VALUE(1)];
        }
        else if (type == kCGPathElementAddCurveToPoint)
        {
            [bezierPoints addObject:VALUE(0)];
            [bezierPoints addObject:VALUE(1)];
            [bezierPoints addObject:VALUE(2)];
        }
    }
}

- (NSArray *)points
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}

// Return a Bezier path buit with the supplied points
+ (UIBezierPath *) pathWithPoints: (NSArray *) points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (points.count == 0) return path;
    [path moveToPoint:POINT(0)];
    for (int i = 1; i < points.count; i++)
        [path addLineToPoint:POINT(i)];
    return path;
}

- (CGFloat) length
{
    NSArray *points = self.points;
    float totalPointLength = 0.0f;
    for (int i = 1; i < points.count; i++)
        totalPointLength += distance(POINT(i), POINT(i-1));
    return totalPointLength;
}

int getAngleABC( CGPoint a, CGPoint b, CGPoint c )
{
    CGPoint ab = { b.x - a.x, b.y - a.y };
    CGPoint cb = { b.x - c.x, b.y - c.y };
    
    float dot = (ab.x * cb.x + ab.y * cb.y); // dot product
    float cross = (ab.x * cb.y - ab.y * cb.x); // cross product
    
    float alpha = atan2(cross, dot);
    
    return (int) floor(alpha * 180. / M_PI + 0.5);
}

- (NSArray *) pointPercentArray
{
    // Use total length to calculate the percent of path consumed at each control point
    NSArray *points = self.points;
    int pointCount = points.count;
    
    float totalPointLength = self.length;
    float distanceTravelled = 0.0f;
    
	NSMutableArray *pointPercentArray = [NSMutableArray array];
	[pointPercentArray addObject:@(0.0)];
    
	for (int i = 1; i < pointCount; i++)
	{
		distanceTravelled += distance(POINT(i), POINT(i-1));
		[pointPercentArray addObject:@(distanceTravelled / totalPointLength)];
	}
    
	// Add a final item just to stop with. Probably not needed.
	[pointPercentArray addObject:[NSNumber numberWithFloat:1.1f]]; // 110%
    
    return pointPercentArray;
}

- (CGPoint) pointAtPercent: (CGFloat) percent withSlope: (CGPoint *) slope
{
    NSArray *points = self.points;
    NSArray *percentArray = self.pointPercentArray;
    CFIndex lastPointIndex = points.count - 1;
    
    if (!points.count)
        return CGPointZero;
    
    // Check for 0% and 100%
    if (percent <= 0.0f) return POINT(0);
    if (percent >= 1.0f) return POINT(lastPointIndex);
    
    // Find a corresponding pair of points in the path
    CFIndex index = 1;
    while ((index < percentArray.count) &&
           (percent > ((NSNumber *)percentArray[index]).floatValue))
        index++;
    
    // This should not happen.
    if (index > lastPointIndex) return POINT(lastPointIndex);
    
    // Calculate the intermediate distance between the two points
    CGPoint point1 = POINT(index -1);
    CGPoint point2 = POINT(index);
    
    float percent1 = [[percentArray objectAtIndex:index - 1] floatValue];
    float percent2 = [[percentArray objectAtIndex:index] floatValue];
    float percentOffset = (percent - percent1) / (percent2 - percent1);
    
    float dx = point2.x - point1.x;
    float dy = point2.y - point1.y;
    
    // Store dy, dx for retrieving arctan
    if (slope) *slope = CGPointMake(dx, dy);
    
    // Calculate new point
    CGFloat newX = point1.x + (percentOffset * dx);
    CGFloat newY = point1.y + (percentOffset * dy);
    CGPoint targetPoint = CGPointMake(newX, newY);
    
    return targetPoint;
}

void getBezierElements(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierElements = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    switch (type)
    {
        case kCGPathElementCloseSubpath:
            [bezierElements addObject:@[@(type)]];
            break;
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
            [bezierElements addObject:@[@(type), VALUE(0)]];
            break;
        case kCGPathElementAddQuadCurveToPoint:
            [bezierElements addObject:@[@(type), VALUE(0), VALUE(1)]];
            break;
        case kCGPathElementAddCurveToPoint:
            [bezierElements addObject:@[@(type), VALUE(0), VALUE(1), VALUE(2)]];
            break;
    }
}

- (NSArray *) bezierElements
{
    NSMutableArray *elements = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)elements, getBezierElements);
    return elements;
}

+ (UIBezierPath *) pathWithElements: (NSArray *) elements
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (elements.count == 0) return path;
    
    for (NSArray *points in elements)
    {
        if (!points.count) continue;
        CGPathElementType elementType = [points[0] integerValue];
        switch (elementType)
        {
            case kCGPathElementCloseSubpath:
                [path closePath];
                break;
            case kCGPathElementMoveToPoint:
                if (points.count == 2)
                    [path moveToPoint:POINT(1)];
                break;
            case kCGPathElementAddLineToPoint:
                if (points.count == 2)
                    [path addLineToPoint:POINT(1)];
                break;
            case kCGPathElementAddQuadCurveToPoint:
                if (points.count == 3)
                    [path addQuadCurveToPoint:POINT(2) controlPoint:POINT(1)];
                break;
            case kCGPathElementAddCurveToPoint:
                if (points.count == 4)
                    [path addCurveToPoint:POINT(3) controlPoint1:POINT(1) controlPoint2:POINT(2)];
                break;
        }
    }
    
    return path;
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
-(NSArray *) chainHull_2D:(NSArray *)P
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