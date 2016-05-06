//
//  ChatTableViewCell.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "TextTableViewCell.h"
#import "mMessageFrame.h"
#import "mMessage.h"
#import "UIImage+Category.h"

@interface TextTableViewCell()

//时间显示
@property (nonatomic, weak) UILabel *dateTimeLabel;
//用户头像
@property (nonatomic, weak) UIImageView *portraitImageView;
//内容
@property (nonatomic, weak) UIButton *contentButton;



@end

@implementation TextTableViewCell


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
        
        //设置圆形头像
        portraitView.layer.cornerRadius = 25;
        portraitView.layer.masksToBounds = YES;
       
        
        //聊天内容
        UIButton *contentView = [[UIButton alloc] init];
        [self.contentView addSubview:contentView];
        self.contentButton = contentView;
        //设置字体大小
        contentView.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        //设置换行
        contentView.titleLabel.numberOfLines = 0;
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
    
    
    if(model.sendType == Send) //主动发送
    {
        self.portraitImageView.image = self.sendPortraitImage;
        [self.contentButton setBackgroundImage:[UIImage stretchableImage:@"chat_send_press_pic"] forState:UIControlStateNormal];
        [self.contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else //被动接收
    {
        self.portraitImageView.image = self.recivePortraitImage;
        [self.contentButton setBackgroundImage:[UIImage stretchableImage:@"chat_recive_nor"] forState:UIControlStateNormal];
        //设置字体的颜色
        [self.contentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
       
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
    
    [self.contentButton setTitle: model.msg forState:UIControlStateNormal] ;
    
    self.dateTimeLabel.frame =messageFrame.dateTimeFrame;
    self.portraitImageView.frame = messageFrame.portraitFrame;
    self.contentButton.frame = messageFrame.contentFrame;

}


@end
