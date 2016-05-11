//
//  VoiceTableViewCell.m
//  chat
//
//  Created by yinxiufeng on 15/5/25.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "VoiceTableViewCell.h"
#import "mMessageFrame.h"
#import "mMessage.h"
#import "mMessageVoice.h"
#import "UIImage+Category.h"
#import "VoiceButton.h"
#import "GQRecordTools.h"
#import "GQStatic.h"

@interface VoiceTableViewCell()

//时间显示
@property (nonatomic, weak) UILabel *dateTimeLabel;
//用户头像
@property (nonatomic, weak) UIImageView *portraitImageView;
//内容
@property (nonatomic, weak) VoiceButton *contentButton;


@end

@implementation VoiceTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        //显示时间
        UILabel *dateTimeView = [[UILabel alloc] init];
        dateTimeView.textColor = [UIColor grayColor];
        [self.contentView addSubview:dateTimeView];
        self.dateTimeLabel = dateTimeView;
        
        dateTimeView.textAlignment = NSTextAlignmentCenter;
        dateTimeView.font = [UIFont systemFontOfSize:11.0f];
        
        //头像
        UIImageView *portraitView = [[UIImageView alloc] init];
        [self.contentView addSubview:portraitView];
        self.portraitImageView = portraitView;
        
        //设置圆形
        portraitView.layer.cornerRadius = 25;
        portraitView.layer.masksToBounds = YES;
        
        
        //聊天内容
        VoiceButton *contentView = [[VoiceButton alloc] init];
        [self.contentView addSubview:contentView];
        self.contentButton = contentView;
        //设置字体大小
        contentView.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        //设置字体的颜色
        [contentView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
       
        //设置按钮中内容的边距
        self.contentButton.contentEdgeInsets = UIEdgeInsetsMake(BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_MARGIN);
        
        //设置选中时没有颜色变化
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentButton addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark 设置本人头像
-(void)setSendPortraitImage:(UIImage *)sendPortraitImage
{
    _sendPortraitImage = sendPortraitImage;
    if(self.messageFrame.messageModel.sendType == Send) //发送消息
    {
        self.portraitImageView.image = self.sendPortraitImage;
    }
}

#pragma mark 设置对方头像
-(void)setRecivePortraitImage:(UIImage *)recivePortraitImage
{
    _recivePortraitImage = recivePortraitImage;
    if(self.messageFrame.messageModel.sendType == Receive) //接收消息
    {
        self.portraitImageView.image = self.recivePortraitImage;
    }
}

#pragma mark 重写setMessageFrame
-(void)setMessageFrame:(mMessageFrame *)messageFrame
{
    _messageFrame = messageFrame;
    mMessage *model = messageFrame.messageModel;
    
    if(model.sendType == Send) //发送消息
    {
        self.portraitImageView.image =  self.sendPortraitImage;
        [self.contentButton setBackgroundImage:[UIImage stretchableImage:@"chat_send_press_pic"] forState:UIControlStateNormal];
        [self.contentButton setImage:[UIImage imageNamed:@"chat_send_icon"] forState:UIControlStateNormal];
        //设置字体的颜色
        [self.contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];


        CGFloat maxX = messageFrame.contentFrame.size.width - 30;
        self.contentButton.iconFrame = CGRectMake(maxX, 19, 10, 21);
        self.contentButton.textFrame = CGRectMake(maxX - 30, 19, 50, 21);
        
        
        
    }else //接收消息
    {
        self.portraitImageView.image = self.recivePortraitImage;
        [self.contentButton setBackgroundImage:[UIImage stretchableImage:@"chat_recive_nor"] forState:UIControlStateNormal];
        [self.contentButton setImage:[UIImage imageNamed:@"chat_recive_icon"] forState:UIControlStateNormal];
        [self.contentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.contentButton.iconFrame = CGRectMake(20, 19, 10, 21);
        self.contentButton.textFrame = CGRectMake(40, 19, 50, 21);
    }
    if(model.hiddenDateTime == NO)
    {
        self.dateTimeLabel.text = model.dateTime;
        self.dateTimeLabel.hidden = NO;
    }
    else
    {
        self.dateTimeLabel.hidden = YES;
    }
    
    [self.contentButton setTitle: [NSString stringWithFormat:@"%zd''",model.messageVoice.timeLength] forState:UIControlStateNormal] ;
    
    self.dateTimeLabel.frame =messageFrame.dateTimeFrame;
    self.portraitImageView.frame = messageFrame.portraitFrame;
    self.contentButton.frame = messageFrame.contentFrame;
    
}

#pragma mark 播放声音
- (void)playVoice {
    // 如果有音频数据，直接播放音频
    NSString *path = self.messageFrame.messageModel.messageVoice.voiceUrl;
    if (path != nil) {
        // 播放音频
        [self.contentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        // 如果单例的块代码中包含self，一定使用weakSelf
        __weak VoiceTableViewCell *weakSelf = self;
        GQRecordTools *recordTools = [GQRecordTools sharedRecorder];
        if ([recordTools.player isPlaying]) {
            [recordTools.player stop];
            if (weakSelf.messageFrame.messageModel.sendType == Send) {
                [weakSelf.contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                [weakSelf.contentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        } else {
            [[GQRecordTools sharedRecorder] playPath:path completion:^{
                if (weakSelf.messageFrame.messageModel.sendType == Send) {
                    [weakSelf.contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                } else {
                    [weakSelf.contentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }];
        }
    }

}


@end
