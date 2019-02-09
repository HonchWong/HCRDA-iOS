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

#if DEBUG_MODULE_ENABLE
static NSString *_hostURL = @"xxx";
#else
static NSString *_hostURL = @"xxx";
#endif
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
    
//    NSMutableURLRequest *request = [QRHttpClient requestWithMethod:QQNetHttpMethodGet
//                                                              path:url
//                                                        parameters:params
//                                                            header:nil
//                                                              body:nil];
//    [request setTimeoutInterval:kAsynchronousTimeout];
//
//    QQHttpClientSession *session =
//    [QQHttpClientSession sessionWithRequest:request
//                                  bussiness:[NSArray arrayWithObjects:[NSNumber numberWithInt:QQNetBizOther], nil]
//                                   resource:QQNetReqResTypeGetJson
//                                    success:^(QQHttpClientSession *sess, id respObject)
//     {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             if ([respObject isKindOfClass:[NSDictionary class]]) {
//                 NSInteger needUploadType = [[respObject objectForKey:@"needUpload"] integerValue];
//                 callback(needUploadType);
//             } else {
//                 callback(HCNeedUploadType_None);
//             }
//         });
//     } fail:^(QQHttpClientSession *sess, NSError *err) {
//         dispatch_main_async_safe(^{
//             callback(HCNeedUploadType_None);
//         });
//     }];
//
//    [QRHttpClient enqueueRequestSession:session];
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

+ (void)uploadUserDB:(HCLogFileUploadProgressBlock)uploadProgressCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isExistUploadTask) {
            if (uploadProgressCallback) {
                uploadProgressCallback(HCLogFileUploadFailType_ExistUploadTask, 0);
            }
            return;
        }
        _isExistUploadTask = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *desZipPath = [self makeDBZip];
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

+ (void)uploadUserDBAndAllXLogFile:(HCLogFileUploadProgressBlock)uploadProgressCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isExistUploadTask) {
            if (uploadProgressCallback) {
                uploadProgressCallback(HCLogFileUploadFailType_ExistUploadTask, 0);
            }
            return;
        }
        _isExistUploadTask = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *desZipPath = [self makeDBAndAllXLogFileZip];
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
    NSString *url = [NSString stringWithFormat:@"%@%@", _hostURL, @"/api/upload"];
    NSMutableURLRequest *request =
    [self requestWithURL:[NSURL URLWithString:url]
               filenName:filePath.lastPathComponent
                filePath:filePath];
    
//    QQHttpClientSession *session =
//    [QQHttpClientSession sessionWithRequest:request
//                                  bussiness:[NSArray arrayWithObjects:[NSNumber numberWithInt:QQNetBizOther], nil]
//                                   resource:QQNetReqResTypeUploadFile
//                                    success:^(QQHttpClientSession *sess, id respObject)
//     {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             _isExistUploadTask = NO;
//         });
//     } fail:^(QQHttpClientSession *sess, NSError *err) {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             _isExistUploadTask = NO;
//             QRSafelyDoBlock2(uploadProgressCallback,
//                              QRUserFileUploadFailType_Netwoking,
//                              0);
//             [self deleteFile:filePath];
//         });
//     }];
//
//    [session setUploadProgressBlock:^(NSUInteger bytes, long long totalBytes, long long totalBytesExpected) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            CGFloat percentage = totalBytes / totalBytesExpected;
//            QRSafelyDoBlock2(uploadProgressCallback,
//                             QRUserFileUploadFailType_None,
//                             percentage);
//            if (percentage == 1) {
//                [self deleteFile:filePath];
//            }
//        });
//    }];
//    [QRHttpClient enqueueRequestSession:session];
}

+ (void)deleteFile:(NSString *)filePath {
    NSError *err;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:filePath
                        error:&err];
}

static NSString *boundary=@"----UploadFileFormBoundary7MA4YWxkTrZu0gW";
+ (NSMutableURLRequest *)requestWithURL:(NSURL *)url
                              filenName:(NSString *)fileName
                               filePath:(NSString *)filePath {
    NSMutableURLRequest *request=
    [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                        timeoutInterval:10.0f];
    request.HTTPMethod = @"POST";
    
    NSString *headStr =
    [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:headStr forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *requestMutableData = [NSMutableData data];
    
    NSMutableString *bodyStr = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",boundary];
    [bodyStr appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_log\"; filename=\"%@\"\r\n",fileName]];
    [bodyStr appendString:[NSString stringWithFormat:@"Content-Type:application/zip\r\n\r\n"]];
    [requestMutableData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    [requestMutableData appendData:[NSData dataWithContentsOfFile:filePath]];
    
    [requestMutableData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    request.HTTPBody = requestMutableData;
    
    return request;
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
//    ZipArchive *zip = [[ZipArchive alloc] init];
//    [zip CreateZipFile2:zipFilePath Password:[self keyStr]];
//    [zip addFileToZip:desFilePath newname:desFilePath.lastPathComponent];
//    BOOL success = [zip CloseZipFile2];
    
    return nil;//success ? zipFilePath : nil;
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
//    ZipArchive *zip = [[ZipArchive alloc] init];
//    [zip CreateZipFile2:zipFilePath Password:[self keyStr]];
//    for (NSString *fileName in fileList) {
//        if (![fileName hasSuffix:@"xlog"]) {
//            continue;
//        }
//        NSString *filePath =
//        [NSString stringWithFormat:@"%@/%@", [XLogHelper xlogFileDirPath], fileName];
//        [zip addFileToZip:filePath newname:filePath.lastPathComponent];
//    }
//    BOOL success = [zip CloseZipFile2];
    
    return nil;//success ? zipFilePath : nil;
}

+ (NSString *)makeDBZip {
//    NSString *dbPath = [[DataCenter sharedInstance] currentDataBasePath];
//    if (!dbPath.length) {return nil;}
//
//    NSString *uin = @"testUin";
//    NSString *fileName = [NSString stringWithFormat:@"uin_%@_DB.zip", uin];
//    NSString *zipFilePath = [[XLogHelper xlogZipDirPath] stringByAppendingPathComponent:fileName];
//    ZipArchive *zip = [[ZipArchive alloc] init];
//    [zip CreateZipFile2:zipFilePath Password:[self keyStr]];
//    [zip addFileToZip:dbPath newname:dbPath.lastPathComponent];
//    BOOL success = [zip CloseZipFile2];
    
//    return success ? zipFilePath : nil;
    return nil;
}

+ (NSString *)makeDBAndAllXLogFileZip {
    NSString *dbFilePath = [self makeDBZip];
    NSString *xlogFilePath = [self makeAllXLogZip];
    if (!dbFilePath.length || !xlogFilePath.length) {
        return nil;
    }
    
    NSString *uin = @"testUin";
    NSString *fileName = [NSString stringWithFormat:@"uin_%@_DB_AllLog.zip", uin];
    NSString *zipFilePath = [[XLogHelper xlogZipDirPath] stringByAppendingPathComponent:fileName];
//    ZipArchive *zip = [[ZipArchive alloc] init];
//    [zip CreateZipFile2:zipFilePath Password:[self keyStr]];
//    [zip addFileToZip:dbFilePath newname:dbFilePath.lastPathComponent];
//    [zip addFileToZip:xlogFilePath newname:xlogFilePath.lastPathComponent];
//    BOOL success = [zip CloseZipFile2];
//    if (success) {
//        [self deleteFile:dbFilePath];
//        [self deleteFile:xlogFilePath];
//    }
    return nil;//success ? zipFilePath : nil;
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


