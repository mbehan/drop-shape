//
//  ViewController.m
//  DropShape
//
//  Created by Michael Behan on 06/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import "ViewController.h"
#import "UIBezierPath+Image.h"
#import <SpriteKit/SpriteKit.h>
#import "DropShapeScene.h"

@interface ViewController ()
{
}
@end

@implementation ViewController

-(void)drawingViewCreatedPath:(UIBezierPath *)path
{
    UIImage *image = [path strokeImageWithColor:[UIColor greenColor]];
    
    UIImageView *shapeView = [[UIImageView alloc] initWithImage:image];
    shapeView.center = self.view.center;
    shapeView.frame = CGPathGetPathBoundingBox(path.CGPath);
    [self.view addSubview:shapeView];
    
    //[gravity addItem:shapeView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _drawingView.delegate = self;
    
    SKView *spriteView = (SKView *) self.view;
    spriteView.showsDrawCount = YES;
    spriteView.showsNodeCount = YES;
    spriteView.showsFPS = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    DropShapeScene* scene = [[DropShapeScene alloc] initWithSize:self.view.bounds.size];
    SKView *spriteView = (SKView *) self.view;
    [spriteView presentScene: scene];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
