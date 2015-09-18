//
//  AVCaptureManager.h
//  SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AVCaptureManagerDelegate <NSObject>
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                      error:(NSError *)error;
@end


@interface AVCaptureManager : NSObject

@property (nonatomic, assign) id<AVCaptureManagerDelegate> delegate;
@property (nonatomic, readonly) BOOL isRecording;

- (id)initWithPreviewView:(UIView *)previewView;
- (void)toggleContentsGravity;
- (void)switchCamera;
- (void)resetFormat;
- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS;
- (void)startRecording;
- (void)stopRecording;
/**
 
 1、模拟api
 json
 
 1：上传视频源
 
 1）、上传视频链接 
   1-1）:验证链接有效性
 2）、自己录制、本地视频－－－>mp4文件
 3）发布动态
 
 2:浏览动态
 
  自己浏览
  别人浏览 －－－审核中看不到
 

 
 */
@end
