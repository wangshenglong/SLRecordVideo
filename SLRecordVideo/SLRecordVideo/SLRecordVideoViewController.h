//
//  SLRecordVideoViewController.h
//  SLRecordVideo
//
//  Created by 王胜龙 on 2017/11/24.
//  Copyright © 2017年 王胜龙. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SCRecorder/SCRecorder.h>

@interface SLRecordVideoViewController : UIViewController

@property (nonatomic, assign) CGFloat maxRecordTime;


@property (nonatomic, copy) void (^completeBlock)(SCRecordSession *recordSession, NSString *filePath);

@end
