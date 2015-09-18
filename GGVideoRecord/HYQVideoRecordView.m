//
//  HYQVideoRecordView.m
//  GGVideoRecord
//
//  Created by __无邪_ on 15/9/15.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import "HYQVideoRecordView.h"

@interface HYQVideoRecordView ()
@property (nonatomic, strong)UIButton *startButton;
@property (nonatomic, strong)UILabel *timeLabel;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger duration;
@end

@implementation HYQVideoRecordView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.duration = 0;
        [self initTopLayout];
        [self initBottomLayout];

    }
    return self;
}


#pragma mark - action

- (void)startAction:(id)sender{
    self.startButton.selected = !self.startButton.isSelected;
    if (self.didClickStartButton) {
        if (self.startButton.isSelected) {
            [self timer];
        }else{
            [self killTimer];
        }
        self.didClickStartButton(self.startButton.isSelected);
    }
}

- (void)stopAction:(id)sender{
    if (self.didClickStopButton) {
        self.didClickStopButton();
    }
}

- (void)interlinkageAction:(id)sender{
    
}

- (void)pressSwitchAction:(id)sender{
    
}

- (void)pressCloseAction:(id)sender{
    
}

- (void)startCount:(id)sender{
    self.duration++;
    if (self.duration >= 30) {
        self.duration =30;
        [self stopAction:nil];
    }
    NSString *timeStr = [NSString stringWithFormat:@"00:00:%02ld",30 - self.duration];
    [self.timeLabel setText:timeStr];
}






#pragma mark - configure


- (void)initTopLayout{
    CGFloat buttonW = 35.0f;
    
    
    UIView *bgTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 50)];
    [bgTopView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
    [bgTopView setUserInteractionEnabled:YES];
    [self addSubview:bgTopView];
    
    //关闭
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 8, buttonW, buttonW)];
    [closeButton setImage:[UIImage imageNamed:@"record_close_normal.png"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"record_close_disable.png"] forState:UIControlStateDisabled];
    [closeButton setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateSelected];
    [closeButton setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(pressCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgTopView addSubview:closeButton];
    
    
    //时间
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 150) / 2, 0, 150, 50)];
    [self.timeLabel setTextColor:[UIColor whiteColor]];
    [self.timeLabel setFont:[UIFont systemFontOfSize:17]];
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [bgTopView addSubview:self.timeLabel];
    [self.timeLabel setText:@"00:00:30"];
    
    //前后摄像头转换
    UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - (buttonW + 10), 8, buttonW, buttonW)];
    [switchButton setBackgroundColor:[UIColor redColor]];
    [switchButton setImage:[UIImage imageNamed:@"record_lensflip_normal.png"] forState:UIControlStateNormal];
    [switchButton setImage:[UIImage imageNamed:@"record_lensflip_disable.png"] forState:UIControlStateDisabled];
    [switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateSelected];
    [switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateHighlighted];
    [switchButton addTarget:self action:@selector(pressSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgTopView addSubview:switchButton];

}



- (void)initBottomLayout{
    UIView *bgBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - TOOLBAR_HEIGHT, CGRectGetWidth(self.bounds), TOOLBAR_HEIGHT)];
    [bgBottomView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
    [bgBottomView setUserInteractionEnabled:YES];
    [self addSubview:bgBottomView];
    
    //链接
    UIButton *leftInterlinkage = [[UIButton alloc] initWithFrame:CGRectMake(24, (TOOLBAR_HEIGHT - 45)/2 , 45, 45)];
    [leftInterlinkage setBackgroundColor:[UIColor redColor]];
    [bgBottomView addSubview:leftInterlinkage];
    [leftInterlinkage addTarget:self action:@selector(interlinkageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *leftInterlinkageLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, (TOOLBAR_HEIGHT - 45)/2 + 45, 45, 20)];
    [leftInterlinkageLabel setFont:[UIFont systemFontOfSize:11]];
    [leftInterlinkageLabel setTextColor:[UIColor whiteColor]];
    [leftInterlinkageLabel setText:@"发布链接"];
    [bgBottomView addSubview:leftInterlinkageLabel];
    
    
    //录制
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 60)/2, (TOOLBAR_HEIGHT - 60)/2 , 60, 60)];
    [self.startButton setBackgroundColor:[UIColor redColor]];
    [bgBottomView addSubview:self.startButton];
    [self.startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    

}



-(NSTimer *)timer{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCount:) userInfo:nil repeats:YES];
    }
    return _timer;
}


- (void)killTimer{
    [_timer invalidate];
    _timer = nil;
}





@end
