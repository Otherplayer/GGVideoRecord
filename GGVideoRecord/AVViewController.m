//
//  ViewController.m
//  SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "AVViewController.h"

#import "AVCaptureManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HYQVideoRecordView.h"
//#import "HYQCheckVideoLinkController.h"

@interface AVViewController ()<AVCaptureManagerDelegate>
{
    NSTimeInterval startTime;
    BOOL isNeededToSave;
}
@property (nonatomic, strong) AVCaptureManager *captureManager;
@property (nonatomic, assign) NSTimer *timer;
@property (nonatomic, strong) UIImage *recStartImage;
@property (nonatomic, strong) UIImage *recStopImage;
@property (nonatomic, strong) UIImage *outerImage1;
@property (nonatomic, strong) UIImage *outerImage2;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *fpsControl;
@property (nonatomic, weak) IBOutlet UIButton *recBtn;
@property (nonatomic, weak) IBOutlet UIImageView *outerImageView;



@property (nonatomic, strong)HYQVideoRecordView *recordView;
@property (nonatomic, assign)BOOL canDoNext;


@end


@implementation AVViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    
    [self.view addSubview:videoView];
    
    self.captureManager = [[AVCaptureManager alloc] initWithPreviewView:self.view];
    self.captureManager.delegate = self;
    self.canDoNext = YES;
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(handleDoubleTap:)];
//    tapGesture.numberOfTapsRequired = 2;
//    [self.view addGestureRecognizer:tapGesture];
    
    
    // Setup images for the Shutter Button
//    UIImage *image;
//    image = [UIImage imageNamed:@"ShutterButtonStart"];
//    self.recStartImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.recBtn setImage:self.recStartImage
//                 forState:UIControlStateNormal];
//    
//    image = [UIImage imageNamed:@"ShutterButtonStop"];
//    self.recStopImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//
//    [self.recBtn setTintColor:[UIColor colorWithRed:245./255.
//                                              green:51./255.
//                                               blue:51./255.
//                                              alpha:1.0]];
//    self.outerImage1 = [UIImage imageNamed:@"outer1"];
//    self.outerImage2 = [UIImage imageNamed:@"outer2"];
//    self.outerImageView.image = self.outerImage1;
    
    [self.navigationController setHide:YES];
    
    self.recordView = [[HYQVideoRecordView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.recordView];
    
    
    HYQWS(weakSelf);
    [self.recordView setDidClickCloseButton:^{
        weakSelf.canDoNext = NO;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.recordView setDidClickStartButton:^(BOOL flag) {
        [weakSelf recButtonTapped:nil];
    }];
    
    [self.recordView setDidClickStopButton:^{
        [weakSelf recButtonTapped:nil];
    }];
    
    [self.recordView setDidReachTargetTime:^{
        [weakSelf shouldStopimmediately];
    }];
    
    // 发布链接
    [self.recordView setDidCheckVideoLinkButton:^{
        if (!weakSelf.captureManager.isRecording) {
            HYQCheckVideoLinkController *checkController = [[HYQCheckVideoLinkController alloc] init];
            [checkController setHidesBottomBarWhenPushed:YES];
            [weakSelf.navigationController pushViewController:checkController animated:YES];
        }else{
            [HYQShowTip showTipTextOnly:@"您正在拍摄，暂不能发布链接" dealy:2];
        }
    }];

    [self.recordView setDidClickSwitchButton:^(BOOL flag) {
        if (!weakSelf.captureManager.isRecording) {
            [weakSelf.captureManager switchCamera];
        }else{
            [HYQShowTip showTipTextOnly:@"您正在拍摄，暂不能切换相机" dealy:2];
        }
    }];

    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setHide:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setHide:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)shouldStopimmediately{
    [self.captureManager stopRecording];
    
    [self.timer invalidate];
    self.timer = nil;
}

-(void)compassVideo
{
    
}

// =============================================================================
#pragma mark - Gesture Handler

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {

    [self.captureManager toggleContentsGravity];
}

// =============================================================================
#pragma mark - Private


- (void)saveRecordedFile:(NSURL *)recordedFile {
    
//    [SVProgressHUD showWithStatus:@"Saving..."
//                         maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        [assetLibrary writeVideoAtPathToSavedPhotosAlbum:recordedFile
                                         completionBlock:
         ^(NSURL *assetURL, NSError *error) {
             
             [self saveRecordedFileMp4:recordedFile];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
//                 [SVProgressHUD dismiss];
                 
                 NSString *title;
                 NSString *message;
                 
                 if (error != nil) {
                     
                     title = @"Failed to save video";
                     message = [error localizedDescription];
                 }
                 else {
                     title = @"Saved!";
                     message = nil;
                 }
                 
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                 message:message
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             });
         }];
    });
}

