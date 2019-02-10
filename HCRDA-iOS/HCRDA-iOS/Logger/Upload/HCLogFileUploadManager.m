//
//  HCLogFileUploadManager.m
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/2/9.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import "HCLogFileUploadManager.h"
#import "XLogHelper.h"
#import "ZipArchive.h"
#import "AFNetworking.h"

static NSString *_hostURL = @"http://192.168.199.229:9080";
static BOOL _isExistUploadTask = NO;

#define XOR_KEY 0xBB

@implementation HCLogFileUploadManager

#pragma mark - Public Function

+ (void)requestNeedUploadWithUin:(NSString *)uin
                        callback:(needUploadCallback)callback {
    if (!uin || !uin.length) {
        if (callback) {
            callback(HCNeedUploadType_None);
        }
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", _hostURL, @"/api/needUpload"];
    NSDictionary *params = @{@"uin" :uin};
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    [manager GET:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (callback) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSInteger needUploadType = [[responseObject objectForKey:@"needUpload"] integerValue];
                callback(needUploadType);
            } else {
                callback(HCNeedUploadType_None);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (callback) {
            callback(HCNeedUploadType_None);
        }
    }];
}

+ (NSArray<NSDate *>*)allXLogFilesDate {
    [XLogHelper flushLog];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:[XLogHelper xlogFileDirPath]
                                                         error:&error];
    NSMutableArray <NSDate *>* temp = [NSMutableArray array];
    for (NSString *fileName in fileList) {
        if (![fileName hasSuffix:@"xlog"]) {
            continue;
        }
        NSString *filePath =
        [NSString stringWithFormat:@"%@/%@", [XLogHelper xlogFileDirPath], fileName];
        NSDictionary *fileAttributes =
        [fileManager attributesOfItemAtPath:filePath
                                      error:&error];
        if (!error) {
            NSDate *fileModDate = [fileAttributes objectForKey:NSFileCreationDate];
            [temp addObject:fileModDate];
        }
    }
    
    return [temp copy];
}

+ (void)    uploadXLogFile:(NSDate *)fileDate
    uploadProgressCallback:(HCLogFileUploadProgressBlock)uploadProgressCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isExistUploadTask) {
            if (uploadProgressCallback) {
                uploadProgressCallback(HCLogFileUploadFailType_ExistUploadTask, 0);
            }
            return;
        }
        _isExistUploadTask = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *desZipPath = [self makeXLogZipWithDate:fileDate];
            if (!desZipPath.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _isExistUploadTask = NO;
                    if (uploadProgressCallback) {
                        uploadProgressCallback(HCLogFileUploadFailType_ZipFile, 0);
                    }
                });
                return;
            }
            
            [self uploadZipFile:desZipPath
                       callback:uploadProgressCallback];
        });
    });
}

+ (void)uploadAllXLogFile:(HCLogFileUploadProgressBlock)uploadProgressCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isExistUploadTask) {
            if (uploadProgressCallback) {
                uploadProgressCallback(HCLogFileUploadFailType_ExistUploadTask, 0);
            }
            return;
        }
        _isExistUploadTask = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *desZipPath = [self makeAllXLogZip];
            if (!desZipPath.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _isExistUploadTask = NO;
                    if (uploadProgressCallback) {
                        uploadProgressCallback(HCLogFileUploadFailType_ZipFile, 0);
                    }
                });
                return;
            }
            
            [self uploadZipFile:desZipPath
                       callback:uploadProgressCallback];
        });
    });
}

#pragma mark - Private Function

