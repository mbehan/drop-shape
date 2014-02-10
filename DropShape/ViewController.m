//
//  ViewController.m
//  DropShape
//
//  Created by Michael Behan on 06/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import "ViewController.h"
#import "UIBezierPath+Image.h"
#import "SKPhysicsBody+ConvexHull.h"
#import <SpriteKit/SpriteKit.h>
#import "DropShapeScene.h"

@interface ViewController ()
{
    DropShapeScene* scene;
}
@end

@implementation ViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _drawingView.delegate = self; 
}

- (void)viewWillLayoutSubviews
{
    scene = [[DropShapeScene alloc] initWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    SKView *spriteView = (SKView *) self.view;
    spriteView.showsDrawCount = YES;
    spriteView.showsNodeCount = YES;
    spriteView.showsFPS = YES;
    [spriteView presentScene: scene];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