-(void)saveRecordedFileMp4:(NSURL*)recordFile{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:recordFile options:nil];
    
    //
    AVAssetTrack *sourceAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        AVMutableComposition* composition = [AVMutableComposition composition];
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                    preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration)
                                       ofTrack:sourceAudioTrack
                                        atTime:kCMTimeZero error:nil];
        //
        
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        NSString* mp4Path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        exportSession.outputURL = [NSURL fileURLWithPath: mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        //
        exportSession.videoComposition = [self getVideoComposition:avAsset composition:composition];
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Successful!");
                    break;
                default:
                    break;
            }
        }];
        
    }
    
}

//get current orientation
-(AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset composition:( AVMutableComposition*)composition{
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionLayerInstruction *layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    CGAffineTransform transform = videoTrack.preferredTransform;
    [layerInst setTransform:transform atTime:kCMTimeZero];
    
    
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    
    CGSize videoSize = videoTrack.naturalSize;
    if(isPortrait_) {
        NSLog(@"video is portrait ");
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    videoComposition.renderSize = videoSize;
    videoComposition.frameDuration = CMTimeMake(1,30);
    videoComposition.renderScale = 1.0;
    return videoComposition;
}


//get video
-(BOOL) isVideoPortrait:(AVAsset *)asset{
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = FALSE;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = FALSE;
        }
    }
    return isPortrait;
}


// =============================================================================
#pragma mark - Timer Handler

- (void)timerHandler:(NSTimer *)timer {
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval recorded = current - startTime;
    
    self.statusLabel.text = [NSString stringWithFormat:@"%.2f", recorded];
}



// =============================================================================
#pragma mark - AVCaptureManagerDeleagte

- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
    
    if (error) {
        NSLog(@"error:%@", error);
        return;
    }
    
    if (!isNeededToSave) {
        return;
    }
    
    if (!self.canDoNext) {
        return;
    }
    
    [self encodeVideo:outputFileURL];
    
    //[self saveRecordedFile:outputFileURL];
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)recButtonTapped:(id)sender {
    
    // REC START
    if (!self.captureManager.isRecording) {

        // change UI
        [self.recBtn setImage:self.recStopImage
                     forState:UIControlStateNormal];
        self.fpsControl.enabled = NO;
        
        // timer start
        startTime = [[NSDate date] timeIntervalSince1970];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(timerHandler:)
                                                    userInfo:nil
                                                     repeats:YES];

        [self.captureManager startRecording];
    }
    // REC STOP
    else {
        
        if (self.recordView.duration > 2) {
            isNeededToSave = YES;
            [self.captureManager stopRecording];
            
            [self.timer invalidate];
            self.timer = nil;
            
            // change UI
            [self.recBtn setImage:self.recStartImage
                         forState:UIControlStateNormal];
            self.fpsControl.enabled = YES;
        }else{
            [GGProgressHUD showTip:@"视频长度过短！(最少2秒钟)" afterDelay:2];
        }

    }
}


- (IBAction)fpsChanged:(UISegmentedControl *)sender {
    
    // Switch FPS
    
    CGFloat desiredFps = 0.0;;
    switch (self.fpsControl.selectedSegmentIndex) {
        case 0:
        default:
        {
            break;
        }
        case 1:
            desiredFps = 60.0;
            break;
        case 2:
            desiredFps = 120.0;
            break;
    }
    
    
//    [SVProgressHUD showWithStatus:@"Switching..."
//                         maskType:SVProgressHUDMaskTypeGradient];
     
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        if (desiredFps > 0.0) {
            [self.captureManager switchFormatWithDesiredFPS:desiredFps];
        }
        else {
            [self.captureManager resetFormat];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (desiredFps > 30.0) {
                self.outerImageView.image = self.outerImage2;
            }
            else {
                self.outerImageView.image = self.outerImage1;
            }
//            [SVProgressHUD dismiss];
        });
    });
}

#pragma mark - private

- (void)encodeVideo:(NSURL *)urlPath{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:urlPath options:nil];
    //NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                           presetName:AVAssetExportPresetMediumQuality];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *_mp4Path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
    
    exportSession.outputURL = [NSURL fileURLWithPath: _mp4Path];
    exportSession.shouldOptimizeForNetworkUse = YES;//是否针对网络使用进行优化
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Error : %@",[[exportSession error] localizedDescription]);
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Successful!%@",_mp4Path);
                [self performSelectorOnMainThread:@selector(convertFinish:) withObject:_mp4Path waitUntilDone:NO];
                break;
            default:
                break;
        }
    }];
}

- (void)convertFinish:(NSString *)urlPath{
    NSLog(@"转码完成%@",urlPath);
    [HYQShowTip showTipTextOnly:@"处理完成" dealy:1.2];
    [self saveVideoToAlbum:urlPath];
    if (_delegate && [_delegate respondsToSelector:@selector(didGetVideoUrlPath:)]) {
        [_delegate didGetVideoUrlPath:urlPath];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    //NSString *urlp = [NSString stringWithFormat:@"file://localhost/private%@",urlPath];
//    void (^block)(NSString *filePath) = objc_getAssociatedObject(self, &GGVideoDidFinishedPicking);
//    if (block) block(urlPath);
}


- (void)saveVideoToAlbum:(NSString *)urlPath{
    UISaveVideoAtPathToSavedPhotosAlbum(urlPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
}
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}





@end
