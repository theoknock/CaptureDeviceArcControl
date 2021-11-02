//
//  ConfigurationView.m
//  CaptureDeviceArcControl
//
//  Created by Xcode Developer on 11/2/21.
//

#import "ConfigurationView.h"

#define degreesToRadians(x) ((x) * M_PI / 180.0)

@implementation ConfigurationView {
    void(^arc_control_attributes_guide)(CGFloat, CGFloat);
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (NSInteger subview_index = 0; subview_index < 5; subview_index++) {
        UIView * subview;
        [subview = [UIView new] setBackgroundColor:[UIColor systemGray4Color]];
        [subview setFrame:CGRectMake(0.0, 0.0, 42.0, 42.0)];
        [subview setCenter:CGPointMake(CGRectGetMaxX(self.bounds),
                                       CGRectGetMaxY(self.bounds))];
        [self addSubview:subview];
    }
    
    arc_control_attributes_guide = ^ (CAShapeLayer * guide_layer) {
        [(CAShapeLayer *)guide_layer setLineWidth:0.5];
        [(CAShapeLayer *)guide_layer setStrokeColor:[UIColor systemBlueColor].CGColor];
        [(CAShapeLayer *)guide_layer setFillColor:[UIColor clearColor].CGColor];
        [(CAShapeLayer *)guide_layer setBackgroundColor:[UIColor clearColor].CGColor];
        
        __block UIBezierPath * bezier_quad_curve;
        
        return ^ (CGFloat radius, CGFloat scale) {
            radius = CGRectGetMaxX(self.bounds) - (fmax(CGRectGetMinX(self.bounds), fminf(CGRectGetMaxX(self.bounds), radius)));
            bezier_quad_curve = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMaxX(self.bounds),
                                                                                  CGRectGetMaxY(self.bounds))
                                                               radius:radius startAngle:degreesToRadians(270.0) endAngle:degreesToRadians(180.0) clockwise:FALSE];

            CGMutablePathRef path_ref = bezier_quad_curve.CGPath;
            const CGRect rects[] = { CGPathGetBoundingBox(path_ref), CGPathGetPathBoundingBox(path_ref) };
            NSUInteger count = sizeof(rects) / sizeof(CGRect);
            CGPathAddRects(path_ref, NULL, rects, count);
            [(CAShapeLayer *)guide_layer setPath:path_ref];
            
            __block CGFloat angle = degreesToRadians(270.0 + 18.0);
            [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat x = CGRectGetMaxX(self.bounds) - fabs(radius * sinf(angle + degreesToRadians((18 - (18.0 / 5.0)) * idx)));
                CGFloat y = CGRectGetMaxY(self.bounds) - fabs(radius * cosf(angle + degreesToRadians((18 - (18.0 / 5.0)) * idx)));
                CGPoint new_center = CGPointMake(x, y);
                [subview setCenter:new_center];
            }];
        };
    }((CAShapeLayer *)[self layer]);
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
    arc_control_attributes_guide(touch_point.x, 1.0);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
    arc_control_attributes_guide(touch_point.x, 1.0);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
    arc_control_attributes_guide(touch_point.x, 1.0);
}

@end
