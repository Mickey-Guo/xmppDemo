//
//  ChatViewController.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "ChatViewController.h"
#import "UIImage+Category.h"
#import "UIButton+Category.h"
#import "mMessageFrame.h"
#import "mMessage.h"
#import "mMessageVoice.h"
#import "mMessageImage.h"
#import "TextTableViewCell.h"
#import "VoiceTableViewCell.h"
#import "ImageTableViewCell.h"

#define marginLeft 10

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate>


@property(nonatomic,strong)  NSMutableArray *array ;

@property(nonatomic,strong) UITableView *tableView;

//本人头像
@property(nonatomic,strong)UIImage *sendPortraitImage;

//对方头像
@property(nonatomic,strong)UIImage *recivePortraitImage;


@end

@implementation ChatViewController


#pragma mark 本人头像
-(UIImage *)sendPortraitImage
{
    if(_sendPortraitImage == nil)
    {
       _sendPortraitImage = [UIImage imageNamed:@"1.jpg"];
    }
    return _sendPortraitImage;
}

#pragma mark 对方头像
-(UIImage *)recivePortraitImage
{
    if(_recivePortraitImage == nil)
    {
        _recivePortraitImage = [UIImage imageNamed:@"2.jpg"];
    }
    return _recivePortraitImage;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createChatView];
    
    [self addKeyboardNotification];
    
    [self createChatContentView];
    
    [self initData];
    
    
}




#pragma mark 创建聊天框
-(void)createChatView
{
    //设置UIView
    UIView *chatView = [[UIView alloc]init];
    chatView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    chatView.backgroundColor = [UIColor redColor];
    [self.view addSubview:chatView];
    
    //设置背景图片
    UIImage *bgImage = [UIImage stretchableImage:@"chat_bottom_bg"];
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:bgImage];
    bgImageView.frame = CGRectMake(0, 0, chatView.bounds.size.width, chatView.bounds.size.height);
    [chatView addSubview:bgImageView];
    
    
    //添加聊天输入框
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(marginLeft, 6, self.view.bounds.size.width - 92, 32)];
    textView.layer.borderColor = [UIColor colorWithRed:0.518f green:0.518f blue:0.518f alpha:1.00f].CGColor;
    textView.layer.borderWidth =1.0f;
    textView.layer.cornerRadius = 6.0f;
    //设置发送按钮
    textView.returnKeyType = UIReturnKeySend;
    [chatView addSubview:textView];
    
    
    //添加表情按钮
    CGFloat browBtnX = CGRectGetMaxX(textView.frame) + 3;
    UIButton *browBtn = [UIButton initWithFrame:CGRectMake(browBtnX, 3, 38, 38) normal:[UIImage imageNamed:@"chat_bottom_smile_nor"] highLighted:[UIImage imageNamed:@"chat_bottom_smile_press"]];
    [chatView addSubview:browBtn];
    
    //添加按钮
    CGFloat addBtnX = CGRectGetMaxX(browBtn.frame) ;
    UIButton *addBtn = [UIButton initWithFrame:CGRectMake(addBtnX, 3, 38, 38) normal:[UIImage imageNamed:@"chat_bottom_up_nor"] highLighted:[UIImage imageNamed:@"chat_bottom_up_press"]];
    [chatView addSubview:addBtn];
    
}

#pragma mark 订阅键盘通知
-(void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardDidChangeFrameNotification object:nil];
}



#pragma mark 监听键盘通知
-(void)keyboardWillAppear:(NSNotification *)notification
{
    
    CGFloat duration = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGRect frame = [notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat offsetY = frame.origin.y- self.view.bounds.size.height;
    [UIView animateWithDuration:duration animations:^{
        self.view.transform=  CGAffineTransformMakeTranslation(0, offsetY);
    }];
}



#pragma mark 隐藏键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark 创建聊天显示内容
-(void)createChatContentView
{
    
    UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    navigationView.backgroundColor = [UIColor colorWithRed:0.216f green:0.573f blue:0.824f alpha:1.00f];
    [self.view addSubview:navigationView];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 44)];
    titleLabel.text = @"与机器人聊天中……";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font =  [UIFont systemFontOfSize:16.0f];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    [navigationView addSubview:titleLabel];
    
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.frame.size.height - 64 - 44) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.allowsSelection = NO;
    tableView.backgroundColor = [UIColor colorWithRed:0.635f green:0.878f blue:0.902f alpha:1.00f];
    tableView.separatorStyle = UITableViewCellAccessoryNone;
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyboard)];
    [self.tableView addGestureRecognizer:tap];
    
    
    
}

#pragma mark 隐藏键盘
-(void)hiddenKeyboard
{
    [self.view endEditing:YES];
}



#pragma mark 总共多少条记录
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

#pragma mark 设置UITableViewCell的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    mMessageFrame *model =self.array[indexPath.row]; //内容
    
    
    if(model.messageModel.messageType == MsgText) //文字消息
    {
    
        static NSString *ID = @"textcelll";
        TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if(cell == nil)
        {
            cell = [[TextTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        cell.messageFrame = model;
        cell.sendPortraitImage = self.sendPortraitImage;
        cell.recivePortraitImage = self.recivePortraitImage;
        return  cell;
    }
    else  if(model.messageModel.messageType == MsgVoice) //语音消息
    {
     
        static NSString *ID = @"voicecelll";
        VoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if(cell == nil)
        {
            cell = [[VoiceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        
        cell.messageFrame = model;
        cell.sendPortraitImage = self.sendPortraitImage;
        cell.recivePortraitImage = self.recivePortraitImage;
        return  cell;
    }
    else  if(model.messageModel.messageType == MsgImage) //图片消息
    {
        static NSString *ID = @"imagecelll";   
        ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if(cell == nil)
        {
            cell = [[ImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        
        cell.messageFrame = model;
        cell.sendPortraitImage = self.sendPortraitImage;
        cell.recivePortraitImage = self.recivePortraitImage;
        return  cell;
    }
    else //发送失败的错误消息
    {
        return nil;
    }
}

#pragma mark 设置Cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    mMessageFrame *model =self.array[indexPath.row]; //内容
    return model.cellHeight;
}


#pragma mark 初始化数据
-(void)initData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"messages" ofType:@"plist"];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    self.array =[NSMutableArray array];
    
    mMessage *tempModel ;
    
    for (int i = 0; i <  array.count; i ++ ) {
        
        mMessage *model = [[mMessage alloc]initDictionary:array[i]];
        
        if([model.dateTime isEqualToString: tempModel.dateTime])
        {
            model.hiddenDateTime = YES;
        }
        
        //添加语音消息
        mMessageVoice *modelVoice = [[mMessageVoice alloc]initDictionary:array[i][@"messageVoice"]];
        model.messageVoice = modelVoice;
        
        //添加图片消息
        mMessageImage *modelImage = [[mMessageImage alloc]initDictionary:array[i][@"messageImage"]];
        model.messageImage = modelImage;
        
        mMessageFrame *frameModel = [[mMessageFrame alloc]init];
        frameModel.messageModel = model;
        
        [self.array addObject:frameModel];
        
        tempModel = model;
    }
    
    [self loadLastMessage];
}

#pragma mark 自动定位到最后信息
-(void)loadLastMessage
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.array.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}








@end
