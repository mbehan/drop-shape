drop-shape
==========

There are plenty of games with this basic mechanic so I wanted to see if I could do it in SpriteKit.

![Shapes being drawn and then becoming part of a physics simulation](https://iosapp.dev/static/img/spritekit-physics.gif)

I make use of some categories on UIBezierPath made by other people, they are: 

* Creating a UIImage from a path, taken from [this stackoverflow answer](http://stackoverflow.com/a/17408397/61698)
* A couple from the [iOS6 cookbook](https://github.com/erica/iOS-6-Cookbook) that make dealing with the points that make up a path much easier

## How it Works 

We’re combining UIKit and SpriteKit here so we’re layering a transparent `UIView` on top of an `SKView`. 

The `SKView` presents a single scene, it will contain our shapes and has a bounding static physics body to stop them escaping. The view controller sets up the scene in standard fashion. 

```objective-c
- (void)viewWillLayoutSubviews
{
    scene = [[DropShapeScene alloc] initWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    SKView *spriteView = (SKView *) self.view;
    [spriteView presentScene: scene];
}
```

We have a very simple `UIView` subclass that sits on top providing very basic drawing functionality - it will handle drawing a single path, once the drawing ends it passes the path to it’s delegate and forgets about it. The drawing is done similar to [my previous post](http://mbehan.com/post/75703618266/a-bit-of-fun-with-uibezierpath-and-cashapelayer), here’s the delegate protocol. 

```objective-c
@protocol SimplePathDrawingDelegate <nsobject>
-(void)drawingViewCreatedPath:(UIBezierPath *)path;
@end
```

We’ll let the view controller be the delegate, and thats where we do the interesting stuff, once it gets the drawn path. 

```objective-c
-(void)drawingViewCreatedPath:(UIBezierPath *)path
{
    CGRect pathBounds = CGPathGetPathBoundingBox(path.CGPath);
    
    UIImage *image = [path strokeImageWithColor:[UIColor greenColor]];
    SKTexture *shapeTexture = [SKTexture textureWithImage:image];
    SKSpriteNode *shapeSprite = [SKSpriteNode spriteNodeWithTexture:shapeTexture size:pathBounds.size];
    
    shapeSprite.position = CGPointMake(pathBounds.origin.x + (pathBounds.size.width/2.0), scene.frame.size.height - pathBounds.origin.y - (pathBounds.size.height/2.0));
    
    shapeSprite.physicsBody = [SKPhysicsBody bodyWithConvexHullFromPath:path];
    shapeSprite.physicsBody.dynamic = YES;
    [scene addChild:shapeSprite];
}
```

We take the drawn line on a journey from path, to image, to a texture that is applied to a sprite. That part is pretty straightforward, more tricky is using that path to create a physics body. 

SKPhysicsBody gives us a number of options for creating physics bodies, they are: 

```objective-c
+ bodyWithCircleOfRadius:
+ bodyWithRectangleOfSize:
+ bodyWithPolygonFromPath:
+ bodyWithEdgeLoopFromRect:
+ bodyWithEdgeFromPoint:toPoint:
+ bodyWithEdgeLoopFromPath:
+ bodyWithEdgeChainFromPath:
```

 There are a few there that will take a path and give us a body, perfect, right? Except on closer inspection only 1 of them will create a path that can be dynamic, and that one `bodyWithPolygonFromPath:` has the caveat 

> A convex polygonal path with counterclockwise winding and no self intersections. 

Sadly any realistic user isn’t going to like having to draw nothing but convex polygonal counterclockwise paths with no intersections. 

Additionally, SpriteKit only lets us have bodies with 12 or fewer sides! 

There are a few approaches we could take for getting by these restrictions: multiple joined physics bodies, using Box2D directly to get around the limit on body vertices, but we’ll use a [convex hull](http://en.wikipedia.org/wiki/Convex_hul) from the points that make up the path and make an `SKPhysicsBody` category to do it for us. 

I won’t list the code here, you can download the project to have a look but here’s what it does. _(I use some existing categories on UIBezierPath to help out here and got a convex hull implementation online too, they’re all included in the project.)_

* Get the points from the path
* Order the points for the convex hull algorithm
* Get the convex hull
* While there are too many points in the hull, smooth it using increasing tolerance (removing points that make the smallest angles).

And that's all there is to it. The results are pretty nice for most shapes, if you wanted to get started on a physics drawing game you wouldn’t need much more than the `SKPhysicsBody (ConvexHull)` category. 

