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
#import "GQMessageCell.h"
#import "GQStreamManager.h"
#import "GQMessageManager.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "GQRosterManager.h"
#import "GQRecordTools.h"
#import "XMPPMessage+Tools.h"


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

@interface GQChatViewController ()<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) XMPPUserCoreDataStorageObject *friend;
@property (strong, nonatomic) NSFetchedResultsController *history;

- (IBAction)sendMessage:(id)sender;
- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;
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
    UIImageView *tableBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg"]];
    [self.tView setBackgroundView:tableBg];
    [self scrollToButtomWithAnimated:YES];
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startRecord:(id)sender {
    NSLog(@"开始录音");
    [[GQRecordTools sharedRecorder] startRecord];
}

- (IBAction)stopRecord:(id)sender {
    NSLog(@"停止录音");
    [[GQRecordTools sharedRecorder] stopRecordSuccess:^(NSURL *url, NSTimeInterval time) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self sendMessageWithData:data bodyName:[NSString stringWithFormat:@"%d", (int)time] typeName:VOICE];
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

#pragma mark - send messages

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.messageField.text;
    if (message.length == 0) {
        return ;
    }
    [[GQMessageManager manager]sendMessage:message toUser:self.friendName];
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
    //mMessageFrame
    mMessageFrame *frameModel = [[mMessageFrame alloc]init];
    
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
        cell.sendPortraitImage = [UIImage imageNamed:@"1.jpg"];
        cell.recivePortraitImage = [UIImage imageNamed:@"2.jpg"];
        return cell;
    } else {
        NSString *timeLenStr = messageObj.message.body;
        NSInteger timeLen = [timeLenStr integerValue];
        NSString *path = [messageObj.message pathForAttachment:self.friendName timestamp:messageObj.timestamp];
        mMessageVoice *voice = [[mMessageVoice alloc]initWithVoiceUrl:path andTimeLength:timeLen];
        model.messageVoice = voice;
        static NSString *ID = @"voiceCell";
        VoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if(cell == nil) {
            cell = [[VoiceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        frameModel.messageModel = model;
        cell.messageFrame = frameModel;
        cell.sendPortraitImage = [UIImage imageNamed:@"1.jpg"];
        cell.recivePortraitImage = [UIImage imageNamed:@"2.jpg"];
        if ([messageObj.message saveAttachmentJID:self.friendName timestamp:messageObj.timestamp]) {
            messageObj.messageStr = [messageObj.message compactXMLString];
            [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext save:NULL];
        }
        return cell;
    }
    return nil;
    
//    static NSString *CellIdentifier = @"MessageCellIdentifier";
//    GQMessageCell *cell = (GQMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[GQMessageCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//    }
//    cell.userInteractionEnabled = YES;
//
//    
//    CGRect rx = [ UIScreen mainScreen ].bounds;
//    CGSize textSize = {rx.size.width-60 ,100000.0};
//    NSDictionary *valueLableAttribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]};
//    NSString *message = messageObj.body;
//    CGSize size = [message boundingRectWithSize:textSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:valueLableAttribute context:nil].size;
//    NSLog(@"size.height:%f",size.height);
//    
//    size.width +=(padding/2);
//    UIFont *test_font = [UIFont boldSystemFontOfSize:13];
//    size.height +=test_font.lineHeight;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *strDate = [dateFormatter stringFromDate:messageObj.timestamp];
//    cell.messageContentView.text = message;
//    cell.senderAndTimeLabel.text = strDate;
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.userInteractionEnabled = NO;
//    
//    UIImage *bgImage = nil;
//    
//    //发送消息
//    if (![messageObj isOutgoing]) {
//        //背景图
//        bgImage = [UIImage imageNamed:@"orange.png"];
//        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width, size.height)];
//        
//        
//        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
//    } else {
//        
//        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
//        
//        [cell.messageContentView setFrame:CGRectMake(rx.size.width-size.width - padding, padding*2, size.width, size.height)];
//        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
//    }
//    
//    cell.bgImageView.image = bgImage;
//
//    if ([messageObj.message saveAttachmentJID:self.friendName timestamp:messageObj.timestamp]) {
//        messageObj.messageStr = [messageObj.message compactXMLString];
//        [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext save:NULL];
//    }
//    
//    cell.audioPath  = nil;
//    NSString *path = [messageObj.message pathForAttachment:self.friendName timestamp:messageObj.timestamp];
//    if ([messageObj.message getMessageType] == MsgVoice) {
//        cell.audioPath = path;
//    }
//    return cell;
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *messageObj = [_history objectAtIndexPath:indexPath];
    mMessageFrame *frameModel = nil;
    MessageType type = [messageObj.message getMessageType];
    if (type == MsgText) {
        TextTableViewCell *cell = (TextTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        frameModel = cell.messageFrame;
    } else if (type == MsgVoice) {
        VoiceTableViewCell *cell = (VoiceTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        frameModel = cell.messageFrame;
    }
    return frameModel.cellHeight;
    
//    XMPPMessageArchiving_Message_CoreDataObject *messageObj = [_history objectAtIndexPath:indexPath];
//    NSString *msg = messageObj.body;
//    
//    CGRect rx = [UIScreen mainScreen].bounds;
//    CGSize textSize = {rx.size.width-60, 10000.0};
//    NSDictionary *valueLableAttribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]};
//    CGSize size = [msg boundingRectWithSize:textSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:valueLableAttribute context:nil].size;
//    
//    size.height +=[UIFont systemFontOfSize:13].lineHeight;//修正偏差
//    size.height += padding*3;
//    
//    CGFloat height = size.height < 65 ? 65 : size.height;
//    
//    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"selected: %@", indexPath);
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
    CGSize contentSize = [self.tView contentSize];
    CGSize screenSize = [[UIScreen mainScreen]bounds].size;
    CGPoint point = CGPointMake(0, contentSize.height - screenSize.height+200);
    [self.tView setContentOffset:point animated:animated];
}
@end
