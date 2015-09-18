//
//  HYQVideoRecordView.h
//  GGVideoRecord
//
//  Created by __无邪_ on 15/9/15.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOOLBAR_HEIGHT 125.0f

@interface HYQVideoRecordView : UIView
@property (nonatomic, strong)void(^(didClickStartButton))(BOOL flag);
@property (nonatomic, strong)void(^(didClickStopButton))();
@end
