//
//  GQRecordTools.h
//  XmppDemo
//
//  Created by guoqing on 16/5/4.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface GQRecordTools : NSObject

/** 播放器 */
@property(nonatomic,strong) AVAudioPlayer *player;

+ (instancetype)sharedRecorder;

/**start record*/
- (void)startRecord;

/**stop record*/
- (void)stopRecordSuccess:(void (^)(NSURL *url, NSTimeInterval time))success andFailed:(void (^)())failed;

/**play voice data*/
- (void)playData:(NSData *)data completion:(void(^)())completion;

/**play voice file*/
- (void)playPath:(NSString *)path completion:(void (^)())completion;
@end
