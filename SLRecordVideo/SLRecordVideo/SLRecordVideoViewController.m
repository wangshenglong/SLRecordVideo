//
//  SLRecordVideoViewController.m
//  SLRecordVideo
//
//  Created by 王胜龙 on 2017/11/24.
//  Copyright © 2017年 王胜龙. All rights reserved.
//

#import "SLRecordVideoViewController.h"
#import <Masonry/Masonry.h>
#import "SCRecordSessionManager.h"
#import "SCTouchDetector.h"
#import "DACircularProgressView.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SLRecordVideoViewController () <SCRecorderDelegate,SCAssetExportSessionDelegate>

@property (nonatomic, strong) UIView *preView;

@property (nonatomic, strong) UIButton *backBT;
@property (nonatomic, strong) UIButton *cameraBT;
@property (nonatomic, strong) UIButton *cancleBT;
@property (nonatomic, strong) UIButton *complteBT;
//@property (nonatomic, strong) UIView *recordView;
@property (nonatomic, strong) DACircularProgressView *recordView;

@property (nonatomic, strong) SCRecorder *recorder;
@property (nonatomic, strong) SCRecordSession *recordSession;
@property (nonatomic, strong) SCAssetExportSession *exportSession;
@end

@implementation SLRecordVideoViewController

- (UIView *)preView {
    if (!_preView) {
        _preView = [UIView new];
        _preView.backgroundColor = [UIColor blackColor];
    }
    return _preView;
}

- (UIButton *)backBT {
    if (!_backBT) {
        _backBT = [UIButton new];
        [_backBT setImage:[UIImage imageNamed:@"btn_back@2x.png"] forState:UIControlStateNormal];
    }
    return _backBT;
}
- (UIButton *)cameraBT {
    if (!_cameraBT) {
        _cameraBT = [UIButton new];
        [_cameraBT setImage:[UIImage imageNamed:@"camera@2x.png"] forState:UIControlStateNormal];
    }
    return _cameraBT;
}
- (UIButton *)cancleBT {
    if (!_cancleBT) {
        _cancleBT = [UIButton new];
        [_cancleBT setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _cancleBT;
}
- (UIButton *)complteBT {
    if (!_complteBT) {
        _complteBT = [UIButton new];
        [_complteBT setTitle:@"完成" forState:UIControlStateNormal];
        [_complteBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_complteBT setHidden:YES];
    }
    return _complteBT;
}
- (DACircularProgressView *)recordView {
    if (!_recordView) {
        _recordView = [DACircularProgressView new];
        _recordView.progressTintColor = [UIColor colorWithRed:0.47 green:0.44 blue:0.96 alpha:1];
        _recordView.thicknessRatio = 0.2;

        _recordView.roundedCorners = 2;
    }
    return _recordView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.navigationController.navigationBar setHidden:YES];
    
    [self initViews];
    
    
    _maxRecordTime = 15;
}

- (void)initViews {
    
    [self.view addSubview:self.preView];
    [self.view addSubview:self.backBT];
    [self.view addSubview:self.cancleBT];
    [self.view addSubview:self.cameraBT];
    [self.view addSubview:self.recordView];
    [self.view addSubview:self.complteBT];
    
    [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.backBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.mas_equalTo(20);
        make.leftMargin.mas_equalTo(20);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    [self.cameraBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.mas_equalTo(20);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    [self.cancleBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leftMargin.mas_equalTo(20);
        make.bottomMargin.mas_equalTo(-20);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(100);
    }];
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.mas_equalTo(self.view);
        make.width.height.mas_equalTo(100);
        make.bottomMargin.mas_equalTo(-20);
    }];
    [self.complteBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.rightMargin.mas_equalTo(-20);
        make.bottomMargin.mas_equalTo(-20);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(100);
    }];
    
    [self.recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
    [self.backBT addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancleBT addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraBT addTarget:self action:@selector(cameraForeOrBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.complteBT addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    //    _recorder.maxRecordDuration = CMTimeMake(10, 1);
    //    _recorder.fastRecordMethodEnabled = YES;
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO;
    _recorder.previewView = self.preView;
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
}

- (void)back: (UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cameraForeOrBack: (UIButton *)button {
    [_recorder switchCaptureDevices];
}
// 录制，暂停
- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    
    if (touchDetector.state == UIGestureRecognizerStateBegan) {
        // 录制
        SCRecordSession *recordSession = _recorder.session;
        if (recordSession != nil) {
            if (CMTimeGetSeconds(recordSession.duration) > _maxRecordTime) {
                return;
            }
        }
        [_recorder record];
    } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
        [_recorder pause];
         [self.complteBT setHidden:NO];
    }
    
}
- (void)completeClick: (UIButton *)button {
    SCRecordSession *recordSession = _recorder.session;
    if (recordSession !=nil && _completeBlock) {

        [self saveToCamera];
    }
}

- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        
        [SVProgressHUD showProgress:progress];
        
        
    });
}
//保存
- (void)saveToCamera {
    
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recorder.session.assetRepresentingSegments];
//    exportSession.videoConfiguration.filter = currentFilter;
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 35;
    exportSession.outputUrl = _recorder.session.outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    exportSession.contextType = SCContextTypeAuto;
    self.exportSession = exportSession;
    
    NSLog(@"Starting exporting");
    
    CFTimeInterval time = CACurrentMediaTime();
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                if (error == nil) {
                    [SVProgressHUD showSuccessWithStatus:@"视频保存成功"];
                    [SVProgressHUD dismissWithDelay:2 completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                        SCRecordSession *recordSession = _recorder.session;
                        _completeBlock(recordSession,path);
                    }];
                    
                } else {
                    
                    [SVProgressHUD showErrorWithStatus:@"视频保存失败"];
                }
            }];
        } else {
            if (!exportSession.cancelled) {
                [SVProgressHUD showErrorWithStatus:@"视频保存失败"];
            }
        }
    }];
}
- (void)cancleClick: (UIButton *)button {
    SCRecordSession *recordSession = _recorder.session;
    
    
    if (recordSession != nil) {
        // 取消
        if (CMTimeGetSeconds(recordSession.duration) == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        _recorder.session = nil;
        [self.complteBT setHidden:YES];
        [self.recordView setProgress:0 animated:YES];
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
        [self prepareSession];
        
    }
    
    
    
    
}

- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareSession];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [_recorder stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)dealloc {
    _recorder.previewView = nil;
}
- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    
    [self updateTimeRecordedLabel];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
//    [self updateGhostImage];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
    
   
//    [self showVideo];
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
    }
    
    
    [self.recordView setProgress:(1.0 * CMTimeGetSeconds(currentTime)/_maxRecordTime) animated:YES];
    if (CMTimeGetSeconds(currentTime) >= _maxRecordTime) {
        
        [_recorder pause];
    }
}
- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
