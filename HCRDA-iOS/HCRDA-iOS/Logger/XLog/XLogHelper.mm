//
//  XLogHelper.m
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/2/9.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import "XLogHelper.h"
#import <mars/xlog/xloggerbase.h>
#import <mars/xlog/xlogger.h>
#import <mars/xlog/appender.h>
#import <sys/xattr.h>

static NSUInteger g_processID = 0;

@implementation XLogHelper

+ (void)setupXlog {
    // set do not backup for logpath
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    setxattr([[self xlogFileDirPath] UTF8String], attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    // init xlog
    //#if DEBUG
    //    xlogger_SetLevel(kLevelDebug);
    //#else
    //    xlogger_SetLevel(kLevelInfo);
    //#endif
    xlogger_SetLevel(kLevelDebug);
    appender_set_console_log(true);
    appender_open(kAppednerAsync, [[self xlogFileDirPath] UTF8String], "testXLog", "");
}

+ (void)logWithLevel:(TLogLevel)logLevel moduleName:(const char*)moduleName fileName:(const char*)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName message:(NSString *)message {
    XLoggerInfo info;
    info.level = logLevel;
    info.tag = moduleName;
    info.filename = fileName;
    info.func_name = funcName;
    info.line = lineNumber;
    gettimeofday(&info.timeval, NULL);
    info.tid = (uintptr_t)[NSThread currentThread];
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    xlogger_Write(&info, message.UTF8String);
}

+ (BOOL)shouldLog:(TLogLevel)level {
    if (level >= xlogger_Level()) {
        return YES;
    }
    
    return NO;
}

+ (void)flushLog {
    appender_flush_sync();
}

+ (void)closeXLog {
    appender_close();
}

+ (NSString *)xlogFileDirPath {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/xlogDir/xlogFileDir"];
}

+ (NSString *)xlogZipDirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *xlogZipDirPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/xlogDir/xlogZipDirPath"];
    if(![fileManager fileExistsAtPath:xlogZipDirPath]){
        [fileManager createDirectoryAtPath:xlogZipDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return xlogZipDirPath;
    
}

@end
