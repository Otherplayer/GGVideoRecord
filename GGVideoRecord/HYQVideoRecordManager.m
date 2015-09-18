//
//  HYQVideoRecordManager.m
//  GGVideoRecord
//
//  Created by __无邪_ on 15/9/15.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import "HYQVideoRecordManager.h"

#define  kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define  kScreenWidth  [[UIScreen mainScreen] bounds].size.width

@interface HYQVideoRecordManager ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong)UIImagePickerController *pickerView;

@end

@implementation HYQVideoRecordManager

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static HYQVideoRecordManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[HYQVideoRecordManager alloc] init];
    });
    return manager;
}

- (void)showVideoRecord:(UIViewController *)controller{
    HYQVideoRecordView *recordView = [[HYQVideoRecordView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    self.pickerView = [[UIImagePickerController alloc] init];
    
    self.pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    self.pickerView.videoMaximumDuration = kMaxDuration;
    self.pickerView.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.pickerView.cameraOverlayView = recordView;
    self.pickerView.showsCameraControls = NO;
    self.pickerView.delegate = self;
    [controller presentViewController:self.pickerView animated:YES completion:nil];
    
    
    [recordView setDidClickStartButton:^(BOOL flag) {
        if (flag) {
            [self.pickerView startVideoCapture];
        }else{
            [self.pickerView stopVideoCapture];
        }
    }];

}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0){
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@",info);
    NSURL *urlPath = info[UIImagePickerControllerMediaURL];
    [self encodeVideo:urlPath];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"%@",picker);
}



#pragma mark - 

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
                NSLog(@"Successful!%@",urlPath);
                [self performSelectorOnMainThread:@selector(convertFinish:) withObject:_mp4Path waitUntilDone:NO];
                break;
            default:
                break;
        }
    }];
}

- (void)convertFinish:(NSString *)urlPath{
    NSLog(@"转码完成%@",urlPath);
}








@end
