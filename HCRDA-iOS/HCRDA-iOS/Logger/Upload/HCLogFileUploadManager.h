//
//  HCLogFileUploadManager.h
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/2/9.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HCNeedUploadType) {
    HCNeedUploadType_None = 0,
    HCNeedUploadType_SingleDateLog = 1,
    HCNeedUploadType_AllDateLog = 2,
    HCNeedUploadType_DB = 3,
    HCNeedUploadType_AllDateLogAndDB = 4,
    HCNeedUploadType_SingleDateLog_WX = 5,
    HCNeedUploadType_AllDateLog_WX = 6,
    HCNeedUploadType_DB_WX = 7,
    HCNeedUploadType_AllDateLogAndDB_WX = 8,
};

typedef NS_ENUM(NSInteger, HCLogFileUploadFailType) {
    HCLogFileUploadFailType_None = 0,
    HCLogFileUploadFailType_ZipFile,
    HCLogFileUploadFailType_Netwoking,
    HCLogFileUploadFailType_ExistUploadTask,
};

typedef void (^needUploadCallback)(HCNeedUploadType type);
typedef void (^HCLogFileUploadProgressBlock)(HCLogFileUploadFailType failType, CGFloat percentage);
//typedef void (^HCLogFileSendWXBlock)(BOOL success);

@interface HCLogFileUploadManager : NSObject

+ (void)requestNeedUploadWithUin:(NSString *)uin
                        callback:(needUploadCallback)callback;

+ (NSArray<NSDate *>*)allXLogFilesDate;
+ (void)    uploadXLogFile:(NSDate *)fileDate
    uploadProgressCallback:(HCLogFileUploadProgressBlock)uploadProgressCallback;
+ (void)uploadAllXLogFile:(HCLogFileUploadProgressBlock)uploadProgressCallback;

//+ (void)uploadUserDB:(HCLogFileUploadProgressBlock)uploadProgressCallback;
//+ (void)uploadUserDBAndAllXLogFile:(HCLogFileUploadProgressBlock)uploadProgressCallback;

/**
 发送微信好友

 */
//+ (void)sendWeiXinSingleXLogFile:(NSDate *)fileDate callback:(HCLogFileSendWXBlock)callback;
//+ (void)sendWeiXinAllXLogFile:(HCLogFileSendWXBlock)callback;
//+ (void)sendWeiXinUserDB:(HCLogFileSendWXBlock)callback;
//+ (void)sendWeiXinUserDBAndAllXLogFile:(HCLogFileSendWXBlock)callback;

@end
