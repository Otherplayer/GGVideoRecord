//
//  ViewController.m
//  GGVideoRecord
//
//  Created by __无邪_ on 15/9/15.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import "ViewController.h"
#import "HYQVideoRecordManager.h"
@interface ViewController ()
@property (nonatomic, strong)UIImagePickerController *pickerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)startAction:(id)sender {
    
    [[HYQVideoRecordManager sharedInstance] showVideoRecord:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
