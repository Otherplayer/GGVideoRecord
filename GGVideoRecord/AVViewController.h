//
//  ViewController.h
//  SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol AVViewControllerDelegate <NSObject>

- (void)didGetVideoUrlPath:(NSString *)urlPath;

@end

@interface AVViewController : UIViewController

@property (nonatomic, assign)id<AVViewControllerDelegate>delegate;

@end
