//
//  DropShapeDrawingView.m
//  DropShape
//
//  Created by Michael Behan on 06/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import "DropShapeDrawingView.h"

@interface DropShapeDrawingView()
{
    UIBezierPath *drawingPath;
}
@end

@implementation DropShapeDrawingView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
        [self addGestureRecognizer:pgr];
    }
    return self;
}

-(void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        drawingPath = [[UIBezierPath alloc] init];
        drawingPath.lineWidth = 3;
        [drawingPath moveToPoint:[gestureRecognizer locationInView:self]];
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        [drawingPath addLineToPoint:[gestureRecognizer locationInView:self]];
    }
    else
    {
        drawingPath = nil;
    }
    [self setNeedsDisplay];
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    // Drawing code
    [drawingPath stroke];
}


@end
