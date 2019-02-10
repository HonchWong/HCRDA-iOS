//
//  LogDebugModule.m
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/1/30.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import "LogDebugModule.h"
#import <HCDebugTool/HCDebugTool.h>
#import "XLogHelper.h"
#import "HCLogUploadViewController.h"

typedef NS_OPTIONS(NSInteger, HCLogDebugOptionViewTag) {
    HCLogDebugOptionViewTag_SetupXLog,
    HCLogDebugOptionViewTag_TestXLog,
    HCLogDebugOptionViewTag_UploadLog,
    HCLogDebugOptionViewTag_SetupRemoteLog,
    HCLogDebugOptionViewTag_TestRemoteLog,
};

@implementation LogDebugModule

#pragma mark - Private

+ (void)load {
    [[HCDebugToolManager sharedManager] registerModule:[[self alloc] init]];
}

- (void)showUinInputView {
    UIAlertController *alertVc =
    [UIAlertController alertControllerWithTitle:@"上传日志"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入您的账号";
    }];
    UIAlertAction *confirm =
    [UIAlertAction actionWithTitle:@"确认"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action)
     {
         //[SVProgressHUD showWithStatus:@"正在加载..."];
         NSString *uin = [[alertVc textFields] firstObject].text;
         [HCLogFileUploadManager requestNeedUploadWithUin:uin
                                                 callback:^(HCNeedUploadType type)
          {
              //[SVProgressHUD dismiss];
              if (type <= HCNeedUploadType_AllDateLogAndDB_WX &&
                  type >= HCNeedUploadType_SingleDateLog) {
                  HCLogUploadViewController *logUploadVC = [[HCLogUploadViewController alloc] initWithUploadType:type];
                  [self pushViewController:logUploadVC];
              }
          }];
     }];
    
    UIAlertAction *cancel =
    [UIAlertAction actionWithTitle:@"取消"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    [alertVc addAction:cancel];
    [alertVc addAction:confirm];
    [self  presentViewController:alertVc];
}

#pragma mark - HCDebugToolCommonOptionViewDelegate

- (void)optionDidSelected:(HCDebugToolCommonOptionItemViewModel *)option
                  atIndex:(NSInteger)index {
    switch (option.viewTag) {
        case HCLogDebugOptionViewTag_SetupXLog:
        {
            [XLogHelper setupXlog];
        }
            break;
        case HCLogDebugOptionViewTag_TestXLog:
        {
            time_t timeresult = time(NULL);
            HCLOG_DEBUG(kLogModuleTestLog, @"TestXLog time: %ju",timeresult);
        }
            break;
        case HCLogDebugOptionViewTag_UploadLog:
        {
            [self showUinInputView];

        }
            break;
        case HCLogDebugOptionViewTag_SetupRemoteLog:
        {
            //            [self hideMenuView:^{
            //                [[FLEXManager sharedManager] showExplorer];
            //            }];
        }
            break;
        case HCLogDebugOptionViewTag_TestRemoteLog:
        {
            //            [self hideMenuView:^{
            //                [[FLEXManager sharedManager] showExplorer];
            //            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - HCDebugToolModuleProtocol

- (NSString *)moduleTitle {
    return @"日志调试";
}

#pragma mark - SuperClass

- (NSArray <NSDictionary *>*)optionDicts {
    return @[@{HCDebugCommonModuleOptionKeys.title: @"初始化XLog",
               HCDebugCommonModuleOptionKeys.viewTag: @(HCLogDebugOptionViewTag_SetupXLog),
               },
             @{HCDebugCommonModuleOptionKeys.title: @"测试XLog",
               HCDebugCommonModuleOptionKeys.viewTag: @(HCLogDebugOptionViewTag_TestXLog),
               },
             @{HCDebugCommonModuleOptionKeys.title: @"上传日志",
               HCDebugCommonModuleOptionKeys.viewTag: @(HCLogDebugOptionViewTag_UploadLog),
               },
             @{HCDebugCommonModuleOptionKeys.title: @"初始化远程日志",
               HCDebugCommonModuleOptionKeys.viewTag: @(HCLogDebugOptionViewTag_SetupRemoteLog),
               },
             @{HCDebugCommonModuleOptionKeys.title: @"测试远程日志",
               HCDebugCommonModuleOptionKeys.viewTag: @(HCLogDebugOptionViewTag_TestRemoteLog),
               }];
}

@end
