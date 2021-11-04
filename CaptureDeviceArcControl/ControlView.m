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

static CGRect arc_control_bounds;
static CGRect (^arc_control_bounds_ref)(CGRect) = ^ CGRect (CGRect parent_rect) {
    return CGRectMake(CGRectGetMaxX(parent_rect) - arc_control_radius,
                      CGRectGetMaxY(parent_rect) - arc_control_radius,
                      arc_control_radius,
                      arc_control_radius);
};

static CGFloat degrees;
dispatch_block_t (^degrees_ref)(dispatch_block_t, CGFloat) = ^ (dispatch_block_t b, CGFloat degrees_ptr) {
    printf("%s", __PRETTY_FUNCTION__);
    degrees = degrees_ptr;
    return b;
};

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    printf("\n%s\t\tdegrees == %f\t\tarca_control_radius == %f\n", __PRETTY_FUNCTION__, degrees, arc_control_radius);
    CGFloat modified_arc_control_radius = arc_control_radius - 42.0;
    
    CGRect bounds = [self bounds];
    CGContextTranslateCTM(ctx, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    
    for (int t = 0; t <= 100; t++) {
        CGFloat scaled_degrees = t * (45.0 / 100.0);
        CGFloat angle  = degrees + degreesToRadians(scaled_degrees);
        
        CGFloat tick_height = (t % 10 == 0) ? 6.0 : 3.0;
        {
            CGPoint xy_outer = CGPointMake(CGRectGetMaxX(bounds) - fabs((modified_arc_control_radius + tick_height) * sinf(angle)),
                                           CGRectGetMaxY(bounds) - fabs((modified_arc_control_radius + tick_height) * cosf(angle)));
            CGPoint xy_inner = CGPointMake(CGRectGetMaxX(bounds) - fabs((modified_arc_control_radius - tick_height) * sinf(angle)),
                                           CGRectGetMaxY(bounds) - fabs((modified_arc_control_radius - tick_height) * cosf(angle)));
            
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
            degrees_ref(^ {
                printf("\n%s\n", __PRETTY_FUNCTION__);
                
                [(CAShapeLayer *)self.layer display];
            }, (CGFloat)degreesToRadians(270.0))();
            
        })();
        
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    degrees_ref(^ {
        [(CAShapeLayer *)self.layer setNeedsDisplay];
    }, (CGFloat)degreesToRadians(rescale(^ CGPoint (UITouch * touch) {
        return CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:self].x)),
                           fmaxf(CGRectGetMinY(touch.view.bounds), fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:self].y)));
    }((UITouch *)touches.anyObject).x, CGRectGetMinX(self.bounds), CGRectGetMaxX(self.bounds)*2.0, 270.0, 360.0)))();
}

// To-Do: Gradually inch the edge of the circle to the finger if the finger is not on the edge while dragging (the finger should eventually be connected to the edge of the circle, but not in one jump)

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    degrees_ref(^ {
        [(CAShapeLayer *)self.layer setNeedsDisplay];
    }, (CGFloat)degreesToRadians(rescale(^ CGPoint (UITouch * touch) {
        return CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:self].x)),
                           fmaxf(CGRectGetMinY(touch.view.bounds), fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:self].y)));
    }((UITouch *)touches.anyObject).x, CGRectGetMinX(self.bounds), CGRectGetMaxX(self.bounds)*2.0, 270.0, 360.0)))();
}

// To-Do: Animate the edge of the circle meeting the finger is dragging is offset (the edge of the circle should meet where the finger was lifted (?))

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    degrees_ref(^ {
        [(CAShapeLayer *)self.layer setNeedsDisplay];
    }, (CGFloat)degreesToRadians(rescale(^ CGPoint (UITouch * touch) {
        return CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:self].x)),
                           fmaxf(CGRectGetMinY(touch.view.bounds), fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:self].y)));
    }((UITouch *)touches.anyObject).x, CGRectGetMinX(self.bounds), CGRectGetMaxX(self.bounds)*2.0, 270.0, 360.0)))();
}

@end
