//
//  ImageTableViewCell.m
//  chat
//
//  Created by yinxiufeng on 15/5/25.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "ImageTableViewCell.h"
#import "mMessageFrame.h"
#import "mMessage.h"
#import "mMessageImage.h"
#import "UIImage+Category.h"
#import "ImageButton.h"

@interface ImageTableViewCell()

//时间显示
@property (nonatomic, weak) UILabel *dateTimeLabel;
//用户头像
@property (nonatomic, weak) UIImageView *portraitImageView;
//内容
@property (nonatomic, weak) ImageButton *contentButton;


@end

@implementation ImageTableViewCell


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
        
        
        //聊天图片
        ImageButton *contentView = [[ImageButton alloc] init];
        [self.contentView addSubview:contentView];
        self.contentButton = contentView;
        //设置按钮中内容的边距
        self.contentButton.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        
        //设置选中时没有颜色变化
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


#pragma mark 设置本人头像
-(void)setSendPortraitImage:(UIImage *)sendPortraitImage
{
    _sendPortraitImage = sendPortraitImage;
    if(self.messageFrame.messageModel.sendType == Send) //主动发送
    {
      self.portraitImageView.image = self.sendPortraitImage;
    }
}

#pragma mark 设置对方头像
-(void)setRecivePortraitImage:(UIImage *)recivePortraitImage
{
    _recivePortraitImage = recivePortraitImage;
    if(self.messageFrame.messageModel.sendType == Receive) //主动发送
    {
        self.portraitImageView.image = self.recivePortraitImage;
    }
}

#pragma mark 重写setMessageFrame
-(void)setMessageFrame:(mMessageFrame *)messageFrame
{
    _messageFrame = messageFrame;
    mMessage *model = messageFrame.messageModel;
    
    if(model.sendType == Send) //主动发送
    {
        [self.contentButton setBackgroundImage:[UIImage stretchableImage:@"chat_send_press_pic"] forState:UIControlStateNormal];
    }else //被动接收
    {
        [self.contentButton setBackgroundImage:[UIImage stretchableImage:@"chat_recive_nor"] forState:UIControlStateNormal];
        
        
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
    
    [self.contentButton setImage:[UIImage imageNamed: model.messageImage.imageUrl] forState:UIControlStateNormal] ;
    self.contentButton.imageFrame = CGRectMake(12, 10, messageFrame.contentFrame.size.width - 24,  messageFrame.contentFrame.size.height - 20);
    self.dateTimeLabel.frame =messageFrame.dateTimeFrame;
    self.portraitImageView.frame = messageFrame.portraitFrame;
    self.contentButton.frame = messageFrame.contentFrame;
    
}


@end

