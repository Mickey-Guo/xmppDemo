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

static NSString* CHATVIEW = @"chatView";

@interface GQChatViewController ()<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) XMPPUserCoreDataStorageObject *friend;
@property (strong, nonatomic) NSFetchedResultsController *history;

- (IBAction)sendMessage:(id)sender;
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

    GQStreamManager *streamManager = [GQStreamManager manager];
    streamManager.messageDelegate = self;
    NSLog(@"%@: %@", CHATVIEW, _friendName);
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

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.messageField.text;
    if (message.length == 0) {
        return ;
    }
    XMPPJID *jid = [XMPPJID jidWithString:self.friendName];
    [[GQMessageManager manager]sendMessage:message forUser:jid];
    self.messageField.text = @"";
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"you" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[GQStatic getCurrentTime] forKey:@"time"];
    
        [self.tView reloadData];
}

#pragma mark -
#pragma mark Table view delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *messageObj = [_history objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    GQMessageCell *cell = (GQMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[GQMessageCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGSize textSize = {rx.size.width-60 ,100000.0};
    NSDictionary *valueLableAttribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]};
    NSString *message = messageObj.body;
    CGSize size = [message boundingRectWithSize:textSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:valueLableAttribute context:nil].size;
    NSLog(@"size.height:%f",size.height);
    
    size.width +=(padding/2);
    UIFont *test_font = [UIFont boldSystemFontOfSize:13];
    size.height +=test_font.lineHeight;
    
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    
    //发送消息
    if (![messageObj isOutgoing]) {
        //背景图
        bgImage = [UIImage imageNamed:@"orange.png"];
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width, size.height)];
        
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    } else {
        
        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(rx.size.width-size.width - padding, padding*2, size.width, size.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }
    
    cell.bgImageView.image = bgImage;
    return cell;
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *messageObj = [_history objectAtIndexPath:indexPath];
    NSString *msg = messageObj.body;
    
    CGRect rx = [UIScreen mainScreen].bounds;
    CGSize textSize = {rx.size.width-60, 10000.0};
    NSDictionary *valueLableAttribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]};
    CGSize size = [msg boundingRectWithSize:textSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:valueLableAttribute context:nil].size;
    
    size.height +=[UIFont systemFontOfSize:13].lineHeight;//修正偏差
    size.height += padding*3;
    
    CGFloat height = size.height < 65 ? 65 : size.height;
    
    return height;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 80;
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

#pragma mark-GQMessageDelegate
- (void)newMessageReceived:(NSDictionary *)messageContent {
    //[self.tView reloadData];
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
//    CGSize contentSize = [_tView contentSize];
//    CGSize screenSize = [[UIScreen mainScreen]bounds].size;
////    CGPoint point = CGPointMake(0, contentSize.height - screenSize.height + 50);
//    CGPoint point = CGPointMake(0, _tView.bounds.size.height);
//    [_tView setContentOffset:point animated:animated];
//    id<NSFetchedResultsSectionInfo> sectionObj = [[_history sections] objectAtIndex:0];
//    [_tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: [sectionObj numberOfObjects]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated: YES];
}
@end
