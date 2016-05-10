//
//  GQAddFriendViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/5/2.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQAddFriendViewController.h"
#import "GQStatic.h"
#import "GQStreamManager.h"
#import "GQRosterManager.h"
#import "XMPP.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPRoster.h"

@interface GQAddFriendViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;


- (IBAction)addFriend:(id)sender;

@end

@implementation GQAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"friend_bg2"];
    self.view.layer.contents = (id)image.CGImage;
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
//press return on textField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self addFriendWithName:textField.text];
    }
    return YES;
}

//add friend
- (void)addFriendWithName:(NSString *)name {
    NSRange range = [name rangeOfString:@"@"];
    if (range.location == NSNotFound) {
        name = [name stringByAppendingFormat:@"@%@", [GQStatic xmppStream].myJID.domain];
    }
    
    // if already be friends, no need to add
    XMPPJID *jid = [XMPPJID jidWithString:name];
    
    XMPPRosterCoreDataStorage *storage = [XMPPRosterCoreDataStorage sharedInstance];
    BOOL contains = [storage userExistsWithJID:jid xmppStream:[GQStatic xmppStream]];
    
    if (contains) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Prompt"
                                                                                 message:@"You each other is friend, no need to add."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [[GQStatic appDelegate].roster subscribePresenceToUser:jid];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addFriend:(id)sender {
    if (self.nameField.text.length > 0) {
        [self addFriendWithName:self.nameField.text];
    }
}
@end
