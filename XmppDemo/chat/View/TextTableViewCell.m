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
#import "TTTAttributedLabel.h"
#import "GQStatic.h"


@interface TextTableViewCell() <TTTAttributedLabelDelegate>

//时间显示
@property (nonatomic, weak) UILabel *dateTimeLabel;
//用户头像
@property (nonatomic, weak) UIImageView *portraitImageView;
//内容
@property (nonatomic, weak) UIButton *contentButton;
//文字
@property (nonatomic, weak) TTTAttributedLabel *label;



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
        TTTAttributedLabel *attributedLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectZero];
        attributedLabel.font = [UIFont systemFontOfSize:14.0f];
        //attributedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        attributedLabel.numberOfLines = 0;
        [self.contentView addSubview:attributedLabel];
        self.label = attributedLabel;

        //设置按钮中内容的边距
        self.contentButton.contentEdgeInsets = UIEdgeInsetsMake(BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_MARGIN);
        
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
        //[self.contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.label.textColor = [UIColor whiteColor];
    }else //被动接收
    {
        self.portraitImageView.image = self.recivePortraitImage;
        [self.contentButton setBackgroundImage:[UIImage stretchableImage:@"chat_recive_nor"] forState:UIControlStateNormal];
        //设置字体的颜色
        //[self.contentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.label.textColor = [UIColor blackColor];
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

    //一下均是设置label的位置
    CGSize size = messageFrame.contentFrame.size;
    CGPoint point = messageFrame.contentFrame.origin;
    point.x += BUTTON_MARGIN;
    size.width -= 2*BUTTON_MARGIN;
    CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
    self.label.frame = rect;
    self.label.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    self.label.delegate = self;
    self.label.text = [model.msg copy];
    self.dateTimeLabel.frame =messageFrame.dateTimeFrame;
    self.portraitImageView.frame = messageFrame.portraitFrame;
    self.contentButton.frame = messageFrame.contentFrame;

}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        return;
    }
    
    UIAlertController *view = [UIAlertController
                                 alertControllerWithTitle:@"URL Link"
                                 message:@"Select Your Choice"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *open = [UIAlertAction
                         actionWithTitle:@"Open Link in Safari"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [[UIApplication sharedApplication] openURL:url];
                             //Do some thing here
                             [view dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    [view addAction:open];
    [view addAction:cancel];
    [self.window.rootViewController presentViewController:view animated:YES completion:nil];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:@"Phone Number"
                               message:@"Select Your Choice"
                               preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *open = [UIAlertAction
                           actionWithTitle:@"Call it"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               UIWebView*callWebview =[[UIWebView alloc] init];
                               NSString *telString = [NSString stringWithFormat:@"tel://%@", phoneNumber];
                               NSURL *telURL =[NSURL URLWithString:telString];// 貌似tel:// 或者 tel: 都行
                               [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
                               //记得添加到view上
                               [self.window.rootViewController.view addSubview:callWebview];
                               //Do some thing here
                               [view dismissViewControllerAnimated:YES completion:nil];
                               
                           }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    [view addAction:open];
    [view addAction:cancel];
    [self.window.rootViewController presentViewController:view animated:YES completion:nil];
}
@end
