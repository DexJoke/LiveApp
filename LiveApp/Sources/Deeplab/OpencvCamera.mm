//
//  NostalgiaCamera.m
//  DeeplabOnIOS
//
//  Created by Dwayne Forde on 2017-12-23.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>
#include "OpencvCamera.h"
#include "TfliteWrapper.h"

using namespace std;
using namespace cv;


@interface OpencvCamera () <CvVideoCameraDelegate>
@end


@implementation OpencvCamera
{
    UIViewController<OpencvCameraDelegate> * delegate;
    CvVideoCamera * videoCamera;
    TfliteWrapper  *tfLiteWrapper;
    cv::Mat imgBackground;
    bool isEnableBackground;
}

- (id)initWithController:(UIViewController<OpencvCameraDelegate>*)c
{
    isEnableBackground = false;
    delegate = c;
    videoCamera = [[CvVideoCamera alloc] init]; // Init with the UIImageView from the ViewController
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront; // Use the back camera
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;

    videoCamera.rotateVideo = YES; // Ensure proper orientation
    videoCamera.defaultFPS = 25; // How often 'processImage' is called, adjust based on the amount/complexity of images
    videoCamera.delegate = self;
//    videoCamera
    
    tfLiteWrapper = [[TfliteWrapper alloc]init];
    tfLiteWrapper = [tfLiteWrapper initWithModelFileName:@"deeplabv3_257_mv_gpu"];
    if(![tfLiteWrapper setUpModelAndInterpreter]) {
        NSLog(@"Failed To Load Model");
        return self;
    }
    
    //    String imageName( "background.jpg" );
    //    Mat image;
    //    image = imread( "background.jpg" , IMREAD_COLOR );
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"];
    const char * cpath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    Mat img_object = imread(cpath);
    cv::cvtColor(img_object, imgBackground, COLOR_BGR2BGRA);
    
    return self;
}

-(void) changeCamera {
    [videoCamera switchCameras];
}

-(void) addBackground: (UIImage*) bgImage {
    if(bgImage == nil) {
        isEnableBackground = false;
        return;
    }
    
    Mat img_object;
    UIImageToMat(bgImage, img_object);
    cv::cvtColor(img_object, imgBackground, COLOR_BGR2BGRA);
    isEnableBackground = true;
}


- (void)processImage:(cv::Mat &)frame {
    cvtColor(frame, frame, COLOR_BGRA2RGBA);

    if(!isEnableBackground) {
        UIImage* img = MatToUIImage(frame);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self->delegate onAddBackground: img];
        });
        return;
    }

    cv::Mat small;
    cv::resize(frame, small, cv::Size(257, 257), 0, 0, INTER_LINEAR);
    float_t *input = [tfLiteWrapper inputTensortFloatAtIndex:0];
    Mat humanMask = Mat(257, 257, CV_8UC4, Scalar(0,0,0,0));

    //BGRA2RGB
    int inputCnt = 0;
    for (int row = 0; row < small.rows; row++) {
        uchar* data = small.ptr(row);
        for (int col = 0; col < small.cols; col++) {
            input[inputCnt++] = (float)data[col * 4 + 2] / 255.0; // Red
            input[inputCnt++] = (float)data[col * 4 + 1] / 255.0; // Green
            input[inputCnt++] = (float)data[col * 4 ] / 255.0; // Bule
        }
    }

    if(![tfLiteWrapper invokeInterpreter]) {
        return;
    }

    float_t *output = [tfLiteWrapper outputTensorAtIndex:0];
    for (int row = 0; row < small.rows; row++) {
        uchar* humandata = humanMask.ptr(row);

        int rowBegin = row * small.cols * 21;
        for (int col = 0; col < small.cols; col++) {
            int colBegin = rowBegin + col  * 21;
            bool isHuman = true;
            float maxValue = output[colBegin + 15];

            for(int chan = 0; chan < 21; chan++) {
                if(output[colBegin+chan] > maxValue) {
                    isHuman = false;
                    break;
                }
            }

            if(isHuman) {
                humandata[col * 4] = 1;
                humandata[col * 4 + 1] = 1;
                humandata[col * 4 + 2] = 1;
                humandata[col * 4 + 3] = 1;
            }
        }
    }

    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    Mat bigMask;
    Mat background;
    cv::resize(self->imgBackground, background, cv::Size(frame.cols, frame.rows), 0, 0, INTER_LINEAR);
    cv::resize(humanMask, bigMask, cv::Size(frame.cols, frame.rows), 0, 0, INTER_LINEAR);
    GaussianBlur(bigMask, bigMask, cv::Size(5,5), 11);
    GaussianBlur(bigMask, bigMask, cv::Size(5,5), 11);

    Mat realbg;
    Mat human = frame.mul(bigMask);
    Mat bg = background.mul(bigMask);

    cv::subtract(background, bg, realbg);

    Mat outputMat;

    add(realbg, human, outputMat);

    UIImage* img = MatToUIImage(outputMat);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->delegate onAddBackground: img];
    });
    //    });

    return;
}

- (void)start
{
    [videoCamera start];
}

- (void)stop
{
    [videoCamera stop];
}

@end
