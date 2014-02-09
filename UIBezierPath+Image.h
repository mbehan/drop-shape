//
//  UIBezierPath+Image.h
//  DropShape
//
//  http://stackoverflow.com/questions/17408209/how-to-create-a-image-with-uibezierpath/17408397#17408397
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Image)

/** Returns an image of the path drawn using a stroke */
-(UIImage*) strokeImageWithColor:(UIColor*)color;

@end
