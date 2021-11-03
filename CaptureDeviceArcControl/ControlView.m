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
dispatch_block_t (^arc_control_radius_ref)(dispatch_block_t) = ^ (dispatch_block_t b) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UserArcControlConfiguration(UserArcControlConfigurationFileOperationRead)(&arc_control_radius);
    });
    return b;
};

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    arc_control_radius -= 42.0;
    CGFloat angle  = degreesToRadians(270.0);
    
    CGRect bounds = [layer bounds];
    CGContextTranslateCTM(ctx, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    
    for (int t = 0; t <= 100; t++) {
        CGFloat scaled_degrees = t * (90.0 / 100.0);
        
        CGFloat tick_height = (t % 10 == 0) ? 6.0 : 3.0;
        {
            CGPoint xy_outer = CGPointMake(CGRectGetMaxX(bounds) - fabs((arc_control_radius + tick_height) * sinf(angle + degreesToRadians(scaled_degrees))),
                                           CGRectGetMaxY(bounds) - fabs((arc_control_radius + tick_height) * cosf(angle + degreesToRadians(scaled_degrees))));
            CGPoint xy_inner = CGPointMake(CGRectGetMaxX(bounds) - fabs((arc_control_radius - tick_height) * sinf(angle + degreesToRadians(scaled_degrees))),
                                           CGRectGetMaxY(bounds) - fabs((arc_control_radius - tick_height) * cosf(angle + degreesToRadians(scaled_degrees))));
        
            CGContextSetStrokeColorWithColor(ctx, [[UIColor systemBlueColor] CGColor]);
            CGContextSetLineWidth(ctx, (t % 10 == 0) ? 0.625 : 0.3125);
            CGContextMoveToPoint(ctx, xy_outer.x, xy_outer.y);
            CGContextAddLineToPoint(ctx, xy_inner.x, xy_inner.y);
        }
        
        CGContextStrokePath(ctx);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        arc_control_radius_ref(^ {
            [(CAShapeLayer *)self.layer display];
        })();
        
    }
    
    return self;
}

static void (^rotate_value_arc_control)(CGRect, CGPoint) = ^ (CGRect touch_rect, CGPoint touch_point) {
//    printf("%s", (CGRectContainsPoint(
//                                      CGRectMake(CGRectGetMaxX(self.bounds) - arc_control_radius,
//                                                 CGRectGetMaxY(self.bounds) - arc_control_radius,
//                                                 arc_control_radius,
//                                                 arc_control_radius),
//                                      touch_point)) ? "\nTRUE\n" : "\nFALSE\n");
//
};


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    rotate_value_arc_control(
//                             ^ CGPoint (UITouch * touch) {
//                                 return CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
//                                                    fmaxf(CGRectGetMinY(touch.view.bounds), fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y)));
//                             }((UITouch *)touches.anyObject));
}

// To-Do: Gradually inch the edge of the circle to the finger if the finger is not on the edge while dragging (the finger should eventually be connected to the edge of the circle, but not in one jump)

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
}

// To-Do: Animate the edge of the circle meeting the finger is dragging is offset (the edge of the circle should meet where the finger was lifted (?))

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
}

@end
