//
//  HYQVideoRecordManager.h
//  GGVideoRecord
//
//  Created by __无邪_ on 15/9/15.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYQVideoRecordView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>

#define kMinDuration 2.0f
#define kMaxDuration 60.0f

@interface HYQVideoRecordManager : NSObject
+ (instancetype)sharedInstance;
- (void)showVideoRecord:(UIViewController *)controller;





@end
