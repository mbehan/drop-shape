//
//  UIBezierPath+Image.h
//  DropShape
//
//  Created by Michael Behan on 06/02/2014.
//  Copyright (c) 2014 Michael Behan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Image)

/** Returns an image of the path drawn using a stroke */
-(UIImage*) strokeImageWithColor:(UIColor*)color;

@end
