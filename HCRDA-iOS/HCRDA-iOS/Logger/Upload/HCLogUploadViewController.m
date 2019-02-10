//
//  HCLogUploadViewController.m
//  HCRDA-iOS
//
//  Created by 黄鸿昌 on 2019/2/10.
//  Copyright © 2019 黄鸿昌. All rights reserved.
//

#import "HCLogUploadViewController.h"
#import "XLogHelper.h"
#import "HCLogUploadResultViewController.h"

#define kFileIconImgWidth        80
#define kFileIconImgHeight       107

@interface HCLogUploadViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIImageView *fileIconImgView;
@property (nonatomic, strong) UILabel *uploadDescTopLabel;
@property (nonatomic, strong) UIView *timeSelectView;
@property (nonatomic, strong) UIPickerView *timePickView;
@property (nonatomic, strong) UIButton *uploadBtn;
@property (nonatomic, assign) HCNeedUploadType uploadType;

@property (nonatomic, strong) NSArray <NSDate *>*allFilesDate;
@property (nonatomic, strong) NSDate *selecedDate;

@end

@implementation HCLogUploadViewController

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
    
    [self loadData];
    [self setupSubview];
}

- (void)setupSubview {
    [self.view addSubview:self.fileIconImgView];
    [self.view addSubview:self.uploadDescTopLabel];
    if (self.uploadType == HCNeedUploadType_SingleDateLog ||
        self.uploadType == HCNeedUploadType_SingleDateLog_WX) {
        [self.view addSubview:self.timePickView];
    }
    [self.view addSubview:self.uploadBtn];
    if ([self isSendWX:self.uploadType]) {
        [self.uploadBtn setTitle:@"发送微信" forState:UIControlStateNormal];
    } else {
        [self.uploadBtn setTitle:@"上传日志" forState:UIControlStateNormal];
    }
}

- (void)loadData {
    if (self.uploadType == HCNeedUploadType_SingleDateLog ||
        self.uploadType == HCNeedUploadType_SingleDateLog_WX) {
        self.allFilesDate = [HCLogFileUploadManager allXLogFilesDate];
        HCLOG_DEBUG(kLogModuleNone, @"allFilesDate %lu", self.allFilesDate.count);
        if (self.allFilesDate.count) {
            self.selecedDate = [self.allFilesDate firstObject];
        }
    }
}

- (BOOL)isSendWX:(HCNeedUploadType)uploadType {
    if (uploadType == HCNeedUploadType_SingleDateLog_WX ||
        uploadType == HCNeedUploadType_AllDateLog_WX ||
        uploadType == HCNeedUploadType_DB_WX ||
        uploadType == HCNeedUploadType_AllDateLogAndDB_WX) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Event

- (void)uploadAction {
    if ([self isSendWX:self.uploadType]) {
        // 发送微信好友
    } else {
        HCLogUploadResultViewController *resultVc =
        [[HCLogUploadResultViewController alloc] initWithUploadType:self.uploadType];
        resultVc.selecedUploadDate = self.selecedDate;
        [self.navigationController pushViewController:resultVc animated:YES];
    }
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    self.selecedDate = [self.allFilesDate objectAtIndex:row];
}

- (CGFloat) pickerView:(UIPickerView *)pickerView
 rowHeightForComponent:(NSInteger)component {
    return 40;
}

#pragma mark - UIPickerViewDataSource

- (nullable NSString *)pickerView:(UIPickerView *)pickerView
                      titleForRow:(NSInteger)row
                     forComponent:(NSInteger)component {
    NSDate *date = [self.allFilesDate objectAtIndex:row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)   pickerView:(UIPickerView *)pickerView
   numberOfRowsInComponent:(NSInteger)component {
    return self.allFilesDate.count;
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

- (UILabel *)uploadDescTopLabel {
    if (!_uploadDescTopLabel) {
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        _uploadDescTopLabel = [[UILabel alloc] init];
        _uploadDescTopLabel.text = @"使用中如发生功能异常或闪退等问题，请上传日志帮助我们更好定位和解决问题。";
        _uploadDescTopLabel.numberOfLines = 0;
        _uploadDescTopLabel.textColor = [UIColor blackColor];
        _uploadDescTopLabel.font = [UIFont systemFontOfSize:16];
        _uploadDescTopLabel.frame =
        CGRectMake(20,
                   CGRectGetMaxY(self.fileIconImgView.frame) + 30,
                   screenWidth - 20 * 2,
                   40);
    }
    return _uploadDescTopLabel;
}

- (UIButton *)uploadBtn {
    if (!_uploadBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIView *topMarginView = self.uploadDescTopLabel;
        if (self.uploadType == HCNeedUploadType_SingleDateLog ||
            self.uploadType == HCNeedUploadType_SingleDateLog_WX) {
            topMarginView = self.timePickView;
        }
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        button.frame =
        CGRectMake(20,
                   CGRectGetMaxY(topMarginView.frame) + 30,
                   screenWidth - 20 * 2,
                   40);
        button.backgroundColor = [UIColor colorWithRed:43/255.0 green:130/255.0 blue:255/255.0 alpha:1.0];
        button.layer.cornerRadius = 4.0;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:@"上传日志" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(uploadAction)
         forControlEvents:UIControlEventTouchUpInside];
        _uploadBtn = button;
    }
    return _uploadBtn;
}

- (UIPickerView *)timePickView {
    if (!_timePickView) {
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        UIPickerView *pickView =
        [[UIPickerView alloc] initWithFrame:
         CGRectMake(0,
                    CGRectGetMaxY(self.uploadDescTopLabel.frame) + 30,
                    screenWidth,
                    40 * 2.8)];
        pickView.delegate = self;
        pickView.dataSource = self;
        pickView.showsSelectionIndicator = YES;
        _timePickView = pickView;
    }
    return _timePickView;
}


@end
