//
//  HCLogUploadResultViewController.m
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/2/10.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import "HCLogUploadResultViewController.h"
#import "HCLogFileUploadManager.h"

#define kFileIconImgWidth        80
#define kFileIconImgHeight       107

@interface HCLogUploadResultViewController ()

@property (nonatomic, strong) UIImageView *fileIconImgView;
@property (nonatomic, strong) UILabel *uploadDescLabel;
@property (nonatomic, strong) UIView *uploadProcessView;
@property (nonatomic, strong) UIView *uploadProcessBGView;
@property (nonatomic, assign) HCNeedUploadType uploadType;

@end

@implementation HCLogUploadResultViewController

- (instancetype)initWithUploadType:(HCNeedUploadType)uploadType {
    if (self = [super init]) {
        self.uploadType = uploadType;
    }
    return self;
}

#pragma mark - Private Function

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"上传日志";

    [self setupSubview];
    [self startUpload];
}

- (void)setupSubview {
    [self.view addSubview:self.fileIconImgView];
    [self.view addSubview:self.uploadDescLabel];
    [self.view addSubview:self.uploadProcessBGView];
    [self.view addSubview:self.uploadProcessView];
}

- (void)startUpload {
    [self beginUploadProcessAnima];
    
    switch (self.uploadType) {
        case HCNeedUploadType_SingleDateLog:
            [self uploadSingleDateLog];
            break;
        case HCNeedUploadType_AllDateLog:
            [self uploadAllDateLog];
            break;
        case HCNeedUploadType_DB:
        case HCNeedUploadType_AllDateLogAndDB:
        case HCNeedUploadType_None:
            [self setUploadDiskFail];
            break;
        default:
            break;
    }
}

- (void)uploadSingleDateLog {
    if (!self.selecedUploadDate) {
        [self setUploadDiskFail];
        return;
    }
    
    [HCLogFileUploadManager uploadXLogFile:self.selecedUploadDate
                    uploadProgressCallback:^(HCLogFileUploadFailType failType, CGFloat percentage)
    {
        [self handleUploadProgressCallback:failType percentage:percentage];
    }];
}

- (void)uploadAllDateLog {
    [HCLogFileUploadManager uploadAllXLogFile:^(HCLogFileUploadFailType failType, CGFloat percentage)
    {
        [self handleUploadProgressCallback:failType percentage:percentage];
    }];
}

- (void)handleUploadProgressCallback:(HCLogFileUploadFailType)failType percentage:(CGFloat)percentage {
    if (failType == HCLogFileUploadFailType_Netwoking) {
        [self setUploadNetFail];
        return;
    }
    
    if (failType == HCLogFileUploadFailType_ZipFile) {
        [self setUploadDiskFail];
        return;
    }
    
    if (failType == HCLogFileUploadFailType_ExistUploadTask) {
        [self setUploadTaskExits];
        return;
    }
    
    if (percentage == 1){
        [self setProcessViewSuccess];
    }
}

- (void)beginUploadProcessAnima {
    [UIView animateWithDuration:60 * 2
                     animations:^
     {
         self.uploadProcessView.frame =
         CGRectMake(self.uploadProcessView.frame.origin.x,
                    self.uploadProcessView.frame.origin.y,
                    self.processViewWidth * 0.85,
                    self.uploadProcessView.frame.size.height);
     }];
}

- (void)setProcessViewSuccess {
    [self.uploadProcessView.layer removeAllAnimations];
    self.uploadProcessView.hidden = NO;
    self.uploadProcessBGView.hidden = NO;
    self.uploadDescLabel.text = @"上传成功，感谢您的合作！";
    self.uploadProcessView.frame =
    CGRectMake(self.uploadProcessView.frame.origin.x,
               self.uploadProcessView.frame.origin.y,
               self.processViewWidth,
               self.uploadProcessView.frame.size.height);
}


- (void)setUploadNetFail {
    self.uploadDescLabel.text = @"网络错误，请打开网络再上传日志";
    self.uploadProcessView.hidden = YES;
    self.uploadProcessBGView.hidden = YES;
}

- (void)setUploadDiskFail {
    self.uploadDescLabel.text = @"文件损坏，请联系客服帮助";
    self.uploadProcessView.hidden = YES;
    self.uploadProcessBGView.hidden = YES;
}

- (void)setUploadTaskExits {
    self.uploadDescLabel.text = @"日志正在上传中";
    self.uploadProcessView.hidden = YES;
    self.uploadProcessBGView.hidden = YES;
}

#pragma mark - getter setter

- (UIImageView *)fileIconImgView {
    if (!_fileIconImgView) {
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat navBarHeight = 44;
        _fileIconImgView = [[UIImageView alloc] initWithFrame:
                            CGRectMake((screenWidth - kFileIconImgWidth) * 0.5,
                                       navBarHeight + 80,
                                       kFileIconImgWidth,
                                       kFileIconImgHeight)];
        _fileIconImgView.image = [UIImage imageNamed:@"logFile"];
    }
    return _fileIconImgView;
}

- (UILabel *)uploadDescLabel {
    if (!_uploadDescLabel) {
        _uploadDescLabel = [[UILabel alloc] init];
        _uploadDescLabel.text = @"正在上传日志\n请不要退出当前页面或关闭App哦";
        _uploadDescLabel.numberOfLines = 0;
        _uploadDescLabel.textColor = [UIColor blackColor];
        _uploadDescLabel.font = [UIFont systemFontOfSize:16];
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        _uploadDescLabel.frame =
        CGRectMake(20,
                   CGRectGetMaxY(self.fileIconImgView.frame) + 30,
                   screenWidth - 20 * 2,
                   40);
        _uploadDescLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _uploadDescLabel;
}

- (UIView *)uploadProcessView {
    if (!_uploadProcessView) {
        _uploadProcessView =
        [[UIView alloc] initWithFrame:
         CGRectMake(20,
                    CGRectGetMaxY(self.uploadDescLabel.frame) + 30,
                    self.processViewWidth * 0.2,
                    10)];
        _uploadProcessView.backgroundColor = [UIColor colorWithRed:43/255.0 green:130/255.0 blue:255/255.0 alpha:1.0];
    }
    return _uploadProcessView;
}

- (UIView *)uploadProcessBGView {
    if (!_uploadProcessBGView) {
        _uploadProcessBGView =
        [[UIView alloc] initWithFrame:
         CGRectMake(20,
                    CGRectGetMaxY(self.uploadDescLabel.frame) + 30,
                    self.processViewWidth,
                    10)];
        _uploadProcessBGView.backgroundColor =
        [UIColor grayColor];
    }
    return _uploadProcessBGView;
}

- (CGFloat)processViewWidth {
    return CGRectGetWidth([UIScreen mainScreen].bounds) - 20 * 2;
}

@end
