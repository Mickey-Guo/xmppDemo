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

static NSString* CHATVIEW = @"chatView";

@interface GQChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (nonatomic, retain) NSMutableArray *messages;

- (IBAction)sendMessage:(id)sender;
@end

@implementation GQChatViewController

- (id)initWithUser:(NSString *)userName {
    if (self = [super init]) {
        _chatWithUser = userName;
    }
    NSLog(@"%@: %@", CHATVIEW, _chatWithUser);
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tView.delegate = self;
    self.tView.dataSource = self;
    _messages = [[NSMutableArray alloc] init];
    self.navigationItem.title = _chatWithUser;
    
    //GQAppDelegate *del = [GQStatic appDelegate];
    //del.messageDelegate = self;
    GQStreamManager *streamManager = [GQStreamManager manager];
    streamManager.messageDelegate = self;
    //[self.messageField becomeFirstResponder];
    NSLog(@"%@: %@", CHATVIEW, _chatWithUser);
    [self.tView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.messageField.text;
    
    if (message.length > 0) {
        //XMPPFramework通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
        //组合
        [mes addChild:body];
        
        //发送消息
        [[GQStatic xmppStream] sendElement:mes];
        
        self.messageField.text = @"";
        [self.messageField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"you" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[GQStatic getCurrentTime] forKey:@"time"];
        
        [self.messages addObject:dictionary];
        [self.tView reloadData];
        NSLog(@"Sent:%@", mes);
    }
}

#pragma mark -
#pragma mark Table view delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *s = (NSDictionary *) [_messages objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"MessageCellIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
//    
//    cell.textLabel.text = [s objectForKey:@"msg"];
//    cell.detailTextLabel.text = [s objectForKey:@"sender"];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.userInteractionEnabled = NO;
    GQMessageCell *cell = (GQMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[GQMessageCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    
    NSMutableDictionary *dict = [self.messages objectAtIndex:indexPath.row];
    
    //发送者
    NSString *sender = [dict objectForKey:@"sender"];
    //消息
    NSString *message = [dict objectForKey:@"msg"];
    //时间
    NSString *time = [dict objectForKey:@"time"];
    NSLog(@"ChatView time: %@", time);
    
    CGSize textSize = {260.0 ,100000.0};
    NSDictionary *valueLableAttribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]};
    CGSize size = [message boundingRectWithSize:textSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:valueLableAttribute context:nil].size;
    NSLog(@"size.height:%f",size.height);
    
    size.width +=(padding/2);
    UIFont *test_font = [UIFont boldSystemFontOfSize:13];
    // NSLog(@"[UIFont boldSystemFontOfSize:13].lineHeight:%f",[UIFont boldSystemFontOfSize:13].lineHeight);//15.509000
    size.height +=test_font.lineHeight;//修正偏差//textView需要留边吗？上下天地留白。。//label不用吧，不知道用不用修正一个lineHeight
    
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    
    //发送消息
    if (![sender isEqualToString:@"you"]) {
        //背景图
        bgImage = [UIImage imageNamed:@"orange.png"];
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width, size.height)];
        
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    } else {
        
        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(320-size.width - padding, padding*2, size.width, size.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }
    
    cell.bgImageView.image = bgImage;
    //    cell.bgImageView.backgroundColor = [UIColor purpleColor];
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
    return cell;
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *dict  = [self.messages objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:@"msg"];
    
    CGSize textSize = {260.0 ,10000.0};
    NSDictionary *valueLableAttribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]};
    CGSize size = [msg boundingRectWithSize:textSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:valueLableAttribute context:nil].size;
    
    size.height +=[UIFont systemFontOfSize:13].lineHeight;//修正偏差
        //size.height += padding*2;
    size.height += padding*3;
    
    CGFloat height = size.height < 65 ? 65 : size.height;
    
//    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
    
}

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark-GQMessageDelegate
- (void)newMessageReceived:(NSDictionary *)messageContent {
    [self.messages addObject:messageContent];
    [self.tView reloadData];
}
@end
