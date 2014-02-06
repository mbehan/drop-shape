//
//  ViewController.m
//  DropShape
//
//  Created by Michael Behan on 06/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravity;
}
@end

@implementation ViewController

-(void)drawingViewCreatedPath:(UIBezierPath *)path
{
    UIView *shapeView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor blackColor].CGColor;
    
    [shapeView.layer addSublayer:shapeLayer];
    
    [self.view addSubview:shapeView];
    
    [gravity addItem:shapeView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    SimplePathDrawingView *drawingView = (SimplePathDrawingView *)self.view;
    drawingView.delegate = self;
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    gravity = [[UIGravityBehavior alloc] init];
    [animator addBehavior:gravity];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
