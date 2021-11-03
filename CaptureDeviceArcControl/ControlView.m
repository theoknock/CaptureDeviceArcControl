//
//  ControlView.m
//  CaptureDeviceArcControl
//
//  Created by Xcode Developer on 11/3/21.
//

#import "ControlView.h"
#import "CaptureDeviceConfigurationPropertyResources.h"

@implementation ControlView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)drawLayer:(CAReplicatorLayer *)layer inContext:(CGContextRef)ctx {
    CGFloat radius;
    UserArcControlConfiguration(UserArcControlConfigurationFileOperationRead)(&radius);
    radius -= 42.0;
    CGFloat angle  = degreesToRadians(270.0);
    
    CGRect bounds = [layer bounds];
    CGContextTranslateCTM(ctx, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    
    for (int t = 0; t <= 100; t++) {
        CGFloat scaled_degrees = t * (90.0 / 100.0);
        
        CGFloat tick_height = (t % 10 == 0) ? 6.0 : 3.0;
        {
            CGPoint xy_outer = CGPointMake(CGRectGetMaxX(bounds) - fabs((radius + tick_height) * sinf(angle + degreesToRadians(scaled_degrees))),
                                           CGRectGetMaxY(bounds) - fabs((radius + tick_height) * cosf(angle + degreesToRadians(scaled_degrees))));
            CGPoint xy_inner = CGPointMake(CGRectGetMaxX(bounds) - fabs((radius - tick_height) * sinf(angle + degreesToRadians(scaled_degrees))),
                                           CGRectGetMaxY(bounds) - fabs((radius - tick_height) * cosf(angle + degreesToRadians(scaled_degrees))));
        
            CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
            CGContextSetLineWidth(ctx, (t % 10 == 0) ? 0.625 : 0.3125);
            CGContextMoveToPoint(ctx, xy_outer.x, xy_outer.y);
            CGContextAddLineToPoint(ctx, xy_inner.x, xy_inner.y);
        }
        
        CGContextStrokePath(ctx);
    }
}

/*
 CAReplicatorLayer *replicator = [CAReplicatorLayer layer];
 replicator.frame = self.bounds;
 [self.layer addSublayer:replicator];
 replicator.instanceCount = 100;
 
 CGFloat radius;
 UserArcControlConfiguration(UserArcControlConfigurationFileOperationRead)(&radius);
 CGFloat angle = degreesToRadians(90.0) / replicator.instanceCount;
 CATransform3D transform = CATransform3DIdentity;
 transform = CATransform3DRotate(transform,
                                 angle, 0.0, 0.0, 1.0);
 [replicator setInstanceTransform:transform];
 replicator.instanceBlueOffset  = -1.0 / replicator.instanceCount;
 replicator.instanceGreenOffset = -1.0 / replicator.instanceCount;
 replicator.instanceRedOffset   = -1.0 / replicator.instanceCount;
 
 CALayer *layer = [CALayer layer];
 layer.frame = CGRectMake(radius, radius, 10.0, 1.0);
 layer.backgroundColor = [UIColor systemBlueColor].CGColor;
 [replicator addSublayer:layer];
 */



- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self drawLayer:self.layer inContext:UIGraphicsGetCurrentContext()];
        [(CAShapeLayer *)self.layer display];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
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
