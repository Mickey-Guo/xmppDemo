//
//  GQMessageCell.m
//  XmppDemo
//
//  Created by guoqing on 16/4/15.
//  Copyright © 2016年 guoqing. All rights reserved.
//
#import "GQMessageCell.h"
#import "GQRecordTools.h"
@interface GQMessageCell() <UITextViewDelegate>
@end

@implementation GQMessageCell

@synthesize senderAndTimeLabel;
@synthesize messageContentView;
@synthesize bgImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //日期标签
        CGRect rx = [UIScreen mainScreen].bounds;
        senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, rx.size.width-20, 20)];
        //居中显示
        senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:senderAndTimeLabel];
        
        //背景图
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView];
        
        //聊天信息
        messageContentView = [[UITextView alloc] init];
        messageContentView.backgroundColor = [UIColor clearColor];
        //不可编辑
        messageContentView.editable = NO;
        messageContentView.scrollEnabled = NO;
        [messageContentView sizeToFit];
        [self.contentView addSubview:messageContentView];
        messageContentView.delegate = self;
        [bgImageView setUserInteractionEnabled:YES];
        [bgImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoice)]];
    }
    return self;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self playVoice];
}
- (void)playVoice {
    // 如果有音频数据，直接播放音频
    if (self.audioPath != nil) {
        // 播放音频
        self.messageContentView.textColor = [UIColor redColor];
        
        // 如果单例的块代码中包含self，一定使用weakSelf
        __weak GQMessageCell *weakSelf = self;
        [[GQRecordTools sharedRecorder] playPath:self.audioPath completion:^{
            weakSelf.messageContentView.textColor = [UIColor whiteColor];
        }];
    }
}

@end
