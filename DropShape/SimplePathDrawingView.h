//
//  DropShapeDrawingView.h
//  DropShape
//
//  Created by Michael Behan on 06/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimplePathDrawingDelegate <NSObject>

-(void)drawingViewCreatedPath:(UIBezierPath *)path;

@end

@interface SimplePathDrawingView : UIView

@property(nonatomic, weak)id<SimplePathDrawingDelegate> delegate;

@end
