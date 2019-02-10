//
//  HCLogUploadResultViewController.h
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/2/10.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCLogFileUploadManager.h"

@interface HCLogUploadResultViewController : UIViewController

@property (nonatomic, strong) NSDate *selecedUploadDate;

- (instancetype)initWithUploadType:(HCNeedUploadType)uploadType;

@end

