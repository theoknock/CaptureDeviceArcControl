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
    void(^arc_control_attributes_guide)(CGFloat);
}

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
        
        return ^ (CGFloat radius) {
            radius = CGRectGetMaxX(self.bounds) - (fmax(22.5, fminf(CGRectGetMidX(self.bounds), radius)));
            bezier_quad_curve = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMaxX(self.bounds),
                                                                                  CGRectGetMaxY(self.bounds))
                                                               radius:radius startAngle:degreesToRadians(270.0) endAngle:degreesToRadians(180.0) clockwise:FALSE];
            
            CGMutablePathRef path_ref = bezier_quad_curve.CGPath;
            const CGRect rects[] = { CGPathGetBoundingBox(path_ref), CGPathGetPathBoundingBox(path_ref) };
            NSUInteger count = sizeof(rects) / sizeof(CGRect);
            CGPathAddRects(path_ref, NULL, rects, count);
            [(CAShapeLayer *)guide_layer setPath:path_ref];
            
            __block CGFloat angle = degreesToRadians(279.0);
            [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat scaled_degrees = (idx * 18.0);
                CGFloat x = CGRectGetMaxX(self.bounds) - fabs(radius * sinf(angle + degreesToRadians(scaled_degrees)));
                CGFloat y = CGRectGetMaxY(self.bounds) - fabs(radius * cosf(angle + degreesToRadians(scaled_degrees)));
                CGPoint new_center = CGPointMake(x, y);
                [subview setCenter:new_center];
            }];
        };
    }((CAShapeLayer *)[self layer]);
    
    arc_control_attributes_guide([self userArcControlConfiguration]);
}

// To-Do: Keep circle at current radius on touchesBegan, adding or subtracting the value of the touch point (makes it easier to make adjustments to the arc control radius when the drag-target is range-wide and prevents jumping from the current radius to the finger location)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    arc_control_attributes_guide(touch_point.x);
}

// To-Do: Gradually inch the edge of the circle to the finger if the finger is not on the edge while dragging (the finger should eventually be connected to the edge of the circle, but not in one jump)

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    arc_control_attributes_guide(touch_point.x);
}

// To-Do: Animate the edge of the circle meeting the finger is dragging is offset (the edge of the circle should meet where the finger was lifted (?))

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = (UITouch *)touches.anyObject;
    CGPoint touch_point = CGPointMake(fmaxf(CGRectGetMinX(touch.view.bounds), fminf(CGRectGetMaxX(touch.view.bounds), [touch locationInView:touch.view].x)),
                                      fminf(CGRectGetMaxY(touch.view.bounds), [touch locationInView:touch.view].y));
    arc_control_attributes_guide([self setUserArcControlConfiguration:touch_point.x]);
}

- (NSString *)userArcControlConfigurationFileName {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * fileName = [NSString stringWithFormat:@"%@/arc_control_configuration.dat", documentsDirectory];
    
    return fileName;
}

- (CGFloat)userArcControlConfiguration {
    CGFloat radius = (CGRectGetMidX(self.bounds) + CGRectGetMinX(self.bounds)) / 2.0;
    __autoreleasing NSError * error = nil;
    NSData *structureData = [[NSData alloc] initWithContentsOfFile:[self userArcControlConfigurationFileName] options:NSDataReadingUncached error:&error];
    if (!error) {
        NSDictionary<NSString *, NSNumber *> * structureDataAsDictionary = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:structureData error:&error];
        radius = [(NSNumber *)[structureDataAsDictionary objectForKey:@"PreferredArcRadius"] floatValue];
    }
    if (error) printf("\nERROR\t\t%s\n", [[error description] UTF8String]);
    
    return radius;
}

- (CGFloat)setUserArcControlConfiguration:(CGFloat)radius {
    NSDictionary<NSString *, NSNumber *> * structureDataAsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:radius], @"PreferredArcRadius", nil];
    __autoreleasing NSError * error = nil;
    NSData *structureData = [NSKeyedArchiver archivedDataWithRootObject:structureDataAsDictionary requiringSecureCoding:FALSE error:&error];
    if (!error) {
        ([structureData writeToFile:[self userArcControlConfigurationFileName] options:NSDataWritingAtomic error:&error]) ?
        ^{ printf("\nThe control-points preferences were saved to %s\n", [[self userArcControlConfigurationFileName] UTF8String]); }() :
        ^{ printf("\nThe control-points preferences were not saved\n"); }();
    }
    if (error) printf("\nERROR\t\t%s\n", [[error description] UTF8String]);
    
    return radius;
}

@end
