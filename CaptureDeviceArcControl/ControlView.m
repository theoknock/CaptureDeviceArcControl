//
//  ControlView.m
//  CaptureDeviceArcControl
//
//  Created by Xcode Developer on 11/3/21.
//

#import "ControlView.h"
#import "CaptureDeviceConfigurationPropertyResources.h"

#include <stdio.h>

@implementation ControlView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

static CGFloat arc_control_radius = 0;
CGFloat * arc_control_radius_ptr = &arc_control_radius;
dispatch_block_t (^arc_control_radius_ref)(dispatch_block_t) = ^ (dispatch_block_t b) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UserArcControlConfiguration(UserArcControlConfigurationFileOperationRead)(&arc_control_radius);
    });
    return b;
};

static CGRect arc_control_bounds;
static CGRect (^arc_control_bounds_ref)(CGRect) = ^ CGRect (CGRect parent_rect) {
    return CGRectMake(CGRectGetMaxX(parent_rect) - arc_control_radius,
                      CGRectGetMaxY(parent_rect) - arc_control_radius,
                      arc_control_radius,
                      arc_control_radius);
};

/*
 You need to specify whether you are traversing the circle positively or negatively. I will discuss the positive (counterclockwise) case; the negative case is computed in the same way with obvious changes.

 For the positive direction, the circle's center is to the left of the arc. Just add 90 degrees to the bearing and travel for the radial distance and stop: that's the center. Now we know the circle's center and radius, we can find any point on it. The bearing from the center to a point on the circle is 90 degrees less than the bearing around the circle (in the positive direction).

 Here are some formulas. The start point has coordinates (x1,x2), the radius is r, and the bearing is alpha. (I use the mathematical convention that 0 is due east, 90 is north.) We seek the coordinates (y1,y2) of the endpoint where the new bearing will be beta. Let the origin's coordinates be (o1,o2).

 The direction vector for bearing alpha is (by definition)

 (cos(alpha), sin(alpha))
 Rotating this 90 degrees to the left gives the unit vector

 (-sin(alpha), cos(alpha))
 Moving along this from (x0,x1) by distance r ends up at

 (o1,o2) = (x1,x2) + r * (-sin(alpha), cos(alpha))
 That's the circle's center.
 The bearing from the center to the end point is beta - 90 degrees. The endpoint is reached by moving a distance r in this direction, whence

 (y1,y2) = (o1,o2) + r * (cos(beta-90), sin(beta-90))
 */

