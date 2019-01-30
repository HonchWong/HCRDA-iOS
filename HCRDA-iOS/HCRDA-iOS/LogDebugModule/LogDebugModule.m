//
//  LogDebugModule.m
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/1/30.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import "LogDebugModule.h"
#import <HCDebugTool/HCDebugTool.h>

typedef NS_OPTIONS(NSInteger, HCLogDebugOptionViewTag) {
    HCLogDebugOptionViewTag_SetupXLog,
    HCLogDebugOptionViewTag_TestXLog,
    HCLogDebugOptionViewTag_SetupRemoteLog,
    HCLogDebugOptionViewTag_TestRemoteLog,
};

@implementation LogDebugModule

#pragma mark - Private

+ (void)load {
    [[HCDebugToolManager sharedManager] registerModule:[[self alloc] init]];
}

#pragma mark - HCDebugToolCommonOptionViewDelegate

- (void)optionDidSelected:(HCDebugToolCommonOptionItemViewModel *)option
                  atIndex:(NSInteger)index {
    switch (option.viewTag) {
        case HCLogDebugOptionViewTag_SetupXLog:
        {
//            HCNetDebugMockViewController *vc =
//            [[HCNetDebugMockViewController alloc] init];
//            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
//            [self hideMenuView:^{
//                [self presentViewController:naviVC];
//            }];
//            mockRequest(@"GET", @"https://www.easy-mock.com/mock/5b877ba37eb5e51ccf7d4db1/example/testBookList");
        }
            break;
        case HCLogDebugOptionViewTag_TestXLog:
        {
//            [self hideMenuView:^{
//                [[FLEXManager sharedManager] showExplorer];
//            }];
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
             @{HCDebugCommonModuleOptionKeys.title: @"初始化远程日志",
               HCDebugCommonModuleOptionKeys.viewTag: @(HCLogDebugOptionViewTag_SetupRemoteLog),
               },
             @{HCDebugCommonModuleOptionKeys.title: @"测试远程日志",
               HCDebugCommonModuleOptionKeys.viewTag: @(HCLogDebugOptionViewTag_TestRemoteLog),
               }];
}

@end