+ (void)uploadZipFile:(NSString *)filePath
             callback:(HCLogFileUploadProgressBlock)uploadProgressCallback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%@", _hostURL, @"/api/upload"];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        NSError *error;
        [formData appendPartWithFileURL:fileUrl name:@"user_log" fileName:filePath.lastPathComponent mimeType:@"application/zip" error:&error];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (uploadProgressCallback) {
            uploadProgressCallback(HCLogFileUploadFailType_None, 1);
        }
        _isExistUploadTask = NO;
        [self deleteFile:filePath];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (uploadProgressCallback) {
            uploadProgressCallback(HCLogFileUploadFailType_Netwoking, 0);
        }
        _isExistUploadTask = NO;
        [self deleteFile:filePath];
    }];
}

+ (void)deleteFile:(NSString *)filePath {
    NSError *err;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:filePath
                        error:&err];
}

+ (NSString *)makeXLogZipWithDate:(NSDate *)date {
    [XLogHelper flushLog];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:[XLogHelper xlogFileDirPath]
                                                         error:&error];
    NSString *desFilePath = nil;
    for (NSString *fileName in fileList) {
        if (![fileName hasSuffix:@"xlog"]) {
            continue;
        }
        NSString *filePath =
        [NSString stringWithFormat:@"%@/%@", [XLogHelper xlogFileDirPath], fileName];
        NSDictionary *fileAttributes =
        [fileManager attributesOfItemAtPath:filePath
                                      error:&error];
        NSDate *fileCreatDate = [fileAttributes objectForKey:NSFileCreationDate];
        if ([fileCreatDate isEqualToDate:date]) {
            desFilePath = filePath;
            break;
        }
    }
    
    if (!desFilePath) {
        return nil;
    }
    
    NSString *uin = @"testUin";
    NSString *fileName = [NSString stringWithFormat:@"uin_%@_SingleLog.zip", uin];
    NSString *zipFilePath = [[XLogHelper xlogZipDirPath] stringByAppendingPathComponent:fileName];
    BOOL success = [SSZipArchive createZipFileAtPath:zipFilePath
                                    withFilesAtPaths:@[desFilePath]
                                        withPassword:[self keyStr]];
    
    return success ? zipFilePath : nil;
}

+ (NSString *)makeAllXLogZip {
    [XLogHelper flushLog];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList =
    [fileManager contentsOfDirectoryAtPath:[XLogHelper xlogFileDirPath]
                                     error:&error];
    if (!fileList.count) {
        return nil;
    }
    
    NSString *uin = @"testUin";
    NSString *fileName = [NSString stringWithFormat:@"uin_%@_AllLog.zip", uin];
    NSString *zipFilePath = [[XLogHelper xlogZipDirPath] stringByAppendingPathComponent:fileName];
    NSMutableArray *desFilePaths = [NSMutableArray array];
    for (NSString *fileName in fileList) {
        if (![fileName hasSuffix:@"xlog"]) {
            continue;
        }
        NSString *filePath =
        [NSString stringWithFormat:@"%@/%@", [XLogHelper xlogFileDirPath], fileName];
        [desFilePaths addObject:filePath];
    }
    BOOL success = [SSZipArchive createZipFileAtPath:zipFilePath
                                    withFilesAtPaths:desFilePaths
                                        withPassword:[self keyStr]];
    return success ? zipFilePath : nil;
}

#pragma mark - xorString

void xorString(unsigned char *str, unsigned char key) {
    unsigned char *p = str;
    while( ((*p) ^=  key) != '\0')  p++;
}

+ (NSString *)keyStr {
    //    NSString *pwd = @"f8MWcDsFf8MWcDsF";
    unsigned char str[] = {(XOR_KEY ^ 'f'),
        (XOR_KEY ^ '8'),
        (XOR_KEY ^ 'M'),
        (XOR_KEY ^ 'W'),
        (XOR_KEY ^ 'c'),
        (XOR_KEY ^ 'D'),
        (XOR_KEY ^ 's'),
        (XOR_KEY ^ 'F'),
        (XOR_KEY ^ '\0')};
    xorString(str, XOR_KEY);
    char result[8];
    memcpy(result, str, 8);
    return [NSString stringWithCString:result encoding:NSUTF8StringEncoding];
}

@end


