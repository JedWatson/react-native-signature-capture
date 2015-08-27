#import "RSSignatureView.h"
#import "RCTConvert.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PPSSignatureView.h"
#import "RSSignatureViewManager.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation RSSignatureView {
    CAShapeLayer *_border;
    BOOL _loaded;
    EAGLContext *_context;
    UILabel *titleLabel;
}

@synthesize sign;
@synthesize manager;

-(instancetype) init
{
    if ((self = [super init])) {
        _border = [CAShapeLayer layer];
        _border.strokeColor = [UIColor blackColor].CGColor;
        _border.fillColor = nil;
        _border.lineDashPattern = @[@4, @2];

        [self.layer addSublayer:_border];
    }

    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if (!_loaded) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        CGSize screen = self.bounds.size;

        self.sign = [[PPSSignatureView alloc]
                     initWithFrame: CGRectMake(0, 0, screen.width, screen.height)
                     context: _context];

        [self addSubview:sign];
        

        //Save button
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[saveButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
        //[saveButton setLineBreakMode:NSLineBreakByClipping];
        [saveButton addTarget:self action:@selector(onSaveButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton.titleLabel setFont:[UIFont systemFontOfSize:22]];

        saveButton.frame = CGRectMake(sign.bounds.size.width - buttonSize.width, 0, buttonSize.width, buttonSize.height);
        [saveButton setBackgroundColor:[UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1.f]];
        [sign addSubview:saveButton];

        //Clear button
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[clearButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
        //[clearButton setLineBreakMode:NSLineBreakByClipping];
        [clearButton addTarget:self action:@selector(onClearButtonPressed)
              forControlEvents:UIControlEventTouchUpInside];
        [clearButton setTitle:@"Reset" forState:UIControlStateNormal];
        [clearButton.titleLabel setFont:[UIFont systemFontOfSize:22]];

        clearButton.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
        [clearButton setBackgroundColor:[UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1.f]];
        [sign addSubview:clearButton];

    }
    _loaded = true;
    _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    _border.frame = self.bounds;
}

-(void) onSaveButtonPressed {
    UIImage *signImage = [self.sign signatureImage];
    NSError *error;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/signature.png"];

    // Remove the file if it already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
        if (error) {
            NSLog(@"Error: %@", error.debugDescription);
        }
    }

    // Resize the image
    CGRect rect = CGRectMake(0, 0, 1024, 768);
    // make a new graphics context (think layer)
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 1.0f);
    // draw our source image to size in the layer
    [signImage drawInRect:rect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
    NSData *imageData = UIImagePNGRepresentation(resizedImage);
    BOOL isSuccess = [imageData writeToFile:tempPath atomically:YES];
    if (isSuccess) {
        NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];
        [self.manager saveImage:tempPath withEncoded:base64Encoded];
    }
}

-(void) onClearButtonPressed {
    [self.sign erase];
}

@end
