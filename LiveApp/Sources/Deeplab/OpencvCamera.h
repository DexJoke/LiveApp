//
//  OpencvCamera.h
//  TwilioRenderer
//
//  Created by Tùng Anh Nguyễn on 04/02/2021.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CMSampleBuffer.h>
#import <UIKit/UIImage.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <Accelerate/Accelerate.h>

// Protocol for callback action
@protocol OpencvCameraDelegate <NSObject>

- (void)onAddBackground:(UIImage*) resultImage;

@end

// Public interface for camera. ViewController only needs to init, start and stop.
@interface OpencvCamera : NSObject
-(id) initWithController:(UIViewController<OpencvCameraDelegate>*)c;
-(void) start;
-(void) addBackground: (UIImage*) bgImage;
-(void) changeCamera;
@end