typedef struct __attribute__((objc_boxable)) ArcDegreesMeasurements ArcDegreesMeasurements;
typedef NSUInteger (^(^ArcDegreesMeasurementsRadius)(void))(void);
typedef NSUInteger (^(^ArcDegreesMeasurementsEnd)(void))(void);
static struct __attribute__((objc_boxable)) ArcDegreesMeasurements
{
    __unsafe_unretained ArcDegreesMeasurementsRadius radius;
    NSUInteger start;
    NSUInteger length;
    __unsafe_unretained ArcDegreesMeasurementsEnd end;
    NSUInteger sectors;
} arcDegreesMeasurements = {
    .radius = ^ {
        return ^ (CGFloat(^radius_user_preferences)(void)) {
            return ^ NSUInteger (void) {
                return (NSUInteger)radius_user_preferences();
            };
        }(^ CGFloat {
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * documentsDirectory = [paths objectAtIndex:0];
            NSString * fileName = [NSString stringWithFormat:@"%@/arc_control_configuration.dat", documentsDirectory];
            
            __autoreleasing NSError * error = nil;
            NSData * structureData = [[NSData alloc] initWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:&error];
            if (!error) {
                NSDictionary<NSString *, NSNumber *> * structureDataAsDictionary = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:structureData error:&error];
                return (CGFloat)[(NSNumber *)[structureDataAsDictionary objectForKey:@"PreferredArcRadius"] floatValue];
            } else {
                printf("\nERROR\t\t%s\n", [[error description] UTF8String]);
                return (CGFloat)NAN;
            }
        });
    },
        .start = 0,
        .length = 360,
        .end = ^ {
            return ^ (ArcDegreesMeasurements * arc_degree_measurements) {
                return ^ NSUInteger (void) {
                    return (NSUInteger)radiansToDegrees(degreesToRadians(arc_degree_measurements->start) + degreesToRadians(arc_degree_measurements->length));
                };
            }(&arcDegreesMeasurements);
        },
        .sectors = 100
};

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGFloat modified_arc_control_radius = 100.0; //arc_control_radius - 42.0;
    
    CGRect bounds = [layer bounds];
    CGContextTranslateCTM(ctx, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    
    for (NSUInteger t = arcDegreesMeasurements.start; t <= arcDegreesMeasurements.end()(); t++) {
        CGFloat angle = degreesToRadians(t);
        
        CGFloat tick_height = (t == arcDegreesMeasurements.start || t == arcDegreesMeasurements.length) ? 10.0 : (t % arcDegreesMeasurements.sectors == 0) ? 6.0 : 3.0;
        {
            CGPoint xy_outer = CGPointMake(((modified_arc_control_radius + tick_height) * cosf(angle)),
                                           ((modified_arc_control_radius + tick_height) * sinf(angle)));
            CGPoint xy_inner = CGPointMake(((modified_arc_control_radius - tick_height) * cosf(angle)),
                                           ((modified_arc_control_radius - tick_height) * sinf(angle)));
            
            CGContextSetStrokeColorWithColor(ctx, (t == arcDegreesMeasurements.start) ? [[UIColor systemGreenColor] CGColor] : (t == arcDegreesMeasurements.end()()) ? [[UIColor systemRedColor] CGColor] : [[UIColor systemBlueColor] CGColor]);
            CGContextSetLineWidth(ctx, (t == arcDegreesMeasurements.start || t == arcDegreesMeasurements.end()()) ? 2.0 : (t % 10 == 0) ? 1.0 : 0.625);
            CGContextMoveToPoint(ctx, xy_outer.x + CGRectGetMidX(bounds), xy_outer.y + CGRectGetMidY(bounds));
            CGContextAddLineToPoint(ctx, xy_inner.x + CGRectGetMidX(bounds), xy_inner.y + CGRectGetMidY(bounds));
        }
        
        CGContextStrokePath(ctx);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [(CAShapeLayer *)self.layer display];
    }
    
    return self;
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ^ (dispatch_block_t completion_block) {
        completion_block();
    }(^ (CAShapeLayer * layer) {
          arcDegreesMeasurements.start = (NSUInteger)(^ CGFloat (UITouch * touch) {
              return rescale(
                             ^ CGPoint (void) {
                                 return CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                                    fmaxf(CGRectGetMinY(touch.view.bounds), fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y)));
                             }().x,
                             CGRectGetMinX(touch.view.bounds),
                             CGRectGetMaxX(touch.view.bounds),
                             0.0,
                             359.0);
          }(touches.anyObject));
          return ^ {
                [layer setNeedsDisplay];
            };
      }((CAShapeLayer *)self.layer));
}

// To-Do: Gradually inch the edge of the circle to the finger if the finger is not on the edge while dragging (the finger should eventually be connected to the edge of the circle, but not in one jump)

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ^ (dispatch_block_t completion_block) {
        completion_block();
    }(^ (CAShapeLayer * layer) {
          arcDegreesMeasurements.start = (NSUInteger)(^ CGFloat (UITouch * touch) {
              return rescale(
                             ^ CGPoint (void) {
                                 return CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                                    fmaxf(CGRectGetMinY(touch.view.bounds), fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y)));
                             }().x,
                             CGRectGetMinX(touch.view.bounds),
                             CGRectGetMaxX(touch.view.bounds),
                             0.0,
                             359.0);
          }(touches.anyObject));
          return ^ {
                [layer setNeedsDisplay];
            };
      }((CAShapeLayer *)self.layer));
}

// To-Do: Animate the edge of the circle meeting the finger is dragging is offset (the edge of the circle should meet where the finger was lifted (?))

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ^ (dispatch_block_t completion_block) {
        completion_block();
    }(^ (CAShapeLayer * layer) {
          arcDegreesMeasurements.start = (NSUInteger)(^ CGFloat (UITouch * touch) {
              return rescale(
                             ^ CGPoint (void) {
                                 return CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                                    fmaxf(CGRectGetMinY(touch.view.bounds), fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y)));
                             }().x,
                             CGRectGetMinX(touch.view.bounds),
                             CGRectGetMaxX(touch.view.bounds),
                             0.0,
                             359.0);
          }(touches.anyObject));
          return ^ {
                [layer setNeedsDisplay];
            };
      }((CAShapeLayer *)self.layer));
}

@end
