//
//  GQChatViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQChatViewController.h"
#import "GQAppDelegate.h"
#import "GQStatic.h"
#import "GQStreamManager.h"
#import "GQMessageManager.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "GQRosterManager.h"
#import "GQRecordTools.h"
#import "XMPPMessage+Tools.h"
#import "UIImage+Scale.h"
#import "GQXMPPRecent.h"


#import "UIImage+Category.h"
#import "UIButton+Category.h"
#import "mMessageFrame.h"
#import "mMessage.h"
#import "mMessageVoice.h"
#import "mMessageImage.h"
#import "TextTableViewCell.h"
#import "VoiceTableViewCell.h"
#import "ImageTableViewCell.h"

static NSString* CHATVIEW = @"chatView";

@interface GQChatViewController ()<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) XMPPUserCoreDataStorageObject *friend;
@property (strong, nonatomic) NSFetchedResultsController *history;
@property (strong, nonatomic) NSCache *cache;
@property (strong, nonatomic) GQXMPPRecent *recent;

- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;
- (IBAction)setPhoto:(id)sender;
@end

@implementation GQChatViewController

- (id)initWithUser:(NSString *)userName {
    if (self = [super init]) {
        self.friendName = userName;
    }
    NSLog(@"%@: %@", CHATVIEW, _friendName);
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tView.delegate = self;
    self.tView.dataSource = self;
    self.navigationItem.title = _friendName;
    NSLog(@"%@: %@", CHATVIEW, _friendName);
    UIImageView *tableBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_bg2"]];
    [self.tView setBackgroundView:tableBg];
    /////////////////////////////////////////////////////////////////
    self.messageField.delegate = self;
    self.messageTextView.delegate = self;
    [self scrollToButtomWithAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    GQRecordTools *recordTools = [GQRecordTools sharedRecorder];
    if (recordTools.player.isPlaying) {
        [recordTools.player stop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFriendName:(NSString *)name {
    _friendName = name;
    
    _friend = [[GQRosterManager manager]getUserByName:_friendName];
    
    _history = [[GQMessageManager manager]getHistoryByName:_friendName];
    _history.delegate = self;
    
    _recent = [GQXMPPRecent shareInstance];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - create cache
- (NSCache *)cache {
    if (_cache == nil) {
        _cache = [[NSCache alloc]init];
    }
    return _cache;
}

#pragma mark - 键盘消失
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.messageTextView resignFirstResponder];
}
#pragma mark - record
- (IBAction)startRecord:(id)sender {
    NSLog(@"开始录音");
    [[GQRecordTools sharedRecorder] startRecord];
}

- (IBAction)stopRecord:(id)sender {
    NSLog(@"停止录音");
    [[GQRecordTools sharedRecorder] stopRecordSuccess:^(NSURL *url, NSTimeInterval time) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data.length > MAX_LEN) {
            data = [data subdataWithRange:NSMakeRange(0, MAX_LEN)];
            time = 40;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                                     message:@"Recording time is longer than 40s! Data was cut and sent."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        [self sendMessageWithData:data bodyName:[NSString stringWithFormat:@"%d", (int)time] typeName:VOICE];
        [self.recent insertName:self.friendName message:@"[voice]" time:[NSDate date]];
    } andFailed:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                                  message:@"Recording time is too short!"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

#pragma mark - setPhoto
- (IBAction)setPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ******************** imgPickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGFloat compression = 1.0;
    NSData *data = UIImageJPEGRepresentation(image, 1);
    while (data.length > 1024*1024 && compression >= 0.0) {
        compression -= 0.1;
        data = UIImageJPEGRepresentation(image, compression);
    }
    
    [self sendMessageWithData:data bodyName:@"image" typeName:IMG];
    [self.recent insertName:self.friendName message:@"[image]" time:[NSDate date]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - textFieldView delegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.messageField) {
        NSString *message = self.messageField.text;
        [[GQMessageManager manager]sendMessage:message toUser:self.friendName];
        [self.recent insertName:self.friendName message:message time:[NSDate date]];
        
        self.messageField.text = @"";
        [theTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark - ******************** textView代理方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 判断按下的是不是回车键。
    if ([text isEqualToString:@"\n"]) {
        
        // 自定义的信息发送方法，传入字符串直接发出去。
        [[GQMessageManager manager]sendMessage:self.messageTextView.text toUser:self.friendName];
        [self.recent insertName:self.friendName message:self.messageTextView.text time:[NSDate date]];
        self.messageTextView.text = nil;
        [self.messageTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name typeName:(NSString *)type{
    [[GQMessageManager manager] sendMessageWithData:data bodyName:name typeName:type toUser:self.friendName];
}

#pragma mark -
#pragma mark Table view delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //获得消息实体
    XMPPMessageArchiving_Message_CoreDataObject *messageObj = [_history objectAtIndexPath:indexPath];
    //获得时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:messageObj.timestamp];
    //mMessage
    mMessage *model = nil;
    if (messageObj.isOutgoing) {
        model = [[mMessage alloc]initWithSendType:Send andDateTime:strDate];
    } else {
        model = [[mMessage alloc]initWithSendType:Receive andDateTime:strDate];
    }
    model.messageType = [messageObj.message getMessageType];
    //NSLog(@"indexPath:%@ sendType:%d", indexPath, model.sendType);
    //mMessageFrame
    mMessageFrame *frameModel = [[mMessageFrame alloc]init];
    
    //如果存进去了，就把字符串转化成简洁的节点后保存
    if ([messageObj.message saveAttachmentJID:self.friendName timestamp:messageObj.timestamp]) {
        messageObj.messageStr = [messageObj.message compactXMLString];
        [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext save:NULL];
    }
    
    //判断消息类型（文字，声音，图片）
    if (model.messageType == MsgText) {
        model.msg = [messageObj.body copy];
        static NSString *ID = @"textCell";
        TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[TextTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        // ATTENTION:这里需要注意，frameModel是mMessageFrame类型，mMessageFrame的成员方法setMessageModel（mMessage类型）中需要用到mMessage中的一些属性，如果此时mMessage中没有什么内容的话，那么计算出的frame将是不正确的
        frameModel.messageModel = model;
        cell.messageFrame = frameModel;
        cell.sendPortraitImage = [UIImage imageNamed:DEFAULT_AVARTAR];
        cell.recivePortraitImage = [UIImage imageNamed:DEFAULT_AVARTAR];
        return cell;
    } else if (model.messageType == MsgVoice){
        NSString *timeLenStr = messageObj.message.body;
        NSInteger timeLen = [timeLenStr integerValue];
        NSString *path = [messageObj.message pathForAttachment:self.friendName timestamp:messageObj.timestamp];
        mMessageVoice *voiceMessage = [[mMessageVoice alloc]initWithVoiceUrl:path andTimeLength:timeLen];
        model.messageVoice = voiceMessage;
        static NSString *ID = @"voiceCell";
        VoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if(cell == nil) {
            cell = [[VoiceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        frameModel.messageModel = model;
        cell.messageFrame = frameModel;
        cell.sendPortraitImage = [UIImage imageNamed:DEFAULT_AVARTAR];
        cell.recivePortraitImage = [UIImage imageNamed:DEFAULT_AVARTAR];
        return cell;
    } else {
        NSString *path = [messageObj.message pathForAttachment:self.friendName timestamp:messageObj.timestamp];
        CGSize size = [[UIImage imageWithContentsOfFile:path]imageSize:200];
        mMessageImage *imageMessage = [[mMessageImage alloc]initWithImageUrl:path andSize:size];
        model.messageImage = imageMessage;
        static NSString *ID = @"imageCell";
        ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[ImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        frameModel.messageModel = model;
        cell.messageFrame = frameModel;
        cell.sendPortraitImage = [UIImage imageNamed:DEFAULT_AVARTAR];
        cell.recivePortraitImage = [UIImage imageNamed:DEFAULT_AVARTAR];
        return cell;
    }
    return nil;
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *row = [NSString stringWithFormat:@"%ld", indexPath.row];
    if ([self.cache objectForKey:row] != nil) {
        return [[self.cache objectForKey:row] floatValue];
    }
    XMPPMessageArchiving_Message_CoreDataObject *messageObj = [_history objectAtIndexPath:indexPath];
    mMessageFrame *frameModel = nil;
    MessageType type = [messageObj.message getMessageType];
    if (type == MsgText) {
        TextTableViewCell *cell = (TextTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        frameModel = cell.messageFrame;
    } else if (type == MsgVoice) {
        VoiceTableViewCell *cell = (VoiceTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        frameModel = cell.messageFrame;
    } else if (type == MsgImage) {
        ImageTableViewCell *cell = (ImageTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        frameModel = cell.messageFrame;
    }
    [self.cache setObject:@(frameModel.cellHeight) forKey:row];
    return frameModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"selected: %@", indexPath);
    [self.messageTextView resignFirstResponder];
}


#pragma mark- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_history sections].count;
}

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section {
    //return self.messages.count;
    id<NSFetchedResultsSectionInfo> sectionObj = [[_history sections] objectAtIndex:section];
    return [sectionObj numberOfObjects];
}

#pragma mark -NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [_tView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            break;
        case NSFetchedResultsChangeUpdate:
            [_tView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [_tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [_tView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [_tView endUpdates];
    [self scrollToButtomWithAnimated:YES];
}



- (void)scrollToButtomWithAnimated:(BOOL)animated {
    NSInteger count = self.history.fetchedObjects.count;
    
    // 数组里面没东西还滚，不是找崩么
    if (count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
        
        // 2. 将要滚动到的位置
        [self.tView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
@end
