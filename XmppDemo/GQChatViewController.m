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

static NSString* CHATVIEW = @"chatView";
@interface GQChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *tView;
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
    
    //[self.messageField becomeFirstResponder];
    NSLog(@"%@: %@", CHATVIEW, _chatWithUser);
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
        //[dictionary setObject:[Statics getCurrentTime] forKey:@"time"];
        
        [self.messages addObject:dictionary];
    }
}

#pragma mark -
#pragma mark Table view delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *s = (NSDictionary *) [_messages objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [s objectForKey:@"msg"];
    cell.detailTextLabel.text = [s objectForKey:@"sender"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
@end
