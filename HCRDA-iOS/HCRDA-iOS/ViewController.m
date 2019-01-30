//
//  ViewController.m
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/1/30.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((width - 100) * 0.5,
                                                               (height - 100) * 0.5,
                                                               100, 100)];
    label.text = @"点击电池三下\n查看日志调试模块";
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}


@end
