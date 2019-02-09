//
//  XLogHelper.h
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/2/9.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mars/xlog/xloggerbase.h>
#import "HCLogModuleDefine.h"

@interface XLogHelper : NSObject

+ (void)setupXlog;

+ (void)logWithLevel:(TLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
             message:(NSString *)message;

+ (BOOL)shouldLog:(TLogLevel)level;
+ (void)flushLog;
+ (void)closeXLog;

+ (NSString *)xlogFileDirPath;
+ (NSString *)xlogZipDirPath;

@end

#define __FILENAME__ (strrchr(__FILE__,'/')+1)

#define HCLOG_ERROR(module, format, ...) \
HCXLog(kLevelError, module, __FILENAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)

#define HCLOG_WARNING(module, format, ...) \
HCXLog(kLevelWarn, module, __FILENAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)

#define HCLOG_INFO(module, format, ...) \
HCXLog(kLevelInfo, module, __FILENAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)

#define HCLOG_DEBUG(module, format, ...) \
HCXLog(kLevelDebug, module, __FILENAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)

#define HCXLog(level, module, file, line, func, format, ...) \
if ([XLogHelper shouldLog:level]) { \
NSString *aMessage = [NSString stringWithFormat:format, ##__VA_ARGS__, nil]; \
[XLogHelper logWithLevel:level moduleName:module fileName:file lineNumber:line funcName:func message:aMessage]; \
} \
