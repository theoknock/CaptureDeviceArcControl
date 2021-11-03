//
//  ConfigurationView.m
//  CaptureDeviceArcControl
//
//  Created by Xcode Developer on 11/2/21.
//

#import "ConfigurationView.h"
#import "CaptureDeviceConfigurationPropertyResources.h"

#define degreesToRadians(x) ((x) * M_PI / 180.0)

@implementation ConfigurationView {
    void(^arc_control_attributes_guide)(CGFloat, CGFloat);
}

static UIButton * (^(^CaptureDeviceConfigurationPropertyButtons)(NSArray<NSArray<NSString *> *> * const, CAShapeLayer *))(CaptureDeviceConfigurationControlProperty) = ^ (NSArray<NSArray<NSString *> *> * const captureDeviceConfigurationControlPropertyImageNames, CAShapeLayer * shape_layer) {
    CGFloat button_boundary_length = (CGRectGetMaxX(UIScreen.mainScreen.bounds) - CGRectGetMinX(UIScreen.mainScreen.bounds)) / ((CGFloat)captureDeviceConfigurationControlPropertyImageNames[0].count - 1.0);
    __block NSMutableArray<UIButton *> * buttons = [[NSMutableArray alloc] initWithCapacity:captureDeviceConfigurationControlPropertyImageNames[0].count];
    [captureDeviceConfigurationControlPropertyImageNames[0] enumerateObjectsUsingBlock:^(NSString * _Nonnull imageName, NSUInteger idx, BOOL * _Nonnull stop) {
        [buttons addObject:^ (CaptureDeviceConfigurationControlProperty property) {
            UIButton * button;
            [button = [UIButton new] setTag:property];
            
            [button setBackgroundColor:[UIColor clearColor]];
            [button setShowsTouchWhenHighlighted:TRUE];
            
            [button setImage:[UIImage systemImageNamed:captureDeviceConfigurationControlPropertyImageNames[0][idx] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateDeselected)] forState:UIControlStateNormal];
            [button setImage:[UIImage systemImageNamed:captureDeviceConfigurationControlPropertyImageNames[1][idx] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateSelected)] forState:UIControlStateSelected];
            
            [button sizeToFit];
            CGSize button_size = [button intrinsicContentSize];
            [button setFrame:CGRectMake(0.0, 0.0,
                                        button_size.width, button_size.height)];
            [button setCenter:CGPointMake(button_boundary_length * property,
                                          CGRectGetMidY(UIScreen.mainScreen.bounds))];

//            [button setEventHandlerBlock:^ {
//                BezierQuadCurveControlPoints bezier_quad_curve_plot_points = bezier_quad_curve_control_points(
//                                                                                                    NSMakeRange(CGRectGetMinX(UIScreen.mainScreen.bounds), (CGRectGetMaxX(UIScreen.mainScreen.bounds) - CGRectGetMinX(UIScreen.mainScreen.bounds))),
//                                                                                                    NSMakeRange(CGRectGetMidY(UIScreen.mainScreen.bounds) + (button_size.height / 2.0), -button_size.height * 2.0/*CGRectGetMinY(UIScreen.mainScreen.bounds))*/),
//                                                                                                    button_boundary_length * property,
//                                                                                                    NSMakeRange(CGRectGetMinX(UIScreen.mainScreen.bounds), (CGRectGetMaxX(UIScreen.mainScreen.bounds) - CGRectGetMinX(UIScreen.mainScreen.bounds)))
//                                                                                                    );
//                BezierQuadCurvePoint bezier_quad_curve_point_position = bezier_quad_curve(bezier_quad_curve_plot_points);
//
//                CGMutablePathRef quad_curve_path = ^ CGMutablePathRef (NSValue * p) {
//                    BezierQuadCurveControlPoints points;
//                    [p getValue:&points];
//                    UIBezierPath * quad_curve = [UIBezierPath bezierPath];
//                    [quad_curve moveToPoint:points.start_point];
//                    [quad_curve addQuadCurveToPoint:points.end_point controlPoint:points.control_point];
//                    return quad_curve.CGPath;
//                }(bezier_quad_curve_plot_points());
//
//                const CGRect rects[] = { /*CGPathGetBoundingBox(quad_curve_path),*/ CGPathGetPathBoundingBox(quad_curve_path) };
//                NSUInteger count = sizeof(rects) / sizeof(CGRect);
//                CGPathAddRects(quad_curve_path, NULL, rects, count);
//
//                [(CAShapeLayer *)shape_layer setStrokeColor:[UIColor whiteColor].CGColor];
//                [(CAShapeLayer *)shape_layer setFillColor:[UIColor clearColor].CGColor];
//                [(CAShapeLayer *)shape_layer setLineWidth:0.5];
//                [(CAShapeLayer *)shape_layer setPath:quad_curve_path];
//
//
//                for (UIButton * b in buttons) {
//                    [b setSelected:(b.tag == [buttons objectAtIndex:property].tag) ? TRUE : FALSE];
//                    CGFloat t_position = button_boundary_length * b.tag;
//                    CGPoint position = bezier_quad_curve_point_position(t_position);
////                    CGFloat x = rescale(position.x,
////                                        CGRectGetMinX(UIScreen.mainScreen.bounds),
////                                        CGRectGetMinX(UIScreen.mainScreen.bounds) + ((CGRectGetMaxX(UIScreen.mainScreen.bounds) - CGRectGetMinX(UIScreen.mainScreen.bounds))),
////                                        t_position,
////                                        CGRectGetMinX(UIScreen.mainScreen.bounds) + ((CGRectGetMaxX(UIScreen.mainScreen.bounds) - CGRectGetMinX(UIScreen.mainScreen.bounds))));
//                    [UIView animateWithDuration:0.2 animations:^{
//                        [b setCenter:CGPointMake(position.x, CGRectGetMidY(UIScreen.mainScreen.bounds))];
//                    }];
//                }
//            }];
//            [button addTarget:button.eventHandlerBlock action:@selector(invoke) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
            
            return ^ UIButton * (void) {
                return button;
            };
        }((CaptureDeviceConfigurationControlProperty)idx)()];
    }];
    return ^ UIButton * (CaptureDeviceConfigurationControlProperty property) {
        return [buttons objectAtIndex:property];
    };
};

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIButton * (^CaptureDeviceConfigurationPropertyButton)(CaptureDeviceConfigurationControlProperty) = CaptureDeviceConfigurationPropertyButtons(CaptureDeviceConfigurationControlPropertyImageValues, (CAShapeLayer *)self.layer);
    for (CaptureDeviceConfigurationControlProperty property = 0; property < CaptureDeviceConfigurationControlPropertyImageKeys.count; property++) {
        [self addSubview:CaptureDeviceConfigurationPropertyButton(property)];
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
            
            __block CGFloat angle = degreesToRadians(270.0);
            [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat scaled_degrees = rescale(22.5 * idx, 0.0, 90, 11.125, 78.875);
                CGFloat x = CGRectGetMaxX(self.bounds) - fabs(radius * sinf(angle + degreesToRadians(scaled_degrees)));
                CGFloat y = CGRectGetMaxY(self.bounds) - fabs(radius * cosf(angle + degreesToRadians(scaled_degrees)));
                CGPoint new_center = CGPointMake(x, y);
                [subview setCenter:new_center];
            }];
        };
    }((CAShapeLayer *)[self layer]);
}

// To-Do: Keep circle at current radius on touchesBegan, adding or subtracting the value of the touch point (makes it easier to make adjustments to the arc control radius when the drag-target is range-wide and prevents jumping from the current radius to the finger location)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
    arc_control_attributes_guide(touch_point.x, 1.0);
}

// To-Do: Gradually inch the edge of the circle to the finger if the finger is not on the edge while dragging (the finger should eventually be connected to the edge of the circle, but not in one jump)

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
    arc_control_attributes_guide(touch_point.x, 1.0);
}

// To-Do: Animate the edge of the circle meeting the finger is dragging is offset (the edge of the circle should meet where the finger was lifted (?))

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    
    arc_control_attributes_guide(touch_point.x, 1.0);
}

@end
