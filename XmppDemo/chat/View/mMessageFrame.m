//
//  mMessageFrame.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "mMessageFrame.h"
#import "mMessage.h"
#import "NSString+Category.h"
#import "mMessageVoice.h"
#import "mMessageImage.h"

//间隙
#define Margin 5

//内容间隙
#define ContentMargin 20

//头像宽度
#define PortraitWidth 45
//头像高度
#define PortraitHeight 45

//设置默认语音最小长度
#define VoiceMin 50
//设置默认语音最大长度
#define VoiceMax 210

@interface mMessageFrame()

@property(nonatomic,assign) CGRect mainScreen;

@end


@implementation mMessageFrame

#pragma mark 重写setMessage

-(void)setMessageModel:(mMessage *)messageModel
{
    _messageModel = messageModel;
    
    //获取主屏幕frame
    self.mainScreen = [UIScreen mainScreen].bounds;
    
    if(!messageModel.hiddenDateTime){
        //设置时间高度
        self.dateTimeFrame = CGRectMake(0, 0, self.mainScreen.size.width, 40);
    }
    
    //计算用户头像frame
    CGFloat portraitX = 0;
    CGFloat portraitY = CGRectGetMaxY(self.dateTimeFrame);
    CGFloat portraitW = PortraitWidth;
    CGFloat portraitH = PortraitHeight;
    
    if(messageModel.sendType == Send) //表示是用户主动发送的消息
    {
         //计算 ： 屏幕宽度 - 右边间隙 - 用户头像宽度
         portraitX = self.mainScreen.size.width - Margin -portraitW;
    }
    else //表示是用户接受消息
    {
         //计算 ： 左边间隙
         portraitX = Margin;
    }
    //计算用户头像frame
    self.portraitFrame =  CGRectMake(portraitX, portraitY, portraitW, portraitH);
    

    
    if(messageModel.messageType == MsgText) //文字消息
    {
        [self countMessage];
    }
     if(messageModel.messageType == MsgImage) //图片消息
    {
        [self countImage];
    }
    else if(messageModel.messageType == MsgVoice) //语音消息
    {
        [self countVoice];
    }
    else //错误消息
    {
    
    }
    
    //计算返回的 cell 高度
    CGFloat portraitMaxY = CGRectGetMaxY(self.portraitFrame);
    CGFloat contentMaxY = CGRectGetMaxY(self.contentFrame);
    self.cellHeight =  MAX(portraitMaxY, contentMaxY) + ContentMargin;
    
}

#pragma mark 计算文字高度
-(void)countMessage
{
    
    //计算文字内容的宽度 和 高度
    CGSize msgSize = [_messageModel.msg sizeWithMaxSize:CGSizeMake(220, MAXFLOAT) fontSize:14.0f];
    
    
    //重新计算内容的宽度 和 高度 ： 内容宽度 ＝ 文字宽度 + 左右两边的间隙
    CGSize contentSize = CGSizeMake(msgSize.width + ContentMargin * 2, msgSize.height + ContentMargin * 2) ;
    
    //计算文字消息frame
    CGFloat msgX = 0;
    CGFloat msgY = self.portraitFrame.origin.y;
    
    if(_messageModel.sendType == Send) //表示是用户主动发送的消息
    {
        //计算 ： 屏幕宽度 - 右边间隙 - 用户头像宽度 - 头像左边间隙 - 内容宽度
        //       mainScreen.size.width - Margin - portraitW - Margin - contentSize.width
        msgX = self.mainScreen.size.width - self.portraitFrame.size.width - 2*Margin - contentSize.width;
    }
    else //表示是用户接受消息
    {
        //计算 ：左边间隙 + 用户左边头像 + 间隙
        msgX =  PortraitWidth + 2* Margin;
        
    }
       //计算文字消息frame
    self.contentFrame =  CGRectMake(msgX, msgY , contentSize.width, contentSize.height);
    
    
   
}
#pragma mark 计算图片高度
-(void)countImage
{

    CGSize imageSize;
    
    //计算图片宽度
    if(_messageModel.messageImage.width > 150)
    {
        CGFloat scale = _messageModel.messageImage.width / 150;
        //设置图片宽度和高度
        imageSize = CGSizeMake(150,_messageModel.messageImage.height/scale);
    }
    else
    {
        //设置图片宽度和高度
        imageSize = CGSizeMake(_messageModel.messageImage.width,_messageModel.messageImage.height);
        
    }
    
    //重新计算图片的宽度 和 高度 ： 内容宽度 ＝ 图片宽度 + 左右两边的间隙
    CGSize contentSize = CGSizeMake(imageSize.width + ContentMargin * 2, imageSize.height + ContentMargin * 2) ;
    
    //计算图片消息frame
    CGFloat imageX = 0;
    CGFloat imageY = self.portraitFrame.origin.y;
    
    if(_messageModel.sendType == Send) //表示是用户主动发送的消息
    {
        //计算 ： 屏幕宽度 - 右边间隙 - 用户头像宽度 - 头像左边间隙 - 图片宽度
        //       mainScreen.size.width - Margin - portraitW - Margin - contentSize.width
        imageX = self.mainScreen.size.width - self.portraitFrame.size.width - 2*Margin - contentSize.width;
    }
    else //表示是用户接受消息
    {
        //计算 ：左边间隙 + 用户左边头像 + 间隙
        imageX =  PortraitWidth + 2* Margin;
        
    }
    //计算图片frame
    self.contentFrame =  CGRectMake(imageX, imageY , contentSize.width, contentSize.height);

}
#pragma mark 计算语音
-(void)countVoice
{
    
    CGSize voiceSize;
    
    //计算语音的长度
    if(_messageModel.messageVoice.timeLength <= 1)
    {
        voiceSize = CGSizeMake(VoiceMin,17.0);
    }
    else
    {
        //大于60秒 都是最大的宽度
        if (_messageModel.messageVoice.timeLength > 60) {
            voiceSize = CGSizeMake(VoiceMax,17.0);
        }
        else
        {
            //根据语音时长设置内容长度
            voiceSize = CGSizeMake(VoiceMin + _messageModel.messageVoice.timeLength * 2.6,17.0);
        }
    }
    
    //重新计算语音内容的宽度 和 高度 ： 内容宽度 ＝ 文字宽度 + 左右两边的间隙
    CGSize contentSize = CGSizeMake(voiceSize.width + ContentMargin * 2, voiceSize.height + ContentMargin * 2) ;
    
    //计算语言消息frame
    CGFloat voiceX = 0;
    CGFloat voiceY = self.portraitFrame.origin.y;
    
    if(_messageModel.sendType == Send) //表示是用户主动发送的消息
    {
        //计算 ： 屏幕宽度 - 右边间隙 - 用户头像宽度 - 头像左边间隙 - 内容宽度
        //       mainScreen.size.width - Margin - portraitW - Margin - contentSize.width
        voiceX = self.mainScreen.size.width - self.portraitFrame.size.width - 2*Margin - contentSize.width;
    }
    else //表示是用户接受消息
    {
        //计算 ：左边间隙 + 用户左边头像 + 间隙
        voiceX =  PortraitWidth + 2* Margin;
        
    }
    //计算语音消息frame
    self.contentFrame =  CGRectMake(voiceX, voiceY , contentSize.width, contentSize.height);

}





@end
